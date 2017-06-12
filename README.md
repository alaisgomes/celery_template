
# About 
Project as a guide with easy installing and manually configuring tutorial for Celery and RabbitMQ.

About the NGINX and uWSGI tutorial and notes, refer to: [install_server]()

## Requirements
	* Python 3.5.* and pip are already installed
	* Django is already installed
	* virtualenvwrapper is already installed

## Installing  and Configuration

### 1. (optional) Get in virtualenvwrapper:

```sh
$ source `which virtualenvwrapper.sh`
$ mkvirtualenv --python=/usr/bin/python3 env-name
```
### 2. (if not already) Install latest Django

```sh
$ pip install django
```

### 3. Install RabbitMQ and celery

```sh
$ sudo apt-get install rabbitmq-server
$ pip install celery
```

### 4. Run Rabbit, create a RabbitMQ user and virtual host and set permissions

```sh
$ sudo rabbitmq-server -detached
$ sudo rabbitmqctl add_user myuser mypassword
$ sudo rabbitmqctl add_vhost myvhost
$ sudo rabbitmqctl set_permissions -p myvhost admin ".*" ".*" ".*"
```
### 5. (optional) Test stopping it then run it again.

```sh
$ sudo rabbitmqctl stop
$ sudo rabbitmq-server -detached
```

### 6. (Skip if already exists) Create a django project and app
```sh
$ django-admin startproject <project_name>
```
### 7. Edit settings.py in *project_name/project_name* and add these at the end of the file, changing myuser, mypassword and myvhost accordingly.
```python
#Celery configuration for Django
BROKER_URL = "amqp://myuser:mypassword@localhost:5672/myvhost"
CELERY_RESULT_BACKEND = 'amqp://localhost:5672'
CELERY_ACCEPT_CONTENT = ['application/json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
```
### 8. In the same folder (*project_name/project_name*), create file celery.py with content below (replacing project_name with your Django project name):
```python
from __future__ import absolute_import
import os
from celery import Celery
from django.conf import settings

# set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project_name.settings')
app = Celery('project_name')

app.config_from_object('django.conf:settings')
app.autodiscover_tasks(lambda: settings.INSTALLED_APPS)


@app.task(bind=True)
def debug_task(self):
    print('Request: {0!r}'.format(self.request))
```
### 9. Again in the same folder (*project_name/project_name*), edit the *\_\_init\_\_.py* by adding the following:
```python
from __future__ import absolute_import

# This will make sure the app is always imported when
from .celery import app as celery_app
```
### 10. With RabbitMQ running in the background, go to your project folder where manage.py file is and run in two separate tabs the worker to receive tasks and beat (task scheduler):
```sh
$ celery -A <project_name> worker -l info
$ celery -A <project_name> beat -l info
```
### 11. (optional) For documentation purposes, create a requirements.txt file with your current running apps in your virtual environment.
```sh
$ pip freeze > requirements.txt
```

