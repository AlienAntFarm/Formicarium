#!/bin/sh
set -e

db="hatchery"
user="hatchery"
passwd="some_password"

pg_ctl initdb 2> /dev/null
pg_ctl start -w
psql -v ON_ERROR_STOP=1 <<- EOSQL
	CREATE USER ${user} PASSWORD '${passwd}';
	CREATE DATABASE ${db};
	GRANT ALL PRIVILEGES ON DATABASE ${db} TO ${user};
EOSQL
pg_ctl stop -w

cat > "${PGDATA}/pg_hba.conf" <<- EOF
	host    all             all             0.0.0.0/0               md5
EOF

(
	umask 177
	cat > "${HOME}/.pgpass" <<- EOF
		*:*:${db}:${user}:${passwd}
	EOF
)
