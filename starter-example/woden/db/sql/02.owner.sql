
\c woden_db;

--CREATE SCHEMA if not exists app_schema;
----------------
-- system variables
----------------
ALTER DATABASE woden_db SET "app.lb_owner_editor" To '{"role":"app_guest"}';

---------------
-- SCHEMA: app_schema
---------------
--CREATE ROLE app_guest nologin;
CREATE ROLE owner_editor nologin; -- permissions to execute app() and insert type=app into register

SET search_path TO app_schema, public;
-----------------
-- FUNCTION: owner
-----------------
-- Create or Update an owner
-- Role:
-- Permissions: EXECUTE
-- Returns: JSONB

CREATE OR REPLACE FUNCTION owner(form JSON)
RETURNS JSONB AS $$
  Declare rc jsonb;
  Declare _model_owner JSONB;
  Declare _form JSONB;
  Declare _jwt_role TEXT;
  Declare _jwt_type TEXT;
  Declare _validation JSONB;
  Declare _password TEXT;

  BEGIN
    -- claims check
    _jwt_role := current_setting('request.jwt.claim.role','t');
    _jwt_type := current_setting('request.jwt.claim.type','t');
    if _jwt_role is NULL or _jwt_type is NULL then
      _jwt_role := 'app_guest';
      _jwt_type := 'owner';
    end if;

    _form := form::JSONB;
    -- evaluate the token
    _model_owner := current_setting('app.lb_owner_editor')::jsonb;

    if not(_model_owner ->> 'role' = _jwt_role) then
        return format('{"status": "401", "msg":"Unauthorized bad token", "jwt_role":"%s"}', _jwt_role)::JSONB;
    end if;
    -- confirm all required attributes are in form
    -- validate attribute values
    _validation := owner_validate(_form);
    if _validation ->> 'status' != '200' then
        return _validation;
    end if;

    --if _form ? 'password' then
    --    _password := _form ->> 'password';
    --    -- never store password in form
    --    _form := _form - 'password';
    --end if;

    if _form ? 'id' then
        return '{"status": "400", "msg": "Update not YET supported"}'::JSONB;
    else

      BEGIN
              INSERT INTO register
                  (exmpl_type, exmpl_form)
              VALUES
                  (_jwt_type, _form);
      EXCEPTION
          WHEN unique_violation THEN
              return '{"status":"400", "msg":"Bad Request, duplicate error"}'::JSONB;
          WHEN check_violation then
              return '{"status":"400", "msg":"Bad Request, validation error"}'::JSONB;
          WHEN others then
              return format('{"status":"500", "msg":"unknown insertion error", "SQLSTATE":"%s", "form":%s, "type":"%s"}',SQLSTATE, _form, _jwt_type)::JSONB;
      END;
    end if;

    rc := '{"msg": "OK", "status": "200"}'::JSONB;
    return rc;
  END;
$$ LANGUAGE plpgsql;
-----------------
-- FUNCTION: owner_VALIDATE
-----------------
-- Permissions: EXECUTE
-- Returns: JSONB
CREATE OR REPLACE FUNCTION owner_validate(form JSONB)
RETURNS JSONB
AS $$

  BEGIN
    -- name, type, "group, owner, password
    -- name, type, app_id, password
    -- confirm all required attributes are in form
    if not(form ? 'type' and form ? 'name' and form ? 'password') then
       return '{"status":"400","msg":"Bad Request, owner_validate is missing one or more form attributes"}'::JSONB;
    end if;
    -- validate attribute values
    if not(form ->> 'type' = 'owner') then
       return '{"status":"400", "msg":"Bad Request type value."}'::JSONB;
    end if;
    -- proper application name
    --if not( exists( select regexp_matches(form ->> 'app_id', '^[a-z][a-z_]+@[1-9]+\.[0-9]+\.[0-9]+') ) ) then
    --   return '{"status":"400", "msg":"Bad Request, bad application id."}'::JSONB;
    --end if;
    -- proper password
    if not (exists(select regexp_matches(form ->> 'password', '^(?=.{8,}$)(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W).*$') )) then
       return '{"status":"400", "msg":"Bad Request, bad password."}'::JSONB;
    end if;
    -- proper name ... name
    if not( exists( select regexp_matches(form ->> 'name', '[a-z\-_0-9]+@[a-z]+\.[a-z]+') ) ) then
       return format('{"status":"400", "msg":"Bad Request, bad name.", "name":"%s"}', form ->> 'name')::JSONB;
    end if;
    -- proper name ... email
    if not( exists( select regexp_matches(form ->> 'email', '[a-z\-_0-9]+@[a-z]+\.[a-z]+') ) ) then
       return format('{"status":"400", "msg":"Bad Request, bad email.", "email":"%s"}', form ->> 'email')::JSONB;
    end if;

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

CREATE OR REPLACE FUNCTION owner(id TEXT) RETURNS JSONB
AS $$
  Select exmpl_form from register where exmpl_id=id;
$$ LANGUAGE sql;
---------------------
-- GRANT: APP_GUEST
---------------------
--grant usage on schema app_schema to app_guest;

grant insert on register to app_guest;
grant EXECUTE on FUNCTION owner(JSON) to app_guest; -- upsert

---------------------
-- GRANT: owner_GUEST
---------------------
grant usage on schema app_schema to owner_editor;

grant select on register to owner_editor;

grant update on register to owner_editor;
grant TRIGGER on register to owner_editor;

grant EXECUTE on FUNCTION register_upsert_trigger_func to owner_editor;
grant EXECUTE on FUNCTION owner(JSON) to owner_editor; -- upsert
grant EXECUTE on FUNCTION owner(TEXT) to owner_editor; -- select

grant EXECUTE on FUNCTION owner_validate(JSONB) to owner_editor;

grant EXECUTE on FUNCTION is_valid_token(TEXT,TEXT) to owner_editor;

--grant app_guest to authenticator;


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
