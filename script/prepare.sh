#!/bin/sh -e

html_dir="/var/www/html"

www_folder() {
	mkdir -p "$1"
	chown -R www-data "$1"
}

www_file() {
	touch "$1"
	chown www-data "$1"
}

php_logs() {
	www_folder "/var/log/php"
	www_file "/var/log/php/access.log"
	www_file "/var/log/php/error.log"

	# The "c" supplementary letter is needed because the first letter will be cut
	# at replacement.
	sed -i \
		-e '/^;catch_workers_output/ccatch_workers_output = yes' \
		-e '/^;log_level/clog_level = debug' \
		-e '/^;listen/clisten = 9000' \
		-e '/^;access.log/caccess.log = /var/log/php/access.log' \
		-e '/^;php_flag\[display_errors\]/cphp_flag[display_errors] = off' \
		-e '/^;php_admin_value\[error_log\]/cphp_admin_value[error_log] = /var/log/php/error.log' \
		-e '/^;php_admin_flag\[log_errors\]/cphp_admin_flag[log_errors] = on' \
		-e '/^;clear_env/cclear_env = no' \
		"/usr/local/etc/php-fpm.d/www.conf"
}

symfony_logs() {
	www_folder "${html_dir}/var"
}

symfony_vendor() {
	www_folder "${html_dir}/vendor"
}

symfony_public() {
	www_folder "${html_dir}/public"
}

php_logs
symfony_logs
symfony_vendor
symfony_public

exec "$@"
