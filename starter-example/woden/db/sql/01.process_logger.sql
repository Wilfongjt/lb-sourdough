
\c wdn_db;

--CREATE SCHEMA if not exists wdn_schema_1_0_0;
----------------
-- system variables
----------------

---------------
-- SCHEMA: wdn_schema_1_0_0
---------------


SET search_path TO wdn_schema_1_0_0, public;

-----------------
-- FUNCTION: process_logger
-----------------
-- Create or Update an owner


CREATE OR REPLACE FUNCTION wdn_schema_1_0_0.process_logger(_form JSONB)
RETURNS JSONB AS $$
  Declare rc jsonb;
  Declare _model_owner JSONB;
  --Declare _form JSONB;
  Declare _jwt_role TEXT;
  Declare _validation JSONB;
  Declare _password TEXT;

  BEGIN
    -- claims check
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
              INSERT INTO wdn_schema_1_0_0.register
                  (reg_type, reg_form)
              VALUES
                  ('process', _form);
      EXCEPTION
          WHEN unique_violation THEN
              return '{"status":"400", "msg":"Bad Process Request, duplicate error"}'::JSONB;
          WHEN check_violation then
              return '{"status":"400", "msg":"Bad Process Request, validation error"}'::JSONB;
          WHEN others then
              return format('{"status":"500", "msg":"Unknown Process insertion error", "SQLSTATE":"%s"}',SQLSTATE)::JSONB;
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
CREATE OR REPLACE FUNCTION wdn_schema_1_0_0.process_logger_validate(form JSONB)
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

    return '{"status": "200"}'::JSONB;
  END;
$$ LANGUAGE plpgsql;


---------------------
-- GRANT: process_logger_role
---------------------
grant usage on schema wdn_schema_1_0_0 to process_logger_role;

grant insert on wdn_schema_1_0_0.register to process_logger_role; -- C ... 'app' only
grant select on wdn_schema_1_0_0.register to process_logger_role; -- R ... 'owner', 'app'

-- TRIGGER
-- process_logger_role should inhert regi ster trigger privileges

grant EXECUTE on FUNCTION wdn_schema_1_0_0.register_upsert_trigger_func to process_logger_role;

grant EXECUTE on FUNCTION wdn_schema_1_0_0.process_logger(JSONB) to process_logger_role; -- upsert

grant EXECUTE on FUNCTION wdn_schema_1_0_0.process_logger_validate(JSONB) to process_logger_role;
