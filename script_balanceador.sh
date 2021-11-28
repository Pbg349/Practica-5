## Balanceador:

#!/bin/bash
set -x

# Configuramos variables:
IP_PRIVADA_FRONT_1=172.31.28.246
IP_PRIVADA_FRONT_2=172.31.93.196
EMAIL_HTTPS=balance@ador.com
DOMAIN=balanceadorpbg.ddns.net


## Actualizamos el equipo:

apt update -y
apt upgrade -y

# Instalación Apache2:

apt install apache2 -y

# Configuración del balanceador como Proxy Inverso:

a2enmod proxy
a2enmod proxy_http
a2enmod proxy_ajp
a2enmod rewrite
a2enmod deflate
a2enmod headers
a2enmod proxy_balancer
a2enmod proxy_connect
a2enmod proxy_html
a2enmod lbmethod_byrequests

## Copiamos archivo de configuración al directorio de apache2:

cp 000-default.conf /etc/apache2/sites-available/000-default.conf

## Modificamos el archivo de configuración en la  nueva ruta:

sed -i "s/IP-HTTP-SERVER-1/$IP_PRIVADA_FRONT_1/" /etc/apache2/sites-available/000-default.conf
sed -i "s/IP-HTTP-SERVER-2/$IP_PRIVADA_FRONT_2/" /etc/apache2/sites-available/000-default.conf

## Reiniciamos Apache
systemctl restart apache2


# -----------------------------------------------------------


# Configuracion HTTPS


## Realizamos la instalacion de snap
snap install core
snap refresh core

## Eliminamos instalaciones previas de cerbot con apt
apt-get remove certbot

# Instalamos Cerbot con snap:

snap install --classic certbot

## Solicitamos el certificado HTTPS:

certbot --apache -m $EMAIL_HTTPS --agree-tos --no-eff-email -d $DOMAIN