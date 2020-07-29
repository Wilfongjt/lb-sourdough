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
# Set STARTER_TOKEN environment variable to help with curl
###############

# good STARTER_TOKEN
export STARTER_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJMeXR0bGVCaXQiLCJzdWIiOiJPcmlnaW4iLCJuYW1lIjoiV29kZW4iLCJyb2xlIjoiZ3Vlc3Rfd2duIn0.XjYxFfJ4HvgP6T7OupQdeMuxA9_WZCzRYRUGuVhNUQ4
echo "STARTER_TOKEN is $STARTER_TOKEN"

################
# Signin and get owner-token
################
echo "--- Signin"
export OWNER_TOKEN=$(curl http://localhost:3100/rpc/signin -X POST \
        -H "Authorization: Bearer $STARTER_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Content-Profile: wdn_schema_1_0_0" \
        -H "Prefer: params=single-object" \
        -d '{"name":"woden@lyttlebit.com", "password":"a1A!aaaa"}')

echo "OWNER_TOKEN is $OWNER_TOKEN"
# pull data out of json
export OWNER_TOKEN=$(echo $OWNER_TOKEN | grep -o '["^][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*[\.][a-zA-Z0-9_\-]*["$]')
# get rid of enclosing quotes
export OWNER_TOKEN=$(echo $OWNER_TOKEN | sed 's/"//g' )
echo "---"
echo "OWNER_TOKEN is $OWNER_TOKEN"
echo "--- Add APP"
###############
# add an application to db
###############
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $OWNER_TOKEN"   \
     -H "Content-Type: application/json" \
     -H "Content-Profile: wdn_schema_1_0_0" \
     -H "Prefer: params=single-object"\
     -d '{"name":"woden@1.0.0", "owner_id":"woden@lyttlebit.com"}'

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
