# lb-sourdough
A starter for an API, backed by a single table. 

# Expectations
* The system is enabled by a JWT token called a woden
* The system expects to be run over an encrypted connection
* Woden is the origin
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
* Woden is an actor 
* Actors get a temporary JWT token, called a actor-token
* Actor-tokens expire
* Getting a woden does not require a token
* Wodens do not expire
* Wodens can be replaced

## Strategy
* Single database, single table design
* Use postgres __schemata__ for versioning the API
* Separate API functions sql file  
* Use __docker-compose__ to pull it all together.


## Prerequisites
* Woden-token
* environment variable file (.env)

## Woden Token
The woden token authorizes access to the signin function of the Woden API.  
Put the Woden Token in the client environment. 
* Manually create a woden (JSON Web Token) at https://jwt.io
    * payload: {"role": "guest_wdn"}
    * jwt.io requires a passord and that password should be at least 32 characters long and is the same value as POSTGRES_JWT_SECRET

## Important
* Change your woden. The woden token shown below is dependent on the POSTGRES_JWT_SECRET.  Changing the POSTGRES_JWT_SECRET will change the woden.  The woden token below will work for every application that uses the "PASSWORDmustBEATLEAST32CHARSLONGLONG" secret.  Not good. Change your password.


# Woden Example
The Germanic chief god, distributor of talents, wisdom and war. In this case, Woden distributes access and permissions via JSON Web Tokens. 
* Initialize a woden when

## Woden API 1.1.0 (wdn_1_1_0)
* actor(form JSON) - insert an actor by woden, encrypts password
* app(form JSON) - insert an application, generates an application specific JWT
* owner(form JSON) - insert an owner by woden, encrypts password
* siginin(form JSON) - insert an attempt to login, returns JWT on success

### Environment Setup (.env)
.env file goes in folder with docker-compose.yml
```
    # Postgres
    POSTGRES_DB=wdn_db
    POSTGRES_USER=postgres
    POSTGRES_PASSWORD=mysecretdatabasepassword
    POSTGRES_JWT_SECRET=PASSWORDmustBEATLEAST32CHARSLONGLONG
    # PostREST, setup all version schemata
    PGRST_DB_SCHEMA=wdn_schema_1_0_0,wdn_schema_1_1_0
    PGRST_DB_ANON_ROLE=guest_wdn
    # Lyttlebit
    LB_WODEN={"name":"woden@lyttlebit.com","password":"a1A!aaaa","roles":"admin"}
    LB_GUEST_PASSWORD=mysecretclientpassword
```

## Woden API 1.0.0 (wdn_1_0_0)
* app(JSON)- insert an application, generates an application specific JWT
* siginin(JSON) - insert attempt to login, returns JWT on sucess
* owner(form JSON) - insert an owner by woden, encrypts password

### Environment Setup (.env)
.env file goes in folder with docker-compose.yml
```
    # Postgres
        POSTGRES_DB=wdn_db
        POSTGRES_USER=postgres
        POSTGRES_PASSWORD=mysecretdatabasepassword
        POSTGRES_JWT_SECRET=PASSWORDmustBEATLEAST32CHARSLONGLONG
    # PostREST
        PGRST_DB_SCHEMA=wdn_schema_1_0_0
        PGRST_DB_ANON_ROLE=guest_wdn
    # Lyttlebit
        LB_WODEN={"name":"woden@lyttlebit.com","password":"a1A!aaaa","roles":"admin"}
        LB_GUEST_PASSWORD=mysecretclientpassword
```
## Curl
```
    # woden (JWT)
        export WODEN_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJMeXR0bGVCaXQiLCJzdWIiOiJPcmlnaW4iLCJuYW1lIjoiV29kZW4iLCJyb2xlIjoiZ3Vlc3Rfd2duIn0.XjYxFfJ4HvgP6T7OupQdeMuxA9_WZCzRYRUGuVhNUQ4

    # Signin and get owner-token
        export AUTHORIZED_USER=$(curl http://localhost:3100/rpc/signin -X POST \
                -H "Authorization: Bearer $WODEN_TOKEN" \
                -H "Content-Type: application/json" \
                -H "Content-Profile: wdn_schema_1_0_0" \
                -H "Prefer: params=single-object" \
                -d '{"name":"woden@lyttlebit.com", "password":"a1A!aaaa"}')

    # pull data out of json and set a one time token for the woden 
        export AUTHORIZED_USER=$(echo $AUTHORIZED_USER | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')
    
    # get rid of enclosing quotes
        export AUTHORIZED_USER=$(echo $AUTHORIZED_USER | sed 's/"//g' )

    # use the one time token to add an application to db
        curl http://localhost:3100/rpc/app -X POST \
             -H "Authorization: Bearer $AUTHORIZED_USER"   \
             -H "Content-Type: application/json" \
             -H "Content-Profile: wdn_schema_1_0_0" \
             -H "Prefer: params=single-object"\
             -d '{"name":"woden@1.0.0", "owner_id":"woden@lyttlebit.com"}'
```




