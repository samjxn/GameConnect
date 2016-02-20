#/bin/bash!

SERVER=proj-309-16.cs.iastate.edu
WEB_DIR=/var/www/html/

echo -n "Enter username for proj-309-16.cs.iastate.edu > "
read USERNM

echo building dart project
pub build
echo compressing build
tar -vzcf ./.build.tar.gz build/web/*
echo "pushing zipped project.  (password needed)"
scp .build.tar.gz $USERNM@$SERVER:$WEB_DIR
echo
echo "unzipping remotely (password needed again)"
ssh $USERNM@$SERVER 'cd /var/www/html/; tar -xzf .build.tar.gz; rm .build.tar.gz; cp -r build/web/* .; rm -r build/*; rmdir build'
echo cleanup
rm .build.tar.gz
