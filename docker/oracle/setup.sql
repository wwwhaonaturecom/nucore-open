alter profile default limit password_life_time unlimited;

CREATE USER nucore_nu_development
    IDENTIFIED BY password
    DEFAULT TABLESPACE bc_nucore
    TEMPORARY TABLESPACE temp;

GRANT connect, resource TO nucore_nu_development;

CREATE USER nucore_nu_test
    IDENTIFIED BY password
    DEFAULT TABLESPACE bc_nucore
    TEMPORARY TABLESPACE temp;

GRANT connect, resource TO nucore_nu_test;

create tablespace BC_NUCORE
    DATAFILE 'bc_nucore.dat'
    SIZE 100M
    AUTOEXTEND ON;
