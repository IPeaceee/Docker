# PostgreSQL Docker Compose Setup

Production-ready PostgreSQL deployment với Docker Compose, hỗ trợ cả môi trường development và production.

## 📋 Mục lục

- [Tính năng](#-tính-năng)
- [Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Thiết lập nhanh](#-thiết-lập-nhanh)
- [Quản trị thường ngày](#-quản-trị-thường-ngày)
- [Backup & Restore](#-backup--restore)
- [Nâng cấp PostgreSQL](#-nâng-cấp-postgresql)
- [Bảo mật & Best Practices](#-bảo-mật--best-practices)
- [Khắc phục sự cố](#-khắc-phục-sự-cố)
- [Phụ lục](#-phụ-lục)

## ✨ Tính năng

- ✅ PostgreSQL 16 với healthcheck tự động
- ✅ Profiles riêng cho Dev và Production
- ✅ PgAdmin 4 cho môi trường development
- ✅ Tự động backup theo lịch với retention policy
- ✅ Scripts tiện ích: backup, restore, psql
- ✅ Persistent volumes cho dữ liệu và backup
- ✅ Network isolation
- ✅ Logging với rotation
- ✅ Docker secrets support
- ✅ Healthcheck và auto-restart

## 📦 Yêu cầu hệ thống

- **Docker**: Version 20.10+ 
- **Docker Compose**: Version 2.0+
- **Dung lượng đĩa**: Tối thiểu 10GB (khuyến nghị 50GB+ cho production)
- **RAM**: Tối thiểu 2GB (khuyến nghị 4GB+ cho production)

### Lưu ý quan trọng

**Linux với SELinux**: Cần cấu hình SELinux context cho volumes
```bash
sudo chcon -Rt svirt_sandbox_file_t ./backups
sudo chcon -Rt svirt_sandbox_file_t ./initdb
```

**Permissions**: Đảm bảo user hiện tại có quyền với Docker
```bash
sudo usermod -aG docker $USER
newgrp docker
```

## 📁 Cấu trúc thư mục

```
postgres/
├── docker-compose.yml           # Main compose configuration
├── docker-compose.override.yml  # Local overrides (optional)
├── .env.example                 # Environment template
├── .env                         # Your environment (create from .env.example)
├── backups/                     # Backup files directory
│   └── .gitkeep
├── initdb/                      # Init scripts (executed on first run)
│   └── 01_create_extensions.sql (optional)
├── migrations/                  # SQL migration scripts
│   └── 001_init.sql (optional)
└── scripts/                     # Utility scripts
    ├── backup.sh                # Manual backup trigger
    ├── restore.sh               # Restore from backup
    └── psql.sh                  # PostgreSQL client wrapper
```

## 🚀 Thiết lập nhanh

### 1. Chuẩn bị cấu hình

```bash
# Copy environment template
cp .env.example .env

# Chỉnh sửa .env với editor yêu thích
nano .env  # hoặc vim, code, etc.
```

**Các biến quan trọng cần cập nhật**:
- `POSTGRES_PASSWORD`: Mật khẩu mạnh cho database
- `PGADMIN_DEFAULT_PASSWORD`: Mật khẩu cho PgAdmin (dev only)
- `TZ`: Timezone (ví dụ: `Asia/Ho_Chi_Minh`)

### 2. Tạo thư mục cần thiết

```bash
mkdir -p backups initdb migrations
chmod +x scripts/*.sh
```

### 3. Khởi động - Development

```bash
# Start với profile dev (có PgAdmin)
docker compose --profile dev up -d

# Kiểm tra trạng thái
docker compose ps

# Xem logs
docker compose logs -f postgres
```

**Truy cập**:
- PostgreSQL: `localhost:5432`
- PgAdmin: `http://localhost:5050`

**Kết nối từ ứng dụng (Dev)**:
```bash
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/myapp_db
```

### 4. Khởi động - Production

```bash
# Start với profile prod (không có PgAdmin, không expose port)
docker compose --profile prod up -d

# Kiểm tra
docker compose ps
docker compose logs -f postgres-prod
```

**Kết nối từ ứng dụng (Prod)** - chỉ từ containers trong cùng network:
```bash
DATABASE_URL=postgresql://postgres:your_password@postgres-prod:5432/myapp_db
```

**Hoặc qua SSH tunnel**:
```bash
ssh -L 5432:localhost:5432 user@production-server
# Sau đó kết nối qua localhost:5432
```

## 🔧 Quản trị thường ngày

### Xem logs

```bash
# Tất cả services
docker compose logs -f

# Chỉ PostgreSQL
docker compose logs -f postgres

# Backup service
docker compose logs -f backup

# Số dòng giới hạn
docker compose logs --tail=100 postgres
```

### Kiểm tra health

```bash
# Trạng thái containers
docker compose ps

# Kiểm tra healthcheck
docker inspect postgres-db --format='{{.State.Health.Status}}'

# Test kết nối
docker compose exec postgres pg_isready -U postgres
```

### Kết nối PostgreSQL CLI

```bash
# Cách 1: Exec vào container
docker compose exec postgres psql -U postgres -d myapp_db

# Cách 2: Dùng psql-runner
docker compose run --rm psql-runner

# Cách 3: Chạy query trực tiếp
docker compose run --rm psql-runner -c "SELECT version();"

# Cách 4: Chạy migration file
docker compose run --rm psql-runner -f /migrations/001_init.sql
```

### Đổi mật khẩu

```bash
# Kết nối vào database
docker compose exec postgres psql -U postgres

# Trong psql prompt
ALTER USER postgres WITH PASSWORD 'new_secure_password';

# Cập nhật .env file
nano .env  # Update POSTGRES_PASSWORD

# Restart services
docker compose down
docker compose --profile dev up -d  # hoặc --profile prod
```

### Stop/Start/Restart

```bash
# Stop
docker compose down

# Stop và xóa volumes (⚠️ XÓA DỮ LIỆU)
docker compose down -v

# Start
docker compose --profile dev up -d

# Restart
docker compose restart postgres

# Restart tất cả
docker compose restart
```

## 💾 Backup & Restore

### Backup tự động

Backup tự động chạy theo lịch được cấu hình trong `.env`:

```bash
SCHEDULE=0 2 * * *  # Hàng ngày lúc 2 giờ sáng
BACKUP_KEEP_DAYS=7
BACKUP_KEEP_WEEKS=4
BACKUP_KEEP_MONTHS=6
```

**Cú pháp SCHEDULE** (cron format):
```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
│ │ │ │ │
* * * * *
```

**Ví dụ**:
- `0 2 * * *` - Hàng ngày lúc 2:00 AM
- `0 */6 * * *` - Mỗi 6 giờ
- `0 0 * * 0` - Chủ nhật hàng tuần lúc midnight
- `@daily` - Hàng ngày lúc midnight

Files backup được lưu tại `./backups/` với định dạng:
```
myapp_db-2025-01-15_02-00.sql.gz
```

### Backup thủ công

```bash
# Trigger backup ngay lập tức
./scripts/backup.sh

# Xem files backup
ls -lh ./backups/

# Xem 5 backup mới nhất
ls -lt ./backups/ | head -6
```

### Restore database

**⚠️ CẢNH BÁO**: Restore sẽ ghi đè dữ liệu hiện tại!

```bash
# Restore vào database hiện tại (ghi đè)
./scripts/restore.sh ./backups/myapp_db-2025-01-15_02-00.sql.gz

# Restore vào database mới
./scripts/restore.sh ./backups/myapp_db-2025-01-15_02-00.sql.gz restored_db

# Xem danh sách databases
docker compose exec postgres psql -U postgres -l
```

**Restore từ production sang development**:

```bash
# 1. Copy backup từ production server
scp user@prod-server:/path/to/backups/prod_backup.sql.gz ./backups/

# 2. Stop dev database
docker compose --profile dev down

# 3. Xóa volume cũ (nếu cần)
docker volume rm postgres_pg_data

# 4. Start lại
docker compose --profile dev up -d

# 5. Restore
./scripts/restore.sh ./backups/prod_backup.sql.gz
```

### Backup thủ công với pg_dump

```bash
# Dump toàn bộ database
docker compose exec postgres pg_dump -U postgres -d myapp_db > manual_backup.sql

# Dump với compression
docker compose exec postgres pg_dump -U postgres -d myapp_db | gzip > manual_backup.sql.gz

# Dump custom format (cho pg_restore)
docker compose exec postgres pg_dump -U postgres -Fc -d myapp_db -f backup.tar

# Dump chỉ schema (không có data)
docker compose exec postgres pg_dump -U postgres --schema-only -d myapp_db > schema.sql

# Dump chỉ data
docker compose exec postgres pg_dump -U postgres --data-only -d myapp_db > data.sql
```

## ⬆️ Nâng cấp PostgreSQL

### Minor version upgrade (16.0 → 16.1)

Minor upgrades thường an toàn và không cần migration dữ liệu:

```bash
# 1. Backup trước khi upgrade
./scripts/backup.sh

# 2. Update image tag trong docker-compose.yml
# Đổi: image: postgres:16
# Thành: image: postgres:16.1

# 3. Pull image mới
docker compose pull postgres

# 4. Rolling restart
docker compose up -d postgres

# 5. Verify
docker compose exec postgres psql -U postgres -c "SELECT version();"
```

### Major version upgrade (16 → 17)

Major upgrades CẦN dump/restore vì có thể không tương thích:

```bash
# 1. BACKUP ĐẦY ĐỦ
./scripts/backup.sh

# Verify backup
ls -lh ./backups/

# 2. Dump toàn bộ dữ liệu
docker compose exec postgres pg_dumpall -U postgres > full_backup_before_upgrade.sql
gzip full_backup_before_upgrade.sql

# 3. Stop containers
docker compose down

# 4. Backup volume
docker run --rm -v postgres_pg_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/pg_data_backup.tar.gz /data

# 5. Xóa volume cũ
docker volume rm postgres_pg_data

# 6. Update docker-compose.yml
# Đổi: image: postgres:16
# Thành: image: postgres:17

# 7. Start với image mới
docker compose --profile dev up -d

# 8. Restore dữ liệu
gunzip -c full_backup_before_upgrade.sql.gz | \
  docker compose exec -T postgres psql -U postgres

# 9. Verify
docker compose exec postgres psql -U postgres -c "SELECT version();"
docker compose exec postgres psql -U postgres -l
```

**Checklist an toàn cho major upgrade**:

- [ ] Đọc PostgreSQL release notes
- [ ] Test upgrade trên môi trường staging
- [ ] Full backup database và volumes
- [ ] Verify backup có thể restore
- [ ] Lập kế hoạch maintenance window
- [ ] Thông báo downtime cho users
- [ ] Có rollback plan
- [ ] Test ứng dụng sau upgrade

## 🔒 Bảo mật & Best Practices

### Production Security Checklist

- [ ] **Không expose port 5432** ra ngoài trong production
  - Profile `prod` đã cấu hình không có `ports` mapping
  - Chỉ internal network access

- [ ] **Sử dụng mật khẩu mạnh**
  ```bash
  # Generate strong password
  openssl rand -base64 32
  ```

- [ ] **Docker secrets thay vì environment variables**
  
  Tạo secret file:
  ```bash
  echo "your_super_secure_password" > postgres_password.txt
  chmod 600 postgres_password.txt
  ```
  
  Update docker-compose.yml:
  ```yaml
  services:
    postgres:
      secrets:
        - postgres_password
      environment:
        POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
  
  secrets:
    postgres_password:
      file: ./postgres_password.txt
  ```

- [ ] **Phân quyền folders**
  ```bash
  # Backup folder
  chmod 700 backups/
  
  # Scripts
  chmod 700 scripts/
  chmod +x scripts/*.sh
  
  # .env file
  chmod 600 .env
  ```

- [ ] **Internal network**
  
  Set `internal: true` trong networks (docker-compose.yml):
  ```yaml
  networks:
    db_net:
      driver: bridge
      internal: true  # Không cho external access
  ```

- [ ] **Regular security updates**
  ```bash
  # Pull latest security patches
  docker compose pull
  docker compose up -d
  ```

- [ ] **Firewall rules**
  ```bash
  # Chỉ cho phép kết nối từ app servers
  sudo ufw allow from 10.0.0.0/24 to any port 5432
  ```

- [ ] **SSL/TLS connections**
  
  Thêm SSL certificates và config:
  ```yaml
  volumes:
    - ./ssl:/var/lib/postgresql/ssl:ro
  command:
    - -c
    - ssl=on
    - -c
    - ssl_cert_file=/var/lib/postgresql/ssl/server.crt
    - -c
    - ssl_key_file=/var/lib/postgresql/ssl/server.key
  ```

- [ ] **Audit logging**
  
  Enable PostgreSQL logging:
  ```yaml
  command:
    - -c
    - log_statement=all
    - -c
    - log_connections=on
    - -c
    - log_disconnections=on
  ```

- [ ] **Backup encryption**
  ```bash
  # Encrypt backups
  gpg --symmetric --cipher-algo AES256 backup.sql.gz
  ```

### Least Privilege

Tạo user với quyền hạn chế cho ứng dụng:

```sql
-- Kết nối vào postgres
docker compose exec postgres psql -U postgres

-- Tạo user cho application
CREATE USER app_user WITH PASSWORD 'app_password';

-- Tạo database
CREATE DATABASE app_db OWNER app_user;

-- Grant quyền hạn chế
GRANT CONNECT ON DATABASE app_db TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Set default privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
```

Sử dụng trong ứng dụng:
```bash
DATABASE_URL=postgresql://app_user:app_password@postgres:5432/app_db
```

## 🔧 Khắc phục sự cố

### Permission denied trên volume

**Triệu chứng**: Container không start, log hiện "Permission denied"

**Nguyên nhân**: UID/GID mismatch hoặc SELinux

**Giải pháp**:

```bash
# 1. Kiểm tra ownership
ls -la | grep pg_data

# 2. Fix ownership (Linux)
sudo chown -R 999:999 ./backups

# 3. Fix SELinux context
sudo chcon -Rt svirt_sandbox_file_t ./backups

# 4. Hoặc disable SELinux cho testing (không khuyến nghị prod)
sudo setenforce 0
```

### Healthcheck fail

**Triệu chứng**: Container restart liên tục, status `unhealthy`

**Debug**:

```bash
# 1. Xem logs chi tiết
docker compose logs postgres

# 2. Check environment variables
docker compose exec postgres env | grep POSTGRES

# 3. Test healthcheck manually
docker compose exec postgres pg_isready -U postgres -d myapp_db

# 4. Check process
docker compose exec postgres ps aux

# 5. Kiểm tra PostgreSQL log
docker compose exec postgres cat /var/lib/postgresql/data/pgdata/log/postgresql-*.log
```

**Giải pháp thường gặp**:

- Sai `POSTGRES_USER` hoặc `POSTGRES_DB` trong healthcheck
- Database chưa khởi tạo xong (tăng `start_period`)
- Không đủ RAM (tăng `shm_size` hoặc RAM)

### Restore lỗi encoding/extension

**Triệu chứng**: Restore fail với lỗi encoding hoặc extension missing

**Giải pháp**:

```bash
# 1. Tạo database với encoding đúng
docker compose exec postgres psql -U postgres -c \
  "CREATE DATABASE restored_db WITH ENCODING='UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';"

# 2. Cài extensions trước (nếu cần)
docker compose exec postgres psql -U postgres -d restored_db -c \
  "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

# 3. Restore lại
./scripts/restore.sh ./backups/backup.sql.gz restored_db
```

Tạo init script cho extensions (./initdb/01_extensions.sql):
```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE EXTENSION IF NOT EXISTS uuid-ossp;
```

### Container không start - port already in use

**Triệu chứng**: Error "port is already allocated"

**Giải pháp**:

```bash
# 1. Tìm process đang dùng port
sudo lsof -i :5432
# hoặc
sudo netstat -tulpn | grep 5432

# 2. Kill process
sudo kill -9 <PID>

# 3. Hoặc đổi port trong .env (dev only)
# Tạo docker-compose.override.yml:
cat > docker-compose.override.yml <<EOF
services:
  postgres:
    ports:
      - "5433:5432"
EOF

# 4. Start lại
docker compose --profile dev up -d
```

### Out of disk space

**Triệu chứng**: Lỗi "No space left on device"

**Giải pháp**:

```bash
# 1. Kiểm tra dung lượng
df -h

# 2. Xóa old backups
find ./backups -name "*.sql.gz" -mtime +30 -delete

# 3. Clean Docker
docker system prune -a --volumes
# ⚠️ CẢNH BÁO: Xóa tất cả unused data

# 4. Xem dung lượng volumes
docker system df -v

# 5. Tăng BACKUP_KEEP_DAYS trong .env để giảm backup retention
```

### Connection refused

**Triệu chứng**: Application không kết nối được database

**Debug**:

```bash
# 1. Kiểm tra container running
docker compose ps

# 2. Kiểm tra network
docker network inspect postgres_db_net

# 3. Test connection từ host (dev only)
psql -h localhost -U postgres -d myapp_db

# 4. Test từ container khác
docker run --rm --network postgres_db_net postgres:16 \
  psql -h postgres -U postgres -d myapp_db

# 5. Check firewall
sudo ufw status
```

## 📚 Phụ lục

### Lệnh thường dùng (Cheat Sheet)

```bash
# === Start/Stop ===
docker compose --profile dev up -d
docker compose --profile prod up -d
docker compose down
docker compose restart

# === Logs ===
docker compose logs -f postgres
docker compose logs --tail=100 postgres

# === Health ===
docker compose ps
docker compose exec postgres pg_isready

# === Database CLI ===
docker compose exec postgres psql -U postgres
docker compose run --rm psql-runner
docker compose exec postgres psql -U postgres -l  # List databases

# === Backup/Restore ===
./scripts/backup.sh
./scripts/restore.sh ./backups/file.sql.gz
ls -lh ./backups/

# === User Management ===
docker compose exec postgres psql -U postgres -c "CREATE USER myuser WITH PASSWORD 'mypass';"
docker compose exec postgres psql -U postgres -c "\du"  # List users

# === Database Operations ===
docker compose exec postgres psql -U postgres -c "CREATE DATABASE mydb;"
docker compose exec postgres psql -U postgres -c "DROP DATABASE mydb;"
docker compose exec postgres psql -U postgres -d mydb -c "\dt"  # List tables

# === Monitoring ===
docker compose exec postgres psql -U postgres -c "SELECT * FROM pg_stat_activity;"
docker compose exec postgres psql -U postgres -c "SELECT pg_size_pretty(pg_database_size('myapp_db'));"

# === Vacuum ===
docker compose exec postgres psql -U postgres -d myapp_db -c "VACUUM ANALYZE;"

# === Performance ===
docker stats postgres-db
docker compose exec postgres psql -U postgres -c "SHOW max_connections;"
```

### Migration workflow example

```bash
# 1. Tạo migration file
cat > migrations/001_create_users.sql <<EOF
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
EOF

# 2. Apply migration
docker compose run --rm psql-runner -f /migrations/001_create_users.sql

# 3. Verify
docker compose exec postgres psql -U postgres -d myapp_db -c "\dt"
docker compose exec postgres psql -U postgres -d myapp_db -c "\d users"
```

### Migrate dữ liệu giữa servers

**Phương pháp 1: Dump/Restore qua network**

```bash
# Từ server cũ
docker compose exec postgres pg_dump -U postgres -Fc myapp_db > dump.tar

# Copy sang server mới
scp dump.tar user@new-server:/tmp/

# Trên server mới
cat /tmp/dump.tar | docker compose exec -T postgres pg_restore -U postgres -d myapp_db
```

**Phương pháp 2: Rsync backups folder**

```bash
# Sync backups từ server cũ
rsync -avz --progress user@old-server:/path/to/backups/ ./backups/

# Restore trên server mới
./scripts/restore.sh ./backups/latest-backup.sql.gz
```

**Phương pháp 3: Direct pipe (nhanh nhất)**

```bash
# Dump từ server cũ, pipe trực tiếp vào server mới
ssh user@old-server "docker compose exec -T postgres pg_dump -U postgres myapp_db" | \
  docker compose exec -T postgres psql -U postgres -d myapp_db
```

### Kết nối từ ứng dụng

**Python (psycopg2)**:
```python
import psycopg2

conn = psycopg2.connect(
    host="postgres",  # hoặc "localhost" nếu dev
    port=5432,
    database="myapp_db",
    user="postgres",
    password="your_password"
)
```

**Node.js (pg)**:
```javascript
const { Pool } = require('pg');

const pool = new Pool({
  host: 'postgres',
  port: 5432,
  database: 'myapp_db',
  user: 'postgres',
  password: 'your_password',
});
```

**Django (settings.py)**:
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'myapp_db',
        'USER': 'postgres',
        'PASSWORD': 'your_password',
        'HOST': 'postgres',
        'PORT': '5432',
    }
}
```

**Docker Compose app service**:
```yaml
services:
  app:
    image: myapp:latest
    environment:
      DATABASE_URL: postgresql://postgres:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
    networks:
      - db_net
    depends_on:
      postgres:
        condition: service_healthy
```

### Performance Tuning

Tạo `docker-compose.override.yml` với tuning parameters:

```yaml
services:
  postgres:
    command:
      - "postgres"
      - "-c"
      - "max_connections=200"
      - "-c"
      - "shared_buffers=256MB"
      - "-c"
      - "effective_cache_size=1GB"
      - "-c"
      - "maintenance_work_mem=64MB"
      - "-c"
      - "checkpoint_completion_target=0.9"
      - "-c"
      - "wal_buffers=16MB"
      - "-c"
      - "default_statistics_target=100"
      - "-c"
      - "random_page_cost=1.1"
      - "-c"
      - "effective_io_concurrency=200"
      - "-c"
      - "work_mem=2MB"
      - "-c"
      - "min_wal_size=1GB"
      - "-c"
      - "max_wal_size=4GB"
```

Hoặc tạo custom postgresql.conf:

```bash
# Tạo custom config
cat > postgresql.conf <<EOF
max_connections = 200
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 2MB
min_wal_size = 1GB
max_wal_size = 4GB
EOF

# Mount trong docker-compose.override.yml
volumes:
  - ./postgresql.conf:/etc/postgresql/postgresql.conf:ro
command: postgres -c config_file=/etc/postgresql/postgresql.conf
```

### Monitoring với pg_stat_statements

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Top 10 slowest queries
SELECT 
    calls,
    mean_exec_time,
    max_exec_time,
    query
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Reset statistics
SELECT pg_stat_statements_reset();
```

---

## 📞 Support

Nếu gặp vấn đề không có trong tài liệu này:

1. Check PostgreSQL logs: `docker compose logs postgres`
2. Check GitHub Issues của postgres-backup-local
3. Tham khảo [PostgreSQL Documentation](https://www.postgresql.org/docs/16/)
4. Stack Overflow tag: `postgresql` + `docker-compose`

---

**Developed with ❤️ for DevOps/DBA**

*Last updated: 2025-01-15*
