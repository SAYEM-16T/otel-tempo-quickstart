# 🚀 OpenTelemetry Gateway + Tempo + Grafana – Tracing Stack

Production-ready, lightweight tracing stack with:

- 📦 OpenTelemetry Collector (gateway mode)
- 📈 Grafana Tempo (trace storage & query backend)
- 📊 Grafana (UI & dashboards)
- 🐳 Docker / Podman support
- ⚙️ One-command automated setup via `setup.sh`

---

## 📖 Overview

This repository provides a minimal but practical observability stack focused on distributed tracing:

- **OpenTelemetry Collector (otel-gateway)**  
  Receives OTLP traffic (gRPC + HTTP) from your applications and forwards traces to Tempo.

- **Grafana Tempo**  
  Stores and indexes traces. Uses local disk storage by default (good for labs/dev).

- **Grafana**  
  Pre-provisioned with a **Tempo datasource** for exploring traces.

- **Container based**  
  Works with **Docker** or **Podman**.

---

## ⚡ Quick Start

```bash
# 1️⃣ Clone and enter the project
git clone https://github.com/SAYEM-16T/otel-tempo-quickstart.git
cd otel-tempo-quickstart

# 2️⃣ Create environment file from example
cp .env.example .env

# 3️⃣ Edit .env and adjust values (host, Grafana admin, retention, ports)
nano .env

# 4️⃣ Make setup script executable
chmod +x setup.sh

# 5️⃣ Run automated setup
./setup.sh

# 6️⃣ Check status
./setup.sh --status
```

That’s it 🎉
You’ll have an OTLP gateway + Tempo + Grafana stack ready in a few minutes.

---

## 📋 Prerequisites

### System Requirements

* **Memory**: 2–4 GB RAM available for containers (more is better)
* **CPU**: 2+ cores recommended
* **Ports (default)**:

  * `4317` – OTLP gRPC (OpenTelemetry)
  * `4318` – OTLP HTTP (OpenTelemetry)
  * `3200` – Tempo HTTP API
  * `3000` – Grafana UI
* **OS**:

  * macOS
  * Linux
  * Windows with WSL2 (Ubuntu, etc.)

### Required Tools

You only need a container runtime:

#### Option A: Docker (recommended)

* macOS: Docker Desktop
* Linux: Docker Engine
* Windows: Docker Desktop + WSL2

#### Option B: Podman

* macOS: `brew install podman podman-compose`
* Linux: Install `podman` + `podman-compose`
* Windows: Podman Desktop

The `setup.sh` script auto-detects Docker vs Podman.

---

## 🔐 Environment Configuration

All configuration is done via a simple `.env` file.

### Step 1: Create `.env` file

```bash
cp .env.example .env
```

### Step 2: Edit `.env` file

Open it with your editor:

```bash
nano .env
```

Example `.env`:

```env
# Public hostname/IP for Grafana URL & docs
MONITORING_HOST=localhost
# e.g. 192.168.57.11 for Vagrant host-only

# Grafana admin login
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=changeme

# Tempo retention – demo lab defaults
# examples: 1h, 24h, 7d, 15d, 30d
TEMPO_RETENTION=24h

# OTEL Gateway Collector ports (apps will hit these)
OTEL_GATEWAY_OTLP_GRPC_PORT=4317
OTEL_GATEWAY_OTLP_HTTP_PORT=4318
```

> ✅ **Recommendations**
>
> * Change `GRAFANA_ADMIN_PASSWORD` before exposing Grafana to others.
> * Use a real hostname/IP for `MONITORING_HOST` in multi-machine setups.
> * Adjust `TEMPO_RETENTION` depending on how long you want to keep traces.

> ⚠️ Never commit your real `.env` file to git. `.env` should already be in `.gitignore`.

---

## 🎮 Setup Commands

The `setup.sh` script is the main entrypoint.

### 🤖 Automated Setup (Recommended)

```bash
# 🚀 Normal setup / update
./setup.sh

# 🧹 Clean installation (remove containers+volumes, then re-setup)
./setup.sh --clean

# 🗑️ Remove all containers and volumes (no re-setup)
./setup.sh --clean-only

# 📊 Check service status
./setup.sh --status

# 🛑 Stop all services
./setup.sh --stop

# ❓ Show help
./setup.sh --help
```

### Command Reference

| Command                   | Requires `.env` | Description                            |
| ------------------------- | --------------- | -------------------------------------- |
| `./setup.sh`              | ✅ Yes           | Start or update the full stack         |
| `./setup.sh --clean`      | ✅ Yes           | Wipe containers+volumes, then re-setup |
| `./setup.sh --clean-only` | ❌ No            | Only remove containers and volumes     |
| `./setup.sh --status`     | ⚠️ Optional     | Show current container status          |
| `./setup.sh --stop`       | ❌ No            | Stop all services                      |
| `./setup.sh --help`       | ❌ No            | Show usage information                 |

---

## ✨ What the Script Does

The `setup.sh` script:

* 🔍 Auto-detects **Docker** or **Podman**
* 🧩 Uses one or more `docker-compose` files:

  * Core stack: `docker-compose.yml` (otel-gateway + tempo)
  * UI stack: `docker-compose.grafana.yml` (Grafana)
* ⏳ Waits a bit for services to start
* 📊 Shows basic status and service URLs
* 🧹 Optionally removes volumes for a full reset

You don’t have to remember or type long `docker compose ...` commands.

---

## 💾 Data Retention & Storage

### Tempo Retention

Tempo is configured via `tempo.yaml` for local storage under:

```text
/var/tempo
```

