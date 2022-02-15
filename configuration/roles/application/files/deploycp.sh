#! /bin/bash

# variables
PROJECT_TEST_FOLDER="test"
VM_PROJECT_PATH="/opt/app"
VM_PY_PATH="/usr/bin/python3.9"
DUMP_FILE="api_test.sql"
REQUIREMENTS_FILE="$VM_PROJECT_PATH/requirements.txt"
TEST_FOLDER="$VM_PROJECT_PATH/$PROJECT_TEST_FOLDER"

echo $(date -u) "Strating deploy script" &>>/var/log/app/app.log

cd $VM_PROJECT_PATH

function setup() {
    printf "***************************************************\n\t\tSetting up Venv \n***************************************************\n"
    # Install virtualenv
    echo 
    echo ======= Installing requiments =======
    pip3 install -r $REQUIREMENTS_FILE
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1
    echo 
    echo ======= Installing virtualenv =======
    pip3 install virtualenv

    # Create virtual environment and activate it
    echo 
    echo ======== Creating virtual env =======
    cd $VM_PROJECT_PATH
    python -m virtualenv -p $VM_PY_PATH $VM_PROJECT_PATH/venv

    echo ======== Activating virtual env =======
    source $VM_PROJECT_PATH/venv/bin/activate
}

# Create and Export required environment variable
function setup_env() {
    printf "***************************************************\n\t\tSetting up environment \n***************************************************\n"
    
    if [[ $1 == "test" ]]; then
        echo 
        echo ======= Exporting the environment variables from "$VM_PROJECT_PATH/.env.test" ========
        source $VM_PROJECT_PATH/.env.test
    elif [[ $1 == "deploy" ]]; then
        echo 
        echo ======= Exporting the environment variables from "$VM_PROJECT_PATH/.env" ========
        export ENV_FILE_LOCATION=$VM_PROJECT_PATH/.env
        source $VM_PROJECT_PATH/.env
    else    
        echo 
        echo ====== Parameter $1 invalid ========
    fi  
}

# Run tests
function setup_docker() {
    printf "***************************************************\n\t\tSetup PostgreSQL docker \n***************************************************\n"

    test_folder="$VM_PROJECT_PATH/$PROJECT_TEST_FOLDER"

    if [[ $1 == "up" ]]; then
        if [[ -d $test_folder ]]; then
            echo 
            echo ====== stop previously postgresql docker ========
            sudo docker stop $(sudo docker ps -aq)
            sudo docker rm $(sudo docker ps -aq)
            echo 
            echo ====== start postgresql docker ========
            cd $VM_PROJECT_PATH
            source $VM_PROJECT_PATH/.env.test
            sudo docker-compose up -d

        else
            echo 
            echo ====== No "test" folder found ========
        fi
    elif [[ $1 == "down" ]]; then
        echo 
        echo ====== removing postgresql docker ========
        sudo docker stop $(sudo docker ps -aq)
        sudo docker rm $(sudo docker ps -aq)
        sudo docker rmi postgres:13-alpine
    else
        echo 
        echo ====== Parameter $1 invalid ========
    fi   

}

function run_tests() {
    printf "***************************************************\n\t\tRunning tests \n***************************************************\n"

    if [[ -d $test_folder ]]; then
        echo 
        echo ====== Installing nose ========
        cd $test_folder
        pip3 install nose
        echo 
        echo ====== Starting unit tests ========
        nosetests test*
    else
        echo 
        echo ====== No "test" folder found ========
    fi   
}

function deploy() {
    printf "***************************************************\n\t\tDeploy app \n***************************************************\n"
    
    echo 
    echo ======== Activating envs =======
    cd $VM_PROJECT_PATH
    source venv/bin/activate
    source .env
    export ENV_FILE_LOCATION=$VM_PROJECT_PATH/.env
    echo ======== start application =======
    gunicorn -b 0.0.0.0:80 --daemon app:app

}

function check_last_step() {
    if [ $1 -ne 0 ]; then
        printf "\n***************************************************\n\t\tDeployment Failed. \n***************************************************\n"
        printf "Exiting early because the previous step has failed.\n"
        printf "For more information read /var/log/app/app.log.\n"
        printf "***************************************************\n\t\tDeployment Failed. \n***************************************************\n"
        exit 2
    fi
}

setup &>>/var/log/app/app.log
check_last_step $?

setup_env "test" &>>/var/log/app/app.log
check_last_step $?

setup_docker "up"
check_last_step $?

run_tests &>>/var/log/app/app.log
check_last_step $?

setup_docker "down" &>>/var/log/app/app.log
check_last_step $?

setup_env "deploy"
check_last_step $?

deploy &>>/var/log/app/app.log
check_last_step $?
