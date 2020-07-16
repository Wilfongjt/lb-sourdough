# lb-sourdough
A starter for an API backed by a single table.

# Expectations
* The system is enabled by a JWT token called a woden
* The system expects to be run over an encrypted connection
* Woden is the origin
* LyttleBit is Woden
* RegisterAPI is the application and actor management system API
* RegisterAPI expects share your application API with multiple clients
* RegisterAPI expects multiple actors/users
* MyApplicationAPI is an application specific API
* My-Application is an application
* My-Application uses the RegisterAPI API
* My-Application uses the MyApplicationAPI API
* Passwords are encrypted before storage
* Passwords are never passed out of the database system
* Registered applications have an application specific token called an app-token
* Actor is a user
* Actors get a temporary JWT token, called a actor-token
* Actor-tokens expire
* Getting a woden does not require a token
* Wodens do not expire
* Wodens can be replaced


# Overview
## Get Server Running (up.sh)
   * Environment (.env)
   * Fireup docker-compose
   * Check server connection: Curl a woden
## Get Client Talking to Server (woden.sh)
   * Manually configure woden in client environment
## Register an Application with the database (newapp.sh)
   * Create an Application record
   * Check proper application creation: Curl an app-token  
## Get Application Talking to the RegisterAPI ()
   * Manually configure app-token in client environment
## Register an Application Actor/User record ()
   * _Create a actor_
   * _Check proper actor creation: Curl an actor_
## _Signin to Application_
   _1. Update login counter_
   _2. Update updated to current date_


## Get Started
  1. Environment (.env)
  * place .env in folder with docker-compose.yml
  ```
      POSTGRES_DB=application_db
      POSTGRES_USER=postgres
      POSTGRES_PASSWORD=mysecretdatabasepassword
      POSTGRES_JWT_SECRET=PASSWORDmustBEATLEAST32CHARSLONG
      LB_GUEST_PASSWORD=mysecretclientpassword
      PGRST_DB_SCHEMA=api_schema
      PGRST_DB_ANON_ROLE=api_guest
  ```

  2. Fireup docker-compose:
  ```
      # cd to folder with docker-compose.yml
      docker-compose up
  ```
  3. Curl a woden
  ```
  curl http://localhost:3100/rpc/woden -X POST \
       -H "Content-Type: application/json"
  ```
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
           -d '{"type": "app", "name": "my-application@1.0.0", "group":"register", "owner": "me@someplace.com", "password": "a1A!aaaa"}'
  ```
  6. Get application-token: app('{"id":""}')
  ```
      curl http://localhost:3100/rpc/app -X POST \
           -H "Authorization: Bearer $WODEN"   \
           -H "Content-Type: application/json" \
           -d '{"id": "my_app@1.0.0"}'
  ```
  7. Set APPTOKEN environment variable:
  ```
      export APPTOKEN=<application-token>
  ```
  8. Register APP application actor (repeat as needed)
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
apis
    app(JSON)
    app(TEXT)
    actor(JSON)
    actor(TEXT)
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
