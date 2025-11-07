# Rancher Production Management Makefile

.PHONY: help setup start stop restart logs backup restore clean health

# Default target
help:
	@echo "Rancher Production Management Commands:"
	@echo "  setup     - Initial setup (create directories, set permissions)"
	@echo "  start     - Start Rancher server"
	@echo "  stop      - Stop Rancher server"
	@echo "  restart   - Restart Rancher server"
	@echo "  logs      - View Rancher logs"
	@echo "  logs-f    - Follow Rancher logs"
	@echo "  backup    - Create backup"
	@echo "  health    - Check Rancher health"
	@echo "  clean     - Clean unused Docker resources"
	@echo "  update    - Update Rancher to latest version"

# Initial setup
setup:
	@echo "Setting up Rancher production environment..."
	@mkdir -p rancher_data rancher_logs ssl-certs
	@if [ ! -f .env ]; then cp .env.example .env; echo "Created .env file - please edit it!"; fi
	@chmod +x backup-rancher.sh
	@echo "Setup complete! Remember to:"
	@echo "1. Edit .env file with your configuration"
	@echo "2. Place SSL certificates in ssl-certs/ directory"
	@echo "3. Run 'make start' to start Rancher"

# Start services
start:
	@echo "Starting Rancher server..."
	docker compose up -d
	@echo "Rancher is starting up. Use 'make logs-f' to follow the logs."
	@echo "Access Rancher at: https://localhost"

# Stop services
stop:
	@echo "Stopping Rancher server..."
	docker compose down

# Restart services
restart:
	@echo "Restarting Rancher server..."
	docker compose restart
	@echo "Rancher restarted successfully."

# View logs
logs:
	docker compose logs rancher

# Follow logs
logs-f:
	docker compose logs -f rancher

# Create backup
backup:
	@echo "Creating backup..."
	@if [ -f backup-rancher.sh ]; then ./backup-rancher.sh; else echo "Backup script not found!"; fi

# Check health
health:
	@echo "Checking Rancher health..."
	@docker compose ps
	@echo ""
	@echo "Container health status:"
	@docker inspect rancher-server --format='Health Status: {{.State.Health.Status}}' 2>/dev/null || echo "Health check not available"
	@echo ""
	@echo "API health check:"
	@curl -k -s https://localhost/ping && echo " - API is responding" || echo " - API is not responding"

# Clean unused resources
clean:
	@echo "Cleaning unused Docker resources..."
	docker system prune -f
	docker volume prune -f

# Update Rancher
update:
	@echo "Updating Rancher..."
	@echo "Current version:"
	@docker inspect rancher-server --format='{{.Config.Image}}' 2>/dev/null || echo "Container not found"
	@echo "Creating backup before update..."
	@make backup
	@echo "Pulling latest image..."
	docker compose pull
	@echo "Restarting with new image..."
	docker compose up -d
	@echo "Update complete. Check logs with 'make logs-f'"

# Development helpers
dev-ssl:
	@echo "Generating self-signed SSL certificates for development..."
	@mkdir -p ssl-certs
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout ssl-certs/tls.key \
		-out ssl-certs/tls.crt \
		-subj "/CN=localhost"
	@echo "Self-signed certificates created in ssl-certs/"

dev-start: dev-ssl setup start