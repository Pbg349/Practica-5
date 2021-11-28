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


## Cambiamos el nombre de la página principal de nuestro Front1:

sed -i "s/Simple LAMP web app/LAMP Front2/" /var/www/html/index.php


# -------------------------------------------------------------------
