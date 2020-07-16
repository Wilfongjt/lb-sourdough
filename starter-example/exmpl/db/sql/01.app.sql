\c postgres

-- create db object
-- create role
-- create role permissions
-- create user
-- assign user to role
-- do something
-- drop db object
/*
_custom is {"role":"api_guest","type":"app"}
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


* issue: ERROR:  database "application_db" already exists
    resolution: DROP DATABASE IF EXISTS application_db;

* issue: "Server lacks JWT secret"
    resolution: (add PGRST_JWT_SECRET to Postrest part of docker-compose)

* issue: "JWSError JWSInvalidSignature"
    resoluton: make sure WODEN is set in client environment
    resolution: (check the docker-compose PGRST_JWT_SECRET password value, should be same as app.settings.jwt_secret value)
    resolution: (check that sign() is using the correct JWT_SECRET value)
    resolution: (replace the WODEN envirnement variable called by curl)
    resolution: POSTGRES_SCHEMA and PGRST_DB_SCHEMA should be the same
    resolution: remove image, docker rmi exmpl_db
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
      try: removing the docker images...docker rmi application_db

* issue:
      schema \"exmpl_schema\" does not exist
      try: docker rmi application_db ... didnt work
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
--\set postgres_jwt_secret `echo "'$POSTGRES_JWT_SECRET'"`

--\set postgres_jwt_secret `echo "'$POSTGRES_JWT_SECRET'"`
--\set lb_guest_password `echo "'$LB_GUEST_PASSWORD'"`

--\set postgres_db `echo "$POSTGRES_DB"`;
--\set postgres_schema `echo "$POSTGRES_SCHEMA"`;
--select :lb_guest_password;
--select :postgres_jwt_secret ;
--------------
-- Environment
--------------

\set postgres_jwt_secret `echo "'$POSTGRES_JWT_SECRET'"`
\set lb_guest_password `echo "'$LB_GUEST_PASSWORD'"`

-- select :lb_guest_password;
-- select :postgres_jwt_secret ;
--------------
-- DATABASE
--------------

DROP DATABASE IF EXISTS application_db;
CREATE DATABASE application_db;

---------------
-- Security, dont let users create anything in public
---------------
-- REVOKE CREATE ON SCHEMA public FROM PUBLIC;

\c application_db

CREATE SCHEMA if not exists api_schema;

CREATE EXTENSION IF NOT EXISTS pgcrypto;;
CREATE EXTENSION IF NOT EXISTS pgtap;;
CREATE EXTENSION IF NOT EXISTS pgjwt;;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-----------------
-- HOST variables
-----------------

-------------
-- JWT
--------------
-- bad practice to put passwords in scripts
--ALTER DATABASE application_db SET "app.testdb" TO 'f';
--select :POSTGRES_JWT_SECRET;
--ALTER DATABASE application_db SET "app.settings.jwt_secret" TO :postgres_jwt_secret;
--ALTER DATABASE application_db SET 'app.settings.jwt_secret' TO :postgres_jwt_secret;
ALTER DATABASE application_db SET "app.settings.jwt_secret" TO :postgres_jwt_secret;
-- ALTER DATABASE application_db SET "jwt-secret" TO :postgres_jwt_secret;

-- select current_setting('app.settings.jwt_secret') as has_secret;
--select current_setting('jwt-secret') as has_secret;

--select current_setting('jwt_secret') as has_secret;


-- doenst work ALTER DATABASE application_db SET "custom.authenticator_secret" TO 'mysecretpassword';
--------------
-- GUEST
--------------
-- add new application
--
-- ALTER DATABASE application_db SET "app.lb_app_tmpl" TO '{"type":"%s",  "group":"%s",  "name":"%s@%s", "role": "%s_guest"}';
--ALTER DATABASE application_db SET "app.app_payload_claims" TO     '{"type":"app", "group":"api",     "app-name":"api",     "version":"1.0.0"}';

--ALTER DATABASE application_db SET "app.lb_app_data_api" TO     '{"type":"app", "group":"api",     "app-name":"api",     "version":"1.0.0"}';
--ALTER DATABASE application_db SET "app.lb_app_data_example" TO '{"type":"app", "group":"example", "app-name":"example", "version":"1.0.0"}';
ALTER DATABASE application_db SET "app.lb_api_guest" To '{"role":"api_guest"}';
-- ALTER DATABASE application_db SET "app.lb_application_form" TO '{"type": "app", "name": "my_app@1.0.0", "group":"example", "owner": "me@someplace.com", "password": "a1A!aaaa"}';
-- ALTER DATABASE application_db SET "app.lb_user_form" TO        '{"type": "user", "app": "my_app@1.0.0", "name": "me@someplace.com", "password": "a1A!aaaa", "roles": [""]}';
--'{"type":"","app_name":"","version":"","username":"","password":"","token":""}'
--'{"type":"user","app_id":"","username":"","password":"",}'
-- Add Application api_guest, insert application-form
-- Insert Application User,         <app-prefix>_guest
-- Authenticate Application User,   <app-prefix>_login
-- Update Application User,         <app-prefix>_user
--
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


CREATE ROLE authenticator noinherit login password :lb_guest_password ;

CREATE ROLE api_guest nologin; -- permissions to execute app() and insert type=app into register
-- each app gets its own _guest role  i.e., example_guest which is <group>_guest {"type":"user", "":""}
-- each app gets its own _user role   i.e., example_user which is <group>_user
--CREATE ROLE example_user nologin; -- permissions to execute user() and insert type=user into register
--CREATE ROLE app_guest nologin;
---------------
-- SCHEMA: api_schema
---------------

SET search_path TO api_schema, public;

----------------
-- TYPE: JWT_TOKEN
----------------
CREATE TYPE woden_token AS (
  woden text
);
CREATE TYPE jwt_token AS (
  token text
);
--CREATE TYPE jwt_token AS (
--  token text
--);
--------------
-- TABLE: REGISTER
--------------
-- Permissions: INSERT, UPDATE, and SELECT

create table if not exists
    register (
        exmpl_id TEXT PRIMARY KEY DEFAULT uuid_generate_v4 (),
        exmpl_type varchar(256) not null check (length(exmpl_type) < 256),
        exmpl_form jsonb not null,
        exmpl_password varchar(256) not null,
        exmpl_active BOOLEAN NOT NULL DEFAULT true,
        exmpl_created timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
        exmpl_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
    );

----------------
-- INDEX
----------------
CREATE UNIQUE INDEX IF NOT EXISTS register_exmpl_id_pkey ON register(exmpl_id);

----------------
-- FUNCTION: EXPML_UPSERT_TRIGGER_FUNC
----------------
-- Permissions: EXECUTE
-- Parameters: None
CREATE OR REPLACE FUNCTION register_upsert_trigger_func() RETURNS trigger
AS $$
Declare _token TEXT;
Declare _payload_claims JSON;
Declare _payload_claims_tmpl TEXT;
Declare _form JSONB;

BEGIN
    -- This trigger handles tokens for "app"
   -- create application token
   -- application specific login
   -- '{"type":"%s",  "group":"%s",  "name":"%s@%s", "role": "%s_guest"}';

    IF (TG_OP = 'INSERT') THEN
      IF (NEW.exmpl_form ->> 'type' = 'app') then
        -- create custom token for a new app
        --: iss (issuer), exp (expiration time), sub (subject)
        --_payload_claims_tmpl := '{"iss":"%s", "sub":"%s", "role":"%s", "name":"%s@%s"}'::TEXT;
        -- iss, sub, role, type, name
        -- create custom
        _payload_claims := format('{"iss":"%s", "sub":"%s", "role":"%s", "name":"%s", "type":"%s"}'::TEXT,
                                  'LyttleBit',
                                  'application',
                                  'app_guest',
                                  NEW.exmpl_form ->> 'app-name',
                                  'actor'
                                  )::JSON;

        _token := sign( _payload_claims, current_setting('app.settings.jwt_secret')::TEXT,  'HS256'::TEXT);
        _form := format('{"token": "%s"}',_token)::JSONB;
        -- overide id, id should be <name>@<verson> after templating
        NEW.exmpl_id := NEW.exmpl_form ->> 'name';
        -- add token to form
        NEW.exmpl_form := NEW.exmpl_form || _form;
        -- encrypt password
        NEW.exmpl_password := crypt(NEW.exmpl_password, gen_salt('bf'));
      --ELSEIF (NEW.exmpl_form ->> 'type' = 'actor') then

      END IF;

    ELSEIF (TG_OP = 'UPDATE') THEN

       NEW.exmpl_updated := CURRENT_TIMESTAMP;

    END IF;

    RETURN NEW;
END; $$ LANGUAGE plpgsql;
----------------
-- TRIGGER: EXMPL_INS_UPD_TRIGGER
----------------
-- Permissions: EXECUTE

CREATE TRIGGER register_ins_upd_trigger
 BEFORE INSERT ON register
 FOR EACH ROW
 EXECUTE PROCEDURE register_upsert_trigger_func();


-----------------
-- FUNCTION: WODEN
-----------------
-- access to insert new applications
-- function requires EXECUTE permissions
-- Parameters: No params
-- Returns: jwt-token
-- token doenst expire
-- iss, sub, role, type
-- iss, sub, role, type, name
-- || access    |
-- || app(JSON) |

CREATE FUNCTION woden() RETURNS woden_token AS $$
  -- make token to execute app(JSON)
  SELECT public.sign(
    row_to_json(r), current_setting('app.settings.jwt_secret')
  ) AS woden
  FROM (
    SELECT
      'LyttleBit' as iss,
      'Origin'::text as sub,
      'Woden'::text as name,
      'api_guest'::text as role,
      'app' as type
  ) r;
$$ LANGUAGE sql;

/*
CREATE FUNCTION woden() RETURNS woden_token AS $$

  SELECT public.sign(
    row_to_json(r), current_setting('app.settings.jwt_secret')
  ) AS woden
  FROM (
    SELECT
      'api_guest'::text as role,
      'app' as type
  ) r;
$$ LANGUAGE sql;
*/
-----------------
-- WODEN
-----------------
-- function requires EXECUTE permissions
-- Parameters: No params
-- Returns: jwt-token
-- token expires in 5 minutes
/*
CREATE FUNCTION woden() RETURNS jwt_token AS $$
  SELECT public.sign(
    row_to_json(r), current_setting('app.settings.jwt_secret')
  ) AS woden
  FROM (
    SELECT
      'api_guest'::TEXT as role,
      'app'::TEXT as type,
      extract(epoch from now())::integer + 300 AS exp
  ) r;
$$ LANGUAGE sql;
*/
-----------------
-- FUNCTION: BAD_TOKEN
-----------------
-- Permissions: EXECUTE
-- Returns: jwt_token
-- token doenst expire

