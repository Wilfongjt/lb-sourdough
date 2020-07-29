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


* issue: AUTHORIZED_USER is {"hint":null,"details":null,"code":"42501","message":"permission denied to set role \"guest_wgn\""}
  ???? added insert privileges to editor_wdn but now gives "Not valid base64url"
  try: remove any end of line characters

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
-- select :lb_guest_password;
-- select :postgres_jwt_secret ;
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

/*
-----------------
-- HOST variables
-----------------

-------------
-- JWT
--------------

ALTER DATABASE wdn_db SET "app.settings.jwt_secret" TO :postgres_jwt_secret;

-- doenst work ALTER DATABASE wdn_db SET "custom.authenticator_secret" TO 'mysecretpassword';
--------------
-- GUEST
--------------
-- ALTER DATABASE wdn_db SET "app.lb_woden" To :lb_woden;

ALTER DATABASE wdn_db SET "app.lb_guest_wgn" To '{"role":"guest_wgn"}';

ALTER DATABASE wdn_db SET "app.lb_editor_wdn" To '{"role":"editor_wdn"}';

-------------------
-- ROLES
-------------------
---- role password cannot be a variable...doesnt work
-------------------
-- These clauses determine whether a role is allowed to log in;
-- that is, whether the role can be given as the initial session authorization name during client connection.
-- A role having the LOGIN attribute can be thought of as a user.
-- Roles without this attribute are useful for managing database privileges, but are not users in the usual sense of the word.
-- If not specified, NOLOGIN is the default, except when CREATE ROLE is invoked through its alternative spelling CREATE USER.

-- IHERE
*/
CREATE ROLE authenticator noinherit login password :lb_guest_password ;

CREATE ROLE guest_wgn nologin noinherit; -- permissions to execute app() and insert type=owner into wdn_schema_1_0_0.register
CREATE ROLE editor_wdn nologin noinherit; -- permissions to execute app() and insert type=app into wdn_schema_1_0_0.register
CREATE ROLE process_logger_role nologin;

