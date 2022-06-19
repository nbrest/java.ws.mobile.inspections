#!/bin/bash

sudo mkdir -p /var/www/www-intellij

sudo chown ${USER}:users -R /var/www/www-intellij
cd /var/www/www-intellij

rm kame-house
ln -s ${HOME}/workspace-intellij/kamehouse/kamehouse-ui/src/main/webapp kame-house

rm kame-house-groot
ln -s ${HOME}/workspace-intellij/kamehouse/kamehouse-groot/public/kame-house-groot kame-house-groot
