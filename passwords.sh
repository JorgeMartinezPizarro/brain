#!/usr/bin/env bash
# Rotate the database passwords of WordPress (mysql) and Nextcloud (mariadb).
# Run it with `make passwords` while the stack is running.
set -euo pipefail
cd "$(dirname "$0")"

for v in PROJECT_NAME MYSQL_ROOT_PASSWORD WORDPRESS_DB_USER NEXTCLOUD_DB_ROOT_PASSWORD NEXTCLOUD_DB_USER; do
	[ -n "${!v:-}" ] || { echo "Missing $v (run it with make passwords)"; exit 1; }
done

dc() { docker compose -p "$PROJECT_NAME" "$@"; }
gen() { openssl rand -hex 24; }
sql() { dc exec -T -e MYSQL_PWD="$2" "$1" mysql -uroot -e "$3"; }
# Write the value to .env and to the environment, which docker compose reads first
set_env() {
	if grep -q "^$1=" .env; then sed -i "s|^$1=.*|$1=$2|" .env; else echo "$1=$2" >> .env; fi
	export "$1=$2"
}

read -rp "Rotate the database passwords of '$PROJECT_NAME'? [y/N] " answer
[ "$answer" = y ] || exit 0

wp=$(gen); wp_root=$(gen); nc=$(gen); nc_root=$(gen)

echo "WordPress (mysql)..."
sql mysql "$MYSQL_ROOT_PASSWORD" "
	ALTER USER '$WORDPRESS_DB_USER'@'%' IDENTIFIED BY '$wp';
	ALTER USER IF EXISTS 'root'@'%' IDENTIFIED BY '$wp_root';
	ALTER USER IF EXISTS 'root'@'localhost' IDENTIFIED BY '$wp_root';"
set_env WORDPRESS_DB_PASSWORD "$wp"
set_env MYSQL_ROOT_PASSWORD "$wp_root"

echo "Nextcloud (mariadb)..."
sql mariadb "$NEXTCLOUD_DB_ROOT_PASSWORD" "
	ALTER USER '$NEXTCLOUD_DB_USER'@'%' IDENTIFIED BY '$nc';
	ALTER USER IF EXISTS 'root'@'%' IDENTIFIED BY '$nc_root';
	ALTER USER IF EXISTS 'root'@'localhost' IDENTIFIED BY '$nc_root';"
set_env NEXTCLOUD_DB_PASSWORD "$nc"
set_env NEXTCLOUD_DB_ROOT_PASSWORD "$nc_root"
dc exec -T -u www-data nextcloud php occ config:system:set dbpassword --value="$nc"

echo "Recreating containers with the new .env..."
dc up -d
echo "Done. Run 'make save' so the next backup matches the new passwords."
