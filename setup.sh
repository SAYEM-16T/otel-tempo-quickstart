#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="otel-tempo-quickstart"

usage() {
  cat <<EOF
Usage: $0 [command]

Commands:
  (no args)     Start or update the stack
  --clean       Remove containers+volumes, then fresh setup
  --clean-only  Remove containers+volumes only
  --status      Show service status
  --stop        Stop all services
  --help        Show this help
EOF
}

detect_runtime() {
  if command -v docker &>/dev/null; then
    RUNTIME="docker"
  elif command -v podman &>/dev/null; then
    RUNTIME="podman"
  else
    echo "❌ Neither docker nor podman found. Install one first."
    exit 1
  fi

  if $RUNTIME compose version &>/dev/null; then
    COMPOSE_CMD="$RUNTIME compose"
  elif command -v docker-compose &>/dev/null; then
    COMPOSE_CMD="docker-compose"
  else
    echo "❌ Neither '$RUNTIME compose' nor 'docker-compose' found."
    exit 1
  fi
}

set_compose_files() {
  # always include core stack
  COMPOSE_FILES="-f docker-compose.yml"

  # if grafana override file exists, include it so stack runs together
  if [[ -f docker-compose.grafana.yml ]]; then
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.grafana.yml"
  fi
}

require_env() {
  if [[ ! -f .env ]]; then
    echo "❌ .env file not found. Copy .env.example to .env and edit values."
    exit 1
  fi
}

start_stack() {
  require_env
  detect_runtime
  set_compose_files

  echo "▶ Starting $PROJECT_NAME stack using $COMPOSE_CMD $COMPOSE_FILES ..."
  $COMPOSE_CMD $COMPOSE_FILES up -d

  echo "⏳ Waiting 10s for services to warm up..."
  sleep 10

  echo "✅ Stack started."
  echo
  if [[ -f docker-compose.grafana.yml ]]; then
    echo "Grafana:  http://localhost:3000   (or http://\$MONITORING_HOST:3000)"
  fi
  echo "Tempo:    http://localhost:3200   (HTTP API)"
  echo "OTLP gRPC: localhost:${OTEL_GATEWAY_OTLP_GRPC_PORT:-4317}"
  echo "OTLP HTTP: localhost:${OTEL_GATEWAY_OTLP_HTTP_PORT:-4318}"
}

show_status() {
  detect_runtime
  set_compose_files
  $COMPOSE_CMD $COMPOSE_FILES ps
}

stop_stack() {
  detect_runtime
  set_compose_files
  $COMPOSE_CMD $COMPOSE_FILES down
}

clean_only() {
  detect_runtime
  set_compose_files
  $COMPOSE_CMD $COMPOSE_FILES down -v
}

clean_and_setup() {
  clean_only
  start_stack
}

case "${1:-}" in
  "")
    start_stack
    ;;
  --status)
    show_status
    ;;
  --stop)
    stop_stack
    ;;
  --clean-only)
    clean_only
    ;;
  --clean)
    clean_and_setup
    ;;
  --help|-h)
    usage
    ;;
  *)
    echo "Unknown command: $1"
    usage
    exit 1
    ;;
esac
