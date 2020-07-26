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

## Strategy
* Use schemata for versioning the API
* Configure schema API versions using db/woden_N_N_N.sql file name pattern ( a new file for each version)
* Leave older versions in the db/ folder. This will leave all versions in the database 
* docker-compose can only run one schema. Designate current schema in the .env file

# Woden API 1.0.0 (wdn_1_0_0)
Located in woden_1_0_0.sql 
```
owner(owner_form JSON)
owner(id TEXT, owner_form JSON)
owner(id TEXT)

signin(signin_form JSON)

app(app_form JSON)
app(id TEXT, app_form JSON)
app(id TEXT)
```

# Setup
Environment (.env)
```
#########################
######## DOCKER RUNTIME
##########################
POSTGRES_DB=wdn_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=mysecretdatabasepassword
POSTGRES_JWT_SECRET=PASSWORDmustBEATLEAST32CHARSLONGLONG
LB_GUEST_PASSWORD=mysecretclientpassword
PGRST_DB_SCHEMA=wdn_schema_1_0_0
PGRST_DB_ANON_ROLE=wdn_guest

WODENADMIN=[{"name":"admin@lyttlebit.com","password":"a1A!aaaa","roles":"admin"}]

```





# Overview



## Curl Client

*
# Woden
The Germanic chief god, distributor of talents, wisdom and war. In this case, Woden distributes access and permissions via JSON Web Tokens. 

## Frontend Prerequisites
* Woden-token

### Woden Token
The woden token authorizes access to the signin function of the Woden API.  
Put the Woden Token in the client environment. 
* Manually create a JSON Web Token for Woden at https://jwt.io
    * payload: {"iss": "LyttleBit", "sub": "Origin", "name": "Woden", "role": "guest_wdn"}
    * password should be 32 characters long and is the same value as POSTGRES_JWT_SECRET


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
#client
LB_GUEST_PASSWORD=mysecretclientpassword
LB_WODEN={"name":"woden@lyttlebit.com","password":"a1A!aaaa"}

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
