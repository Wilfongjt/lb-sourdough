\c postgres

-- create db object
-- create role
-- create role permissions
-- create user
-- assign user to role
-- do something
-- drop db object
/*
_custom is {"role":"guest_wgn","type":"app"}
app_form is
user_form is
(api)              (Validation)   (TABLE)   (TRIGGER)       (FUNCTION)
woden()                                                     sign(_custom, current_setting('app.settings.jwt_secret')::TEXT,  'HS256'::TEXT)
app(app_form JSON) app_validate   register  register_trig   register_trig_func
user(user_form JSON)

*/
/*
* database
* table
* function
* user
* grant
*

* todo: use two functions (overload) for update and insert instead of single function
  ???? app(JSON) and app(TEXT, JSON)

* issue: permission denied to set role
  try: granting guest_wgn to postgres ... didnt work
  try: checking that environmen vars are not empty ... not empty
  Try: makeing an new starter-token
  Try: check jwt.io and remove any trailing eol in encoded
  something is missing, look in wdn.1.0.0 runs with wdn.1.0.0 added to startup
  Try: add grant guest_wgn to authenticator; ... that's it... this time

* issue: AUTHORIZED_USER is {"hint":null,"details":null,"code":"42501","message":"permission denied to set role \"guest_wgn\""}
  ???? added insert privileges to editor_wdn but now gives "Not valid base64url"
  try: remove any end of line characters from ???

* issue: {"message":"JWSError (JSONDecodeError \"Not valid base64url\")"}
  resolution: token contains extra characters. in this case the token is wrapped in double quotes, remove quotes before using Token


* issue: ERROR:  database "wdn_db" already exists
    resolution: DROP DATABASE IF EXISTS wdn_db;

* issue: "Server lacks JWT secret"
    resolution: (add PGRST_JWT_SECRET to Postrest part of docker-compose)

* issue: "JWSError JWSInvalidSignature"
    resoluton: make sure WODEN is set in client environment
    resolution: (check the docker-compose PGRST_JWT_SECRET password value, should be same as app.settings.jwt_secret value)
    resolution: (check that sign() is using the correct JWT_SECRET value)
    resolution: (replace the WODEN envirnement variable called by curl)
    resolution: POSTGRES_SCHEMA and PGRST_DB_SCHEMA should be the same
    resolution: remove image, docker rmi reg_db
    resolution: put quotes around the export WORDEN=""
    try: ?payoad in trigger has to match payload in woden function?
    try: set env variables out side of  client
    try: reboot

* issue: "hint":"No function matches the given name and argument types. You might need to add explicit type casts.","details":null,"code":"42883","message":"function app(type => text) does not exist"
    evaluation: looks like the JSONB type doesnt translate via curl. JSON object is passed as TEXT. Postgres doesnt have a method pattern that matches "app(TEXT)"
    resolution: didnt work ... rewrite app(JSONB) to app(TEXT), cast the text to JSONB once passed to function.
    evaluation: curl -d '{"mytype": "app","myval": "xxx"}' is interpeted as two text parameters rather than one JSON parameter
    resolution: add header ... -H "Prefer: params=single-object" to curl call
    read: http://postgrest.org/en/v7.0.0/

* issue:
    evaluation: sign method not matching parameters. passing JSONB when should be passing JSON
    resolution: update trigger to cast _form to _form::JSON for token creation

* issue:
    description: status:500 when insert on table with trigger
    evaluation: user must have TRIGGER  permissions on table
    evaluation: user must have EXECUTE permissions on trigger functions

* issue:
    unrecognized configuration parameter \"request.jwt.claim.type
    evaluation: the WODEN env variable isnt set
    resolution: export WODEN='paste a valid a token here'

* issue:
      description: FATAL:  password authentication failed for user "authenticator"
      evaluation: password changes seem to cause this
      try: removing the docker images...docker rmi wdn_db

* issue:
      schema \"reg_schema\" does not exist
      try: docker rmi wdn_db ... didnt work
      try: reboot... didnt work
      try: check docker-compose.yml, change POSTGRES_SCHEMA to match
      try: dropping postgres images
      try: setting the tolken value ... OK

extra code
      \set postgres_password `echo "'$POSTGRES_PASSWORD'"`
      \set postgres_jwt_secret `echo "'$POSTGRES_JWT_SECRET'"`
      \set lb_guest_password `echo "'$LB_GUEST_PASSWORD'"`

      select
        :postgres_password as postgres_password,
        :postgres_jwt_secret as postgres_jwt_secret,
        :lb_guest_password as lb_guest_password;
        --:pgrst_db_uri as pgrst_db_uri;
*/

--------------
-- Environment
--------------

\set postgres_jwt_secret `echo "'$POSTGRES_JWT_SECRET'"`
\set lb_guest_password `echo "'$LB_GUEST_PASSWORD'"`
\set lb_woden `echo "'$LB_WODEN'"`
select :lb_guest_password;
select :postgres_jwt_secret ;
select :lb_woden ;
--------------
-- DATABASE
--------------

DROP DATABASE IF EXISTS wdn_db;
CREATE DATABASE wdn_db;

---------------
-- Security, dont let users create anything in public
---------------
-- REVOKE CREATE ON SCHEMA public FROM PUBLIC;

\c wdn_db

-- CREATE SCHEMA if not exists wdn_schema_1_0_0;

CREATE EXTENSION IF NOT EXISTS pgcrypto;;
CREATE EXTENSION IF NOT EXISTS pgtap;;
CREATE EXTENSION IF NOT EXISTS pgjwt;;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Roles

CREATE ROLE authenticator noinherit login password :lb_guest_password ;

CREATE ROLE guest_wgn nologin noinherit; -- permissions to execute app() and insert type=owner into wdn_schema_1_0_0.register
CREATE ROLE editor_wdn nologin noinherit; -- permissions to execute app() and insert type=app into wdn_schema_1_0_0.register
CREATE ROLE process_logger_role nologin;

-- grant guest_wgn to postgres;
