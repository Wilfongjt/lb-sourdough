
------------------------
-- TESTs
------------------------
\c application_db;

SET search_path TO api_schema, public;

BEGIN;

  SELECT plan(3);
  -- Insert
  SELECT is (
    api_schema.app('{"type": "app",
      "name": "my_app@1.0.0",
      "group":"register",
      "owner": "me@someplace.com",
      "password": "a1A!aaaa"}'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'app - insert test'::TEXT
  );
  -- Insert
  SELECT is (
    api_schema.actor('{"type": "actor",
      "app_id": "my_app@1.0.0",
      "username": "me@someplace.com",
      "password": "a1A!aaaa"}'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'app - insert test'::TEXT
  );

  -- select
  --SELECT matches(
  --  api_schema.actor('my_app@1.0.0'::TEXT)::TEXT,
  --  '[a-zA-Z\.0-9_]+',
  --  'app - select from register by id and check token'::TEXT
  --);

  -- update: no update

  SELECT * FROM finish();

ROLLBACK;
