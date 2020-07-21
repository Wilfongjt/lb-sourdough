
\c woden_db;

--CREATE SCHEMA if not exists app_schema;
----------------
-- system variables
----------------
--ALTER DATABASE woden_db SET "app.lb_editor_wdn" To '{"role":"app_guest"}';

---------------
-- SCHEMA: app_schema
---------------
--CREATE ROLE app_guest nologin;
--CREATE ROLE editor_wdn nologin; -- permissions to execute app() and insert type=app into register
CREATE ROLE process_logger_role nologin;

SET search_path TO app_schema, public;

-----------------
-- FUNCTION: owner
-----------------
-- Create or Update an owner
-- Role:
-- Permissions: EXECUTE
-- Returns: JSONB

CREATE OR REPLACE FUNCTION process_logger(_form JSONB)
RETURNS JSONB AS $$
  Declare rc jsonb;
  Declare _model_owner JSONB;
  --Declare _form JSONB;
  Declare _jwt_role TEXT;
  Declare _validation JSONB;
  Declare _password TEXT;

  BEGIN
    -- claims check
    --_jwt_role := current_setting('request.jwt.claim.role','t');
    --_jwt_type := 'app';
    --if _jwt_role is NULL then
    --  _jwt_role := 'app_guest';

    --end if;
    -- process_logger optionally passes a type so add it
    --_form := form::JSONB || '{"type":"process"}'::JSONB;
    --_form := form::JSONB;
    -- evaluate the token
    --_model_owner := current_setting('app.lb_editor_wdn')::jsonb;

    --if not(_model_owner ->> 'role' = _jwt_role) then
    --    return format('{"status": "401", "msg":"Unauthorized bad token", "jwt_role":"%s"}', _jwt_role)::JSONB;
    --end if;
    -- confirm all required attributes are in form
    -- validate attribute values
    _validation := process_logger_validate(_form);
    if _validation ->> 'status' != '200' then
        return _validation;
    end if;

    if _form ? 'id' then
        return '{"status": "400", "msg": "Update not supported"}'::JSONB;
    else
      -- obfuscate the password before logging
      --_form := form::JSONB || '{"password":"sssssssssss"}'::JSONB;
      BEGIN
              INSERT INTO register
                  (exmpl_type, exmpl_form)
              VALUES
                  ('process', _form);
      EXCEPTION
          WHEN unique_violation THEN
              return '{"status":"400", "msg":"Bad Request, duplicate error"}'::JSONB;
          WHEN check_violation then
              return '{"status":"400", "msg":"Bad Request, validation error"}'::JSONB;
          WHEN others then
              return format('{"status":"500", "msg":"unknown insertion error", "SQLSTATE":"%s", "form":%s, "type":"%s"}',SQLSTATE, _form, 'process')::JSONB;
      END;
    end if;

    rc := '{"msg": "OK", "status": "200"}'::JSONB;
    return rc;
  END;
$$ LANGUAGE plpgsql;
-----------------
-- FUNCTION: process_logger_validate
-----------------
-- Permissions: EXECUTE
-- Returns: JSONB
CREATE OR REPLACE FUNCTION process_logger_validate(form JSONB)
RETURNS JSONB
AS $$

  BEGIN
    -- name, type, "group, owner, password
    -- name, type, app_id, password
    -- confirm all required attributes are in form
    -- process_logger's type can be  different from the form.type
    if not(form ? 'type' ) then
       return '{"status":"400","msg":"Bad Request, process_logger_validate is missing one or more form attributes"}'::JSONB;
    end if;
    -- validate attribute values
    --if not(form ->> 'type' = 'process_logger') then
    --   return '{"status":"400", "msg":"Bad Request type value."}'::JSONB;
    --end if;
    -- proper application name
    --if not( exists( select regexp_matches(form ->> 'app_id', '^[a-z][a-z_]+@[1-9]+\.[0-9]+\.[0-9]+') ) ) then
    --   return '{"status":"400", "msg":"Bad Request, bad application id."}'::JSONB;
    --end if;
    -- proper password
    --if not (exists(select regexp_matches(form ->> 'password', '^(?=.{8,}$)(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W).*$') )) then
    --   return '{"status":"400", "msg":"Bad Request, bad password."}'::JSONB;
    --end if;
    -- proper name ... name
    --if not( exists( select regexp_matches(form ->> 'name', '[a-z\-_0-9]+@[a-z]+\.[a-z]+') ) ) then
    --   return format('{"status":"400", "msg":"Bad Request, bad name.", "name":"%s"}', form ->> 'name')::JSONB;
    --end if;

    return '{"status": "200"}'::JSONB;
  END;
$$ LANGUAGE plpgsql;


-----------------
-- FUNCTION: owner
-----------------
-- select an owner
-- Role:
-- Permissions: EXECUTE
-- Returns: JSONB
--CREATE OR REPLACE FUNCTION owner(id TEXT) RETURNS JSONB
--AS $$
--  Select exmpl_form from register where exmpl_id=id and exmpl_type='owner';
--$$ LANGUAGE sql;
---------------------
-- GRANT: APP_GUEST
---------------------
--grant usage on schema app_schema to app_guest;
-- Table permission
--grant insert on register to process_logger_role;
-- process logger will inhert register privileges

--grant EXECUTE on FUNCTION process_logger(JSONB) to process_logger_role; -- upsert
--grant EXECUTE on FUNCTION process_logger(JSON) to process_logger_role; -- upsert

---------------------
-- GRANT: process_logger_role
---------------------
grant usage on schema app_schema to process_logger_role;

grant insert on register to process_logger_role; -- C ... 'app' only
grant select on register to process_logger_role; -- R ... 'owner', 'app'
--grant update on register to editor_wdn; -- U ... 'owner'
-- grant delete on register to editor_wdn; -- D ... 'owner'
-- TRIGGER
-- grant TRIGGER on register to process_logger_role; --
-- process_logger_role should inhert register trigger privileges

grant EXECUTE on FUNCTION register_upsert_trigger_func to process_logger_role;

grant EXECUTE on FUNCTION process_logger(JSONB) to process_logger_role; -- upsert

grant EXECUTE on FUNCTION process_logger_validate(JSONB) to process_logger_role;

--grant EXECUTE on FUNCTION is_valid_token(TEXT,TEXT) to process_logger_role;

--grant app_guest to authenticator;
--grant process_logger_role to editor_wdn;
--grant process_logger_role to app_guest ;


/*

# Create owner
curl http://localhost:3100/rpc/owner -X POST \
     -H "Authorization: Bearer $APPTOKEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "owner", "name":"smithr@smith.com", "app_name":"my_app@1.0.0", "password":"a1A!aaaa"}'
type
name
app_name
password

*/
