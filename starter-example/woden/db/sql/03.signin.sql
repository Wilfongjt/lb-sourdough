
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

SET search_path TO app_schema, public;


-----------------
-- FUNCTION: owner
-----------------
-- Create or Update an owner
-- Role:
-- Permissions: EXECUTE
-- Returns: JSONB
/*
CREATE OR REPLACE FUNCTION signin(form JSON)
RETURNS JSONB AS $$
  Declare rc jsonb;
  Declare _model_owner JSONB;
  Declare _form JSONB;
  Declare _jwt_role TEXT;

  Declare _validation JSONB;
  Declare _password TEXT;
  Declare _user_token TEXT;
  Declare _signin_form JSONB;

  BEGIN
    -- claims check
    _jwt_role := current_setting('request.jwt.claim.role','t');
    --_jwt_type := 'app';
    if _jwt_role is NULL then
      _jwt_role := 'app_guest';

    end if;
    -- signin optionally passes a type so add it
    _form := form::JSONB || '{"type":"signin"}'::JSONB;
    -- evaluate the token
    _model_owner := current_setting('app.lb_editor_wdn')::jsonb;

    if not(_model_owner ->> 'role' = _jwt_role) then
        return format('{"status": "401", "msg":"Unauthorized bad token", "jwt_role":"%s"}', _jwt_role)::JSONB;
    end if;
    -- confirm all required attributes are in form
    -- validate attribute values
    _validation := signin_validate(_form);
    if _validation ->> 'status' != '200' then
        return _validation;
    end if;

    if _form ? 'id' then
        return '{"status": "400", "msg": "Update not supported"}'::JSONB;
    else
      select exmpl_form into _signin_form
      from register
      where exmpl_id = _form ->> 'name';
      _user_token := replace(replace(editor_wdn('name')::TEXT,'(',''),')','');
      _signin_form := _signin_form - 'password';
      --_signin_form := _signin_form::JSONB || format('{"token":"%s"}'::TEXT, 'xxxx')::JSONB;

      --_signin_form := _signin_form::JSONB || format('{"token":"%s"}'::TEXT, _user_token::TEXT)::JSONB;
      -- obfuscate the password before logging
      _form := _form || '{"password":"sssssssssss"}'::JSONB;

      PERFORM app_schema.process_logger(_form);

    end if;

    rc := format('{"msg": "OK", "status": "200", "token":"%s"}', _user_token)::JSONB;
    return rc;
  END;
$$ LANGUAGE plpgsql;
*/

/*
CREATE OR REPLACE FUNCTION signin_token(form JSON)
RETURNS TEXT AS $$
  Declare rc jsonb;
  BEGIN
    rc := '{}'::JSONB;
    return rc;
  END;
  $$ LANGUAGE plpgsql;
*/

/*
Create or Replace Function signin_token(_id TEXT) RETURNS TEXT AS $$
DECLARE rc TEXT;
BEGIN
  -- make token to execute editor_wdn(JSON)
  rc := 'xxx.xxx.aaa';

  return rc;
END;  $$ LANGUAGE plpgsql;
*/


/*
Create or Replace Function signin_token(_id TEXT) RETURNS TEXT AS $$
DECLARE rc TEXT;
BEGIN
  -- make token to execute editor_wdn(JSON)


  SELECT public.sign(
    row_to_json(r), current_setting('app.settings.jwt_secret')
  ) AS woden into rc
  FROM (
    SELECT
      'LyttleBit' as iss,
      'Woden'::text as name,
      'Owner'::text as sub,
      'editor_wdn'::text as role,
      _id as jti
  ) r;

  return rc;
END;  $$ LANGUAGE plpgsql;
*/
/*
Create or Replace Function signin_token(_id TEXT) RETURNS TEXT AS $$
DECLARE rc TEXT;
BEGIN
  -- make token to execute editor_wdn(JSON)

  SELECT public.sign(
    row_to_json(r), current_setting('app.settings.jwt_secret')
  ) AS woden into rc
  FROM (
    SELECT
      'LyttleBit' as iss,
      'Woden'::text as name,
      'Owner'::text as sub,
      'editor_wdn'::text as role,
      _id as jti
  ) r;

  return rc;
END;  $$ LANGUAGE plpgsql;
*/

/*
CREATE OR REPLACE FUNCTION signin(form JSON) RETURNS JSON AS $$
  -- make token to execute app(JSON)

    SELECT row_to_json(r) as result
    from
    (SELECT
      '200' as status,
      'OK' as msg,
      signin_token(form) as token
    ) r;

$$ LANGUAGE sql;
*/




