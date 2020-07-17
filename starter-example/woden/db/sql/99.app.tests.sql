
------------------------
-- TESTs
------------------------
\c woden_db;

SET search_path TO app_schema, public;

BEGIN;

  SELECT plan(2);
  -- Insert
  SELECT is (
    app_schema.app('{"type": "app",
      "id": "my_app@1.0.0",
      "name": "my_app",
      "owner_id": "me@someplace.com",
      "password": "a1A!aaaa",
      "group":"register"}'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'app - insert test'::TEXT
  );

  -- select
  SELECT matches(
    app_schema.app('my_app@1.0.0'::TEXT)::TEXT,
    '[a-zA-Z\.0-9_]+',
    'app - select from register by id and check token'::TEXT
  );

  -- update: no update

  SELECT * FROM finish();

ROLLBACK;
