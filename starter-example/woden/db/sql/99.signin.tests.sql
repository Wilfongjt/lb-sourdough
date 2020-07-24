
------------------------
-- TESTs
------------------------
\c wdn_db;

SET search_path TO wdn_schema, public;

BEGIN;

  SELECT plan(3);
  -- Add user for test
  SELECT is (
    wdn_schema.owner('{
      "name":  "me@someplace.com",
      "password": "a1A!aaaa"
      }'::JSON
    ),
    '{"msg": "OK", "status": "200"}'::JSONB,
    'owner - insert test'::TEXT
  );
  -- Insert
SELECT ok (
  wdn_schema.signin('{
    "name":  "me@someplace.com",
    "password": "a1A!aaaa"
    }'
  )::JSON ->> 'status' = '200','signin - insert'
);
/*
  SELECT is (
    wdn_schema.signin('{
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
    wdn_schema.owner('{"type": "owner",
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
  --  wdn_schema.owner('my_app@1.0.0'::TEXT)::TEXT,
  --  '[a-zA-Z\.0-9_]+',
  --  'app - select from regi ster by id and check token'::TEXT
  --);

  -- update: no update

  SELECT * FROM finish();

ROLLBACK;
