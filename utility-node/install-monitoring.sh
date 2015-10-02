# install monitoring

# install graphite, apache and collectd
sudo apt-get update
sudo apt-get install graphite-web graphite-carbon apache2 libapache2-mod-wsgi -y

# configure graphite
echo "SECRET_KEY = '384572985443985275925y243yu2iu5hkhfghdfxjghdsughsdfkghsdfguhkdfuhsvlh'" | sudo tee -a /etc/graphite/local_settings.py
echo "TIME_ZONE = 'Europe/London'" | sudo tee -a /etc/graphite/local_settings.py
echo "USE_REMOTE_USER_AUTHENTICATION = True" | sudo tee -a /etc/graphite/local_settings.py
echo "\
DATABASES = {
    'default': {
        'NAME': '/var/lib/graphite/graphite.db',
        'ENGINE': 'django.db.backends.sqlite3',
        'USER': 'root',
        'PASSWORD': 'password',
        'HOST': '',
        'PORT': ''
    }
}" | sudo tee -a sudo tee -a /etc/graphite/local_settings.py
sudo graphite-manage syncdb #<<EOF <-- this doesn't work yet
#yes
#root
#null@null.com
#password
#password
#EOF
sudo chmod 666 /var/lib/graphite/graphite.db
sudo chmod 755 /usr/share/graphite-web/graphite.wsgi


# configure carbon for graphite
echo "CARBON_CACHE_ENABLED=true" | sudo tee -a /etc/default/graphite-carbon
echo "ENABLE_LOGROTATION = True" | sudo tee -a /etc/carbon/carbon.conf
sudo cp etc_carbon_storage-aggregation.conf /etc/carbon/storage-aggregation.conf
sudo cp /usr/share/doc/graphite-carbon/examples/storage-aggregation.conf.example /etc/carbon/storage-aggregation.conf


# configure apache for graphite
sudo a2dissite 000-default
sudo cp /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-available
sudo a2enmod wsgi
sudo a2ensite apache2-graphite
sudo service apache2 reload


# install grafana
wget https://grafanarel.s3.amazonaws.com/builds/grafana_2.1.3_amd64.deb
sudo apt-get install adduser libfontconfig -y
sudo dpkg -i grafana_2.1.3_amd64.deb
sudo service grafana-server start
sudo update-rc.d grafana-server defaults 95 10