-----------------
-- FUNCTION: signin_validate
-----------------
-- Permissions: EXECUTE
-- Returns: JSONB
CREATE OR REPLACE FUNCTION signin_validate(form JSONB)
RETURNS JSONB
AS $$

  BEGIN
    -- name, type, "group, owner, password
    -- name, type, app_id, password
    -- confirm all required attributes are in form
    if not(form ? 'type' and form ? 'name' and form ? 'password') then
        return http_response('400', 'Bad Request, missing one or more form attributes');
    end if;
    -- validate attribute values
    if not(form ->> 'type' = 'signin') then
        return http_response('400', 'Bad Request type value.');
    end if;
    -- proper password
    if not (exists(select regexp_matches(form ->> 'password', '^(?=.{8,}$)(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W).*$') )) then
        return http_response('400', 'Bad Request, bad password.');
    end if;
    -- proper name ... name
    if not( exists( select regexp_matches(form ->> 'name', '[a-z\-_0-9]+@[a-z]+\.[a-z]+') ) ) then
      return http_response('400', format('Bad Request, bad name'));
    end if;

    return http_response('200', 'OK');
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION signin(form JSON) RETURNS JSON AS $$
  -- make token to execute app(JSON)
  declare rc JSONB;
  declare signin_token TEXT;
  declare process_error JSONB;
  declare _form JSONB;
  Declare _jwt_role TEXT;
  Declare _model_owner JSONB;
  Declare _validation JSONB;
  Declare _pw TEXT;
  BEGIN
  -- claims check
    _jwt_role := current_setting('request.jwt.claim.role','t');
    if _jwt_role is NULL then
      -- needed for tapps testing only
      _jwt_role := 'app_guest';
    end if;

    _form := form::JSONB;
    -- signin optionally passes a type so add it
    _form := _form || '{"type":"signin"}'::JSONB;
    -- evaluate the token
    _model_owner := current_setting('app.lb_editor_wdn')::jsonb;
    if not(_model_owner ->> 'role' = _jwt_role) then
        return http_response('401',format('Unauthorized bad token: jwt_role %s',_jwt_role )::text);
    end if;
    -- validate input form
    -- confirm all required attributes are in form
    -- validate attribute values
    _validation := signin_validate(_form);
    if _validation ->> 'status' != '200' then
        return _validation;
    end if;
    -- remove password
    _pw = _form ->> 'password';
    _form := _form - 'password';
    -- validate name and password

    if not(exists(select exmpl_form from register where exmpl_id = _form ->> 'name' and exmpl_form ->> 'password' = crypt(_pw, exmpl_form ->> 'password'))) then
      -- login failure
      _form := _form || '{"status":"401", "msg":"Unauthenticated"}'::JSONB;
      PERFORM app_schema.process_logger(_form);
      return http_response('401','Unauthenticated');
    end if;

    -- make signin_token
    SELECT public.sign(
      row_to_json(r), current_setting('app.settings.jwt_secret')
    ) AS woden into signin_token
    FROM (
      SELECT
        'LyttleBit' as iss,
        'Woden'::text as name,
        'Owner'::text as sub,
        'editor_wdn'::text as role,
        _form ->> 'name' as jti
    ) r;
    -- log success
    _form := _form || '{"state":1}'::JSONB;

    PERFORM app_schema.process_logger(_form);
    -- test for owner account
    -- wrap signin_token in JSON
    return (SELECT row_to_json(r) as result
      from (
        SELECT
        '200' as status,
        'OK' as msg,
        signin_token as token
      ) r
    );

  END;
$$ LANGUAGE plpgsql;

/*
CREATE OR REPLACE FUNCTION signin(form JSON) RETURNS JSON AS $$
  -- make token to execute app(JSON)

  BEGIN

    return (SELECT row_to_json(r) as result
      from
      (SELECT
        '200' as status,
        'OK' as msg,
        signin_token(form::JSONB ->> 'name') as token
      ) r
    );
  END;
$$ LANGUAGE plpgsql;

*/

/*
CREATE OR REPLACE FUNCTION signin(form JSON)
RETURNS JSONB AS $$
  Declare rc jsonb;
  Declare _model_owner JSONB;
  Declare _form JSONB;
  Declare _jwt_role TEXT;

  Declare _validation JSONB;
  Declare _password TEXT;
  Declare _user_token TEXT;
  Declare _signin_form JSONB;

  BEGIN
    -- claims check
    _jwt_role := current_setting('request.jwt.claim.role','t');
    if _jwt_role is NULL then
      _jwt_role := 'app_guest';
    end if;
    -- signin optionally passes a type so add it
    _form := form::JSONB || '{"type":"signin"}'::JSONB;
    -- evaluate the token
    _model_owner := current_setting('app.lb_editor_wdn')::jsonb;

    if not(_model_owner ->> 'role' = _jwt_role) then
        return format('{"status": "401", "msg":"Unauthorized bad token", "jwt_role":"%s"}', _jwt_role)::JSONB;
    end if;
    -- confirm all required attributes are in form
    -- validate attribute values
    _validation := signin_validate(_form);
    if _validation ->> 'status' != '200' then
        return _validation;
    end if;

    if _form ? 'id' then
        return '{"status": "400", "msg": "Update not supported"}'::JSONB;
    else
      select exmpl_form into _signin_form
      from register
      where exmpl_id = _form ->> 'name';
      _user_token := replace(replace(editor_wdn('name')::TEXT,'(',''),')','');
      _signin_form := _signin_form - 'password';

      -- obfuscate the password before logging
      _form := _form || '{"password":"sssssssssss"}'::JSONB;

      PERFORM app_schema.process_logger(_form);

    end if;

    rc := format('{"msg": "OK", "status": "200", "token":"%s"}', _user_token)::JSONB;
    return rc;
  END;
$$ LANGUAGE plpgsql;


*/



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

grant insert on register to app_guest;
grant EXECUTE on FUNCTION owner(JSON) to app_guest; -- upsert

---------------------
-- GRANT: owner_GUEST
---------------------
grant usage on schema app_schema to editor_wdn;

grant insert on register to editor_wdn; -- C ... 'app' only
grant select on register to editor_wdn; -- R ... 'owner', 'app'
grant update on register to editor_wdn; -- U ... 'owner'
-- grant delete on register to editor_wdn; -- D ... 'owner'

grant TRIGGER on register to editor_wdn; --

grant EXECUTE on FUNCTION register_upsert_trigger_func to editor_wdn;

grant EXECUTE on FUNCTION signin(JSON) to editor_wdn; -- upsert
-- grant EXECUTE on FUNCTION signin(TEXT) to editor_wdn; -- select
-- grant EXECUTE on FUNCTION owner(????) to editor_wdn; -- delete

grant EXECUTE on FUNCTION signin_validate(JSONB) to editor_wdn;

grant EXECUTE on FUNCTION is_valid_token(TEXT,TEXT) to editor_wdn;

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
