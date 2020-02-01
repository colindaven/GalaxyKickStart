#!/usr/bin/env bash
set -e
ansible-galaxy install -r requirements_roles.yml -p roles
ansible-playbook -i inventory_files/galaxy-kickstart galaxy.yml

curl --fail $BIOBLEND_GALAXY_URL/api/version

# Galaxy test user (may be dispensable)
sudo chown -R $GALAXY_TRAVIS_USER:$GALAXY_TRAVIS_USER $GALAXY_HOME

# ftp test
date > $HOME/date.txt && curl --fail -T $HOME/date.txt ftp://localhost:21 --user $GALAXY_USER:$GALAXY_USER_PASSWD

####     bioblend tests    #####

# install test environement :
sudo su $GALAXY_TRAVIS_USER -c 'pip install --ignore-installed --user "bioblend==0.13.0" pytest'

# test
sudo -E su $GALAXY_TRAVIS_USER -c "export PATH=$GALAXY_HOME/.local/bin/:$PATH &&
cd $GALAXY_HOME &&
bioblend-galaxy-tests -v $GALAXY_HOME/.local/lib/python2.7/site-packages/bioblend/_tests/TestGalaxy*.py"
