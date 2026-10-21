#!/usr/bin/env bash
# Rotate the passwords of WordPress and Nextcloud: their databases (mysql, mariadb) and their admin users.
# Run it with `make passwords` while the stack is running. The new passwords are written to .env.
set -euo pipefail
cd "$(dirname "$0")"

missing=""
for v in PROJECT_NAME MYSQL_ROOT_PASSWORD WORDPRESS_DB_USER WORDPRESS_DB_NAME WORDPRESS_ADMIN_USER \
	NEXTCLOUD_DB_ROOT_PASSWORD NEXTCLOUD_DB_USER NEXTCLOUD_ADMIN_USER; do
	[ -n "${!v:-}" ] || missing="$missing $v"
done
[ -z "$missing" ] || { echo "Missing or empty in .env:$missing (run it with make passwords)"; exit 1; }

dc() { docker compose -p "$PROJECT_NAME" "$@"; }
gen() { openssl rand -hex 24; }
sql() { dc exec -T -e MYSQL_PWD="$2" "$1" mysql -uroot -e "$3"; }
# WP-CLI in a throwaway container that shares the files and network of the WordPress container
wp() {
	local c; c=$(dc ps -q wordpress)
	[ -n "$c" ] || { echo "WordPress is not running"; exit 1; }
	docker run --rm --user 33:33 -e HOME=/tmp --volumes-from "$c" --network "container:$c" \
		-e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER -e WORDPRESS_DB_PASSWORD -e WORDPRESS_DB_NAME \
		wordpress:cli-php8.3 wp "$@"
}
# Write the value to .env and to the environment, which docker compose reads first
set_env() {
	if grep -q "^$1=" .env; then sed -i "s|^$1=.*|$1=$2|" .env; else echo "$1=$2" >> .env; fi
	export "$1=$2"
}

read -rp "Rotate the database and admin passwords of '$PROJECT_NAME'? [y/N] " answer
[ "$answer" = y ] || exit 0

# Only the root passwords in .env must be right: the app users are reset through root
can_login() {
	dc exec -T -e MYSQL_PWD="$2" "$1" mysql -uroot -e "SELECT 1" >/dev/null 2>&1 ||
		{ echo "Can't log in to $1 as root with $3 from .env (wrong password, or the database is still starting)"; exit 1; }
}
can_login mysql "$MYSQL_ROOT_PASSWORD" MYSQL_ROOT_PASSWORD
can_login mariadb "$NEXTCLOUD_DB_ROOT_PASSWORD" NEXTCLOUD_DB_ROOT_PASSWORD

wp=$(gen); wp_root=$(gen); nc=$(gen); nc_root=$(gen)

echo "WordPress database (mysql)..."
sql mysql "$MYSQL_ROOT_PASSWORD" "
	ALTER USER '$WORDPRESS_DB_USER'@'%' IDENTIFIED BY '$wp';
	ALTER USER IF EXISTS 'root'@'%' IDENTIFIED BY '$wp_root';
	ALTER USER IF EXISTS 'root'@'localhost' IDENTIFIED BY '$wp_root';"
set_env WORDPRESS_DB_PASSWORD "$wp"
set_env MYSQL_ROOT_PASSWORD "$wp_root"
# From here on, whatever happens, recreate the containers so they use the new .env
trap 'echo "Recreating containers with the new .env..."; dc up -d' EXIT

echo "Nextcloud database (mariadb)..."
sql mariadb "$NEXTCLOUD_DB_ROOT_PASSWORD" "
	ALTER USER '$NEXTCLOUD_DB_USER'@'%' IDENTIFIED BY '$nc';
	ALTER USER IF EXISTS 'root'@'%' IDENTIFIED BY '$nc_root';
	ALTER USER IF EXISTS 'root'@'localhost' IDENTIFIED BY '$nc_root';"
set_env NEXTCLOUD_DB_PASSWORD "$nc"
set_env NEXTCLOUD_DB_ROOT_PASSWORD "$nc_root"
dc exec -T -u www-data nextcloud php occ config:system:set dbpassword --value="$nc"

echo "WordPress admin ($WORDPRESS_ADMIN_USER)..."
pass=$(gen)
wp user update "$WORDPRESS_ADMIN_USER" --user_pass="$pass" --skip-email
set_env WORDPRESS_ADMIN_PASSWORD "$pass"
wp user session destroy "$WORDPRESS_ADMIN_USER" --all

echo "Nextcloud admin ($NEXTCLOUD_ADMIN_USER)..."
pass=$(gen)
dc exec -T -u www-data -e OC_PASS="$pass" nextcloud php occ user:resetpassword --password-from-env "$NEXTCLOUD_ADMIN_USER"
set_env NEXTCLOUD_ADMIN_PASSWORD "$pass"

trap - EXIT
echo "Recreating containers with the new .env..."
dc up -d
echo "Done. The new passwords are in .env: keep a copy in your password manager and run 'sudo make save'."
