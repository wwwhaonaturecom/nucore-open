#!/bin/bash
# Generate test database.yml file on circle ci

# get db_random
DB_RANDOM=`cat ~/.db_random`
rm ~/.db_random

# Delete User

sqlplus "$DB_USER/$DB_PASSWORD@$DB_NAME" <<EOF
DROP USER $DB_RANDOM CASCADE;
EXIT
EOF