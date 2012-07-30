CREATE SEQUENCE "ACCOUNTS_SEQ"

/

CREATE SEQUENCE "ACCOUNT_USERS_SEQ"

/

CREATE SEQUENCE "AFFILIATES_SEQ"

/

CREATE SEQUENCE "BI_NETIDS_SEQ"

/

CREATE SEQUENCE "BUDGETED_CHART_STRINGS_SEQ"

/

CREATE SEQUENCE "BUNDLE_PRODUCTS_SEQ"

/

CREATE SEQUENCE "EXTERNAL_SERVICES_SEQ"

/

CREATE SEQUENCE "EXTERNAL_SERVICE_PASSERS_SEQ"

/

CREATE SEQUENCE "EXTERNAL_SERVICE_RECEIVERS_SEQ"

/

CREATE SEQUENCE "FACILITIES_SEQ"

/

CREATE SEQUENCE "FACILITY_ACCOUNTS_SEQ"

/

CREATE SEQUENCE "FILE_UPLOADS_SEQ"

/

CREATE SEQUENCE "INSTRUMENT_STATUSES_SEQ"

/

CREATE SEQUENCE "JOURNALS_SEQ"

/

CREATE SEQUENCE "JOURNAL_ROWS_SEQ"

/

CREATE SEQUENCE "NUCS_ACCOUNTS_SEQ"

/

CREATE SEQUENCE "NUCS_CHART_FIELD1S_SEQ"

/

CREATE SEQUENCE "NUCS_DEPARTMENTS_SEQ"

/

CREATE SEQUENCE "NUCS_FUNDS_SEQ"

/

CREATE SEQUENCE "NUCS_GL066S_SEQ"

/

CREATE SEQUENCE "NUCS_GRANTS_BUDGET_TREES_SEQ"

/

CREATE SEQUENCE "NUCS_PROGRAMS_SEQ"

/

CREATE SEQUENCE "NUCS_PROJECT_ACTIVITIES_SEQ"

/

CREATE SEQUENCE "ORDERS_SEQ"

/

CREATE SEQUENCE "ORDER_DETAILS_SEQ"

/

CREATE SEQUENCE "ORDER_STATUSES_SEQ"

/

CREATE SEQUENCE "PRICE_GROUPS_SEQ"

/

CREATE SEQUENCE "PRICE_GROUP_MEMBERS_SEQ"

/

CREATE SEQUENCE "PRICE_GROUP_PRODUCTS_SEQ"

/

CREATE SEQUENCE "PRICE_POLICIES_SEQ"

/

CREATE SEQUENCE "PRODUCTS_SEQ"

/

CREATE SEQUENCE "PRODUCT_ACCESSORIES_SEQ"

/

CREATE SEQUENCE "PRODUCT_ACCESS_GROUPS_SEQ"

/

CREATE SEQUENCE "PRODUCT_USERS_SEQ"

/

CREATE SEQUENCE "RELAYS_SEQ"

/

CREATE SEQUENCE "RESERVATIONS_SEQ"

/

CREATE SEQUENCE "SCHEDULE_RULES_SEQ"

/

CREATE SEQUENCE "STATEMENTS_SEQ"

/

CREATE SEQUENCE "STATEMENT_ROWS_SEQ"

/

CREATE SEQUENCE "USERS_SEQ"

/

CREATE SEQUENCE "USER_ROLES_SEQ"

/

CREATE SEQUENCE "VERSIONS_SEQ"

/

CREATE TABLE "ACCOUNTS" (
"ID" NUMBER(38,0) NOT NULL,
 "TYPE" VARCHAR2(50) NOT NULL,
 "ACCOUNT_NUMBER" VARCHAR2(50) NOT NULL,
 "DESCRIPTION" VARCHAR2(50) NOT NULL,
 "EXPIRES_AT" DATE NOT NULL,
 "NAME_ON_CARD" VARCHAR2(200),
 "EXPIRATION_MONTH" NUMBER(38,0),
 "EXPIRATION_YEAR" NUMBER(38,0),
 "CREATED_AT" DATE NOT NULL,
 "CREATED_BY" NUMBER(38,0) NOT NULL,
 "UPDATED_AT" DATE,
 "UPDATED_BY" NUMBER(38,0),
 "SUSPENDED_AT" DATE,
 "REMITTANCE_INFORMATION" CLOB,
 "FACILITY_ID" NUMBER(38,0),
 "AFFILIATE_ID" NUMBER(38,0),
 "AFFILIATE_OTHER" VARCHAR2(255),
 CONSTRAINT SYS_C00254031 PRIMARY KEY (ID)
)

/

CREATE  INDEX "INDEX_ACCOUNTS_ON_AFFILIATE_ID" ON "ACCOUNTS" ("AFFILIATE_ID")

/

