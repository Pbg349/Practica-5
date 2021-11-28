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
