## Notes on Installing NGINX uWSGI server
### Run the  script
```sh
chmod u+x install.sh
./install.sh -n <PROJECT_NAME>
```

Where _<project_name>_ should be the name of your project. This is needed in order to auto-generate uwsgi and nginx configuration files. You can edit them later as described below. If not inserted, it is auto-set for "_hexgis_project_" as name.


### After running the script

First file created
```sh	
/etc/nginx/sites-available/$PROJECT_NAME
```
Edit this file to configurate root project and its _<project_name>.sock_. If creating a new file, make sure to create its link:
```sh
sudo ln -s <newfile_path> /etc/nginx/sites-enabled
```
We also have virtual env configuration, where the configured virtualenv is called $PROJECT_NAME. This virtual env contains celery, django, python3 as default and all other requirements. Virtual envs made with virtuaenvlwrapper will be put at:
```sh
$HOME/Env/
```

Another file is the uWSGI configuration and inicialization file. When editing, make sure to define base directory used (project folder), uid (whoami) and project name.
```sh
/etc/uwsgi/sites/$PROJECT_NAME.ini
```
Next one is a uwsgi unit file to run server. Make sure to edit user who is running server (hexgis for example).
```sh
/etc/systemd/system/uwsgi.service
```

Other observations:
	After running the script you might need to access it again by doing:
```sh
mkvirtualenv $PROJECT_NAME
workon $PROJECT_NAME
```	

Remember to edit your django project to work with celery and rabbitmq as well as activating static root and allowed_hosts. More information on the celery tutorial file of this project.

Add Static Roo and run collectstatic:
```python
STATIC_ROOT = os.path.join(BASE_DIR, 'static/')
```
```sh
python manage.py collectstatic
```

And don't forget to check if everything was installed correctly! Things installed include:
* Python 3.* (if not there already)
* pip (if not in the machine)
* uWSGI
* nginx
* celery 3.1.* (globally and locally on virtualenv)
* django (globally and locally)
* virtualenvwrapper (globally)
* rabbitMQ
* flower (locally on virtualenv)
* gdal-2.1.0

### References
* https://www.digitalocean.com/community/tutorials/how-to-serve-django-applications-with-uwsgi-and-nginx-on-ubuntu-16-04
* http://knowpapa.com/django-celery-rabbitmq/
* http://simondlr.com/post/24479818721/basic-django-celery-and-rabbitmq-example
	

