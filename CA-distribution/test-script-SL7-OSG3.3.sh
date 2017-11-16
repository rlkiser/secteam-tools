#!/bin/sh

#This is a script to test Koji build (for OSG3.3) in Scientific Linux 7.

#--------------------General notes/checks for the script--------------------
#Make sure you have a reliable Internet conection before running this script
wget -q --spider http://google.com
if [ $? -ne 0 ];
then
    echo "You are offline."
    echo "Please make sure that you have a reliable Internet connection before running this script."
    exit
fi

#Make sure you are running this script as a superuser i.e. as 'root'.
if [[ $EUID -ne 0 ]];
then
   echo "Please run this script as root."
   exit
fi
#--------------------General notes/checks completed--------------------



#--------------------Variable declaration--------------------
#Set IGTF_CERTS_VERSION according to the release indicated
echo "Enter the IGTF cert version according to the release indicated:"
read IGTF_CERTS_VERSION
export IGTF_CERTS_VERSION

#Set the OSG certificate distribution version
echo "Enter our OSG cert version i.e. n.xNEW:"
read OUR_OSG_VERSION
export OUR_OSG_VERSION

#Set the OSG certificate distribution version
echo "Enter our IGTF cert version i.e. n.xIGTFNEW:"
read OUR_IGTF_VERSION
export OUR_IGTF_VERSION

#Set the PWD to store the result of the script 
export CWD=`pwd`
#--------------------Variable declaration completed--------------------



#--------------------Install dependencies--------------------
#Make sure system is updated
yum -y update

yum -y install yum-plugin-priorities
yum -y install fetch-crl
yum -y install perl-LWP-Protocol-https
#--------------------Installation completed--------------------



#Upgrade the packages
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh http://repo.grid.iu.edu/osg/3.3/osg-3.3-el7-release-latest.rpm

#Creating a "testresult" file to store the results of this test	script
> testresult
echo >> testresult 
echo "----------------------------------------" >> testresult
echo "----------------------------------------" >> testresult
echo " Test results of test-script-SL7-OSG3.3 " >> testresult
echo "----------------------------------------" >> testresult
echo "----------------------------------------" >> testresult
echo >> testresult



#--------------------OSG CA certs--------------------
echo "Results for OSG CA certs:" >> testresult
yum -y --enablerepo osg-development install osg-ca-certs

#Check the version number in certificates
cd /etc/grid-security/certificates
#Open any certificate with .info format for example, TSU-GE.info and verify the version number
export RANDOM_CERT=$(ls *info | shuf -n 1)
if cat $RANDOM_CERT | grep -q $IGTF_CERTS_VERSION;
then
    echo "IGTF version number is correct." >> $CWD/testresult
else
    echo "IGTF version number is incorrect." >> $CWD/testresult
    exit
fi

#Open INDEX.txt and verify our OSG version
if cat INDEX.txt | tail -2 | grep -q $OUR_OSG_VERSION;
then
    echo "Our OSG version is correct." >> $CWD/testresult
else
    echo "Our OSG version is incorrect." >> $CWD/testresult
    exit
fi

/usr/sbin/fetch-crl
#if [ $? -eq 0 ];
#then
#    echo "Retrieval of CRLs was successful." >> $CWD/testresult
#else
#    echo "Retrieval of CRLs failed." >> $CWD/testresult
#    exit
#fi

#Make sure no files are unreadable
find /etc/grid-security/certificates \! -perm -a+r -print
if [ $? -eq 0 ];
then
    echo "All the files are readable." >> $CWD/testresult
else
    echo "One or more file(s) are unreadable." >> $CWD/testresult
    exit
fi

#Check for expiring certs for new packages
for x in /etc/grid-security/certificates/*.pem
do
  echo $(date -d "$(openssl x509 -in $x -noout -enddate | cut -d = -f 2)" +%Y-%m-%d) $x
done | sort -nr

#Clean up
yum -y remove osg-ca-certs



#--------------------IGTF CA certs--------------------
echo >> $CWD/testresult
echo "Results for IGTF CA certs:" >> $CWD/testresult
yum -y --enablerepo osg-development install igtf-ca-certs

#Check the version number in certificates
cd /etc/grid-security/certificates
#Open any certificate with .info format for example, TSU-GE.info and verify the version number
export RANDOM_CERT=$(ls *info | shuf -n 1)
if cat $RANDOM_CERT | grep -q $IGTF_CERTS_VERSION;
then
    echo "IGTF version number is correct." >> $CWD/testresult
else
    echo "IGTF version number is incorrect." >> $CWD/testresult
    exit
fi

#Open INDEX.txt and verify our IGTF version
if cat INDEX.txt | tail -2 | grep -q $OUR_IGTF_VERSION;
then
    echo "Our IGTF version is correct." >> $CWD/testresult
else
    echo "Our IGTF version is incorrect." >> $CWD/testresult
    exit
fi

/usr/sbin/fetch-crl
#if [ $? -eq 0 ];
#then
#    echo "Retrieval of CRLs was successful." >> $CWD/testresult
#else
#    echo "Retrieval of CRLs failed." >> $CWD/testresult
#    exit
#fi

#Make sure no files are unreadable
find /etc/grid-security/certificates \! -perm -a+r -print
if [ $? -eq 0 ];
then
    echo "All the files are readable." >> $CWD/testresult
else
    echo "One or more file(s) are unreadable." >> $CWD/testresult
    exit
fi

#Check for expiring certs for new packages
for x in /etc/grid-security/certificates/*.pem
do
  echo $(date -d "$(openssl x509 -in $x -noout -enddate | cut -d = -f 2)" +%Y-%m-%d) $x
done | sort -nr

#Clean up
yum -y remove igtf-ca-certs
rm -rf /etc/grid-security/certificates



#--------------------Developer tests--------------------
#Install the packages on test machines and check that the packages install and update cleanly

#Check which release you are running
echo "You are running:"
cat /etc/redhat-release
echo

#Install the package on test machines
echo "Installing a newly built package on this system:"
rpm -ivh http://repo.grid.iu.edu/osg/3.3/osg-3.3-el7-release-latest.rpm
echo

#Check an installed RPM Package
echo "Installed package is:"
rpm -q osg-release-3.3-*.osg33.el7.noarch
echo 

#Upgrade a RPM Package
rpm -Uvh http://repo.grid.iu.edu/osg/3.3/osg-3.3-el7-release-latest.rpm



#Display the test results
cat $CWD/testresult
