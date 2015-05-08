#!/bin/bash

# set environment vars
export INSTALLDIR=/home/ubuntu/install
export GITCLONE=/srv/jupyterhub

# remove repo cloned (if exists)
sudo rm -Rf $INSTALLDIR/jupyterhub-demo


# remove working directorys
sudo rm -Rf /srv
sudo rm /var/log/jupyterhub.err.log
sudo rm /var/log/jupyterhub.out.log

#create root folder to clone repo and others sub folders
sudo mkdir /srv
sudo mkdir $GITCLONE
#sudo mkdir $GITCLONE/ssl

#installing git 
sudo apt-get install git

# clone demo repo in target directory
git clone https://github.com/minrk/jupyterhub-demo.git $GITCLONE


# make new ssl files
cd $GITCLONE/ssl
openssl genrsa -des3 -passout pass:x -out server.pass.key 2048
openssl rsa -passin pass:x -in server.pass.key -out ssl.key
rm server.pass.key
openssl req -new -key ssl.key -out ssl.csr
openssl x509 -req -days 365 -in ssl.csr -signkey ssl.key -out ssl.crt

#cd into repo folder
cd $GITCLONE

# copy jupyterhub_config.py, env and userlist to working directory
sudo cp $INSTALLDIR/userlist $GITCLONE
sudo cp $INSTALLDIR/env $GITCLONE
sudo cp $INSTALLDIR/jupyterhub_config.py $GITCLONE

# run install
cd $GITCLONE
sudo sh install.sh 

# configure server
sudo ./configure.sh

# sometimes server fails to start with configure.sh
sudo supervisorctl stop jupyterhub
sudo supervisorctl start jupyterhub