CREATE FUNCTION bad_woden() RETURNS jwt_token AS $$
  SELECT public.sign(
    row_to_json(r), current_setting('app.settings.jwt_secret')
  ) AS woden
  FROM (
    SELECT
      'bad_role'::text as role,
      'bad_type' as type
  ) r;
$$ LANGUAGE sql;


------------
-- FUNCTION: IS_VALID_WODEN
-----------------
-- test if role is expected role
-- for internal use only
-- Permissions: EXECUTE
-- Returns: BOOLEAN
CREATE OR REPLACE FUNCTION is_valid_token(_token TEXT, expected_role TEXT) RETURNS Boolean
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

-----------------
-- FUNCTION: APP_VALIDATE
-----------------
-- Permissions: EXECUTE
-- Returns: BOOLEAN
CREATE OR REPLACE FUNCTION
app_validate(form JSONB) RETURNS JSONB
AS $$

  BEGIN


    -- confirm all required attributes are in form
    if not(form ? 'type' and form ? 'name' and form ? 'owner' and form ? 'password') then
       return '{"status":"400","msg":"Bad Request, missing one or more form attributes"}'::JSONB;
    end if;

    -- validate attribute values
    if not(form ->> 'type' = 'app') then
       return '{"status":"400", "msg":"Bad Request type value."}'::JSONB;
    end if;

    -- proper application name
    if not( exists( select regexp_matches(form ->> 'name', '^[a-z][a-z_]+@[1-9]+\.[0-9]+\.[0-9]+') ) ) then
       return '{"status":"400", "msg":"Bad Request, bad applicaton name."}'::JSONB;
    end if;

    -- proper password
    if not (exists(select regexp_matches(form ->> 'password', '^(?=.{8,}$)(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W).*$') )) then
       return '{"status":"400", "msg":"Bad Request, bad password."}'::JSONB;
    end if;

    -- proper owner name ... email
    if not( exists( select regexp_matches(form ->> 'owner', '[a-z\-_0-9]+@[a-z]+\.[a-z]+') ) ) then
       return format('{"status":"400", "msg":"Bad Request, bad owner name.", "owner":"%s"}', form ->> 'owner')::JSONB;
    end if;

    return '{"status": "200"}'::JSONB;
  END;
