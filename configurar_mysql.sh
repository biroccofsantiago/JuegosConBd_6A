#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
PYTHON=".venv/bin/python"

if [[ ! -x "$PYTHON" ]]; then
  echo "No encuentro el entorno virtual. Primero ejecutá: python3 -m venv .venv && .venv/bin/pip install -r requirements.txt"
  exit 1
fi

if ! command -v mysql >/dev/null 2>&1; then
  echo "No encuentro el cliente de MySQL. Instalá MySQL y volvé a ejecutar este script."
  exit 1
fi

APP_DB_USER="juegos_web_app"
DB_PASSWORD="$("$PYTHON" -c 'import secrets; print(secrets.token_hex(32))')"
SECRET_KEY="$("$PYTHON" -c 'import secrets; print(secrets.token_hex(32))')"

# El administrador local de Ubuntu suele autenticarse con sudo mysql.
echo "Configurando la base de datos y un usuario local para la aplicación..."
sudo mysql <<SQL
CREATE DATABASE IF NOT EXISTS juegos_6A CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER IF NOT EXISTS '${APP_DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${APP_DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON juegos_6A.* TO '${APP_DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

TABLA_EXISTE="$(sudo mysql --batch --skip-column-names -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'juegos_6A' AND table_name = 'usuarios';")"
if [[ "$TABLA_EXISTE" == "0" ]]; then
  echo "La tabla usuarios no existe; importando base.sql..."
  ARCHIVO_CNF="$(mktemp)"
  trap 'rm -f "$ARCHIVO_CNF"' EXIT
  chmod 600 "$ARCHIVO_CNF"
  printf '[client]\nuser=%s\npassword=%s\nhost=localhost\n' "$APP_DB_USER" "$DB_PASSWORD" > "$ARCHIVO_CNF"
  mysql --defaults-extra-file="$ARCHIVO_CNF" juegos_6A < base.sql
fi

umask 077
cat > .env <<ENV
DB_HOST=localhost
DB_PORT=3306
DB_NAME=juegos_6A
DB_USER=${APP_DB_USER}
DB_PASSWORD=${DB_PASSWORD}
SECRET_KEY=${SECRET_KEY}
APP_HOST=127.0.0.1
APP_PORT=5000
ENV

printf '\nListo: MySQL quedó configurado y la conexión se guardó en .env.\n'
if [[ "$TABLA_EXISTE" != "0" ]]; then
  echo "Se conservó la tabla existente; no se volvió a importar base.sql."
fi
echo "Ahora reiniciá el servidor Flask para que cargue la configuración nueva."
