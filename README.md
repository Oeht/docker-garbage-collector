# 🗑️ Docker Garbage Collector

A lightweight, containerized Docker cleanup service that runs on a schedule to remove unused containers, images, networks, and optionally volumes.

Supports:
- **Safe** mode: Keeps volumes, only removes unused containers/images/networks.
- **Aggressive** mode: Also removes unused volumes.
- **Dry-run** mode: Shows what would be deleted without deleting.
- **Age filtering**: Only delete objects older than `X` days.
- **Label protection**: Never delete objects with certain labels.
- **Cron scheduling**: Run at fixed times (default: every day at 03:00).

## 📦 Features
- Run entirely inside Docker (no host cron needed).
- Customizable schedule via environment variables.
- Fine-grained deletion control (safe vs aggressive).
- Protect specific images via labels.
- Compatible with Linux hosts running Docker.

## 🚀 Quick Start
```bash
docker compose up -d
```
Default: **Safe mode**, runs every day at **03:00** in `Europe/Berlin` timezone.

## ⚙️ Configuration
| Environment Variable | Default         | Description |
|----------------------|-----------------|-------------|
| `TZ`                | `Europe/Berlin` | Timezone for cron schedule |
| `CRON_SCHEDULE`     | `0 3 * * *`     | Cron expression for cleanup time |
| `PRUNE_MODE`        | `safe`          | `safe` or `aggressive` |
| `DRY_RUN`           | `false`         | If `true`, show actions without deleting |
| `AGE_DAYS`          | `0`             | Only delete objects older than `X` days (`0` = no filter) |
| `KEEP_LABELS`       | *(empty)*       | Comma-separated list of labels to never delete |

## 🔍 Examples
```bash
# Aggressive mode
PRUNE_MODE=aggressive docker compose up -d

# Dry run
DRY_RUN=true docker compose up -d

# Only delete items older than 14 days
AGE_DAYS=14 docker compose up -d

# Protect images with certain labels
KEEP_LABELS=keep,base docker compose up -d
```
---
## 📄 License
This project is licensed under the [MIT License](LICENSE).