$$ LANGUAGE plpgsql;
-- FUNCTION
-----------------
-- FUNCTION: APP
-----------------
-- inserts an application record into the system
-- Permissions: EXECUTE
-- Returns: JSONB
-- Role: api_guest

CREATE OR REPLACE FUNCTION app(form JSON)
RETURNS JSONB AS $$
  Declare rc jsonb;
  Declare _model_user JSONB;
  Declare _form JSONB;
  Declare _jwt_role TEXT;
  Declare _jwt_type TEXT;
  Declare _validation JSONB;
  Declare _password TEXT;

  BEGIN

    -- get request values
    _jwt_role := current_setting('request.jwt.claim.role','t');
    _jwt_type := current_setting('request.jwt.claim.type','t');
    if _jwt_role is NULL or _jwt_type is NULL then
      _jwt_role := 'api_guest';
      _jwt_type := 'app';
    end if;

    _form := form::JSONB;
    -- evaluate the token
    _model_user := current_setting('app.lb_api_guest')::jsonb;

    if not(_model_user ->> 'role' = _jwt_role) then
        return '{"status": "401", "msg":"Unauthorized bad token"}'::JSONB;
    end if;

    _validation := app_validate(_form);
    if _validation ->> 'status' != '200' then
        return _validation;
    end if;

    if _form ? 'id' then
        return '{"status": "400", "msg": "Update not supported"}'::JSONB;
    end if;

    if _form ? 'password' then
        _password := _form ->> 'password';
        -- never store password in form
        _form := _form - 'password';
    end if;

    BEGIN
            INSERT INTO register
                (exmpl_type, exmpl_form, exmpl_password)
            VALUES
                (_jwt_type, _form, _password );
    EXCEPTION
        WHEN unique_violation THEN
            return '{"status":"400", "msg":"Bad Request, duplicate error"}'::JSONB;
        WHEN check_violation then
            return '{"status":"400", "msg":"Bad Request, validation error"}'::JSONB;
        WHEN others then
            return format('{"status":"500", "msg":"unknown insertion error", "SQLSTATE":"%s", "type":"%s", "password":"%s", "form":%s}',SQLSTATE, _jwt_type, _password, _form)::JSONB;
    END;

    -- rc := format('{"status": "200", "form": %s , "role":"%s", "type":"%s"}', _form::TEXT, _jwt_role, _type)::JSONB;

    rc := '{"msg": "OK", "status": "200"}'::JSONB;

    return rc;
  END;
