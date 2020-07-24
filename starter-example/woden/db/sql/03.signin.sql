
\c wdn_db;

SET search_path TO wdn_schema, public;

-----------------
-- FUNCTION: signin_validate
-----------------
-- Permissions: EXECUTE
-- Returns: JSONB
CREATE OR REPLACE FUNCTION signin_validate(form JSONB)
RETURNS JSONB
AS $$

  BEGIN

    -- confirm all required attributes are in form
    if not(form ? 'type' and form ? 'name' and form ? 'password') then
        return http_response('400', 'Bad Request, missing one or more form attributes.');
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
      return http_response('400', format('Bad Request, bad name.'));
    end if;

    return http_response('200', 'OK');
  END;
$$ LANGUAGE plpgsql;

grant EXECUTE on FUNCTION signin_validate(JSONB) to guest_wgn; -- upsert


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
      _jwt_role := 'guest_wgn';
    end if;
    if not(_jwt_role = 'guest_wgn') then
      _validation := '{"status":"401", "msg":"Unauthorized"}'::JSONB;
      PERFORM wdn_schema.process_logger(_validation);
      return _validation;
    end if;

    _form := form::JSONB;
    -- force a type
    _form := _form || '{"type":"signin"}'::JSONB;
    -- evaluate the token
    _model_owner := current_setting('app.lb_guest_wgn')::jsonb;
    if not(_model_owner ->> 'role' = _jwt_role) then
        _validation := http_response('401','Unauthorized');
        PERFORM wdn_schema.process_logger(_validation);
        return _validation;
    end if;
    --
    -- validate input form
    -- confirm all required attributes are in form
    -- validate attribute values
    _validation := signin_validate(_form);
    if _validation ->> 'status' != '200' then
        PERFORM wdn_schema.process_logger(_validation);
        return _validation;
    end if;
    -- remove password
    _pw = _form ->> 'password';
    _form := _form - 'password';
    -- validate name and password

    if not(exists(select exmpl_form from register where exmpl_id = _form ->> 'name' and exmpl_form ->> 'password' = crypt(_pw, exmpl_form ->> 'password'))) then
      -- login failure
      _form := _form || '{"status":"404", "msg":"Not Found"}'::JSONB;
      PERFORM wdn_schema.process_logger(_form);
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
        _form ->> 'name' as jti,
        'editor_wdn'::text as role
    ) r;
    -- log success
    _validation := _form || '{"status":"200"}'::JSONB;

    PERFORM wdn_schema.process_logger(_validation);
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

grant EXECUTE on FUNCTION signin(JSON) to guest_wgn; -- upsert
