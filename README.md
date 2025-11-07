# 🐳 Docker Templates & Deployments

> Repository chứa các template Docker Compose production-ready cho các services phổ biến

---

## 📋 Mục Lục

- [Tổng Quan](#-tổng-quan)
- [Danh Sách Templates](#-danh-sách-templates)
- [Quick Start](#-quick-start)
- [Cấu Trúc Chung](#-cấu-trúc-chung)
- [Best Practices](#-best-practices)
- [Contributing](#-contributing)

---

## 🎯 Tổng Quan

Repository này cung cấp:

✅ **Production-ready templates** cho các services phổ biến  
✅ **Docker Compose configurations** với best practices  
✅ **Automated backups** và recovery procedures  
✅ **Security hardening** mặc định  
✅ **Complete documentation** từ setup đến troubleshooting  
✅ **Environment-based configs** (Dev/Staging/Prod)  

---

## 📦 Danh Sách Templates

### 1. PostgreSQL
**📍 Folder:** `postgres/`

#### 🔍 Mô Tả
Production-ready PostgreSQL deployment với auto-backup và PgAdmin.

#### ✨ Tính Năng
- ✅ PostgreSQL 16 với healthcheck
- ✅ Profiles riêng Dev/Production
- ✅ PgAdmin 4 (development only)
- ✅ Automated backup với retention policy
- ✅ Restore scripts
- ✅ Migration support
- ✅ Performance tuning ready

#### 📚 Documentation
- [README.md](postgres/README.md) - Comprehensive guide (400+ lines)
- [QUICKSTART.md](postgres/QUICKSTART.md) - 5-minute setup
- [Makefile](postgres/Makefile) - Common commands

#### 🚀 Quick Start
```bash
cd postgres/
cp .env.example .env
# Edit .env với passwords
docker compose --profile dev up -d
```

#### 🔗 Access
- PostgreSQL: `localhost:5432`
- PgAdmin: `http://localhost:5050`

#### 📊 Use Cases
- ✅ Application database (Django, Rails, Node.js...)
- ✅ Data warehouse
- ✅ Analytics
- ✅ Microservices database

---

### 2. MariaDB
**📍 Folder:** `mariadb/`

#### 🔍 Mô Tả
MariaDB deployment cho WordPress hoặc PHP applications.

#### ✨ Tính Năng
- ✅ MariaDB với custom configuration
- ✅ Optimized for WordPress
- ✅ Persistent volumes
- ✅ Custom my.cnf tuning

#### 📚 Files
```
mariadb/
├── docker-compose.yaml    # Main config
├── my.cnf                 # Custom MySQL config
├── .env                   # Environment variables (gitignored)
└── backups/               # Backup storage
```

#### 🚀 Quick Start
```bash
cd mariadb/
docker compose up -d
```

#### 🔗 Access
- MariaDB: `localhost:3306`
- User: (from .env)
- Password: (from .env)

#### 📊 Use Cases
- ✅ WordPress hosting
- ✅ PHP applications (Laravel, Symfony...)
- ✅ MySQL-compatible applications

---

### 3. N8N (Workflow Automation)
**📍 Folder:** `n8n/`

#### 🔍 Mô Tả
N8N workflow automation platform - alternative to Zapier/Make.

#### ✨ Tính Năng
- ✅ Self-hosted automation
- ✅ Visual workflow builder
- ✅ 200+ integrations
- ✅ Persistent workflows
- ✅ SQLite database

#### 📚 Files
```
n8n/
├── docker-compose.yml     # N8N configuration
├── .env                   # Environment (gitignored)
└── n8n-data/              # Workflows & database
```

#### 🚀 Quick Start
```bash
cd n8n/
docker compose up -d
```

#### 🔗 Access
- Web UI: `http://localhost:5678`
- First login: Create admin account

#### 📊 Use Cases
- ✅ Workflow automation
- ✅ API integrations
- ✅ Data synchronization
- ✅ Scheduled tasks
- ✅ Webhooks processing

---

### 4. Portainer (Docker Management)
**📍 Folder:** `portainer/`

#### 🔍 Mô Tả
Web-based Docker management UI - quản lý containers, images, volumes...

#### ✨ Tính Năng
- ✅ Visual Docker management
- ✅ Container monitoring
- ✅ Logs viewer
- ✅ Stack deployment
- ✅ User management

#### 📚 Files
```
portainer/
└── portainer-compose.yaml  # Portainer configuration
```

#### 🚀 Quick Start
```bash
cd portainer/
docker compose -f portainer-compose.yaml up -d
```

#### 🔗 Access
- Web UI: `http://localhost:9000`
- First login: Create admin account

#### 📊 Use Cases
- ✅ Docker host management
- ✅ Multi-environment monitoring
- ✅ Team collaboration
- ✅ Container orchestration

---

### 5. Rancher (Kubernetes Management)
**📍 Folder:** `rancher/`

#### 🔍 Mô Tả
Rancher platform để quản lý Kubernetes clusters.

#### ✨ Tính Năng
- ✅ Multi-cluster management
- ✅ RBAC & authentication
- ✅ Monitoring & logging
- ✅ Helm charts catalog
- ✅ Backup automation

#### 📚 Documentation
- [README.md](rancher/README.md) - Setup guide
- [Makefile](rancher/Makefile) - Common operations
- [backup-rancher.sh](rancher/backup-rancher.sh) - Backup script

#### 🚀 Quick Start
```bash
cd rancher/
cp .env.example .env
make start
# hoặc
docker compose up -d
```

#### 🔗 Access
- Web UI: `http://localhost` hoặc `http://your-ip`
- Bootstrap password: (from .env)

#### 📊 Use Cases
- ✅ Kubernetes cluster management
- ✅ Multi-cloud deployments
- ✅ Container orchestration at scale
- ✅ DevOps platform

---

## 🚀 Quick Start

### Prerequisites
```bash
# Docker
docker --version  # 20.10+

# Docker Compose
docker compose version  # 2.0+
```

### General Workflow

```bash
# 1. Chọn template cần deploy
cd <template-folder>/

# 2. Copy environment template (nếu có)
cp .env.example .env

# 3. Customize environment
nano .env  # hoặc vim, code...

# 4. Start services
docker compose up -d

# 5. Check status
docker compose ps
docker compose logs -f

# 6. Access service
# Xem phần "Access" của từng template
```

---

## 📁 Cấu Trúc Chung

Mỗi template tuân theo structure nhất quán:

```
<service-name>/
├── docker-compose.yml       # Main compose file
├── .env.example             # Environment template
├── .env                     # Your config (gitignored)
├── README.md                # Comprehensive documentation
├── QUICKSTART.md            # Quick setup guide (optional)
├── Makefile                 # Common commands (optional)
├── scripts/                 # Utility scripts
│   ├── backup.sh
│   ├── restore.sh
│   └── ...
├── configs/                 # Configuration files
│   └── ...
├── data/                    # Persistent data (gitignored)
└── backups/                 # Backup storage (gitignored)
```

### Environment Files

**✅ LUÔN gitignore:**
- `.env` - Contains passwords & secrets
- `data/` - Database files
- `backups/` - Backup files
- `*.log` - Log files

**✅ LUÔN commit:**
- `.env.example` - Template cho team
- `docker-compose.yml` - Service definition
- `README.md` - Documentation
- Scripts - Automation tools

---

## 🔒 Best Practices

### 1. Security

#### ✅ Environment Variables
```bash
# ✅ DO: Dùng .env files
POSTGRES_PASSWORD=secure_password_here

# ❌ DON'T: Hardcode trong docker-compose.yml
environment:
  POSTGRES_PASSWORD: password123
```

#### ✅ Secrets Management
```bash
# Generate strong passwords
openssl rand -base64 32

# Use Docker secrets (production)
echo "my_secret_password" | docker secret create db_password -
```

#### ✅ Network Isolation
```yaml
# Tách network cho từng stack
networks:
  db_net:
    internal: true  # No external access
  web_net:
    # Allow external
```

#### ✅ Non-root Users
```yaml
# Run containers as non-root
user: "1000:1000"
```

### 2. Performance

#### ✅ Resource Limits
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

#### ✅ Healthchecks
```yaml
healthcheck:
  test: ["CMD", "pg_isready", "-U", "postgres"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 30s
```

#### ✅ Restart Policies
```yaml
restart: unless-stopped  # Recommended
# hoặc
restart: on-failure:3
```

### 3. Data Management

#### ✅ Named Volumes
```yaml
volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      device: /mnt/data/postgres
      o: bind
```

#### ✅ Backup Strategy
```bash
# Automated daily backups
# Retention: Daily (7), Weekly (4), Monthly (6)

# Test restore regularly
./scripts/restore.sh latest-backup.sql.gz test_db
```

#### ✅ Volume Backups
```bash
# Backup Docker volume
docker run --rm \
  -v db_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/volume-backup.tar.gz /data
```

### 4. Monitoring

#### ✅ Logging
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

#### ✅ Health Monitoring
```bash
# Quick health check all services
docker compose ps

# Detailed stats
docker stats

# Monitor logs
docker compose logs -f --tail=100
```

### 5. Development vs Production

#### Development Profile
```yaml
services:
  app:
    profiles: ["dev"]
    ports:
      - "5432:5432"  # Expose ports
    volumes:
      - ./src:/app  # Mount source code
    environment:
      DEBUG: "true"
```

#### Production Profile
```yaml
services:
  app:
    profiles: ["prod"]
    # No ports exposed
    volumes:
      - app_data:/app/data  # Named volumes only
    environment:
      DEBUG: "false"
    restart: always
```

Usage:
```bash
# Development
docker compose --profile dev up -d

# Production
docker compose --profile prod up -d
```

---

## 🛠️ Common Operations

### Start/Stop Services

```bash
# Start
docker compose up -d

# Stop (keep data)
docker compose down

# Stop and remove volumes (⚠️ DELETES DATA)
docker compose down -v

# Restart
docker compose restart

# Restart specific service
docker compose restart postgres
```

### Logs & Debugging

```bash
# View logs
docker compose logs -f

# Specific service
docker compose logs -f postgres

# Last 100 lines
docker compose logs --tail=100

# Timestamps
docker compose logs -f -t
```

### Execute Commands

```bash
# Interactive shell
docker compose exec postgres bash

# Run command
docker compose exec postgres psql -U postgres

# One-off command
docker compose run --rm postgres psql --version
```

### Updates & Maintenance

```bash
# Pull latest images
docker compose pull

# Recreate containers with new images
docker compose up -d --force-recreate

# Remove unused images
docker image prune -a

# Full cleanup (⚠️ careful)
docker system prune -a --volumes
```

---

## 📊 Monitoring & Alerting

### Basic Monitoring Stack

```bash
# 1. Resource usage
docker stats

# 2. Container status
watch -n 5 'docker compose ps'

# 3. Disk usage
docker system df

# 4. Network inspection
docker network inspect <network-name>
```

### Advanced Monitoring

Khuyến nghị thêm monitoring stack:

- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **Loki** - Log aggregation
- **cAdvisor** - Container metrics

*(Templates cho monitoring stack sẽ được thêm trong tương lai)*

---

## 🔄 Backup & Disaster Recovery

### Backup Checklist

- [ ] Database backups automated
- [ ] Volume backups scheduled
- [ ] Backup retention policy set
- [ ] Restore procedure tested
- [ ] Backups stored offsite
- [ ] Encryption enabled (nếu cần)

### Example Backup Strategy

```bash
# Daily backups
0 2 * * * /path/to/scripts/backup.sh

# Weekly volume backup
0 3 * * 0 /path/to/scripts/backup-volumes.sh

# Monthly offsite sync
0 4 1 * * rsync -avz backups/ user@backup-server:/backups/
```

### Disaster Recovery Plan

1. **Stop services**
   ```bash
   docker compose down
   ```

2. **Restore volumes**
   ```bash
   docker volume create db_data
   docker run --rm -v db_data:/data -v $(pwd):/backup \
     alpine tar xzf /backup/volume-backup.tar.gz -C /
   ```

3. **Restore database**
   ```bash
   ./scripts/restore.sh latest-backup.sql.gz
   ```

4. **Start services**
   ```bash
   docker compose up -d
   ```

5. **Verify**
   ```bash
   docker compose ps
   docker compose logs
   ```

---

## 🚧 Roadmap

### Planned Templates

- [ ] **Redis** - Caching & session storage
- [ ] **MongoDB** - NoSQL database
- [ ] **Elasticsearch** - Search engine
- [ ] **RabbitMQ** - Message broker
- [ ] **MinIO** - S3-compatible object storage
- [ ] **Traefik** - Reverse proxy & load balancer
- [ ] **Nginx Proxy Manager** - Easy reverse proxy
- [ ] **GitLab** - Git repository & CI/CD
- [ ] **Jenkins** - CI/CD automation
- [ ] **Nextcloud** - File hosting
- [ ] **Monitoring Stack** - Prometheus + Grafana + Loki
- [ ] **ELK Stack** - Elasticsearch + Logstash + Kibana
- [ ] **Keycloak** - Identity & access management
- [ ] **Vault** - Secrets management
- [ ] **WikiJS** - Documentation platform

### Enhancements

- [ ] Terraform modules cho mỗi template
- [ ] Ansible playbooks deployment
- [ ] Kubernetes Helm charts
- [ ] CI/CD pipeline examples
- [ ] Multi-environment configs
- [ ] Testing frameworks
- [ ] Performance benchmarks

---

## 🤝 Contributing

### Adding New Template

1. **Create folder structure**
   ```bash
   mkdir -p new-service/{scripts,configs,data,backups}
   ```

2. **Required files**
   - `docker-compose.yml` - Service definition
   - `.env.example` - Environment template
   - `README.md` - Documentation
   - `.gitignore` - Ignore sensitive files

3. **Documentation standards**
   - Quick start section
   - Configuration details
   - Backup/restore procedures
   - Troubleshooting common issues
   - Use cases

4. **Testing**
   - Test fresh deployment
   - Test backup/restore
   - Test upgrades
   - Document all steps

5. **Submit PR**
   - Update main README.md
   - Add to template list
   - Include screenshots nếu có

---

## 📚 Resources

### Docker Documentation
- [Docker Docs](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### Learning Resources
- [Docker Tutorial](https://www.docker.com/101-tutorial)
- [Play with Docker](https://labs.play-with-docker.com/)
- [Docker Hub](https://hub.docker.com/)

### Tools
- [Dive](https://github.com/wagoodman/dive) - Explore image layers
- [Lazydocker](https://github.com/jesseduffield/lazydocker) - Terminal UI
- [ctop](https://github.com/bcicen/ctop) - Container metrics

---

## ⚠️ Important Notes

### .gitignore

File này đã được cấu hình để ignore:

```gitignore
# Environment variables
.env
*.env
!.env.example

# Database files
*.sqlite
*.db

# Backups
*.sql
*.sql.gz
*.dump

# Logs
*.log

# Data directories (thường mounted as volumes)
*/data/
*/backups/
```

### Security Considerations

🔒 **NEVER commit:**
- Passwords trong .env
- Database files
- Backup files
- SSL certificates private keys
- API keys/tokens

✅ **ALWAYS:**
- Use strong passwords
- Enable SSL/TLS trong production
- Update images regularly
- Monitor security advisories
- Implement least privilege
- Enable firewalls
- Backup encryption

### Production Checklist

Trước khi deploy production:

- [ ] Strong passwords set
- [ ] SSL/TLS configured
- [ ] Firewall rules applied
- [ ] Backups automated & tested
- [ ] Monitoring enabled
- [ ] Resource limits set
- [ ] Healthchecks configured
- [ ] Logging configured
- [ ] Network isolated
- [ ] Documentation updated
- [ ] Team trained
- [ ] Rollback plan ready

---

## 📞 Support

### Troubleshooting

Nếu gặp vấn đề:

1. Check logs: `docker compose logs -f`
2. Check status: `docker compose ps`
3. Check resources: `docker stats`
4. Restart service: `docker compose restart <service>`
5. Xem template-specific README.md

### Common Issues

| Issue | Solution |
|-------|----------|
| Port already in use | Change port trong .env hoặc stop conflicting service |
| Permission denied | Check file/folder ownership, chown nếu cần |
| Out of disk space | Clean: `docker system prune -a` |
| Container keeps restarting | Check logs, verify environment variables |
| Cannot connect | Check network, firewall, service started |

---

## 📄 License

Templates và configurations trong repo này được cung cấp AS-IS.

Third-party software có licenses riêng:
- PostgreSQL: PostgreSQL License
- MariaDB: GPL v2
- N8N: Sustainable Use License
- Portainer: Zlib License
- Rancher: Apache 2.0

---

## 👥 Authors

For questions or contributions:
- 📧 Email: truongminhan9998@gmail.com

---

**📌 Last Updated:** November 7, 2025  
**📌 Version:** 1.0.0  
**📌 Total Templates:** 5 (+ more coming soon)

---

> 💡 **Pro Tip:** Mỗi template đều có README riêng với hướng dẫn chi tiết. Luôn đọc documentation trước khi deploy!
