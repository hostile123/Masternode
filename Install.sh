#!/bin/bash
#This will build the lastest master from github or existing files.  Contact turtleflax for questions
buildDir=~/buildPIVX305

echo This script will build the lastest PIVX master from github in your homedrive
echo It will DELETE $buildDir and ALL contents!!!!!!
echo This script contains attended installs that require input
echo To build from PIVX Master just run the script.  Otherwise download the zip for what you want to build and extract it to $buildDir/PIVX before running.   Then call the script with UseExisting for an argument

read -p "Press [Enter] key if you understand and accept"
sudo apt-get update
sudo apt-get install build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libevent-dev libminiupnpc-dev libdb4.8-dev libdb4.8++-dev
read -p "install done press enter"
cd ~

rm -rf $buildDir
mkdir $buildDir
cd $buildDir

if [ $# -eq 0 ]; then
        echo No arguments found, building from master
        git clone https://github.com/PIVX-Project/PIVX.git
else
        echo Argument found, building from $1
        wget $1
        unzip *
        rm *.zip
        mv PIVX-*/ PIVX/
fi

cd $buildDir/PIVX/

####GET DEPENDANCIES####
sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update
####SET GLOBAL VARIABLES####
PIVX_ROOT=$(pwd)
BDB_PREFIX="${PIVX_ROOT}/db4"
#####SETUP BERKLEY DB - SKIP IF YOU'VE DONE THIS BEFORE####
mkdir -p $BDB_PREFIX
wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256sum -c
tar -xzvf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix/
../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX
make install
####COMPILE SOURCE CODE####
cd $buildDir/PIVX
./autogen.sh
./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/"
make
####INSTALL WALLET FILES####
make install
####RUN DAEMON WALLET####
cd ~
# Use this line to start pivxd and pivx-cli is in the same dir
# $buildDir/PIVX/src/pivxd -daemon

