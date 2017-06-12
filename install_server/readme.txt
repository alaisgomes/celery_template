
================= To Run ===================
	chmod u+x install.sh
	./install.sh -n <PROJECT_NAME>

	-- Where <name> should be the name of your project. This is needed in order to auto-generate uwsgi and nginx configuration files. You can edit them later as described below. If not inserted, auto-set for "hexgis_project" as name.


============= After Running it =============

Files Created:
	
	/etc/nginx/sites-available/$PROJECT_NAME
	-- Edit this file to configurate root project and its <project_name>.sock. If creating a new file, make sure to create its link:
	sudo ln -s <newfile> /etc/nginx/sites-enabled
	
	~/.bashrc
	-- virtual env

	/etc/uwsgi/sites/$PROJECT_NAME.ini
	-- uwsgi inicialization *.ini file make sure to define base directory used (project folder), uid and project name.

	/etc/systemd/system/uwsgi.service
	-- uwsgi unit file to run server. Make sure to edit user who is running server (hexgis for example)

	-- There's also a virtual env created with PROJECT_NAME. This virtual env contains celery, django, python3 as default and all other requirements. 

Other observations:
	After running the script you might need to recreate the virtualenv you desire to work on 

	Edit your django project to work with celery and rabbitmq as well as activating static root and allowed_hosts

	Static Root:
		STATIC_ROOT = os.path.join(BASE_DIR, 'static/')

		and run:
		python manage.py collectstatic

============================================

Useful tutorial guide:
	https://www.digitalocean.com/community/tutorials/how-to-serve-django-applications-with-uwsgi-and-nginx-on-ubuntu-16-04
	

