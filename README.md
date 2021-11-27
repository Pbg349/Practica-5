# Practica-5

## En ésta práctica 5 Balanceador de carga con Apache, crearemos una arquitectura que constará de 1 capa frontend, formada por 2 servidores (Front1 y Front2), una capa backend, formada por un servidor con MySQL server, actuando de servidor de base de datos, y un balanceador de carga de manera que formemos una arquitectura de alta disponibilidad que sea escalable y redundante, y que podamos balancear la carga entre todos los frontales web.

Para ello: 

-Crearemos los scripts de configuración pertinentes para cada máquina, responsables de la instalación y configuración de programas y archivos que necesitaremos para crear una arquitectura completa y funcional.
-Registraremos nuestro nombre de DNS, en nuestro caso mediante NO-IP y (balanceadorpbg.ddns.net)
-Instalaremos el certificado HTTP y HTTPS con Cerbot, una herramienta que nos permite emitir certificados de manera gratuita y sencilla.



# SCRIPTS: 

## Frontend1:

#!/bin/bash
set -x

# Variables de Configuración:

IP_MYSQL=172.31.10.177


# Instalamos pila LAMP:

## Actualizamos el sistema

apt update
apt upgrade -y

## Instalamos Apache:

apt install apache2 -y
 

## Instalamos php-mysql:

apt install php libapache2-mod-php php-mysql -y

## Reiniciamos el server apache:

systemctl restart apache2

## Copiamos el archivo de configuración de php:

cp info.php /var/www/html

#--------------------------------------------------------------------


# Herramientas adicionales:

## Obetenemos Adminer:

cd /var/www/html

mkdir adminer

cd adminer

wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php

mv adminer-4.8.1-mysql.php index.php

## Actualizamos propietario grupo del directorio /var/www/html

sudo chown www-data:www-data /var/www/html -R 


# --------------------------------------------------------------------


# Aplicación Web:

cd /var/www/html

## Clonamos repositorio:

git clone https://github.com/josejuansanchez/iaw-practica-lamp.git

## Movemos codigo de aplicación a /var/www/html:

mv iaw-practica-lamp/src/* /var/www/html


## Eliminamos index.html

rm /var/www/html/index.html

## Eliminamos el directorio del repositorio

rm -rf /var/www/html/iaw-practica-lamp

## Configuramos la IP de MYSQL en el archivo config.php del Front2

sed -i "s/localhost/$IP_MYSQL/" /var/www/html/config.php


## Cambiamos propietario y grupo

chown www-data:www-data /var/www/html -R 


## Cambiamos el nombre de la página principal de nuestro Front2:

sed -i "s/Simple LAMP web app/LAMP Front2/" /var/www/html/index.php


# -------------------------------------------------------------------


## Frontend2:

#!/bin/bash
set -x

# Variables de Configuración:

IP_MYSQL=172.31.10.177


# Instalamos la pila LAMP:

## Actualizamos el sistema
apt update
apt upgrade -y

## Instalamos Apache:
apt install apache2 -y
 

## Instalamos php-mysql:
apt install php libapache2-mod-php php-mysql -y

## Reiniciamos el server apache:
systemctl restart apache2


# --------------------------------------------------------------------


# Herramientas adicionales:

## Adminer:

cd /var/www/html
mkdir adminer
cd adminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php
mv adminer-4.8.1-mysql.php index.php

## Actualizamos propietario grupo de nuestro directorio /var/www/html

chown www-data:www-data /var/www/html -R 


# --------------------------------------------------------------------


# Aplicación Web:

cd /var/www/html

## Clonamos el repositorio
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git

## Movemos el codigo de la aplicación a /var/www/html

mv iaw-practica-lamp/src/* /var/www/html


## Eliminamos index.html

rm /var/www/html/index.html

## Eliminamos el directorio del repositorio

rm -rf /var/www/html/iaw-practica-lamp

## Configuramos la IP de MYSQL en el archivo config.php

sed -i "s/localhost/$IP_MYSQL/" /var/www/html/config.php


## Cambiamos propietario y grupo
chown www-data:www-data /var/www/html -R 


## Cambiamos el nombre de la página principal:

sed -i "s/Simple LAMP web app/LAMP Front1/" /var/www/html/index.php

# -------------------------------------------------------------------------------

## Backend:

#!/bin/bash
set -x

# Variables Configuración:

MYSQL_ROOT_PASSWORD=root

# -------------------------------------------------------------------------------

# Instalamos la pila LAMP

## Actualizamos sistema:

apt update
apt upgrade -y

apt install apache2 -y

# Instalamos MYSQL Server:
apt install mysql-server -y


# ---------------------------------------------------------------------------------


# Configuramos MYSQL:

## Cambiamos la contraseña del usuario root:

mysql <<< "ALTER USER root@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"

## Configuramos MySQL para aceptar conexiones desde cualquier interfaz de red:

sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

## Reiniciamos el servicio de MySQL:

systemctl restart mysql


# Desplegamos aplicación Web:

cd /var/www/html

## Clonamos repositorio de la aplicación:

rm -rf /var/www/html/iaw-practica-lamp

git clone https://github.com/josejuansanchez/iaw-practica-lamp.git

## Importamos script de la base de datos:

mysql -u root -p$MYSQL_ROOT_PASSWORD < /var/www/html/iaw-practica-lamp/db/database.sql 

## Borramos directorio del repositorio:

rm -rf /var/www/html/iaw-practica-lamp

# --------------------------------------------------------------------------------

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
