#!/bin/bash
# Install Oracle instant client libraries and files

# Create cache directory
if [[ ! -d ~/instantclient_deb ]]; then
  mkdir ~/instantclient_deb
fi

# Download deb files
if [[ ! -f ~/instantclient_deb/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.deb ]]; then
  wget --n0-verbose --auth-no-challenge --header='Accept:application/octet-stream' https://$GITHUB_ACCESS:@api.github.com/repos/tablexi/nucore-nu/releases/assets/795779 -O ~/instantclient_deb/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.deb
fi
if [[ ! -f ~/instantclient_deb/oracle-instantclient12.1-sdk-12.1.0.2.0-1.x86_64.deb ]]; then
  wget --n0-verbose --auth-no-challenge --header='Accept:application/octet-stream' https://$GITHUB_ACCESS:@api.github.com/repos/tablexi/nucore-nu/releases/assets/795777 -O ~/instantclient_deb/oracle-instantclient12.1-sdk-12.1.0.2.0-1.x86_64.deb
fi
if [[ ! -f ~/instantclient_deb/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.deb ]]; then
  wget --n0-verbose --auth-no-challenge --header='Accept:application/octet-stream' https://$GITHUB_ACCESS:@api.github.com/repos/tablexi/nucore-nu/releases/assets/795778 -O ~/instantclient_deb/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.deb
fi

# Install instantclients
sudo dpkg -i ~/instantclient_deb/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.deb
sudo dpkg -i ~/instantclient_deb/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.deb
sudo dpkg -i ~/instantclient_deb/oracle-instantclient12.1-sdk-12.1.0.2.0-1.x86_64.deb