$$ LANGUAGE plpgsql;
--------------------
-- FUNCTION: APP(TEXT)
--------------------
CREATE OR REPLACE FUNCTION
app(id TEXT) RETURNS JSONB
AS $$
  Select exmpl_form from register where exmpl_id=id;
$$ LANGUAGE sql;
----------------
-- GRANT: API_GUEST
----------------
-- Next make a role to use for anonymous web requests.
-- When a request comes in, PostgREST will switch into this role in the database to run queries.
--

grant usage on schema api_schema to api_guest;

grant select on register to api_guest;
grant insert on register to api_guest;
grant update on register to api_guest;
grant TRIGGER on register to api_guest;

grant EXECUTE on FUNCTION register_upsert_trigger_func to api_guest;

grant EXECUTE on FUNCTION app(JSON) to api_guest;
grant EXECUTE on FUNCTION app(TEXT) to api_guest;

grant EXECUTE on FUNCTION app_validate(JSONB) to api_guest;

grant EXECUTE on FUNCTION is_valid_token(TEXT,TEXT) to api_guest;




-- It’s a good practice to create a dedicated role for connecting to the database, instead of using the highly privileged postgres role.
-- So we’ll do that, name the role authenticator and also grant him the ability to switch to the api_guest role :
------------------
-- GRANT: AUTHENTICATOR
------------------
--create role authenticator noinherit login password 'mysecretpassword';
grant api_guest to authenticator;
-- grant usage on schema api_schema to authenticator;