# Overview



## Curl Client
*


## Backend Prerequisites 
* Name the Woden 
* Environment File (.env)
* Docker-compose 

### Name the Woden
Give Woden a user name and password. The woden can add applications and therefor create an application specific JWT.  
Put Woden in the .env.
```
LB_WODEN=LB_WODEN={"name":"woden@lyttlebit.com","password":"a1A!aaaa"}
```

### Backend Environment File (.env)
* Put the .env file in the folder with the docker-compose.yml 
```
# database 
POSTGRES_DB=wdn_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=mysecretdatabasepassword
POSTGRES_JWT_SECRET=PASSWORDmustBEATLEAST32CHARSLONGLONG
# api
PGRST_DB_SCHEMA=wdn_v_1_0_0
PGRST_DB_ANON_ROLE=wdn_guest
LB_WODEN={"name":"woden@lyttlebit.com","password":"a1A!aaaa"}
#client
LB_GUEST_PASSWORD=mysecretclientpassword
```
* Swap out the passwords and secrets 

# Woden API Overview
* Keep a list of applications
* Keep a list of application owners
* Provide an app-token for a specific application

## Owner 
 ```
DATABASE:   wdn_db
SCHEMA:     wdn_schema
TABLE:      Register
COLUMNS:    id, type, form, active, created, updated
INDEX:      id
ROLE:       guest_wgn
ROLE:       owner_editor
```
```
API: Owner, CRUD
    owner: {id, type, |email|, name, [password]}

               function           token           VERB     return   guest_wgn
               --------           -----           ----     ------   ---------
    * insert , owner(owner::JSON),<woden-token> , POST   , <status> E
    * select , owner(TEXT)      , <app-token>   , GET    , <owner>  N
    * select , owner(TEXT, JSON), <app-token>   , GET    , <owner>  N
    * update , owner(JSON)      , <owner-token> , POST   , <status> N
    * delete , owner(????,????) , <owner-token> , DELETE , <status> N

Permissions CRUDE: Create Read Update Delete Execute
                    guest_wgn   owner_editor
register                C           RUD
C owner(JSON)           E
R owner(TEXT)                       E
U owner(TEXT, JSON)                 E
D owner(????)                       E
C app(JSON)                         E
R app(TEXT)                         E
U app(TEXT, JSON)                   E
D app(????,????)                    E
Rules:
    * Anyone can add an owner
    * Ownership is designated by the id in the owner record
    * User can only modifiy (UD) their own data, row specific
    * User can see all applications in the portfolio
    * Application is owned by the person who enters it
    *

    <status> is {"status":"", "msg":""}
    <owner> is {"status":"200", "token":"<app-token>"}
    <woden-token> is {"iss": "LyttleBit", "sub": "Origin", "name": "Woden", "role": "wdn_guest", "type": "owner"}
    <app-token>   is {"iss": "LyttleBit", "sub": "Origin", "name": "Woden", "role": "????_guest", "type": "owner"}
```
## Signin
```
API: Signin, C
    signin:  {"type":"signin", "name":"<email>", "password":"<TEXT>"}

    * insert , signin(signin::JSON), <woden-token> , POST   , <owner>

    Dependencis
    owner:
    <owner-token> is

```
## App
```
API: App, form: {id, type, |name|, owner_id, token}
               function           token           VERB     return
               --------           -----           ----     ------
    * insert , app(JSON)        , <owner-token> , POST   , <status>
    * select , app(TEXT)        , <owner-token> , GET    , <status>
    * select , app(TEXT, JSON)  , <????-token>  , GET    , <status>
    * update , app(JSON)        , <????-token>  , POST   , <status>
    * delete , app(????,????)   , <????-token>  , DELETE , <status>


* [ ] is encrypted value
* | | is id value or part of a compound id value
* ( ) is parameter list
* { } is json attribute list
* < > is value/variable
* id attribute triggers an update
* ???? is a marker for undefined
* table has index on id



  roles
    guest_wgn
    owner_editor
 ```      
  tokens
        woden: claims: (iss, sub, name, role, type)
          type: app
          role: api_guest
        app-token: claims: (iss, sub, name, role, type)  
          _iss: LyttleBit_
          _sub: _
          _name: <application-name>_
          _roles:[guest_wgn]_
          _type: actor_
        _actor-token: claims: (iss, sub, name, role, type)_
          _iss:_
          _sub:_
          _name: <username>_
          _roles: []_
          _type:_

                    guest_wgn,  owner_editor
        register    C           

        app(JSON)               
        app(JSON)   

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
    guest_wgn
    actor_editor
tokens
      woden: claims: (iss, sub, name, role, type)
        type: app
        role: api_guest
      app-token: claims: (iss, sub, name, role, type)  
        _iss: LyttleBit_
        _sub: _
        _name: <application-name>_
        _roles:[guest_wgn]_
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