CREATE TABLE "ACCOUNT_USERS" (
"ID" NUMBER(38,0) NOT NULL,
 "ACCOUNT_ID" NUMBER(38,0) NOT NULL,
 "USER_ID" NUMBER(38,0) NOT NULL,
 "USER_ROLE" VARCHAR2(50) NOT NULL,
 "CREATED_AT" DATE NOT NULL,
 "CREATED_BY" NUMBER(38,0) NOT NULL,
 "DELETED_AT" DATE,
 "DELETED_BY" NUMBER(38,0),
 CONSTRAINT SYS_C00254038 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "AFFILIATES" (
"ID" NUMBER(38,0) NOT NULL,
 "NAME" VARCHAR2(255),
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 CONSTRAINT SYS_C00254040 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "BI_NETIDS" (
"ID" NUMBER(38,0) NOT NULL,
 "NETID" VARCHAR2(255) NOT NULL,
 "FACILITY_ID" NUMBER(38,0) NOT NULL,
 CONSTRAINT SYS_C00254044 PRIMARY KEY (ID)
)

/

CREATE  INDEX "INDEX_BI_NETIDS_ON_FACILITY_ID" ON "BI_NETIDS" ("FACILITY_ID")

/

CREATE  INDEX "INDEX_BI_NETIDS_ON_NETID" ON "BI_NETIDS" ("NETID")

/

CREATE TABLE "BUDGETED_CHART_STRINGS" (
"ID" NUMBER(38,0) NOT NULL,
 "FUND" VARCHAR2(20) NOT NULL,
 "DEPT" VARCHAR2(20) NOT NULL,
 "PROJECT" VARCHAR2(20),
 "ACTIVITY" VARCHAR2(20),
 "ACCOUNT" VARCHAR2(20),
 "STARTS_AT" DATE NOT NULL,
 "EXPIRES_AT" DATE NOT NULL,
 CONSTRAINT SYS_C00254050 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "BUNDLE_PRODUCTS" (
"ID" NUMBER(38,0) NOT NULL,
 "BUNDLE_PRODUCT_ID" NUMBER(38,0) NOT NULL,
 "PRODUCT_ID" NUMBER(38,0) NOT NULL,
 "QUANTITY" NUMBER(38,0) NOT NULL,
 CONSTRAINT SYS_C00254055 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "EXTERNAL_SERVICES" (
"ID" NUMBER(38,0) NOT NULL,
 "TYPE" VARCHAR2(255),
 "LOCATION" VARCHAR2(255),
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 CONSTRAINT SYS_C00254057 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "EXTERNAL_SERVICE_PASSERS" (
"ID" NUMBER(38,0) NOT NULL,
 "EXTERNAL_SERVICE_ID" NUMBER(38,0),
 "PASSER_ID" NUMBER(38,0),
 "PASSER_TYPE" VARCHAR2(255),
 "ACTIVE" NUMBER(1,0) DEFAULT 0,
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 CONSTRAINT SYS_C00254059 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "EXTERNAL_SERVICE_RECEIVERS" (
"ID" NUMBER(38,0) NOT NULL,
 "EXTERNAL_SERVICE_ID" NUMBER(38,0),
 "RECEIVER_ID" NUMBER(38,0),
 "RECEIVER_TYPE" VARCHAR2(255),
 "RESPONSE_DATA" VARCHAR2(255),
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 CONSTRAINT SYS_C00254061 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "FACILITIES" (
"ID" NUMBER(38,0) NOT NULL,
 "NAME" VARCHAR2(200) NOT NULL,
 "ABBREVIATION" VARCHAR2(50) NOT NULL,
 "URL_NAME" VARCHAR2(50) NOT NULL,
 "IS_ACTIVE" NUMBER(1,0) NOT NULL,
 "CREATED_AT" DATE NOT NULL,
 "UPDATED_AT" DATE NOT NULL,
 "DESCRIPTION" CLOB,
 "ACCEPTS_CC" NUMBER(1,0) DEFAULT 1,
 "ACCEPTS_PO" NUMBER(1,0) DEFAULT 1,
 "SHORT_DESCRIPTION" CLOB NOT NULL,
 "ADDRESS" CLOB,
 "PHONE_NUMBER" VARCHAR2(255),
 "FAX_NUMBER" VARCHAR2(255),
 "EMAIL" VARCHAR2(255),
 "JOURNAL_MASK" VARCHAR2(50) NOT NULL,
 "ACCEPTS_MULTI_ADD" NUMBER(1,0) DEFAULT 0  NOT NULL,
 CONSTRAINT SYS_C00254072 PRIMARY KEY (ID)
)

/

CREATE UNIQUE INDEX "SYS_C008531" ON "FACILITIES" ("NAME")

/

CREATE UNIQUE INDEX "SYS_C008532" ON "FACILITIES" ("ABBREVIATION")

/

CREATE UNIQUE INDEX "SYS_C008533" ON "FACILITIES" ("URL_NAME")

/

CREATE TABLE "FACILITY_ACCOUNTS" (
"ID" NUMBER(38,0) NOT NULL,
 "FACILITY_ID" NUMBER(38,0) NOT NULL,
 "ACCOUNT_NUMBER" VARCHAR2(50) NOT NULL,
 "IS_ACTIVE" NUMBER(1,0) NOT NULL,
 "CREATED_BY" NUMBER(38,0) NOT NULL,
 "CREATED_AT" DATE NOT NULL,
 "REVENUE_ACCOUNT" NUMBER(38,0) NOT NULL,
 CONSTRAINT SYS_C00254080 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "FILE_UPLOADS" (
"ID" NUMBER(38,0) NOT NULL,
 "ORDER_DETAIL_ID" NUMBER(38,0),
 "PRODUCT_ID" NUMBER(38,0),
 "NAME" VARCHAR2(200) NOT NULL,
 "FILE_TYPE" VARCHAR2(50) NOT NULL,
 "CREATED_BY" NUMBER(38,0) NOT NULL,
 "CREATED_AT" DATE NOT NULL,
 "FILE_FILE_NAME" VARCHAR2(255),
 "FILE_CONTENT_TYPE" VARCHAR2(255),
 "FILE_FILE_SIZE" NUMBER(38,0),
 "FILE_UPDATED_AT" DATE,
 CONSTRAINT SYS_C00254086 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "INSTRUMENT_STATUSES" (
"ID" NUMBER(38,0) NOT NULL,
 "INSTRUMENT_ID" NUMBER(38,0) NOT NULL,
 "IS_ON" NUMBER(1,0) NOT NULL,
 "CREATED_AT" DATE NOT NULL,
 CONSTRAINT SYS_C00254091 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "JOURNALS" (
"ID" NUMBER(38,0) NOT NULL,
 "FACILITY_ID" NUMBER(38,0),
 "REFERENCE" VARCHAR2(50),
 "DESCRIPTION" VARCHAR2(200),
 "IS_SUCCESSFUL" NUMBER(1,0),
 "CREATED_BY" NUMBER(38,0) NOT NULL,
 "CREATED_AT" DATE NOT NULL,
 "UPDATED_BY" NUMBER(38,0),
 "UPDATED_AT" DATE,
 "FILE_FILE_NAME" VARCHAR2(255),
 "FILE_CONTENT_TYPE" VARCHAR2(255),
 "FILE_FILE_SIZE" NUMBER(38,0),
 "FILE_UPDATED_AT" DATE,
 "JOURNAL_DATE" DATE NOT NULL,
 CONSTRAINT SYS_C00254096 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "JOURNAL_ROWS" (
"ID" NUMBER(38,0) NOT NULL,
 "JOURNAL_ID" NUMBER(38,0) NOT NULL,
 "ORDER_DETAIL_ID" NUMBER(38,0),
 "AMOUNT" NUMBER(9,2) NOT NULL,
 "DESCRIPTION" VARCHAR2(200),
 "REFERENCE" VARCHAR2(50),
 "FUND" VARCHAR2(3) NOT NULL,
 "DEPT" VARCHAR2(7) NOT NULL,
 "PROJECT" VARCHAR2(8),
 "ACTIVITY" VARCHAR2(2),
 "PROGRAM" VARCHAR2(4),
 "ACCOUNT" VARCHAR2(5) NOT NULL,
 CONSTRAINT SYS_C00254103 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "NUCS_ACCOUNTS" (
"ID" NUMBER(38,0) NOT NULL,
 "VALUE" VARCHAR2(16) NOT NULL,
 "AUXILIARY" VARCHAR2(512),
 CONSTRAINT SYS_C00254106 PRIMARY KEY (ID)
)

/

CREATE  INDEX "INDEX_NUCS_ACCOUNTS_ON_VALUE" ON "NUCS_ACCOUNTS" ("VALUE")

/

CREATE TABLE "NUCS_CHART_FIELD1S" (
"ID" NUMBER(38,0) NOT NULL,
 "VALUE" VARCHAR2(16) NOT NULL,
 "AUXILIARY" VARCHAR2(512),
 CONSTRAINT SYS_C00254109 PRIMARY KEY (ID)
)

/

CREATE  INDEX "I_NUCS_CHART_FIELD1S_VALUE" ON "NUCS_CHART_FIELD1S" ("VALUE")

/

CREATE TABLE "NUCS_DEPARTMENTS" (
"ID" NUMBER(38,0) NOT NULL,
 "VALUE" VARCHAR2(16) NOT NULL,
 "AUXILIARY" VARCHAR2(512),
 CONSTRAINT SYS_C00254112 PRIMARY KEY (ID)
)

/

CREATE  INDEX "I_NUCS_DEPARTMENTS_VALUE" ON "NUCS_DEPARTMENTS" ("VALUE")

/

CREATE TABLE "NUCS_FUNDS" (
"ID" NUMBER(38,0) NOT NULL,
 "VALUE" VARCHAR2(8) NOT NULL,
 "AUXILIARY" VARCHAR2(512),
 CONSTRAINT SYS_C00254115 PRIMARY KEY (ID)
)

/

CREATE  INDEX "INDEX_NUCS_FUNDS_ON_VALUE" ON "NUCS_FUNDS" ("VALUE")

/

CREATE TABLE "NUCS_GL066S" (
"ID" NUMBER(38,0) NOT NULL,
 "BUDGET_PERIOD" VARCHAR2(8) NOT NULL,
 "FUND" VARCHAR2(8) NOT NULL,
 "DEPARTMENT" VARCHAR2(16) NOT NULL,
 "PROJECT" VARCHAR2(16) NOT NULL,
 "ACTIVITY" VARCHAR2(16) NOT NULL,
 "ACCOUNT" VARCHAR2(16) NOT NULL,
 "STARTS_AT" DATE,
 "EXPIRES_AT" DATE,
 CONSTRAINT SYS_C00254123 PRIMARY KEY (ID)
)

/

CREATE  INDEX "INDEX_NUCS_GL066S_ON_ACCOUNT" ON "NUCS_GL066S" ("ACCOUNT")

/

CREATE  INDEX "INDEX_NUCS_GL066S_ON_ACTIVITY" ON "NUCS_GL066S" ("ACTIVITY")

/

CREATE  INDEX "INDEX_NUCS_GL066S_ON_FUND" ON "NUCS_GL066S" ("FUND")

/

CREATE  INDEX "INDEX_NUCS_GL066S_ON_PROJECT" ON "NUCS_GL066S" ("PROJECT")

/

CREATE  INDEX "I_NUCS_GL066S_DEPARTMENT" ON "NUCS_GL066S" ("DEPARTMENT")

/

CREATE TABLE "NUCS_GRANTS_BUDGET_TREES" (
"ID" NUMBER(38,0) NOT NULL,
 "ACCOUNT" VARCHAR2(16) NOT NULL,
 "ACCOUNT_DESC" VARCHAR2(32) NOT NULL,
 "ROLL_UP_NODE" VARCHAR2(32) NOT NULL,
 "ROLL_UP_NODE_DESC" VARCHAR2(32) NOT NULL,
 "PARENT_NODE" VARCHAR2(32) NOT NULL,
 "PARENT_NODE_DESC" VARCHAR2(32) NOT NULL,
 "ACCOUNT_EFFECTIVE_AT" DATE NOT NULL,
 "TREE" VARCHAR2(32) NOT NULL,
 "TREE_EFFECTIVE_AT" DATE NOT NULL,
 CONSTRAINT SYS_C00254134 PRIMARY KEY (ID)
)

/

CREATE  INDEX "I_NUC_GRA_BUD_TRE_ACC" ON "NUCS_GRANTS_BUDGET_TREES" ("ACCOUNT")

/

CREATE TABLE "NUCS_PROGRAMS" (
"ID" NUMBER(38,0) NOT NULL,
 "VALUE" VARCHAR2(8) NOT NULL,
 "AUXILIARY" VARCHAR2(512),
 CONSTRAINT SYS_C00254137 PRIMARY KEY (ID)
)

/

CREATE  INDEX "INDEX_NUCS_PROGRAMS_ON_VALUE" ON "NUCS_PROGRAMS" ("VALUE")

/

CREATE TABLE "NUCS_PROJECT_ACTIVITIES" (
"ID" NUMBER(38,0) NOT NULL,
 "PROJECT" VARCHAR2(16) NOT NULL,
 "ACTIVITY" VARCHAR2(16) NOT NULL,
 "AUXILIARY" VARCHAR2(512),
 CONSTRAINT SYS_C00254141 PRIMARY KEY (ID)
)

/

CREATE  INDEX "I_NUC_PRO_ACT_ACT" ON "NUCS_PROJECT_ACTIVITIES" ("ACTIVITY")

/

CREATE  INDEX "I_NUC_PRO_ACT_PRO" ON "NUCS_PROJECT_ACTIVITIES" ("PROJECT")

/

CREATE TABLE "ORDERS" (
"ID" NUMBER(38,0) NOT NULL,
 "ACCOUNT_ID" NUMBER(38,0),
 "USER_ID" NUMBER(38,0) NOT NULL,
 "CREATED_BY" NUMBER(38,0) NOT NULL,
 "CREATED_AT" DATE NOT NULL,
 "UPDATED_AT" DATE NOT NULL,
 "ORDERED_AT" DATE,
 "FACILITY_ID" NUMBER(38,0),
 "STATE" VARCHAR2(50),
 CONSTRAINT SYS_C00254147 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "ORDER_DETAILS" (
"ID" NUMBER(38,0) NOT NULL,
 "ORDER_ID" NUMBER(38,0) NOT NULL,
 "PRODUCT_ID" NUMBER(38,0) NOT NULL,
 "QUANTITY" NUMBER(38,0) NOT NULL,
 "PRICE_POLICY_ID" NUMBER(38,0),
 "ACTUAL_COST" NUMBER(10,2),
 "ACTUAL_SUBSIDY" NUMBER(10,2),
 "ASSIGNED_USER_ID" NUMBER(38,0),
 "ESTIMATED_COST" NUMBER(10,2),
 "ESTIMATED_SUBSIDY" NUMBER(10,2),
 "ACCOUNT_ID" NUMBER(38,0),
 "DISPUTE_AT" DATE,
 "DISPUTE_REASON" VARCHAR2(200),
 "DISPUTE_RESOLVED_AT" DATE,
 "DISPUTE_RESOLVED_REASON" VARCHAR2(200),
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 "ORDER_STATUS_ID" NUMBER(38,0) NOT NULL,
 "STATE" VARCHAR2(50),
 "RESPONSE_SET_ID" NUMBER(38,0),
 "GROUP_ID" NUMBER(38,0),
 "BUNDLE_PRODUCT_ID" NUMBER(38,0),
 "NOTE" VARCHAR2(100),
 "FULFILLED_AT" DATE,
 "REVIEWED_AT" DATE,
 "STATEMENT_ID" NUMBER(38,0),
 "JOURNAL_ID" NUMBER(38,0),
 "RECONCILED_NOTE" VARCHAR2(255),
 CONSTRAINT SYS_C00254153 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "ORDER_STATUSES" (
"ID" NUMBER(38,0) NOT NULL,
 "NAME" VARCHAR2(50) NOT NULL,
 "FACILITY_ID" NUMBER(38,0),
 "PARENT_ID" NUMBER(38,0),
 "LFT" NUMBER(38,0),
 "RGT" NUMBER(38,0),
 CONSTRAINT SYS_C00254156 PRIMARY KEY (ID)
)

/

CREATE UNIQUE INDEX "SYS_C008542" ON "ORDER_STATUSES" ("FACILITY_ID", "PARENT_ID", "NAME")

/

CREATE TABLE "PRICE_GROUPS" (
"ID" NUMBER(38,0) NOT NULL,
 "FACILITY_ID" NUMBER(38,0),
 "NAME" VARCHAR2(50) NOT NULL,
 "DISPLAY_ORDER" NUMBER(38,0) NOT NULL,
 "IS_INTERNAL" NUMBER(1,0) NOT NULL,
 CONSTRAINT SYS_C00254161 PRIMARY KEY (ID)
)

/

CREATE UNIQUE INDEX "SYS_C008577" ON "PRICE_GROUPS" ("FACILITY_ID", "NAME")

/

CREATE TABLE "PRICE_GROUP_MEMBERS" (
"ID" NUMBER(38,0) NOT NULL,
 "TYPE" VARCHAR2(50) NOT NULL,
 "PRICE_GROUP_ID" NUMBER(38,0) NOT NULL,
 "USER_ID" NUMBER(38,0),
 "ACCOUNT_ID" NUMBER(38,0),
 CONSTRAINT SYS_C00254165 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "PRICE_GROUP_PRODUCTS" (
"ID" NUMBER(38,0) NOT NULL,
 "PRICE_GROUP_ID" NUMBER(38,0) NOT NULL,
 "PRODUCT_ID" NUMBER(38,0) NOT NULL,
 "RESERVATION_WINDOW" NUMBER(38,0),
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 CONSTRAINT SYS_C00254169 PRIMARY KEY (ID)
)

/

CREATE  INDEX "I_PRI_GRO_PRO_PRI_GRO_ID" ON "PRICE_GROUP_PRODUCTS" ("PRICE_GROUP_ID")

/

CREATE  INDEX "I_PRI_GRO_PRO_PRO_ID" ON "PRICE_GROUP_PRODUCTS" ("PRODUCT_ID")

/

CREATE TABLE "PRICE_POLICIES" (
"ID" NUMBER(38,0) NOT NULL,
 "TYPE" VARCHAR2(50) NOT NULL,
 "PRICE_GROUP_ID" NUMBER(38,0) NOT NULL,
 "START_DATE" DATE NOT NULL,
 "UNIT_COST" NUMBER(10,2),
 "UNIT_SUBSIDY" NUMBER(10,2),
 "USAGE_RATE" NUMBER(10,2),
 "USAGE_MINS" NUMBER(38,0),
 "RESERVATION_RATE" NUMBER(10,2),
 "RESERVATION_MINS" NUMBER(38,0),
 "OVERAGE_RATE" NUMBER(10,2),
 "OVERAGE_MINS" NUMBER(38,0),
 "MINIMUM_COST" NUMBER(10,2),
 "CANCELLATION_COST" NUMBER(10,2),
 "USAGE_SUBSIDY" NUMBER(10,2),
 "RESERVATION_SUBSIDY" NUMBER(10,2),
 "OVERAGE_SUBSIDY" NUMBER(10,2),
 "EXPIRE_DATE" DATE NOT NULL,
 "PRODUCT_ID" NUMBER(38,0),
 "CAN_PURCHASE" NUMBER(1,0) DEFAULT 0  NOT NULL,
 CONSTRAINT SYS_C00254176 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "PRODUCTS" (
"ID" NUMBER(38,0) NOT NULL,
 "TYPE" VARCHAR2(50) NOT NULL,
 "FACILITY_ID" NUMBER(38,0) NOT NULL,
 "NAME" VARCHAR2(200) NOT NULL,
 "URL_NAME" VARCHAR2(50) NOT NULL,
 "DESCRIPTION" CLOB,
 "REQUIRES_APPROVAL" NUMBER(1,0) NOT NULL,
 "INITIAL_ORDER_STATUS_ID" NUMBER(38,0),
 "IS_ARCHIVED" NUMBER(1,0) NOT NULL,
 "IS_HIDDEN" NUMBER(1,0) NOT NULL,
 "CREATED_AT" DATE NOT NULL,
 "UPDATED_AT" DATE NOT NULL,
 "MIN_RESERVE_MINS" NUMBER(38,0),
 "MAX_RESERVE_MINS" NUMBER(38,0),
 "MIN_CANCEL_HOURS" NUMBER(38,0),
 "FACILITY_ACCOUNT_ID" NUMBER(38,0),
 "ACCOUNT" VARCHAR2(5),
 "SHOW_DETAILS" NUMBER(1,0) DEFAULT 0  NOT NULL,
 "AUTO_CANCEL_MINS" NUMBER(38,0),
 CONSTRAINT SYS_C00254188 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "PRODUCT_ACCESSORIES" (
"ID" NUMBER(38,0) NOT NULL,
 "PRODUCT_ID" NUMBER(38,0) NOT NULL,
 "ACCESSORY_ID" NUMBER(38,0) NOT NULL,
 CONSTRAINT SYS_C00254192 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "PRODUCT_ACCESS_GROUPS" (
"ID" NUMBER(38,0) NOT NULL,
 "PRODUCT_ID" NUMBER(38,0) NOT NULL,
 "NAME" VARCHAR2(255),
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 CONSTRAINT SYS_C00254195 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "PRODUCT_ACCESS_SCHEDULE_RULES" (
"PRODUCT_ACCESS_GROUP_ID" NUMBER(38,0) NOT NULL,
 "SCHEDULE_RULE_ID" NUMBER(38,0) NOT NULL
)

/



/

CREATE TABLE "PRODUCT_USERS" (
"ID" NUMBER(38,0) NOT NULL,
 "PRODUCT_ID" NUMBER(38,0) NOT NULL,
 "USER_ID" NUMBER(38,0) NOT NULL,
 "APPROVED_BY" NUMBER(38,0) NOT NULL,
 "APPROVED_AT" DATE NOT NULL,
 "PRODUCT_ACCESS_GROUP_ID" NUMBER,
 CONSTRAINT SYS_C00254203 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "RELAYS" (
"ID" NUMBER(38,0) NOT NULL,
 "INSTRUMENT_ID" NUMBER(38,0),
 "IP" VARCHAR2(15),
 "PORT" NUMBER(38,0),
 "USERNAME" VARCHAR2(50),
 "PASSWORD" VARCHAR2(50),
 "AUTO_LOGOUT" NUMBER(1,0),
 "TYPE" VARCHAR2(255),
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 CONSTRAINT SYS_C00254205 PRIMARY KEY (ID)
)

/

CREATE  INDEX "INDEX_RELAYS_ON_INSTRUMENT_ID" ON "RELAYS" ("INSTRUMENT_ID")

/

CREATE TABLE "RESERVATIONS" (
"ID" NUMBER(38,0) NOT NULL,
 "ORDER_DETAIL_ID" NUMBER(38,0),
 "INSTRUMENT_ID" NUMBER(38,0) NOT NULL,
 "RESERVE_START_AT" DATE NOT NULL,
 "RESERVE_END_AT" DATE NOT NULL,
 "ACTUAL_START_AT" DATE,
 "ACTUAL_END_AT" DATE,
 "CANCELED_AT" DATE,
 "CANCELED_BY" NUMBER(38,0),
 "CANCELED_REASON" VARCHAR2(50),
 CONSTRAINT SYS_C00254210 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "SCHEDULE_RULES" (
"ID" NUMBER(38,0) NOT NULL,
 "INSTRUMENT_ID" NUMBER(38,0) NOT NULL,
 "DISCOUNT_PERCENT" NUMBER(10,2) DEFAULT 0.0  NOT NULL,
 "START_HOUR" NUMBER(38,0) NOT NULL,
 "START_MIN" NUMBER(38,0) NOT NULL,
 "END_HOUR" NUMBER(38,0) NOT NULL,
 "END_MIN" NUMBER(38,0) NOT NULL,
 "DURATION_MINS" NUMBER(38,0) NOT NULL,
 "ON_SUN" NUMBER(1,0) NOT NULL,
 "ON_MON" NUMBER(1,0) NOT NULL,
 "ON_TUE" NUMBER(1,0) NOT NULL,
 "ON_WED" NUMBER(1,0) NOT NULL,
 "ON_THU" NUMBER(1,0) NOT NULL,
 "ON_FRI" NUMBER(1,0) NOT NULL,
 "ON_SAT" NUMBER(1,0) NOT NULL,
 CONSTRAINT SYS_C00254226 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "SCHEMA_MIGRATIONS" (
"VERSION" VARCHAR2(255) NOT NULL
)

/

CREATE UNIQUE INDEX "UNIQUE_SCHEMA_MIGRATIONS" ON "SCHEMA_MIGRATIONS" ("VERSION")

/

CREATE TABLE "STATEMENTS" (
"ID" NUMBER(38,0) NOT NULL,
 "FACILITY_ID" NUMBER(38,0) NOT NULL,
 "CREATED_BY" NUMBER(38,0) NOT NULL,
 "CREATED_AT" DATE NOT NULL,
 "ACCOUNT_ID" NUMBER(38,0) NOT NULL,
 CONSTRAINT SYS_C00254233 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "STATEMENT_ROWS" (
"ID" NUMBER(38,0) NOT NULL,
 "STATEMENT_ID" NUMBER(38,0) NOT NULL,
 "ORDER_DETAIL_ID" NUMBER(38,0) NOT NULL,
 "AMOUNT" NUMBER(10,2) NOT NULL,
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 CONSTRAINT SYS_C00254238 PRIMARY KEY (ID)
)

/



/

CREATE TABLE "USERS" (
"ID" NUMBER(38,0) NOT NULL,
 "USERNAME" VARCHAR2(255) NOT NULL,
 "FIRST_NAME" VARCHAR2(255),
 "LAST_NAME" VARCHAR2(255),
 "EMAIL" VARCHAR2(255) DEFAULT ''  NOT NULL,
 "ENCRYPTED_PASSWORD" VARCHAR2(255) DEFAULT NULL ,
 "PASSWORD_SALT" VARCHAR2(255) DEFAULT NULL ,
 "SIGN_IN_COUNT" NUMBER(38,0) DEFAULT 0,
 "CURRENT_SIGN_IN_AT" DATE,
 "LAST_SIGN_IN_AT" DATE,
 "CURRENT_SIGN_IN_IP" VARCHAR2(255),
 "LAST_SIGN_IN_IP" VARCHAR2(255),
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 "RESET_PASSWORD_TOKEN" VARCHAR2(255),
 "RESET_PASSWORD_SENT_AT" DATE,
 "UID" NUMBER(38,0),
 CONSTRAINT SYS_C00254242 PRIMARY KEY (ID)
)

/

CREATE UNIQUE INDEX "INDEX_USERS_ON_EMAIL" ON "USERS" ("EMAIL")

/

CREATE  INDEX "INDEX_USERS_ON_UID" ON "USERS" ("UID")

/

CREATE UNIQUE INDEX "INDEX_USERS_ON_USERNAME" ON "USERS" ("USERNAME")

/

CREATE TABLE "USER_ROLES" (
"ID" NUMBER(38,0) NOT NULL,
 "USER_ID" NUMBER(38,0) NOT NULL,
 "FACILITY_ID" NUMBER(38,0),
 "ROLE" VARCHAR2(255) NOT NULL,
 CONSTRAINT SYS_C00254246 PRIMARY KEY (ID)
)

/

CREATE  INDEX "I_USE_ROL_USE_ID_FAC_ID_ROL" ON "USER_ROLES" ("USER_ID", "FACILITY_ID", "ROLE")

/

CREATE TABLE "VERSIONS" (
"ID" NUMBER(38,0) NOT NULL,
 "VERSIONED_ID" NUMBER(38,0),
 "VERSIONED_TYPE" VARCHAR2(255),
 "USER_ID" NUMBER(38,0),
 "USER_TYPE" VARCHAR2(255),
 "USER_NAME" VARCHAR2(255),
 "MODIFICATIONS" CLOB,
 "VERSION_NUMBER" NUMBER(38,0),
 "TAG" VARCHAR2(255),
 "CREATED_AT" DATE,
 "UPDATED_AT" DATE,
 "REASON_FOR_UPDATE" VARCHAR2(255),
 "REVERTED_FROM" NUMBER(38,0),
 "COMMIT_LABEL" VARCHAR2(255),
 CONSTRAINT SYS_C00254248 PRIMARY KEY (ID)
)

/

CREATE  INDEX "INDEX_VERSIONS_ON_COMMIT_LABEL" ON "VERSIONS" ("COMMIT_LABEL")

/

CREATE  INDEX "INDEX_VERSIONS_ON_CREATED_AT" ON "VERSIONS" ("CREATED_AT")

/

CREATE  INDEX "INDEX_VERSIONS_ON_NUMBER" ON "VERSIONS" ("VERSION_NUMBER")

/

CREATE  INDEX "INDEX_VERSIONS_ON_TAG" ON "VERSIONS" ("TAG")

/

CREATE  INDEX "INDEX_VERSIONS_ON_USER_NAME" ON "VERSIONS" ("USER_NAME")

/

CREATE  INDEX "I_VERSIONS_USER_ID_USER_TYPE" ON "VERSIONS" ("USER_ID", "USER_TYPE")

/

CREATE  INDEX "I_VER_VER_ID_VER_TYP" ON "VERSIONS" ("VERSIONED_ID", "VERSIONED_TYPE")

/

ALTER TABLE "ACCOUNTS" ADD CONSTRAINT "FK_ACCOUNT_FACILITY_ID" FOREIGN KEY ("FACILITY_ID") REFERENCES "FACILITIES"(id)

/

ALTER TABLE "ACCOUNT_USERS" ADD CONSTRAINT "FK_ACCOUNTS" FOREIGN KEY ("ACCOUNT_ID") REFERENCES "ACCOUNTS"(id)

/

ALTER TABLE "BI_NETIDS" ADD CONSTRAINT "SYS_C00254252" FOREIGN KEY ("FACILITY_ID") REFERENCES "FACILITIES"(id)

/

ALTER TABLE "BUNDLE_PRODUCTS" ADD CONSTRAINT "FK_BUNDLE_PROD_BUNDLE" FOREIGN KEY ("PRODUCT_ID") REFERENCES "PRODUCTS"(id)

/

ALTER TABLE "BUNDLE_PRODUCTS" ADD CONSTRAINT "FK_BUNDLE_PROD_PROD" FOREIGN KEY ("BUNDLE_PRODUCT_ID") REFERENCES "PRODUCTS"(id)

/

ALTER TABLE "FACILITY_ACCOUNTS" ADD CONSTRAINT "FK_FACILITIES" FOREIGN KEY ("FACILITY_ID") REFERENCES "FACILITIES"(id)

/

ALTER TABLE "FILE_UPLOADS" ADD CONSTRAINT "FK_FILES_OD" FOREIGN KEY ("ORDER_DETAIL_ID") REFERENCES "ORDER_DETAILS"(id)

/

ALTER TABLE "FILE_UPLOADS" ADD CONSTRAINT "FK_FILES_PRODUCT" FOREIGN KEY ("PRODUCT_ID") REFERENCES "PRODUCTS"(id)

/

ALTER TABLE "INSTRUMENT_STATUSES" ADD CONSTRAINT "FK_INT_STATS_PRODUCT" FOREIGN KEY ("INSTRUMENT_ID") REFERENCES "PRODUCTS"(id)

/

ALTER TABLE "ORDERS" ADD CONSTRAINT "ORDERS_FACILITY_ID_FK" FOREIGN KEY ("FACILITY_ID") REFERENCES "FACILITIES"(id)

/

ALTER TABLE "ORDERS" ADD CONSTRAINT "SYS_C008808" FOREIGN KEY ("ACCOUNT_ID") REFERENCES "ACCOUNTS"(id)

/

ALTER TABLE "ORDER_DETAILS" ADD CONSTRAINT "SYS_C009172" FOREIGN KEY ("ORDER_ID") REFERENCES "ORDERS"(id)

/

ALTER TABLE "ORDER_DETAILS" ADD CONSTRAINT "SYS_C009175" FOREIGN KEY ("PRICE_POLICY_ID") REFERENCES "PRICE_POLICIES"(id)

/

ALTER TABLE "ORDER_DETAILS" ADD CONSTRAINT "FK_BUNDLE_PROD_ID" FOREIGN KEY ("BUNDLE_PRODUCT_ID") REFERENCES "PRODUCTS"(id)

/

ALTER TABLE "ORDER_DETAILS" ADD CONSTRAINT "SYS_C009173" FOREIGN KEY ("PRODUCT_ID") REFERENCES "PRODUCTS"(id)

/

ALTER TABLE "ORDER_DETAILS" ADD CONSTRAINT "FK_OD_ACCOUNTS" FOREIGN KEY ("ACCOUNT_ID") REFERENCES "ACCOUNTS"(id)

/

ALTER TABLE "PRICE_GROUPS" ADD CONSTRAINT "SYS_C008578" FOREIGN KEY ("FACILITY_ID") REFERENCES "FACILITIES"(id)

/

ALTER TABLE "PRICE_GROUP_MEMBERS" ADD CONSTRAINT "SYS_C008583" FOREIGN KEY ("PRICE_GROUP_ID") REFERENCES "PRICE_GROUPS"(id)

/

ALTER TABLE "PRICE_POLICIES" ADD CONSTRAINT "SYS_C008589" FOREIGN KEY ("PRICE_GROUP_ID") REFERENCES "PRICE_GROUPS"(id)

/

ALTER TABLE "PRODUCTS" ADD CONSTRAINT "SYS_C008556" FOREIGN KEY ("FACILITY_ID") REFERENCES "FACILITIES"(id)

/

ALTER TABLE "PRODUCTS" ADD CONSTRAINT "FK_FACILITY_ACCOUNTS" FOREIGN KEY ("FACILITY_ACCOUNT_ID") REFERENCES "FACILITY_ACCOUNTS"(id)

/

ALTER TABLE "PRODUCT_USERS" ADD CONSTRAINT "FK_PRODUCTS" FOREIGN KEY ("PRODUCT_ID") REFERENCES "PRODUCTS"(id)

/

ALTER TABLE "RESERVATIONS" ADD CONSTRAINT "RES_ORD_DET_ID_FK" FOREIGN KEY ("ORDER_DETAIL_ID") REFERENCES "ORDER_DETAILS"(id)

/

ALTER TABLE "RESERVATIONS" ADD CONSTRAINT "RESERVATIONS_INSTRUMENT_ID_FK" FOREIGN KEY ("INSTRUMENT_ID") REFERENCES "PRODUCTS"(id)

/

ALTER TABLE "SCHEDULE_RULES" ADD CONSTRAINT "SYS_C008573" FOREIGN KEY ("INSTRUMENT_ID") REFERENCES "PRODUCTS"(id)

/

ALTER TABLE "STATEMENTS" ADD CONSTRAINT "FK_STATEMENT_FACILITIES" FOREIGN KEY ("FACILITY_ID") REFERENCES "FACILITIES"(id)

/

INSERT INTO schema_migrations (version) VALUES ('20100422215947')

/

INSERT INTO schema_migrations (version) VALUES ('20100423185710')

/

INSERT INTO schema_migrations (version) VALUES ('20100427192902')

/

INSERT INTO schema_migrations (version) VALUES ('20100427202835')

/

INSERT INTO schema_migrations (version) VALUES ('20100428152408')

/

INSERT INTO schema_migrations (version) VALUES ('20100430184238')

/

INSERT INTO schema_migrations (version) VALUES ('20100430222700')

/

INSERT INTO schema_migrations (version) VALUES ('20100506170137')

/

INSERT INTO schema_migrations (version) VALUES ('20100511164522')

/

INSERT INTO schema_migrations (version) VALUES ('20100512222847')

/

INSERT INTO schema_migrations (version) VALUES ('20100521172707')

/

INSERT INTO schema_migrations (version) VALUES ('20100524203345')

/

INSERT INTO schema_migrations (version) VALUES ('20100526190311')

/

INSERT INTO schema_migrations (version) VALUES ('20100527225704')

/

INSERT INTO schema_migrations (version) VALUES ('20100528190549')

/

INSERT INTO schema_migrations (version) VALUES ('20100528195301')

/

INSERT INTO schema_migrations (version) VALUES ('20100528201017')

/

INSERT INTO schema_migrations (version) VALUES ('20100528201316')

/

INSERT INTO schema_migrations (version) VALUES ('20100528203109')

/

INSERT INTO schema_migrations (version) VALUES ('20100528204023')

/

INSERT INTO schema_migrations (version) VALUES ('20100528212342')

/

INSERT INTO schema_migrations (version) VALUES ('20100528230042')

/

INSERT INTO schema_migrations (version) VALUES ('20100528230902')

/

INSERT INTO schema_migrations (version) VALUES ('20100604214008')

/

INSERT INTO schema_migrations (version) VALUES ('20100607194341')

/

INSERT INTO schema_migrations (version) VALUES ('20100607194817')

/

INSERT INTO schema_migrations (version) VALUES ('20100609205743')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182659')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182660')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182661')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182662')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182663')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182664')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182665')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182666')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182667')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182668')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182669')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182670')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182671')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182672')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182673')

/

INSERT INTO schema_migrations (version) VALUES ('20100615182674')

/

INSERT INTO schema_migrations (version) VALUES ('20100615183227')

/

INSERT INTO schema_migrations (version) VALUES ('20100616192941')

/

INSERT INTO schema_migrations (version) VALUES ('20100628183740')

/

INSERT INTO schema_migrations (version) VALUES ('20100628204300')

/

INSERT INTO schema_migrations (version) VALUES ('20100630233226')

/

INSERT INTO schema_migrations (version) VALUES ('20100701000551')

/

INSERT INTO schema_migrations (version) VALUES ('20100701183019')

/

INSERT INTO schema_migrations (version) VALUES ('20100701232820')

/

INSERT INTO schema_migrations (version) VALUES ('20100707185202')

/

INSERT INTO schema_migrations (version) VALUES ('20100707190304')

/

INSERT INTO schema_migrations (version) VALUES ('20100708000052')

/

INSERT INTO schema_migrations (version) VALUES ('20100708195447')

/

INSERT INTO schema_migrations (version) VALUES ('20100708221022')

/

INSERT INTO schema_migrations (version) VALUES ('20100712194630')

/

INSERT INTO schema_migrations (version) VALUES ('20100713171653')

/

INSERT INTO schema_migrations (version) VALUES ('20100713200332')

/

INSERT INTO schema_migrations (version) VALUES ('20100713224404')

/

INSERT INTO schema_migrations (version) VALUES ('20100714154110')

/

INSERT INTO schema_migrations (version) VALUES ('20100715171938')

/

INSERT INTO schema_migrations (version) VALUES ('20100715223533')

/

INSERT INTO schema_migrations (version) VALUES ('20100719192104')

/

INSERT INTO schema_migrations (version) VALUES ('20100721183524')

/

INSERT INTO schema_migrations (version) VALUES ('20100726171853')

/

INSERT INTO schema_migrations (version) VALUES ('20100727184318')

/

INSERT INTO schema_migrations (version) VALUES ('20100729174129')

/

INSERT INTO schema_migrations (version) VALUES ('20100804191731')

/

INSERT INTO schema_migrations (version) VALUES ('20100804225934')

/

INSERT INTO schema_migrations (version) VALUES ('20100805165201')

/

INSERT INTO schema_migrations (version) VALUES ('20100805175405')

/

INSERT INTO schema_migrations (version) VALUES ('20100806160008')

/

INSERT INTO schema_migrations (version) VALUES ('20100806161930')

/

INSERT INTO schema_migrations (version) VALUES ('20100812170701')

/

INSERT INTO schema_migrations (version) VALUES ('20100827204813')

/

INSERT INTO schema_migrations (version) VALUES ('20100908224462')

/

INSERT INTO schema_migrations (version) VALUES ('20100914171717')

/

INSERT INTO schema_migrations (version) VALUES ('20100916154915')

/

INSERT INTO schema_migrations (version) VALUES ('20100917145745')

/

INSERT INTO schema_migrations (version) VALUES ('20100930180831')

/

INSERT INTO schema_migrations (version) VALUES ('20101007204359')

/

INSERT INTO schema_migrations (version) VALUES ('20101007224415')

/

INSERT INTO schema_migrations (version) VALUES ('20101011172245')

/

INSERT INTO schema_migrations (version) VALUES ('20101011184759')

/

INSERT INTO schema_migrations (version) VALUES ('20101012164247')

/

INSERT INTO schema_migrations (version) VALUES ('20101012181426')

/

INSERT INTO schema_migrations (version) VALUES ('20101015210647')

/

INSERT INTO schema_migrations (version) VALUES ('20101015215418')

/

INSERT INTO schema_migrations (version) VALUES ('20101018192720')

/

INSERT INTO schema_migrations (version) VALUES ('20101018203424')

/

INSERT INTO schema_migrations (version) VALUES ('20101018221409')

/

INSERT INTO schema_migrations (version) VALUES ('20101019163858')

/

INSERT INTO schema_migrations (version) VALUES ('20101020162405')

/

INSERT INTO schema_migrations (version) VALUES ('20101027175630')

/

INSERT INTO schema_migrations (version) VALUES ('20110124175855')

/

INSERT INTO schema_migrations (version) VALUES ('20110125171722')

/

INSERT INTO schema_migrations (version) VALUES ('20110125200529')

/

INSERT INTO schema_migrations (version) VALUES ('20110125210146')

/

INSERT INTO schema_migrations (version) VALUES ('20110125211233')

/

INSERT INTO schema_migrations (version) VALUES ('20110125212209')

/

INSERT INTO schema_migrations (version) VALUES ('20110125221400')

/

INSERT INTO schema_migrations (version) VALUES ('20110126175835')

/

INSERT INTO schema_migrations (version) VALUES ('20110203223006')

/

INSERT INTO schema_migrations (version) VALUES ('20110208211613')

/

INSERT INTO schema_migrations (version) VALUES ('20110215200647')

/

INSERT INTO schema_migrations (version) VALUES ('20110216002247')

/

INSERT INTO schema_migrations (version) VALUES ('20110216164102')

/

INSERT INTO schema_migrations (version) VALUES ('20110216205725')

/

INSERT INTO schema_migrations (version) VALUES ('20110221225822')

/

INSERT INTO schema_migrations (version) VALUES ('20110224063354')

/

INSERT INTO schema_migrations (version) VALUES ('20110314201317')

/

INSERT INTO schema_migrations (version) VALUES ('20110403013939')

/

INSERT INTO schema_migrations (version) VALUES ('20110411215240')

/

INSERT INTO schema_migrations (version) VALUES ('20110412174924')

/

INSERT INTO schema_migrations (version) VALUES ('20110415224140')

/

INSERT INTO schema_migrations (version) VALUES ('20110425225944')

/

INSERT INTO schema_migrations (version) VALUES ('20110426221701')

/

INSERT INTO schema_migrations (version) VALUES ('20110428204626')

/

INSERT INTO schema_migrations (version) VALUES ('20110428204714')

/

INSERT INTO schema_migrations (version) VALUES ('20110428204720')

/

INSERT INTO schema_migrations (version) VALUES ('20110428204745')

/

INSERT INTO schema_migrations (version) VALUES ('20110428204746')

/

INSERT INTO schema_migrations (version) VALUES ('20110506191358')

/

INSERT INTO schema_migrations (version) VALUES ('20110507055026')

/

INSERT INTO schema_migrations (version) VALUES ('20110511180455')

/

INSERT INTO schema_migrations (version) VALUES ('20110608215021')

/

INSERT INTO schema_migrations (version) VALUES ('20110608222354')

/

INSERT INTO schema_migrations (version) VALUES ('20110608222406')

/

INSERT INTO schema_migrations (version) VALUES ('20110608222657')

/

INSERT INTO schema_migrations (version) VALUES ('20110627182814')

/

INSERT INTO schema_migrations (version) VALUES ('20110725210324')

/

INSERT INTO schema_migrations (version) VALUES ('20110729173029')

/

INSERT INTO schema_migrations (version) VALUES ('20110810225150')

/

INSERT INTO schema_migrations (version) VALUES ('20110810232349')

/

INSERT INTO schema_migrations (version) VALUES ('20111209185608')

/

INSERT INTO schema_migrations (version) VALUES ('20111219210901')

/

INSERT INTO schema_migrations (version) VALUES ('20111219213559')

/

INSERT INTO schema_migrations (version) VALUES ('20111219220830')

/

INSERT INTO schema_migrations (version) VALUES ('20111220164710')

/

INSERT INTO schema_migrations (version) VALUES ('20120117210956')

/

INSERT INTO schema_migrations (version) VALUES ('20120203185844')

/

INSERT INTO schema_migrations (version) VALUES ('20120209231652')

/

INSERT INTO schema_migrations (version) VALUES ('20120222161624')

/

INSERT INTO schema_migrations (version) VALUES ('20120420204254')

/

INSERT INTO schema_migrations (version) VALUES ('20120501184422')

/

INSERT INTO schema_migrations (version) VALUES ('20120502223446')

/

INSERT INTO schema_migrations (version) VALUES ('20120503203910')

/

INSERT INTO schema_migrations (version) VALUES ('20120510172358')

/

INSERT INTO schema_migrations (version) VALUES ('20120512014131')

/

INSERT INTO schema_migrations (version) VALUES ('20120620181642')

/

INSERT INTO schema_migrations (version) VALUES ('20120622185758')

/

