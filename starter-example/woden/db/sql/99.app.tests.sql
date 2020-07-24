
------------------------
-- TESTs
------------------------
\c wdn_db;

SET search_path TO wdn_schema, public;

BEGIN;

  SELECT plan(2);
  -- Insert
  SELECT is (
    wdn_schema.app('{
      "name": "my_app@1.0.0",
      "owner_id": "me@someplace.com"}'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'app - insert test'::TEXT
  );

  -- select
  SELECT matches(
    wdn_schema.app('my_app@1.0.0'::TEXT)::TEXT,
    '[a-zA-Z\.0-9_]+',
    'app - select from register by id and check token'::TEXT
  );

  -- update: no update

  SELECT * FROM finish();

ROLLBACK;
