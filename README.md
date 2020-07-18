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

# Architecture 

## Woden
Administrate portfolio of applications
Originator of application tokens
Recomend One per organization 
Init
* Manually make a woden, https://jwt.io  
* configure woden in your environment

Storage
    * register 
Functions           
    * app()             
    * actor-owner() 
    * woden()

## Application-Configuration
Custom configuration for an application.
One per application 
Init 
* get app-token from Woden
* configure in enviroment

Storage
    * application
Functions
    * actor-admin()
    * token-app()

## Application
Storage
    * application
Function    
    * actor-user()
    * token()
*

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

# Woden API Overview
* Keep a list of applications
* Keep a list of application owners
* Provide an app-token for a specific application
* 
 
 ## woden_db
 ### app_schema
      
Register TABLE columns: id, type, form, active, created, updated
              
Owner API: {id, type, |email|, name, [password]}
            
| Func   | call        | token         | VERB | return |
| ------- | -------------- | ------------------- | ---- | ---------- |
| insert | owner(JSON) | \<woden-token> | POST | \<status> |
| signin | owner(TEXT,TEXT) | \<woden-token> | POST | \<owner> | 
| select | owner(TEXT) | \<app-token>   | GET  | \<json> |
| select | owner(TEXT, JSON) | \<app-token> | GET | \<status> |
| update | owner(JSON) | \<owner-token> | POST | \<status> |
| delete | owner(????,????) | \<owner-token> | DELETE | \<status> |

<status> is {"status":"", "msg":""} 
<owner> is {"status":"200", "token":"<app-token>"}

              
App API: {id, type, |name|, owner_id, token}

| Func   | call        | token         | VERB | return |
| ====== | =========== | ============= | ==== | ====== |
| insert | app(JSON) | <owner-token> | POST | <status> |
| select | app(TEXT) | <owner-token> | GET | <status> |
| select | app(TEXT, JSON) | <????-token> | GET | <status> |
| update | app(JSON) | <????-token> | POST | <status> |
| delete | app(????,????) | <????-token> | DELETE | <status> |
            
                
        * [ ] is encrypted value
        * | | is id value or part of a compound id value
        * ( ) is parameter list
        * { } is json attribute list
        * < > is value/variable
        * id attribute triggers an update
        * ???? is a marker for undefined
        * table has index on id 
        
        
  roles
  
       app_guest
       owner_editor
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

# Exmpl Model Overview

application_db
    api_schema
        woden ()
        register columns: (id, type, form, password, active, created, updated)
            app: atts: (id, type, app-name, version, username, [password], token)
              insert app (Authorization: woden)(creates:app-token)
              select app (Authorization: woden)(returns:app-token)
            actor: atts: (id, type, app_id, name,[password])
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