The `TEMPO_RETENTION` environment variable in `.env` is used (together with the Tempo config) to control how long traces are kept, for example:

* `1h` – keep traces for 1 hour (good for labs)
* `24h` – keep traces for 1 day
* `7d` – keep traces for 7 days

Shorter retention = less disk usage.

### Volumes

Docker volumes are used to persist data:

* `tempo-data` – Tempo trace storage
* `grafana-storage` – Grafana dashboards & config

Use:

```bash
./setup.sh --clean
```

or

```bash
./setup.sh --clean-only
```

if you want a fully clean slate.

---

## 🛠 Manual Setup (Optional)

If you prefer to start services manually instead of using `setup.sh`:

### Docker

```bash
# Start full stack (core + grafana)
docker compose -f docker-compose.yml -f docker-compose.grafana.yml up -d
```

### Podman

```bash
podman-compose -f docker-compose.yml -f docker-compose.grafana.yml up -d
```

> ⚠️ The `setup.sh` script already handles the recommended way.
> Manual commands are useful for debugging or custom workflows.

---

## 🌐 Service URLs

Once the stack is running:

| Service          | URL                               | Description                   |
| ---------------- | --------------------------------- | ----------------------------- |
| Grafana          | `http://localhost:3000`           | Traces UI                     |
| Tempo HTTP API   | `http://localhost:3200`           | Tempo diagnostics / API       |
| OTLP gRPC (apps) | `http://localhost:4317` (default) | OpenTelemetry OTLP gRPC input |
| OTLP HTTP (apps) | `http://localhost:4318` (default) | OpenTelemetry OTLP HTTP input |

> 🔐 **Default Grafana credentials**
>
> * **Username**: value from `GRAFANA_ADMIN_USER` (default `admin`)
> * **Password**: value from `GRAFANA_ADMIN_PASSWORD` (default `changeme`)

Change the password in `.env` for anything beyond local testing.

---

## 📈 OpenTelemetry Agent Integration

### Connection Settings (from your app’s perspective)

| Parameter     | Value (default)         |
| ------------- | ----------------------- |
| OTLP gRPC URL | `http://localhost:4317` |
| OTLP HTTP URL | `http://localhost:4318` |
| Protocol      | OTLP / OTLP-HTTP        |
| Service Name  | your app’s service name |

> If your app runs **inside another Docker compose project**, use the correct hostname / network (e.g. `otel-gateway:4317`) instead of `localhost`.

### Example: Node.js (OTLP gRPC)

```js
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-grpc';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

const traceExporter = new OTLPTraceExporter({
  url: 'http://localhost:4317', // or otel-gateway:4317 from another container
});

const sdk = new NodeSDK({
  traceExporter,
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'express-app-sqlite',
  }),
});

sdk.start();
```

Any traces sent to the gateway will flow:

`App → otel-gateway (OTEL Collector) → Tempo → Grafana (Tempo datasource)`

---

## 📊 Project Structure

```text
otel-tempo-quickstart/
├── README.md                     # This documentation
├── setup.sh                      # Automated setup script
├── docker-compose.yml            # Core stack: otel-gateway + tempo
├── docker-compose.grafana.yml    # Grafana stack (optional override file)
├── .env.example                  # Example environment configuration
├── .env                          # Your local env file (not in git)
├── otel-gateway.yaml             # OTEL Collector gateway config
├── tempo.yaml                    # Tempo configuration
└── grafana/
    └── provisioning/
        └── datasources/
            └── datasources.yaml  # Pre-provisioned Tempo datasource
```

---

## 🗂️ Key Files

| File / Path                                         | Purpose                                |
| --------------------------------------------------- | -------------------------------------- |
| `setup.sh`                                          | 🤖 Smart setup & management script     |
| `docker-compose.yml`                                | 📦 Core services (otel-gateway, tempo) |
| `docker-compose.grafana.yml`                        | 📦 Grafana stack                       |
| `.env`                                              | 🔑 Environment variables               |
| `otel-gateway.yaml`                                 | ⚙️ OTEL Collector config (gateway)     |
| `tempo.yaml`                                        | ⚙️ Tempo configuration                 |
| `grafana/provisioning/datasources/datasources.yaml` | 📈 Tempo datasource in Grafana         |

---

## 🔐 Security Guidelines

### Dev vs Production

| Aspect        | Development                 | Production                          |
| ------------- | --------------------------- | ----------------------------------- |
| Grafana login | Simple, default credentials | Strong, unique password             |
| Network       | Local only                  | Restrict via firewall / VPN / Nginx |
| TLS/HTTPS     | Optional                    | Recommended (reverse proxy)         |
| Exposure      | Local machine               | Carefully controlled                |

### Production Checklist

* [ ] Change `GRAFANA_ADMIN_PASSWORD` to a strong secret
* [ ] Restrict access to Grafana (firewall, VPN, reverse proxy)
* [ ] Consider running behind HTTPS (nginx / traefik)
* [ ] Monitor disk usage of Tempo volume
* [ ] Tune `TEMPO_RETENTION` for your storage budget

---

## ✨ Setup Script Features (Recap)

* 🎯 Runtime detection (Docker vs Podman)
* 🚀 One-command stack bring-up
* 🧹 Clean reset options (`--clean`, `--clean-only`)
* 📊 Status helper (`--status`)
* 🛑 Graceful stop (`--stop`)

### Example Workflows

```bash
# First time
./setup.sh

# After changing configs
./setup.sh

# Need a totally fresh environment
./setup.sh --clean

# Just see what’s running
./setup.sh --status

# Temporarily stop everything
./setup.sh --stop
```

