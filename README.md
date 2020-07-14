# lb-sourdough
A starter for an API backed by a single table.

* The system is enabled by a JWT token called a woden
* The system expects to be run over an encrypted connection
* Woden is the origin
* LyttleBit is Woden
* RegisterAPI is the application and actor management system API
* AdoptionAPI is an application specific API
* Adopt-a-Drain is an application
* Adopt-a-Drain uses the RegisterAPI API
* Adopt-a-Drain uses the AdoptionAPI API
* Passwords are encrypted before storage
* Passwords are never passed out of the database system
* Registered applications have an application specific token called an app-token
* Actors is a user
* Actors get a temporary JWT token called a actor-token
* Actor-tokens expire
* RegisterAPI woden API call does not require a token
* Wodens do not expire
* Wodens can be replaced


# Setup
1. Configure
   1. Environment (.env)
   2. Manually Configure woden: Run docker-compose
   3. Get a woden: Curl a worden
2. Register an Application
   1. Create an Application record
   2. Check proper application creation: Curl an Application  
3. Register an Application User record
   1. Create a actor
   2. Check proper actor creation: Curl a actor
_4. Signin to Application_
   _1. Update login counter_
   _2. Update updated to current date_


## Setup
  1.1. Configure .env (place .env in folder with docker-compose.yml)
  ```
      POSTGRES_DB=application_db
      POSTGRES_USER=postgres
      POSTGRES_PASSWORD=mysecretdatabasepassword
      POSTGRES_JWT_SECRET=PASSWORDmustBEATLEAST32CHARSLONG
      LB_GUEST_PASSWORD=mysecretclientpassword
      PGRST_DB_SCHEMA=api_schema
      PGRST_DB_ANON_ROLE=api_guest
  ```

  1.2. Fireup docker-compose:
  ```
      docker-compose up
  ```

  3. Get a woden from the docker-compose start up or get one from postgres with woden()
  4. Set WODEN environment variable:
  ```
      # this woden will work but may break in the future
      # run docker-compose up to get fresh woden  
      export WODEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJMeXR0bGVCaXQiLCJzdWIiOiJPcmlnaW4iLCJuYW1lIjoiV29kZW4iLCJyb2xlIjoiYXBpX2d1ZXN0IiwidHlwZSI6ImFwcCJ9.tocptwoT-rnls4PmWhj82AMeEhyC4fs7ZfhbCLhNB0M"

  ```
  5. Register an application
  ```
      curl http://localhost:3100/rpc/app -X POST \
           -H "Authorization: Bearer $WODEN"   \
           -H "Content-Type: application/json" \
           -H "Prefer: params=single-object"\
           -d '{"type": "app", "name": "request@1.0.0", "group":"register", "owner": "me@someplace.com", "password": "a1A!aaaa"}'
  ```
  6. Get application-token: app('{"id":""}')
  ```
      curl http://localhost:3100/rpc/app -X POST \
           -H "Authorization: Bearer $WODEN"   \
           -H "Content-Type: application/json" \
           -d '{"id": "my_app@1.0.0"}'
  ```
  7. Set AADTOKEN environment variable:
  ```
      export AADTOKEN=<application-token>
  ```
  8. Register AAD application actor (repeat as needed)
  ```
      curl http://localhost:3100/rpc/actor -X POST \
           -H "Authorization: Bearer $APPTOKEN"   \
           -H "Content-Type: application/json" \
           -H "Prefer: params=single-object"\
           -d '{"type": "actor", "name": "request@1.0.0", "username": "me@someplace.com", "password": "a1A!aaaa"}'

  ```
  9. Application Signin Or get actor-token:
  ```
      curl http://localhost:3100/rpc/actor -X POST \
           -H "Authorization: Bearer $APPTOKEN"   \
           -H "Content-Type: application/json" \
           -d '{"username":"", "password":""}'
  ```

# DB Overview

application_db
    api_schema
        woden ()
        register columns: (id, type, form, password, active, created, updated)
            app: atts: (id, type, app-name, version, username, [password], token)
              insert app (Authorization: woden)(creates:app-token)
              select app (Authorization: woden)(returns:app-token)
            actor: atts: (id, type, app_id, username,[password])
              insert actor (Authorization: app-token)
              select actor (app-token)(returns: actor-token)
              update actor (actor-token)
              delete/deactivate actor (actor-token)
        adoption columns: (id, type, form, active, created, updated)
            adoption
              insert adoption (actor-token)
              update adoption (actor-token)
              delete adoption (actor-token)
roles
    api_guest
    app_guest
    actor_editor
tokens
      woden: claims: (iss, sub, name, role, type)
        type: app
        role: api_guest
      app-token: claims: (iss, sub, name, role, type)  
        _iss: LyttleBit_
        _sub: _
        _name: <application-name>_
        _roles:[app_guest]_
        _type: actor_
      _actor-token: claims: (iss, sub, name, role, type)_
        _iss:_
        _sub:_
        _name: <username>_
        _roles: []_
        _type:_

# History
* actor: upsert for actor
* roles: change from single role to multiple roles   
* woden: add iss, sub, name, roles type to woden  
* add insert test for app
* add select test for app  
