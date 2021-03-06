#! /bin/bash

# project config

PROJECT_TEST_FOLDER="test"
VM_PROJECT_PATH="/opt/app"
VM_PY_PATH="/usr/bin/python3.9"
DUMP_FILE="$VM_PROJECT_PATH/$PROJECT_TEST_FOLDER/api_test.sql"
REQUIREMENTS_FILE="$VM_PROJECT_PATH/requirements.txt"
TEST_FOLDER="$VM_PROJECT_PATH/$PROJECT_TEST_FOLDER"

function check_last_step() {
    if [ $1 -ne 0 ]; then
        printf "\n***************************************************\n\t\tDeployment Failed. \n***************************************************\n"
        printf "Exiting early because the previous step has failed.\n"
        printf "***************************************************\n\t\tDeployment Failed. \n***************************************************\n"
        exit 2
    fi
}

# Config app
cd $VM_PROJECT_PATH
chmod 666 $DUMP_FILE
pip3 install -r $REQUIREMENTS_FILE
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1
pip3 install virtualenv
python -m virtualenv -p $VM_PY_PATH $VM_PROJECT_PATH/venv
source $VM_PROJECT_PATH/venv/bin/activate
source $VM_PROJECT_PATH/.env.test
export ENV_FILE_LOCATION=$VM_PROJECT_PATH/.env.test

check_last_step $?

# testing app
cd $VM_PROJECT_PATH

sudo docker stop postgres
sudo docker rm postgres
sudo docker-compose up -d
cd $TEST_FOLDER
pip3 install -r $REQUIREMENTS_FILE
pip3 install nose

nosetests test*

check_last_step $?

deploy app
sudo docker stop $(sudo docker ps -aq)
sudo docker rm $(sudo docker ps -aq)
sudo docker rmi postgres:13-alpine

cd $VM_PROJECT_PATH
source venv/bin/activate
source .env
export ENV_FILE_LOCATION=$VM_PROJECT_PATH/.env
gunicorn -b 0.0.0.0:80 --daemon app:app

check_last_step $?

printf "\n***************************************************\n\t\tDeployment Sucessed. \n***************************************************\n"