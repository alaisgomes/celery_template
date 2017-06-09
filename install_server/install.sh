#!/bin/bash
# HEX
# script to install required apps for server:
#     RabbitMQ, Celery, NGINX, uWSGI

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in

        -n|--project-name)
        shift 
        PROJECT_NAME="$1" # Django project name
        ;;

        -n=*|--project-name=*)
        PROJECT_NAME="${key#*=}"
        ;;
        *)

        # Do whatever you want with extra options
        echo "Unknown argument passed '$key'"
        ;;
    esac
    # Shift after checking all the cases to get the next option
    shift

done


if [ -z $PROJECT_NAME ]
then
    PROJECT_NAME="hexgis_project"

fi

# Getting Python and pip
    cd
    sudo apt-get update
    sudo apt-get install python3
    sudo apt-get install python3-pip

    # Virtual env. 
    sudo -H pip3 install --upgrade pip
    sudo -H pip3 install virtualenv virtualenvwrapper

    echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bashrc
    echo "export WORKON_HOME=~/Env" >> ~/.bashrc
    echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
    source ~/.bashrc
    mkvirtualenv $PROJECT_NAME
    workon $PROJECT_NAME

    # UWSGI: install and configure
    cd
    sudo -H pip3 install uwsgi
    sudo mkdir -p /etc/uwsgi/sites

    # .ini file

    extension=".ini"
    uswgi_ini_path="/etc/uwsgi/sites/$PROJECT_NAME$extension"
    sudo sh -c -e "echo '[uwsgi] \nproject = $PROJECT_NAME \nuid = $USER \nbase = /home/%(uid)\n' > $uswgi_ini_path"
    sudo sh -c -e "echo 'chdir = %(base)/%(project)\nhome = %(base)/Env/%(project) \nmodule = %(project).wsgi:application' >> $uswgi_ini_path"
    sudo sh -c -e "echo '\nmaster = true \nprocesses = 10\n\nsocket = /run/uwsgi/%(project).sock \nchown-socket = %(uid):www-data 
    \nchmod-socket = 660 \nvacuum = true' >> $uswgi_ini_path"

    # uswgi.service file 
    uwsgi_service_path="/etc/systemd/system/uwsgi.service"
    sudo sh -c -e "echo '[Unit] \nDescription=uWSGI Emperor service\n\n[Service]' > $uwsgi_service_path"
    sudo sh -c -e "echo \"ExecStartPre=/bin/bash -c 'mkdir -p /run/uwsgi; chown $USER:www-data /run/uwsgi' \" >> $uwsgi_service_path"
    sudo sh -c -e "echo 'ExecStart=/usr/local/bin/uwsgi --emperor /etc/uwsgi/sites \nRestart=always' >> $uwsgi_service_path"
    sudo sh -c -e "echo 'KillSignal=SIGQUIT \nType=notify \nNotifyAccess=all\n' >> $uwsgi_service_path"
    sudo sh -c -e "echo '[Install] \nWantedBy=multi-user.target' >> $uwsgi_service_path"


    # NGINX: CONFIGURE AND START SERVER
    sudo apt-get install nginx

    sock_ext=".sock"
    server_ip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
    sites_available_path="/etc/nginx/sites-available/$PROJECT_NAME"
    sudo sh -c -e "echo 'server {\n  listen 80;\n  server_name $server_ip http://$server_ip;\n' > $sites_available_path"
    sudo sh -c -e "echo '  location = /favicon.ico { access_log off; log_not_found off; }\n\n' >> $sites_available_path"
    sudo sh -c -e "echo '  location /static/ {\n    root ${HOME}/${PROJECT_NAME};\n  }\n' >> $sites_available_path"
    sudo sh -c -e "echo '  location / {\n    include         uwsgi_params;' >> $sites_available_path"
    sudo sh -c -e "echo '    uwsgi_pass      unix:/run/uwsgi/$PROJECT_NAME$sock_ext;\n  }\n\n}' >> $sites_available_path"

    sudo ln -s /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled
    sudo nginx -t
    sudo systemctl restart nginx
    sudo systemctl start uwsgi
    sudo systemctl enable nginx
    sudo systemctl enable uwsgi


    # RABBITMQ - CELERY: config virtualenv to use django, rabbitmq, celery
    sudo pip3 install django
    sudo pip3 install celery==3.1.18 

    workon $PROJECT_NAME
    pip3 install django
    sudo apt-get install rabbitmq-server
    pip3 install celery==3.1.18             
    pip3 install flower
    pip3 freeze > ${PROJECT_NAME}_requirements.txt  

    sudo rabbitmq-server -detached


    # sudo rabbitmqctl add_user $USER 'hexgis2017'
    # sudo rabbitmqctl add_vhost hexgis
    # sudo rabbitmqctl set_permissions -p hexgis $USER ".*" ".*" ".*"


