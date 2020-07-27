#!/bin/bash


echo "#-----------------Install the MYSQL and SNIPEIT Docker Image-------------------#"

echo ""
echo "Set the external volume for SNIPEIT Database and App volumes"

echo -n "Enter Installation Directory:"
read install_dir

echo "#-------Setting up the DB,App,Config directories-----------"

if [ -d $install_dir/snipeit ] ; then

     echo "The following directories are available"
     ls -ald ls -ald $install_dir/snipeit/config $install_dir/snipeit/mysql $install_dir/snipeit/app  

else
   echo " Creating DB,App,Config directories" 
   mkdir  $install_dir/snipeit $install_dir/snipeit/config $install_dir/snipeit/mysql $install_dir/snipeit/app
   cp $PWD/*.env $install_dir/snipeit/config/
   ls -ald $install_dir/snipeit/config $install_dir/snipeit/mysql $install_dir/snipeit/app
   ls -altr $install_dir/snipeit/config/*

fi ;



echo "#--------------Start the Snipeit Installation---------------#"

echo "#---------- Set the Variables-------------------------------#"
install_dir="$install_dir/snipeit"
snipeitapp_mysql="$install_dir/mysql"
snipeitapp_vol="$install_dir/app"
host=$(hostname)

echo "Install Directory  :$install_dir "
echo "MySQL directory    :$snipeitapp_mysql"
echo "App Directory      :$snipeitapp_vol"
echo "HostName           :$host"

echo "-----------------Downloading mysql image-------------------#"
docker pull mysql:5.6
echo "#-----------------------------------------------------------#"
echo "downloading snipeit image"
docker pull snipe/snipe-it:v4.1.13

echo "#--------------Docker Image show-----------------------------#"

docker image list


echo "#-----------------Stop and Remove existing process -------#"

docker ps -as

echo ""
echo ""
echo ""


docker stop snipeit-app snipeit-mysql

echo ""

echo " #-------------Delete docker process----------------------#"
docker rm snipeit-app snipeit-mysql

echo ""
echo ""

echo "#-----------------------Please standby for clean process--------------------#"

sleep 30
docker ps -as

echo "#----------------------Starting mysql container------------#"

docker run --detach \
        --publish 6603:3306 \
        --name snipeit-mysql \
        --env-file=$install_dir/config/mysql.env \
        --volume $snipeit_mysql:/var/lib/mysql \
        mysql:5.6


sleep 60

docker ps -as


echo "#-------------------Starting App container-Wait for 1 minitue-----------------------#"

sleep 60


docker run --detach \
        --publish 8080:80 \
        --name snipeit-app \
        --volume $snipeitapp_vol:/var/lib/snipeit \
        --link  snipeit-mysql:mysql \
        --env-file=$install_dir/config/docker.env \
        docker.io/snipe/snipe-it:v4.1.13
sleep 60

docker ps -as

echo "#---------------------- Showing the docker process - Wait time 2 mts---------"

sleep 120

docker ps -as

echo "#------------------------------- Check the Website -------#"
echo ""
echo ""
wget -c http://$host:8080/

rm ./index.html

echo ""

echo "The Access url :  http://$host:8080/ "


echo   "#---------------End of Installation---------------------#"


