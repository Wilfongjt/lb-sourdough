
\c wdn_db;

----------------
-- system variables
----------------

SET search_path TO wdn_schema, public;
-----------------
-- FUNCTION: owner
-----------------

CREATE OR REPLACE FUNCTION wdn_schema.owner(form JSON)
RETURNS JSONB AS $$
  Declare rc jsonb;
  Declare _model_owner JSONB;
  Declare _form JSONB;
  Declare _jwt_role TEXT;
  Declare _validation JSONB;
  Declare _password TEXT;

  BEGIN
    -- claims check
    _jwt_role := current_setting('request.jwt.claim.role','t');
    if _jwt_role is NULL then
      -- assume insert
      -- runs during tests only
      _jwt_role := 'guest_wgn';
      if form::JSONB ? 'id' then
        _jwt_role := 'editor_wdn';
      end if;

    end if;

    -- handle multiple tokens
    BEGIN
      _model_owner := current_setting(format('app.lb_%s',_jwt_role))::jsonb;
    EXCEPTION
      WHEN others then
        -- PERFORM wdn_schema.process_logger(format('{"status":"500", "msg":"Unknown ", "SQLSTATE":"%s", "role":"%s"}',SQLSTATE, _jwt_role)::JSONB);
        return format('{"status":"500", "msg":"Unknown ", "SQLSTATE":"%s", "role":"%s"}',SQLSTATE, _jwt_role)::JSONB;
    END;
    --_model_owner := current_setting('app.lb_editor_wdn')::jsonb;

    -- in acceptable roles
    /*
    if not(_model_owner ->> 'role' = _jwt_role) then
      _model_owner := current_setting('app.lb_editor_wdn')::jsonb;
      if not(_model_owner ->> 'role' = _jwt_role) then
        return format('{"status": "401", "msg":"Unauthorized"}', _jwt_role)::JSONB;
      end if;

    end if;
    */
    -- type stamp and convert to JSONB
    _form := form::JSONB || '{"type":"owner"}'::JSONB;
    -- confirm all required attributes are in form
    -- validate attribute values
    _validation := owner_validate(_form);
    if _validation ->> 'status' != '200' then
        -- PERFORM wdn_schema.process_logger(_validation);
        return _validation;
    end if;

    if _form ? 'id' then
      -- editor
        return '{"status": "400", "msg": "Update not YET supported"}'::JSONB;
    else
      -- guest role
      BEGIN
              INSERT INTO wdn_schema.register
                  (exmpl_type, exmpl_form)
              VALUES
                  ('owner', _form);
      EXCEPTION
          WHEN unique_violation THEN
              -- PERFORM wdn_schema.process_logger(_form || '{"status":"400", "msg":"Bad Request, duplicate owner"}'::JSONB);
              return '{"status":"400", "msg":"Bad App Request, duplicate owner"}'::JSONB;
          WHEN check_violation then
              ---- PERFORM process_logger();
              return '{"status":"400", "msg":"Bad Owner Request, validation error"}'::JSONB;
          WHEN others then
              ---- PERFORM process_logger();
              return format('{"status":"500", "msg":"Unknown Owner insertion error", "SQLSTATE":"%s", "form":%s}',SQLSTATE, _form)::JSONB;
      END;
    end if;

    rc := '{"msg": "OK", "status": "200"}'::JSONB;
    return rc;
  END;
$$ LANGUAGE plpgsql;
grant EXECUTE on FUNCTION wdn_schema.owner(JSON) to guest_wgn; -- upsert
grant EXECUTE on FUNCTION wdn_schema.owner(JSON) to editor_wdn; -- upsert

-----------------
-- FUNCTION: owner_VALIDATE
-----------------
-- Permissions: EXECUTE
-- Returns: JSONB
CREATE OR REPLACE FUNCTION wdn_schema.owner_validate(form JSONB)
RETURNS JSONB
AS $$

  BEGIN
    -- name, type, "group, owner, password
    -- name, type, app_id, password
    -- confirm all required attributes are in form
    if not(form ? 'type' and form ? 'name' and form ? 'password') then
       return '{"status":"400","msg":"Bad Request, owner is missing one or more form attributes"}'::JSONB;
    end if;
    -- validate attribute values
    if not(form ->> 'type' = 'owner') then
       return '{"status":"400", "msg":"Bad Request type value."}'::JSONB;
    end if;

    -- proper password
    if not (exists(select regexp_matches(form ->> 'password', '^(?=.{8,}$)(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W).*$') )) then
       return '{"status":"400", "msg":"Bad Request password value."}'::JSONB;
    end if;
    -- proper name ... name
    if not( exists( select regexp_matches(form ->> 'name', '[a-z\-_0-9]+@[a-z]+\.[a-z]+') ) ) then
       return format('{"status":"400", "msg":"Bad Request name value."}')::JSONB;
    end if;

    return '{"status": "200", "msg":"OK"}'::JSONB;
  END;
$$ LANGUAGE plpgsql;

grant EXECUTE on FUNCTION wdn_schema.owner_validate(JSONB) to guest_wgn; -- upsert
grant EXECUTE on FUNCTION wdn_schema.owner_validate(JSONB) to editor_wdn; -- upsert


-----------------
-- FUNCTION: owner
-----------------
-- select an owner


CREATE OR REPLACE FUNCTION wdn_schema.owner(id TEXT) RETURNS JSONB
AS $$
  Select exmpl_form from wdn_schema.register where exmpl_id=id and exmpl_type='owner';
$$ LANGUAGE sql;

grant EXECUTE on FUNCTION wdn_schema.owner(JSON) to editor_wdn; -- select
