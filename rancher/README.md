# Rancher Internal Setup

## Quick Start

1. **Setup**:
   ```bash
   cp .env.example .env
   mkdir -p rancher_data rancher_logs backups
   ```

2. **Start Rancher**:
   ```bash
   docker compose up -d
   ```

3. **Access**: http://localhost hoặc http://your-internal-ip

## Configuration

### Environment Variables (.env)
```bash
RANCHER_BOOTSTRAP_PASSWORD=Admin123!  # Default password
CATTLE_SERVER_URL=https://rancher.internal.com
```

### Resource Limits
- Memory: 2GB limit, 1GB reservation  
- CPU: 1 core limit, 0.5 core reservation

## Backup

### Manual Backup
```bash
# Linux/macOS
./backup-rancher.sh


### Automated (Weekly)
```bash
# Linux crontab: 0 2 * * 0 /path/to/backup-rancher.sh
```

## Common Commands

```bash
# Start
docker compose up -d

# Stop  
docker compose down

# Logs
docker compose logs -f rancher

# Health check
curl http://localhost/ping

# Status
docker compose ps
```

## Troubleshooting

**Container won't start**: Check `docker compose logs rancher`

**Permission errors**: 
```bash
# Linux/macOS
chown -R 1000:1000 rancher_data rancher_logs

# Windows
# Ensure Docker has directory access
```

**Resource issues**: Monitor with `docker stats rancher-server`

## Security Notes

- `.env` file is gitignored (contains passwords)
- Uses privileged mode for internal container management
- Weekly backup retention (7 days)
- Basic audit logging enabled