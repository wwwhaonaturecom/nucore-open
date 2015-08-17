#!/bin/bash
# Generate test database.yml file on circle ci

DB_RANDOM="ruby_$(openssl rand 4 | od -DAn | tr -d " ")"

# without sourcing file make variable available at delete
echo $DB_RANDOM > ~/.db_random

# Generarte user

sqlplus "$DB_USER/$DB_PASSWORD@$DB_NAME" <<EOF
GRANT CONNECT, RESOURCE TO $DB_RANDOM IDENTIFIED BY $DB_RANDOM;
ALTER USER $DB_RANDOM DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp;
EXIT
EOF

cat <<EOF > config/database.yml
test:
  adapter: oracle_enhanced
  database: '$DB_NAME'
  username: $DB_RANDOM
  password: $DB_RANDOM
  encoding: utf8
EOF
