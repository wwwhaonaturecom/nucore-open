#!/bin/bash
# Generate test database.yml file on circle ci

DB_USERNAME="circle_${CIRCLE_BUILD_NUM}_${CIRCLE_NODE_INDEX}"

# Delete User
sqlplus "$DB_USER/$DB_PASSWORD@$DB_NAME" <<EOF
DROP USER $DB_USERNAME CASCADE;
PURGE RECYCLEBIN;
EXIT
EOF
