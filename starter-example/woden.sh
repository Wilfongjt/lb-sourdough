###############
# Woden
###############
# * Woden makes JSON Web Tokens for your applications
# * Woden is a user
# * woden is configured by POSTGRES_USER
# * Woden is configured at startup
# * Woden is configured in .env
# *


###############
## Prerequisites
#########
# * add WODEN to .env, WODEN=[{"name":"woden@lyttlebit.com","password":"a1A!aaaa","roles":"admin"}]
# * create a woden (JSON Web Token) at https://jwt.io with the claim {"role": "guest_wgn"}
# * Docker-compose must be running
# fireup Docker-compose
###############
# Configure a woden aka JSON Web Token
# Make your woden at https://jwt.io
# at a minimum include the claim {"role": "guest_wgn"}
# you can reverse engineer the WODEN token below to gain some understanding
###############
echo ""
###############
# Set WODEN_TOKEN environment variable to help with curl
###############

# good WODEN_TOKEN
export WODEN_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJMeXR0bGVCaXQiLCJzdWIiOiJPcmlnaW4iLCJuYW1lIjoiV29kZW4iLCJyb2xlIjoiZ3Vlc3Rfd2duIn0.XjYxFfJ4HvgP6T7OupQdeMuxA9_WZCzRYRUGuVhNUQ4
echo "WODEN_TOKEN is $WODEN_TOKEN"
echo "--- Add Owner"
###############
# Add an owner aka a user with special privileges.
###############
curl http://localhost:3100/rpc/owner -X POST \
     -H "Authorization: Bearer $WODEN_TOKEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"name":"me@someplace.com", "password":"a1A!aaaa"}'
echo "---"
################
# BAD Signin and get owner-token
################
echo "--- Bad Signin user"
export AUTHORIZED_USER=$(curl http://localhost:3100/rpc/signin -X POST \
        -H "Authorization: Bearer $WODEN_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Prefer: params=single-object" \
        -d '{"name":"bad@someplace.com", "password":"a1A!aaaa"}')
echo "--- Bad Signin password"
export AUTHORIZED_USER=$(curl http://localhost:3100/rpc/signin -X POST \
        -H "Authorization: Bearer $WODEN_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Prefer: params=single-object" \
        -d '{"name":"me@someplace.com", "password":"xxxxa1A!aaaa"}')
################
# Signin and get owner-token
################
echo "--- Signin"
export AUTHORIZED_USER=$(curl http://localhost:3100/rpc/signin -X POST \
        -H "Authorization: Bearer $WODEN_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Prefer: params=single-object" \
        -d '{"name":"me@someplace.com", "password":"a1A!aaaa"}')

echo "AUTHORIZED_USER is $AUTHORIZED_USER"
# pull data out of json
export AUTHORIZED_USER=$(echo $AUTHORIZED_USER | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')
# get rid of enclosing quotes
export AUTHORIZED_USER=$(echo $AUTHORIZED_USER | sed 's/"//g' )
echo "---"
echo "AUTHORIZED_USER is $AUTHORIZED_USER"
echo "--- Add APP"
###############
# add an application to db
###############
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $AUTHORIZED_USER"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"name":"woden@1.0.0", "owner_id":"me@someplace.com"}'

###############
# Set Application Token
###############
#export APPTOKEN=\
#$(curl http://localhost:3100/rpc/app -X POST \
#     -H "Authorization: Bearer $APPTOKEN"   \
#     -H "Content-Type: application/json" \
#     -d '{"id": "request@1.0.0"}')
#     # extract the woden value
#     export APPTOKEN=$(echo $APPTOKEN | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')
#     # cleanup: remove starting and ending double quotes
#     export APPTOKEN=$(echo $APPTOKEN | sed 's/"//g' )
#echo "AppToken is $APPTOKEN"


##############
# Register an Application User
##############
#curl http://localhost:3100/rpc/actor -X POST \
#     -H "Authorization: Bearer $APPTOKEN"   \
#     -H "Content-Type: application/json" \
#     -H "Prefer: params=single-object"\
#     -d '{"type": "actor", "app_id": "request@1.0.0", "name": "me@someplace.com", "password": "a1A!aaaa"}'

##
##
##
