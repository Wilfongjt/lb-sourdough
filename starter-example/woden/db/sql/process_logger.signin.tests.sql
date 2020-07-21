
------------------------
-- TESTs
------------------------
\c woden_db;

SET search_path TO app_schema, public;

BEGIN;

  SELECT plan(3);
  -- Insert
  SELECT is (
    app_schema.process_logger('{
      "type":"test",
      "name":"some stuff",
      "desc":"more stuff"
      }'::JSONB
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'process_logger - insert test'::TEXT
  );

  -- Update
  /*
  SELECT is (
    app_schema.owner('{"type": "owner",
      "app_id": "my_app@1.0.0",
      "name": "me@someplace.com",
      "password": "a2A!aaaa"}'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'owner - update test'::TEXT
  );
*/
  -- select
  --SELECT matches(
  --  app_schema.owner('my_app@1.0.0'::TEXT)::TEXT,
  --  '[a-zA-Z\.0-9_]+',
  --  'app - select from register by id and check token'::TEXT
  --);

  -- update: no update

  SELECT * FROM finish();

ROLLBACK;
