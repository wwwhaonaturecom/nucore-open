#!/bin/bash
# Generate test database.yml file on circle ci

# Generate user
sqlplus "system/oracle@localhost:1521/xe" <<EOF
GRANT CONNECT, RESOURCE TO nucore_nu_test IDENTIFIED BY password;
CREATE TABLESPACE BC_NUCORE DATAFILE 'bc_nucore.dat' SIZE 100M AUTOEXTEND ON;
ALTER USER nucore_nu_test DEFAULT TABLESPACE bc_nucore TEMPORARY TABLESPACE temp;
EXIT
EOF

