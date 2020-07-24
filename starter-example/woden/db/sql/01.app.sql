\c wdn_db

SET search_path TO wdn_schema, public;

-----------------
-- FUNCTION: APP_VALIDATE
-----------------

CREATE OR REPLACE FUNCTION wdn_schema.app_validate(form JSONB) RETURNS JSONB
AS $$

  BEGIN
    -- confirm all required attributes are in form
    if not(form ? 'name' and form ? 'owner_id' ) then
       return format('{"status":"400","msg":"Bad Request, missing one or more form attributes","form":%s}', form::TEXT)::JSONB;
    end if;
    -- validate attribute values
    if not(form ->> 'type' = 'app') then
       return '{"status":"400", "msg":"Bad Request type value."}'::JSONB;
    end if;

    if not( exists( select regexp_matches(form ->> 'name', '^[a-z][a-z_]+@[1-9]+\.[0-9]+\.[0-9]+') ) ) then
       return format('{"status":"400", "msg":"Bad Request, bad application name.", "name":"%s"}',form ->> 'name')::JSONB;
    end if;

    -- proper owner name ... email
    if not( exists( select regexp_matches(form ->> 'owner_id', '[a-z\-_0-9]+@[a-z]+\.[a-z]+') ) ) then
       return format('{"status":"400", "msg":"Bad Request, bad owner id.", "owner_id":"%s"}', form ->> 'owner_id')::JSONB;
    end if;

    return '{"status": "200"}'::JSONB;
  END;
$$ LANGUAGE plpgsql;

grant EXECUTE on FUNCTION wdn_schema.app_validate(JSONB) to editor_wdn;


-- FUNCTION
-----------------
-- FUNCTION: APP
-----------------
-- inserts an application record into the system

CREATE OR REPLACE FUNCTION wdn_schema.app(form JSON)
RETURNS JSONB AS $$
  Declare rc jsonb;
  Declare _model_user JSONB;
  Declare _form JSONB;
  Declare _jwt_role TEXT;
  Declare _jwt_app TEXT;
  Declare _validation JSONB;

  BEGIN

    -- get request values
    _jwt_role := current_setting('request.jwt.claim.role','t');
    if _jwt_role is NULL then
      _jwt_role := 'editor_wdn';
    end if;
    if _jwt_role != 'editor_wdn' then
      _validation := format('{"status":"401", "msg":"Unauthorized Token", "jwt_role":"%s"}',_jwt_role)::JSONB;
      -- PERFORM wdn_schema.process_logger(_validation);
      return _validation;
    end if;
    -- type stamp form
    _form := form::JSONB || '{"type":"app"}'::JSONB;

    BEGIN
      _model_user := current_setting(format('app.lb_%s',_jwt_role))::jsonb;
    EXCEPTION
      WHEN others then
        _validation := format('{"status": "401", "msg":"Unauthorized Token", "jwt_role":"%s","model_role":%s}',_jwt_role,_model_user )::JSONB;
        -- PERFORM wdn_schema.process_logger(_validation);
        return _validation;
        ---- PERFORM wdn_schema.process_logger(format('{"status":"500", "msg":"Unknown APP", "SQLSTATE":"%s", "role":"%s"}',SQLSTATE, _jwt_role)::JSONB);
        --return format('{"status":"500", "msg":"Unknown APP", "SQLSTATE":"%s", "role":"%s"}',SQLSTATE, _jwt_role)::JSONB;
    END;

    --if not(_model_user ->> 'role' = _jwt_role) then
    --    return format('{"status": "401", "msg":"Unauthorized token", "jwt_role":"%s","model_role":%s}',_jwt_role,_model_user )::JSONB;
    -- end if;

    _validation := app_validate(_form);
    if _validation ->> 'status' != '200' then
      -- PERFORM wdn_schema.process_logger(_validation);
      return _validation;
    end if;

    BEGIN
            INSERT INTO wdn_schema.register
                (exmpl_type, exmpl_form)
            VALUES
                ('app', _form );
    EXCEPTION
        WHEN unique_violation THEN
            _validation := '{"status":"400", "msg":"Bad App Request, duplicate error"}'::JSONB;
            -- PERFORM wdn_schema.process_logger(_validation);
            return _validation;
        WHEN check_violation then
            _validation :=  '{"status":"400", "msg":"Bad App Request, validation error"}'::JSONB;
            -- PERFORM wdn_schema.process_logger(_validation);
            return _validation;
        WHEN others then
            _validation :=  format('{"status":"500", "msg":"Unknown App insertion error", "SQLSTATE":"%s"}',SQLSTATE)::JSONB;
            -- PERFORM wdn_schema.process_logger(_validation);
            return _validation;
    END;

    rc := '{"msg": "OK", "status": "200"}'::JSONB;

    return rc;
  END;
$$ LANGUAGE plpgsql;

grant EXECUTE on FUNCTION wdn_schema.app(JSON) to editor_wdn; -- C

--------------------
-- FUNCTION: APP(TEXT)
--------------------
CREATE OR REPLACE FUNCTION wdn_schema.app(id TEXT) RETURNS JSONB
AS $$
  Select exmpl_form from wdn_schema.register where exmpl_id=id and exmpl_type='app';
$$ LANGUAGE sql;

grant guest_wgn to authenticator;
grant editor_wdn to authenticator;
