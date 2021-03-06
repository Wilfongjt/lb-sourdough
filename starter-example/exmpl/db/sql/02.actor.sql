
\c application_db;

CREATE SCHEMA if not exists api_schema;
----------------
-- system variables
----------------
ALTER DATABASE application_db SET "app.lb_actor_editor" To '{"role":"guest_wgn"}';

---------------
-- SCHEMA: api_schema
---------------
CREATE ROLE guest_wgn nologin;
CREATE ROLE actor_editor nologin; -- permissions to execute app() and insert type=app into register

SET search_path TO api_schema, public;
-----------------
-- FUNCTION: ACTOR
-----------------
-- Create or Update an Actor
-- Role:
-- Permissions: EXECUTE
-- Returns: JSONB

CREATE OR REPLACE FUNCTION actor(form JSON)
RETURNS JSONB AS $$
  Declare rc jsonb;
  Declare _model_actor JSONB;
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
      _jwt_role := 'guest_wgn';
      _jwt_type := 'actor';
    end if;

    _form := form::JSONB;
    -- evaluate the token
    _model_actor := current_setting('app.lb_actor_editor')::jsonb;

    if not(_model_actor ->> 'role' = _jwt_role) then
        return format('{"status": "401", "msg":"Unauthorized bad token", "jwt_role":"%s"}', _jwt_role)::JSONB;
    end if;
    -- confirm all required attributes are in form
    -- validate attribute values
    _validation := actor_validate(_form);
    if _validation ->> 'status' != '200' then
        return _validation;
    end if;

    if _form ? 'password' then
        _password := _form ->> 'password';
        -- never store password in form
        _form := _form - 'password';
    end if;

    if _form ? 'id' then
        return '{"status": "400", "msg": "Update not YET supported"}'::JSONB;
    else

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
              return format('{"status":"500", "msg":"unknown insertion error", "SQLSTATE":"%s", "form":%s, "type":"%s", "password":"%s"}',SQLSTATE, _form, _jwt_type, _password)::JSONB;
      END;
    end if;

    rc := '{"msg": "OK", "status": "200"}'::JSONB;
    return rc;
  END;
$$ LANGUAGE plpgsql;
-----------------
-- FUNCTION: ACTOR_VALIDATE
-----------------
-- Permissions: EXECUTE
-- Returns: JSONB
CREATE OR REPLACE FUNCTION actor_validate(form JSONB)
RETURNS JSONB
AS $$

  BEGIN
    -- name, type, "group, owner, password
    -- name, type, app_id, password
    -- confirm all required attributes are in form
    if not(form ? 'type' and form ? 'app_id' and form ? 'name' and form ? 'password') then
       return '{"status":"400","msg":"Bad Request, actor_validate is missing one or more form attributes"}'::JSONB;
    end if;
    -- validate attribute values
    if not(form ->> 'type' = 'actor') then
       return '{"status":"400", "msg":"Bad Request type value."}'::JSONB;
    end if;
    -- proper application name
    if not( exists( select regexp_matches(form ->> 'app_id', '^[a-z][a-z_]+@[1-9]+\.[0-9]+\.[0-9]+') ) ) then
       return '{"status":"400", "msg":"Bad Request, bad application id."}'::JSONB;
    end if;
    -- proper password
    if not (exists(select regexp_matches(form ->> 'password', '^(?=.{8,}$)(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W).*$') )) then
       return '{"status":"400", "msg":"Bad Request, bad password."}'::JSONB;
    end if;
    -- proper name ... email
    if not( exists( select regexp_matches(form ->> 'name', '[a-z\-_0-9]+@[a-z]+\.[a-z]+') ) ) then
       return format('{"status":"400", "msg":"Bad Request, bad name.", "name":"%s"}', form ->> 'name')::JSONB;
       -- return '{"status":"400", "msg":"Bad Request, bad owner name."}'::JSONB;
    end if;
    return '{"status": "200"}'::JSONB;
  END;
$$ LANGUAGE plpgsql;


-----------------
-- FUNCTION: ACTOR
-----------------
-- select an actor
-- Role:
-- Permissions: EXECUTE
-- Returns: JSONB

CREATE OR REPLACE FUNCTION actor(id TEXT) RETURNS JSONB
AS $$
  Select exmpl_form from register where exmpl_id=id;
$$ LANGUAGE sql;
---------------------
-- GRANT: guest_wgn
---------------------
grant usage on schema api_schema to guest_wgn;

grant insert on register to guest_wgn;
grant EXECUTE on FUNCTION actor(JSON) to guest_wgn; -- upsert

---------------------
-- GRANT: ACTOR_GUEST
---------------------
grant usage on schema api_schema to actor_editor;

grant select on register to actor_editor;

grant update on register to actor_editor;
grant TRIGGER on register to actor_editor;

grant EXECUTE on FUNCTION register_upsert_trigger_func to actor_editor;
grant EXECUTE on FUNCTION actor(JSON) to actor_editor; -- upsert
grant EXECUTE on FUNCTION actor(TEXT) to actor_editor; -- select

grant EXECUTE on FUNCTION actor_validate(JSONB) to actor_editor;

grant EXECUTE on FUNCTION is_valid_token(TEXT,TEXT) to actor_editor;

grant guest_wgn to authenticator;


/*

# Create Actor
curl http://localhost:3100/rpc/actor -X POST \
     -H "Authorization: Bearer $APPTOKEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "actor", "name":"smithr@smith.com", "app_name":"my_app@1.0.0", "password":"a1A!aaaa"}'
type
name
app_name
password

*/
