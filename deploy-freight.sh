#!/bin/bash
set +e
HOST=web1d

ENVIRONMENT=$@

echo "...Updating from Git..."
git pull
echo "...Removing old Bower components and Dist..."
rm -rf ./app/bower_components
rm -rf ./dist
echo "...Updating Bower with new install..."
bower install
echo "...Processing Gulp for production..."
gulp || { exit 1; }
cd ./dist
echo "...Compressing Dist for transfer..."
tar -zcf ../freight.tar.gz .
cd ..
echo "...Copying Dist to server..."
scp -i ~/.ssh/ICEsoft_Linux_Test_Key_Pair.pem freight.tar.gz ubuntu@web1d:~/. || { exit 1; }

if [[ $ENVIRONMENT == *'staging'* ]] ; then
	DESTDIR="/usr/share/nginx/html/static/demos/staging/freight"
else
	DESTDIR="/usr/share/nginx/html/static/demos/freight"
fi

echo "Remote destination directory = $DESTDIR"

echo "...Unpacking Dist on server..."
ssh -i ~/.ssh/ICEsoft_Linux_Test_Key_Pair.pem ubuntu@web1d "sudo tar -zxf /home/ubuntu/freight.tar.gz -C $DESTDIR"
echo "...Cleaning up local compressed file..."
rm freight.tar.gz
