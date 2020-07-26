
------------------------
-- TESTs
------------------------
\c wdn_db;

SET search_path TO wdn_schema_1_0_0, public;

BEGIN;

  SELECT plan(3);
  -- Insert
  SELECT is (
    wdn_schema_1_0_0.process_logger('{
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
    wdn_schema_1_0_0.owner('{"type": "owner",
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
  --  wdn_schema_1_0_0.owner('my_app@1.0.0'::TEXT)::TEXT,
  --  '[a-zA-Z\.0-9_]+',
  --  'app - select from r egister by id and check token'::TEXT
  --);

  -- update: no update

  SELECT * FROM finish();

ROLLBACK;
