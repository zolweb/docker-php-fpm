#!/bin/sh -e

php_logs() {
	conf_file="/usr/local/etc/php-fpm.d/www.conf"

	log_dir="/var/log/php"
	access_log_file="${log_dir}/access.log"
	error_log_file="${log_dir}/error.log"

	mkdir -p "${log_dir}" \
		&& touch "${access_log_file}" \
		&& touch "${error_log_file}"

	if [ -n "$UID" ] && [ -n "$GID" ]; then
		chown -R "$UID:$GID" "${log_dir}"
	fi

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

	if [ -n "$UID" ] && [ -n "$GID" ]; then
		# To avoid permissions issues, create directly the /var/www/html/var directory and give it to $UID:$GID

		mkdir -p "${var_dir}"
		chown -R "$UID:$GID ${var_dir}"
	fi
}

php_logs
symfony_logs

exec "$@"