/*
--------------
-- SCHEMA
--------------
CREATE SCHEMA if not exists wdn_schema_1_0_0;
---------------
-- SCHEMA Permissions
---------------
grant usage on schema wdn_schema_1_0_0 to guest_wgn;
grant usage on schema wdn_schema_1_0_0 to editor_wdn;
grant usage on schema wdn_schema_1_0_0 to process_logger_role;

---------------
-- SCHEMA: set
---------------

SET search_path TO wdn_schema_1_0_0, public;

----------------
-- TYPE: JWT_TOKEN
----------------
CREATE TYPE wdn_schema_1_0_0.woden_token AS (
  woden text
);
CREATE TYPE wdn_schema_1_0_0.jwt_token AS (
  token text
);

--------------
-- TABLE: wdn_schema_1_0_0.register
--------------

create table if not exists
    wdn_schema_1_0_0.register (
        reg_id TEXT PRIMARY KEY DEFAULT uuid_generate_v4 (),
        reg_type varchar(256) not null check (length(reg_type) < 256),
        reg_form jsonb not null,
        reg_active BOOLEAN NOT NULL DEFAULT true,
        reg_created timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
        reg_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
    );
----------------
-- INDEX
-- * index automatically go in the parent table's schema
----------------
CREATE UNIQUE INDEX IF NOT EXISTS register_reg_id_pkey ON wdn_schema_1_0_0.register(reg_id);

grant insert on wdn_schema_1_0_0.register to guest_wgn; -- C
grant select on wdn_schema_1_0_0.register to guest_wgn; -- R, signin

grant insert on wdn_schema_1_0_0.register to editor_wdn; -- C
grant update on wdn_schema_1_0_0.register to editor_wdn; -- U
grant select on wdn_schema_1_0_0.register to editor_wdn; -- R

grant insert on wdn_schema_1_0_0.register to process_logger_role; -- C

----------------
-- FUNCTION: regi ster_upsert_trigger_func
----------------

CREATE OR REPLACE FUNCTION wdn_schema_1_0_0.register_upsert_trigger_func() RETURNS trigger
AS $$
Declare _token TEXT;
Declare _payload_claims JSON;
Declare _payload_claims_tmpl TEXT;
Declare _form JSONB;
Declare _pw TEXT;
BEGIN
    -- This trigger handles tokens for "app"
   -- create application token
   -- application specific login

    IF (TG_OP = 'INSERT') THEN
      IF (NEW.reg_form ->> 'type' = 'owner' or NEW.reg_form ->> 'type' = 'woden') then
        NEW.reg_id := NEW.reg_form ->> 'name';
        _form := format('{"id":"%s", "password":"%s"}'::TEXT, NEW.reg_form ->> 'name', crypt(NEW.reg_form ->> 'password', gen_salt('bf')) )::JSONB;

        NEW.reg_form := NEW.reg_form  || _form;
        -- encrypt password
      ELSEIF (NEW.reg_form ->> 'type' = 'app') then
        -- create guest token for use by new app, similar to woden

        _payload_claims := format('{"iss":"%s", "sub":"%s", "role":"%s", "name":"%s", "type":"%s"}'::TEXT,
                                  'LyttleBit',
                                  'application',
                                  'guest_wgn',
                                  NEW.reg_form ->> 'app-name',
                                  'owner'
                                  )::JSON;

        _token := sign( _payload_claims, current_setting('app.settings.jwt_secret')::TEXT,  'HS256'::TEXT);
        _form := format('{"token": "%s"}',_token)::JSONB;
        -- overide id, id should be <name>@<verson> after templating
        --  NEW.reg_id := NEW.reg_form ->> 'id';
        NEW.reg_id := NEW.reg_form ->> 'name';
        -- add token to form
        NEW.reg_form := NEW.reg_form || _form;
        -- encrypt password
        --NEW.reg_password := crypt(NEW.reg_password, gen_salt('bf'));
      --ELSEIF (NEW.reg_form ->> 'type' = 'owner') then

      END IF;

    ELSEIF (TG_OP = 'UPDATE') THEN

       NEW.reg_updated := CURRENT_TIMESTAMP;

    END IF;

    RETURN NEW;
END; $$ LANGUAGE plpgsql;

grant EXECUTE on FUNCTION wdn_schema_1_0_0.register_upsert_trigger_func to guest_wgn;
grant EXECUTE on FUNCTION wdn_schema_1_0_0.register_upsert_trigger_func to editor_wdn;

----------------
-- TRIGGER: reg_INS_UPD_TRIGGER
-- * the trigger inherits the schema of its table
----------------

CREATE TRIGGER register_ins_upd_trigger
 BEFORE INSERT ON wdn_schema_1_0_0.register
 FOR EACH ROW
 EXECUTE PROCEDURE wdn_schema_1_0_0.register_upsert_trigger_func();

grant TRIGGER on wdn_schema_1_0_0.register to guest_wgn;
grant TRIGGER on wdn_schema_1_0_0.register to editor_wdn;
 -----------------
 -- FUNCTION: http_response
 -----------------

 Create Or Replace FUNCTION wdn_schema_1_0_0.http_response(_status text, _msg text) RETURNS JSON AS $$
   SELECT
     row_to_json(r)
   FROM (
     SELECT
       _status as status,
       _msg as msg
   ) r;
 $$ LANGUAGE sql;

grant EXECUTE on FUNCTION wdn_schema_1_0_0.http_response(TEXT, TEXT) to guest_wgn; -- C
grant EXECUTE on FUNCTION wdn_schema_1_0_0.http_response(TEXT, TEXT) to editor_wdn; -- C

------------
-- FUNCTION: IS_VALID_TOKEN
-----------------

CREATE OR REPLACE FUNCTION wdn_schema_1_0_0.is_valid_token(_token TEXT, expected_role TEXT) RETURNS Boolean
AS $$

  DECLARE good Boolean;
  DECLARE actual_role TEXT;

BEGIN
  -- does role in token match expected role
  -- use db parameter app.settings.jwt_secret
  -- process the token
  -- return true/false
  good:=false;

  select payload ->> 'role' as role into actual_role  from verify(_token, current_setting('app.settings.jwt_secret'));

  if expected_role = actual_role then
    good := true;
  end if;

  RETURN good;
END;  $$ LANGUAGE plpgsql;

grant EXECUTE on FUNCTION wdn_schema_1_0_0.is_valid_token(TEXT, TEXT) to guest_wgn; -- C
grant EXECUTE on FUNCTION wdn_schema_1_0_0.is_valid_token(TEXT, TEXT) to editor_wdn; -- C

----------------
-- setup woden as user
----------------
insert into wdn_schema_1_0_0.register (reg_type, reg_form) values ('woden', (:lb_woden::JSONB || '{"type":"woden", "roles":"admin"}'::JSONB) );
*/
