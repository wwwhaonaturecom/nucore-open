#!/bin/bash
# Generate test database.yml file on circle ci

DB_USERNAME="circle_${CIRCLE_BUILD_NUM}_${CIRCLE_NODE_INDEX}"

# Generate user
sqlplus "$DB_USER/$DB_PASSWORD@$DB_NAME" <<EOF
GRANT CONNECT, RESOURCE TO $DB_USERNAME IDENTIFIED BY $DB_USERNAME;
ALTER USER $DB_USERNAME DEFAULT TABLESPACE bc_nucore TEMPORARY TABLESPACE temp;
EXIT
EOF

cat <<EOF > config/database.yml
test:
  adapter: oracle_enhanced
  database: '$DB_NAME'
  username: $DB_USERNAME
  password: $DB_USERNAME
  encoding: utf8
EOF
