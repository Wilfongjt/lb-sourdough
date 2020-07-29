# Setup Environment

## .env
```
echo 'POSTGRES_DB=application_db' > .env
echo 'POSTGRES_USER=postgres' >> .env
echo 'POSTGRES_PASSWORD=mysecretdatabasepassword' >> .env
echo 'POSTGRES_JWT_SECRET=PASSWORDmustBEATLEAST32CHARSLONG' >> .env
echo 'LB_GUEST_PASSWORD=mysecretclientpassword' >> .env
echo 'PGRST_DB_SCHEMA=api_schema' >> .env
echo 'PGRST_DB_ANON_ROLE=api_guest' >> .env
```

# woden
```
# this woden will work but may break in the future
# run docker-compose up to get fresh woden  
export WODEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJMeXR0bGVCaXQiLCJzdWIiOiJPcmlnaW4iLCJuYW1lIjoiV29kZW4iLCJyb2xlIjoiYXBpX2d1ZXN0IiwidHlwZSI6ImFwcCJ9.tocptwoT-rnls4PmWhj82AMeEhyC4fs7ZfhbCLhNB0M"
```
# Docker Compose
```
docker-compose up
```
# Processes

## Register an Application
```
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -H "Prefer: params=single-object"\
     -d '{"type": "app", "name": "request@1.0.0", "group":"register", "owner": "me@someplace.com", "password": "a1A!aaaa"}'
```

## Get an Application Token
```
curl http://localhost:3100/rpc/app -X POST \
     -H "Authorization: Bearer $WODEN"   \
     -H "Content-Type: application/json" \
     -d '{"id": "my_app@1.0.0"}'
```
