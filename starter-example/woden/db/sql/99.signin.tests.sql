
------------------------
-- TESTs
------------------------
\c woden_db;

SET search_path TO app_schema, public;

BEGIN;

  SELECT plan(3);
  -- Add user for test
  SELECT is (
    app_schema.owner('{"type": "owner",
      "name":  "me@someplace.com",
      "email": "me@someplace.com",
      "password": "a1A!aaaa"
      }'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'owner - insert test'::TEXT
  );
  -- Insert
SELECT ok (
  app_schema.signin('{
    "name":  "me@someplace.com",
    "password": "a1A!aaaa"
    }'
  )::JSON ->> 'status' = '200','signin - insert'
);
/*
  SELECT is (
    app_schema.signin('{
      "name":  "me@someplace.com",
      "password": "a1A!aaaa"
      }'::JSON
    ),
    '{"id": "me@someplace.com", "name": "me@someplace.com", "type": "owner", "email": "me@someplace.com", "status": "200"}'::JSONB,
    'signin - insert test'::TEXT
  );
*/




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
