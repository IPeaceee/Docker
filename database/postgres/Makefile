# PostgreSQL Docker Compose Makefile
# Quick commands for common operations

.PHONY: help setup dev prod stop restart logs backup restore clean

help: ## Show this help message
	@echo "PostgreSQL Docker Compose Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Initial setup - create .env from template
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✓ Created .env file - please update with your configuration"; \
	else \
		echo "⚠ .env already exists, skipping"; \
	fi
	@mkdir -p backups initdb migrations
	@chmod +x scripts/*.sh
	@echo "✓ Setup complete"

dev: ## Start development environment (with PgAdmin)
	docker compose --profile dev up -d
	@echo "✓ Development environment started"
	@echo "  PostgreSQL: localhost:5432"
	@echo "  PgAdmin:    http://localhost:5050"

prod: ## Start production environment (no PgAdmin, no exposed ports)
	docker compose --profile prod up -d
	@echo "✓ Production environment started"

stop: ## Stop all services
	docker compose down
	@echo "✓ Services stopped"

restart: ## Restart all services
	docker compose restart
	@echo "✓ Services restarted"

logs: ## Show logs (add SVC=postgres to filter specific service)
	docker compose logs -f $(SVC)

ps: ## Show running containers
	docker compose ps

health: ## Check health status
	@docker compose ps
	@echo ""
	@echo "PostgreSQL health:"
	@docker compose exec postgres pg_isready -U postgres || echo "Not ready"

backup: ## Create manual backup
	@./scripts/backup.sh

restore: ## Restore from backup (use FILE=path/to/backup.sql.gz)
	@if [ -z "$(FILE)" ]; then \
		echo "Error: Please specify FILE=path/to/backup.sql.gz"; \
		exit 1; \
	fi
	@./scripts/restore.sh $(FILE) $(DB)

psql: ## Connect to PostgreSQL CLI
	docker compose exec postgres psql -U postgres -d $(DB)

psql-dev: ## Connect to PostgreSQL CLI (dev container)
	docker compose exec postgres psql -U postgres

psql-prod: ## Connect to PostgreSQL CLI (prod container)
	docker compose exec postgres-prod psql -U postgres

list-backups: ## List available backups
	@ls -lh backups/

list-dbs: ## List all databases
	docker compose exec postgres psql -U postgres -l

create-db: ## Create new database (use DB=dbname)
	@if [ -z "$(DB)" ]; then \
		echo "Error: Please specify DB=database_name"; \
		exit 1; \
	fi
	docker compose exec postgres psql -U postgres -c "CREATE DATABASE $(DB);"
	@echo "✓ Database $(DB) created"

drop-db: ## Drop database (use DB=dbname) - DANGEROUS!
	@if [ -z "$(DB)" ]; then \
		echo "Error: Please specify DB=database_name"; \
		exit 1; \
	fi
	@echo "⚠ WARNING: This will permanently delete database $(DB)"
	@read -p "Are you sure? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		docker compose exec postgres psql -U postgres -c "DROP DATABASE $(DB);"; \
		echo "✓ Database $(DB) dropped"; \
	else \
		echo "Cancelled"; \
	fi

clean: ## Remove all containers and volumes - DANGEROUS!
	@echo "⚠ WARNING: This will delete all data including backups in volumes"
	@read -p "Are you sure? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		docker compose down -v; \
		echo "✓ All containers and volumes removed"; \
	else \
		echo "Cancelled"; \
	fi

update: ## Pull latest images and restart
	docker compose pull
	docker compose up -d
	@echo "✓ Images updated and services restarted"

stats: ## Show resource usage
	docker stats postgres-db postgres-backup --no-stream

vacuum: ## Run VACUUM ANALYZE on database (use DB=dbname)
	@if [ -z "$(DB)" ]; then \
		DB=postgres; \
	fi
	docker compose exec postgres psql -U postgres -d $(DB) -c "VACUUM ANALYZE;"
	@echo "✓ VACUUM ANALYZE completed on $(DB)"

# Development helpers
dev-init: setup dev ## Setup and start dev environment
	@echo "✓ Development environment ready"

prod-init: setup prod ## Setup and start prod environment
	@echo "✓ Production environment ready"
