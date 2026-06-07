#!/usr/bin/env bash
set -euo pipefail

# Help: sh.wss.moe/pgsql.help
# Contact: https://wyf9.top/c

echo "=== PostgreSQL One-Click Install Script ==="
echo "Help:    sh.wss.moe/pgsql.help"
echo "Contact: https://wyf9.top/c"
echo ""

# check deps
command -v apt >/dev/null || { echo "Error: apt not found. This script supports Ubuntu/Debian only."; exit 1; }

echo "Updating system packages..."
apt update -qq

echo "Installing PostgreSQL..."
apt install -y postgresql postgresql-contrib

echo "Enabling and starting PostgreSQL service..."
systemctl enable --now postgresql >/dev/null

echo "PostgreSQL version:"
psql --version

# parse parameters
DB_NAME=""
DB_USER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --db)
            DB_NAME="$2"
            shift 2
            ;;
        --user)
            DB_USER="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# create db user (only if --db is provided)
if [[ -n "$DB_NAME" ]]; then
    echo ""
    echo "=== Create Database User ==="

    if [[ -z "$DB_USER" ]]; then
        DB_USER="gitea"
        echo "Username not provided, using default: ${DB_USER}"
    fi

    read -rsp "Password: " DB_PASS
    echo ""

    sudo -u postgres psql -c "
    CREATE DATABASE ${DB_NAME} WITH ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE template0;
    CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}' CREATEDB;
    GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
    " >/dev/null

    echo "Database '${DB_NAME}' and user '${DB_USER}' created."
else
    echo ""
    echo "No --db parameter provided, skipping database and user creation."
fi

# security configuration
echo ""
echo "Applying security configurations..."
PG_CONF="/etc/postgresql/$(psql -V | awk '{print $3}' | cut -d. -f1,2)/main/postgresql.conf"

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '127.0.0.1'/" "$PG_CONF"
sed -i "s/#password_encryption = md5/password_encryption = scram-sha-256/" "$PG_CONF"
sed -i "s/#log_min_messages = warning/log_min_messages = warning/" "$PG_CONF"
sed -i "s/#log_checkpoints = on/log_checkpoints = on/" "$PG_CONF"

systemctl restart postgresql

echo "Security settings applied:"
echo "  - Listen only on 127.0.0.1"
echo "  - Password encryption: scram-sha-256"

echo ""
if [[ -n "$DB_NAME" && -n "${DB_PASS:-}" ]]; then
    echo "Connection string:"
    echo "  postgresql://${DB_USER}:${DB_PASS}@127.0.0.1:5432/${DB_NAME}"
else
    echo "Connection string example:"
    echo "  postgresql://username:password@127.0.0.1:5432/dbname"
fi
echo ""
echo "Done."
