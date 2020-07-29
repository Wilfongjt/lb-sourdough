
------------------------
-- TESTs
------------------------
\c application_db;

SET search_path TO api_schema, public;

BEGIN;

  SELECT plan(3);
  -- Insert
  SELECT is (
    api_schema.actor('{"type": "actor",
      "name": "me@someplace.com",
      "app_id": "my_app@1.0.0",
      "password": "a1A!aaaa"
      }'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'actor - insert test'::TEXT
  );

  -- Update
  /*
  SELECT is (
    api_schema.actor('{"type": "actor",
      "app_id": "my_app@1.0.0",
      "name": "me@someplace.com",
      "password": "a2A!aaaa"}'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'actor - update test'::TEXT
  );
*/
  -- select
  --SELECT matches(
  --  api_schema.actor('my_app@1.0.0'::TEXT)::TEXT,
  --  '[a-zA-Z\.0-9_]+',
  --  'app - select from regis ter by id and check token'::TEXT
  --);

  -- update: no update

  SELECT * FROM finish();

ROLLBACK;
