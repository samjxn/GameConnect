#/bin/bash!

SERVER=proj-309-16.cs.iastate.edu
WEB_DIR=/var/www/html/

echo -n "Enter username for proj-309-16.cs.iastate.edu > "
read USERNM

echo -n Password:
read -s password
echo
# Run Command
echo $password

echo building dart project
pub build
echo compressing build
tar -vzcf ./.build.tar.gz build/web/*
echo connecting to server...
scp .build.tar.gz $USERNM@$SERVER:$WEB_DIR
echo
echo You\'re going to have to enter a password again.  Sorry about that.
echo
ssh $USERNM@$SERVER 'cd /var/www/html/; tar -xzf .build.tar.gz; rm .build.tar.gz; cp -r build/web/* .; rm -r build/*; rmdir build'
echo cleanup
rm .build.tar.gz
