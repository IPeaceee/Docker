# Quick Start Guide

## 🚀 5 phút để chạy PostgreSQL

### 1. Chuẩn bị
```bash
# Copy environment file
cp .env.example .env

# Chỉnh sửa mật khẩu (bắt buộc!)
# Mở .env và thay đổi:
# - POSTGRES_PASSWORD
# - PGADMIN_DEFAULT_PASSWORD (nếu dùng dev)
```

### 2. Khởi động Development
```bash
# Cách 1: Dùng Docker Compose
docker compose --profile dev up -d

# Cách 2: Dùng Makefile (khuyến nghị)
make dev
```

### 3. Kiểm tra
```bash
# Xem trạng thái
docker compose ps

# Xem logs
docker compose logs -f postgres

# Test kết nối
docker compose exec postgres pg_isready
```

### 4. Truy cập

**PostgreSQL:**
- Host: `localhost`
- Port: `5432`
- User: `postgres`
- Password: (từ file .env)
- Database: `myapp_db`

**PgAdmin (GUI):**
- URL: http://localhost:5050
- Email: (từ file .env - PGADMIN_DEFAULT_EMAIL)
- Password: (từ file .env - PGADMIN_DEFAULT_PASSWORD)

### 5. Kết nối từ ứng dụng

```bash
# Connection string
postgresql://postgres:your_password@localhost:5432/myapp_db
```

Python:
```python
import psycopg2
conn = psycopg2.connect(
    "postgresql://postgres:your_password@localhost:5432/myapp_db"
)
```

Node.js:
```javascript
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: 'postgresql://postgres:your_password@localhost:5432/myapp_db'
});
```

## 📋 Lệnh thường dùng

```bash
# Start
make dev              # Development với PgAdmin
make prod             # Production (không có PgAdmin)

# Stop
make stop

# Logs
make logs             # Tất cả logs
make logs SVC=postgres  # Chỉ PostgreSQL

# Database CLI
make psql             # Kết nối PostgreSQL CLI
make list-dbs         # Liệt kê databases

# Backup
make backup           # Backup ngay
make list-backups     # Xem backups

# Restore
make restore FILE=./backups/backup.sql.gz

# Health check
make health
```

## 🔧 Troubleshooting nhanh

### Container không start?
```bash
# Xem lỗi
docker compose logs postgres

# Kiểm tra port conflict
sudo lsof -i :5432

# Restart
docker compose restart postgres
```

### Quên mật khẩu?
```bash
# Xem trong .env
cat .env | grep POSTGRES_PASSWORD

# Đổi mật khẩu
docker compose exec postgres psql -U postgres -c \
  "ALTER USER postgres WITH PASSWORD 'new_password';"
# Nhớ cập nhật .env
```

### Không kết nối được?
```bash
# Kiểm tra container chạy chưa
docker compose ps

# Kiểm tra healthcheck
docker inspect postgres-db --format='{{.State.Health.Status}}'

# Test từ container
docker compose exec postgres psql -U postgres -l
```

## 🎯 Next Steps

- Đọc [README.md](README.md) đầy đủ
- Thiết lập backup tự động
- Cấu hình performance tuning
- Setup monitoring

---

**Có vấn đề?** Xem [Troubleshooting](README.md#-khắc-phục-sự-cố) trong README.
