!/bin/bash
# source ./__scripts/00.settings.sh
source ./_conf.sh

# check for database folder and make if not there
echo "LB_ENV_working_folder is ${LB_ENV_working_folder}"
echo "LB_ENV_data_folder is ${LB_ENV_data_folder}"
echo "LB_PROJECT_branch is ${LB_PROJECT_branch}"
echo "LB_PROJECT_name is ${LB_PROJECT_name}"
echo "LB_PROJECT_prefix is ${LB_PROJECT_prefix}"
echo "LB_PROJECT_owner is ${LB_PROJECT_owner}"
echo "LB_POSTGRES_MODEL_username is ${LB_POSTGRES_MODEL_username}"
echo "LB_POSTGRES_MODEL_password is ${LB_POSTGRES_MODEL_password}"
echo "LB_DB_MODEL_username is ${LB_DB_MODEL_username}"
echo "LB_DB_MODEL_role is ${LB_DB_MODEL_role}"
echo "LB_DB_MODEL_password is ${LB_DB_MODEL_password}"
echo "MY_REPOURL is ${MY_REPOURL}"

cd exmpl/
echo '---------------- API environment ----------------'
docker-compose run api env
echo '---------------- DB environment ----------------'
docker-compose run db env




