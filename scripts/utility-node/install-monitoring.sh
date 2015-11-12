#!/bin/bash

## FUNCTIONS A-Z

install_apache() {
  apt-get install apache2 libapache2-mod-wsgi --yes \
  && e_success "Installed apache"
  a2dissite 000-default
  cp /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-available
  a2enmod wsgi
  a2ensite apache2-graphite
  service apache2 reload \
  && e_success "Reloaded apache config"
}

install_carbon() {
  echo "Installing carbon..."
  apt-get install graphite-carbon --yes \
  && e_success "Installed graphite-carbon"
  echo "Configuring carbon..."
  echo "CARBON_CACHE_ENABLED=true" >> /etc/default/graphite-carbon
  echo "ENABLE_LOGROTATION = True" >> /etc/carbon/carbon.conf
  cp /usr/share/riak-pi-cluster/utility_node/etc_carbon_storage-schemas.conf /etc/carbon/storage-schemas.conf
  cp /usr/share/doc/graphite-carbon/examples/storage-aggregation.conf.example /etc/carbon/storage-aggregation.conf
}

install_grafana() {
  echo "Installing grafana..."
  wget https://github.com/fg2it/grafana-on-raspberry/blob/master/v2.1.2/grafana_2.1.2_armhf.deb
  apt-get install adduser libfontconfig -y
  dpkg -i grafana_2.1.2_armhf.deb \
  && e_success "Installed grafana"
  service grafana-server start \
  && e_success "Started grafana service"
  update-rc.d grafana-server defaults 95 10
}

install_graphite() {
  apt-get install graphite-web --yes \
  && e_success "Installed graphite-web"
  echo "SECRET_KEY = '384572985443985275925y243yu2iu5hkhfghdfxjghdsughsdfkghsdfguhkdfuhsvlh'" >> /etc/graphite/local_settings.py
  echo "TIME_ZONE = 'Europe/London'" >> /etc/graphite/local_settings.py
  echo "USE_REMOTE_USER_AUTHENTICATION = True" >> /etc/graphite/local_settings.py
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
}" \
  >> /etc/graphite/local_settings.py
  #graphite-manage syncdb # todo: currently interactive so need to replace with django --noinput
                          # see https://docs.djangoproject.com/en/dev/howto/initial-data/
                          # needs values passed to it as below
  ##yes
  ##root
  ##null@null.com
  ##password
  ##password
  #chmod 666 /var/lib/graphite/graphite.db
  #chmod 755 /usr/share/graphite-web/graphite.wsgi
}

## SCRIPT

script_path="$(cd $(dirname ${0}) && pwd)"
source "${script_path}/../.riak-pi-include"

run_as_superuser
install_graphite
install_carbon
install_apache
#install_grafana # todo: need to test with https://github.com/fg2it/grafana-on-raspberry
