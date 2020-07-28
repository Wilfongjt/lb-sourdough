
------------------------
-- TESTs
------------------------
\c wdn_db;

SET search_path TO wdn_schema_1_0_0, public;

BEGIN;

  SELECT plan(2);
  -- Insert
  SELECT is (
    wdn_schema_1_0_0.app('{
      "name": "my_app@1.0.0",
      "owner_id": "me@someplace.com"}'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'app - insert test'::TEXT
  );

  -- select
  SELECT matches(
    wdn_schema_1_0_0.app('my_app@1.0.0'::TEXT)::TEXT,
    '[a-zA-Z\.0-9_]+',
    'app - select from register by id and check token'::TEXT
  );

  -- update: no update

  SELECT * FROM finish();

ROLLBACK;

-------------------
-- OWNER TESTs
-------------------

BEGIN;

  SELECT plan(3);
  -- Insert
  SELECT is (
    wdn_schema_1_0_0.owner('{
      "name":  "me@someplace.com",
      "password": "a1A!aaaa"
      }'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'owner - insert test'::TEXT
  );

  SELECT * FROM finish();

ROLLBACK;

--------------------
-- PROCESS_LOGGER Tests
--------------------

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

  SELECT * FROM finish();

ROLLBACK;



-------------------
-- SIGNIN Tests
-------------------

BEGIN;

  SELECT plan(3);
  -- Add user for test
  SELECT is (
    wdn_schema_1_0_0.owner('{
      "name":  "me@someplace.com",
      "password": "a1A!aaaa"
      }'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'owner - insert test'::TEXT
  );
  -- Insert
SELECT ok (
  wdn_schema_1_0_0.signin('{
    "name":  "me@someplace.com",
    "password": "a1A!aaaa"
    }'
  )::JSON ->> 'status' = '200','signin - insert'
);

  SELECT * FROM finish();

ROLLBACK;