-- Switching occures when the user is authenticated and the jWT token contains an existing role
-----------------
-- Show permissions
-----------------

/*
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema='api_schema';

select * from information_schema.routine_privileges
where specific_schema = 'api_schema';
*/
----------------
-- WODEN VALUES
----------------
--select woden() ;
--select current_setting('app.settings.jwt_secret') as jwt_secret;

--select format('export WODEN="%s"',replace(replace(woden()::TEXT,'(',''),')',''));
--select format('export WODEN="%s"',replace(replace(bad_woden()::TEXT,'(',''),')',''));


----------------
-- CURL
----------------
/*
Applications
'{"type": "app", "name": "my_app@1.0.0", "group":"my_app", "owner": "me@someplace.com", "password": "a1A!aaaa"}'
'{"type": "app", "name": "my_app@2.0.0", "group":"my_app", "owner": "me@someplace.com", "password": "a1A!aaaa"}'

Users
'{"type": "user", "apps": ["my_app@1.0.0"], "name": "me@someplace.com", "password": "a1A!aaaa"}'

Curl Samples

# sucess with round trip to server
--curl http://localhost:3100/rpc/round_trip -X POST \
--     -H "Authorization: Bearer $WODEN"   \
--     -H "Content-Type: application/json" \
--     -H "Prefer: params=single-object"



# get a token
curl http://localhost:3100/rpc/woden -X GET \
     -H "Content-Type: application/json"

# get a bad app token
curl http://localhost:3100/rpc/bad_woden -X GET \
     -H "Content-Type: application/json"

# put token in environment
export WODEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJMeXR0bGVCaXQiLCJzdWIiOiJPcmlnaW4iLCJuYW1lIjoiV29kZW4iLCJyb2xlIjoiYXBpX2d1ZXN0IiwidHlwZSI6ImFwcCJ9.AskzpKl1sMipgHb6U2snkyEJKQ_WQi7xx75Xf_tMYtI"
export WODEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJMeXR0bGVCaXQiLCJzdWIiOiJPcmlnaW4iLCJuYW1lIjoiV29kZW4iLCJyb2xlIjoiYXBpX2d1ZXN0IiwidHlwZSI6ImFwcCJ9.AskzpKl1sMipgHb6U2snkyEJKQ_WQi7xx75Xf_tMYtI"
export BADWODEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYmFkX3JvbGUiLCJ0eXBlIjoiYmFkX3R5cGUifQ.Hhs_kC0xypud3AhjGIlLO35xEVAtl4_QwP02gR25lPE"

# fail with bad token
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $BADWODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "app","val": "xxx"}'

# fail with bad type
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "bad", "name": "my-app@1.0.0", "group":"register", "owner": "me@someplace.com", "password": "a1A!aaaa"}'

# fail with bad application name value
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "app", "name": "my!app@1.0.0", "group":"register", "owner": "me@someplace.com", "password": "a1A!aaaa"}'

# fail with bad password value
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "app", "name": "my_app@1.0.0", "group":"register", "owner": "me@someplace.com", "password": "password"}'

# fail with bad owner name value
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "app", "name": "my_app@1.0.0", "group":"register", "owner": "mesomeplace.com", "password": "P1!password"}'

# success with id
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"id": "xxx", "type": "app", "name": "my_app@1.0.0", "group":"register", "owner": "me@someplace.com", "password": "a1A!aaaa"}'

# ADD APP success with good attributes, values and token
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "app", "name": "my_app@1.0.0", "group":"register", "owner": "me@someplace.com", "password": "a1A!aaaa"}'

 # GET APP success with good attributes, values and token
 curl http://localhost:3100/rpc/app -X POST \
      -H "Authorization: Bearer $WODEN"   \
      -H "Content-Type: application/json" \
      -d '{"id": "my_app@1.0.0"}'

# GET APP success with BAD attributes, values and token
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $BADWODEN"   \
     -H "Content-Type: application/json" \
     -d '{"id": "my_app@1.0.0"}'

*/
