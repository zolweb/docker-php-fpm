#!/bin/sh -e

php_logs() {
	conf_file="/usr/local/etc/php-fpm.d/www.conf"

	log_dir="/var/log/php"
	access_log_file="${log_dir}/access.log"
	error_log_file="${log_dir}/error.log"

	mkdir -p "${log_dir}" \
		&& touch "${access_log_file}" \
		&& touch "${error_log_file}"

	chown -R www-data "${log_dir}"

	# The "c" supplementary letter is needed because the first letter will be cut at replacement.
	sed -i \
		-e '/^;catch_workers_output/ccatch_workers_output = yes' \
		-e '/^;log_level/clog_level = debug' \
		-e '/^;listen/clisten = 9000' \
		-e '/^;access.log/caccess.log = /var/log/php/access.log' \
		-e '/^;php_flag\[display_errors\]/cphp_flag[display_errors] = off' \
		-e '/^;php_admin_value\[error_log\]/cphp_admin_value[error_log] = /var/log/php/error.log' \
		-e '/^;php_admin_flag\[log_errors\]/cphp_admin_flag[log_errors] = on' \
		-e '/^;clear_env/cclear_env = no' \
		"${conf_file}"
}

symfony_logs() {
	html_dir="/var/www/html"
	var_dir="${html_dir}/var"

	mkdir -p "${var_dir}"
	chown -R www-data "${var_dir}"
}

php_logs
symfony_logs

exec "$@"
