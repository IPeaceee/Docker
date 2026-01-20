# BunkerWeb Deployment Guide

Hướng dẫn triển khai BunkerWeb với Docker Compose

## Giới thiệu

BunkerWeb là một Web Application Firewall (WAF) hiện đại, mã nguồn mở, được thiết kế để bảo vệ các ứng dụng web khỏi các cuộc tấn công. Triển khai này sử dụng **Autoconf mode** để tự động quản lý cấu hình thông qua Docker labels.

## Thành phần

- **BunkerWeb**: Web server và WAF chính (port 80, 443)
- **BW-Scheduler**: Quản lý lịch trình và cấu hình
- **BW-Autoconf**: Dịch vụ tự động cấu hình theo Docker labels
- **BW-Docker**: Docker socket proxy để an toàn
- **BW-DB**: MariaDB database lưu trữ cấu hình
- **CrowdSec**: Hệ thống phát hiện và ngăn chặn mối đe dọa (Option)

## Yêu cầu

- Docker Engine 20.10+
- Docker Compose 2.0+
- 2GB RAM tối thiểu
- Cổng 80 và 443 khả dụng
- File `.env` với các biến môi trường cần thiết

## Cấu hình

### 1. Tạo file `.env`

Tạo file `.env` trong thư mục `docker-autoconf/` với nội dung sau:

```env
# MariaDB Configuration
MYSQL_ROOT_PW=your_secure_root_password
MYSQL_DATABASE=bunkerweb
MYSQL_USER=bunkerweb
MYSQL_PASSWORD=your_secure_db_password

# CrowdSec (tuỳ chọn)
CROWDSEC_API_KEY=your_crowdsec_api_key
```

### 2. Thay đổi quyền hạn

```bash
chmod 600 .env
```

## Triển khai

### Khởi động BunkerWeb

```bash
cd docker-autoconf
docker-compose up -d
```

### Kiểm tra trạng thái

```bash
docker-compose ps
```

Tất cả các container nên ở trạng thái `Up`.

### Xem logs

```bash
# Xem tất cả logs
docker-compose logs -f

# Xem logs của container cụ thể
docker-compose logs -f bunkerweb
docker-compose logs -f bw-autoconf
docker-compose logs -f bw-scheduler
```

## Cấu hình Dịch vụ Web

Để thêm dịch vụ web cần bảo vệ, sử dụng Docker labels. Ví dụ:

```yaml
services:
  my-app:
    image: my-app:latest
    networks:
      - bw-services  # Kết nối tới BunkerWeb network
    labels:
      - "bunkerweb.SERVER_NAME=example.com"
      - "bunkerweb.AUTO_LETS_ENCRYPT=yes"
      - "bunkerweb.USE_MODSECURITY=yes"
      - "bunkerweb.REVERSE_PROXY_URL=/app"
      - "bunkerweb.REVERSE_PROXY_HOST=http://my-app:8080"
```

## Biến Môi Trường (Environment Variables)

### Cấu hình Cơ Bản

| Biến | Mô tả | Ví dụ |
|------|-------|-------|
| `SERVER_NAME` | Tên miền (domain) | `example.com` |
| `AUTO_LETS_ENCRYPT` | Tự động cấp SSL certificate | `yes` |
| `USE_MODSECURITY` | Bật ModSecurity WAF | `yes` |
| `REVERSE_PROXY_URL` | Đường dẫn proxy | `/app` |
| `REVERSE_PROXY_HOST` | Host của ứng dụng backend | `http://backend:8000` |

### Whitelist IP

```env
API_WHITELIST_IP="127.0.0.0/8 192.168.96.0/20 10.20.30.0/24 0.0.0.0/0"
```

### CrowdSec Integration

```env
CROWDSEC_ENABLED=yes
CROWDSEC_API_URL=http://crowdsec:8080/
CROWDSEC_API_KEY=your_api_key
```

## Quản lý

### Dừng BunkerWeb

```bash
docker-compose down
```

### Dừng nhưng giữ data

```bash
docker-compose stop
```

### Khởi động lại

```bash
docker-compose restart
```

### Cập nhật version

```bash
# Cập nhật image
docker-compose pull

# Khởi động lại
docker-compose up -d
```

### Xóa dữ liệu và khởi động lại từ đầu

```bash
docker-compose down -v
docker-compose up -d
```

## Truy cập

### HTTP/HTTPS
- Các yêu cầu được điều hướng qua port 80 và 443
- Tự động redirect HTTP → HTTPS nếu bật SSL

### Dashboard (nếu có)
- Kiểm tra documentation chính thức để cấu hình dashboard quản lý

## Cấu trúc Network

```
┌─────────────────────────────────────┐
│        Internet (Port 80/443)      │
└────────────────┬────────────────────┘
                 │
         ┌───────▼────────┐
         │  BunkerWeb WAF │
         └───────┬────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    │    bw-services          │
    │    (backend apps)       │
    │                         │
└─────────────────────────────┘
```

## Mạng (Networks)

- **bw-universe**: Kết nối giữa BunkerWeb, scheduler, autoconf
- **bw-services**: Nơi các ứng dụng backend kết nối
- **bw-docker**: Kết nối Docker socket proxy
- **bw-db**: Kết nối database

## Khối lượng lưu trữ (Volumes)

- **bw-data**: Lưu trữ MariaDB database
- **bw-storage**: Lưu trữ cache, backups

## Ghi chú quan trọng

### Bảo mật

1. **Thay đổi mật khẩu mặc định** trong file `.env`
2. **Không commit `.env`** vào Git (thêm vào `.gitignore`)
3. **Sử dụng HTTPS** cho tất cả các kết nối
4. **Giới hạn IP whitelist** phù hợp với yêu cầu của bạn
5. **Cập nhật regularly** để nhận các bản vá bảo mật

### Hiệu suất

- Tăng `max-allowed-packet` trong MariaDB cho các query lớn
- Sử dụng persistent volumes để tránh mất dữ liệu
- Theo dõi resource usage: `docker stats`

### CrowdSec

- Yêu cầu CrowdSec instance chạy riêng
- Cung cấp `CROWDSEC_API_KEY` để kích hoạt
- Tự động phát hiện và chặn các hành vi đe dọa

## Troubleshooting

### BunkerWeb không khởi động

```bash
docker-compose logs bunkerweb
```

Kiểm tra:
- Cổng 80, 443 có sẵn không
- File `.env` có các biến cần thiết không

### Database connection error

```bash
docker-compose logs bw-autoconf
```

Kiểm tra:
- MariaDB container đang chạy: `docker-compose ps bw-db`
- Mật khẩu database trong `.env` chính xác không

### Autoconf không tự động cập nhật

```bash
docker-compose restart bw-autoconf
```

### Xem container logs chi tiết

```bash
docker-compose logs --tail=100 bw-autoconf
```

## Liên kết hữu ích

- [BunkerWeb Documentation](https://docs.bunkerweb.io/)
- [Docker Documentation](https://docs.docker.com/)
- [MariaDB Documentation](https://mariadb.com/docs/)
- [CrowdSec Documentation](https://docs.crowdsec.net/)

## Hỗ trợ

Nếu gặp vấn đề:

1. Kiểm tra logs: `docker-compose logs`
2. Xác thực cấu hình Docker Compose
3. Đảm bảo tất cả images được tải về: `docker-compose pull`
4. Tham khảo tài liệu chính thức của BunkerWeb
