Changes made to the new version of IGTF: https://dist.igtf.net/distribution/current/CHANGES

# Creating CA Distributions
This page documents the OSG Security process for creating new Certificate Authority packages for distribution to OSG sites.

# Setup the environment
1.Get a user certificate + key in pkcs12 format from the OSG CA. [See CertificateUserGet for instructions](https://twiki.grid.iu.edu/bin/view/ReleaseDocumentation/CertificateUserGet).

2.Ask the OSG Software-Release team for permissions to access the svn repository i.e.  https://vdt.cs.wisc.edu/svn/certs 
*	Tim Theisen creates accounts for svn (as of 12/29/16)
*	Find more contact information [here](https://twiki.opensciencegrid.org/bin/view/SoftwareTeam/WebHome)

3.Ask the OSG Software team for access to the Koji build system
*	Mat Selmeci grants access to the Koji build system (as of 12/29/16)

4.Verify that rpmbuild is installed. The rpmbuild command is required for making the rpm, so it's best to use a RedHat machine (any flavor e.g. Scientific Linux) for this process.
* su -
* yum install rpm-build

5.Verify that dpkg-deb, fakeroot, dpkg-scanpackages and debsigs are in your $PATH
* which dpkg-deb fakeroot dpkg-scanpackages debsigs
 - If any of the tools are not installed on your system you may use build-debian-tools to download and install them 
  - sudo yum -y install dpkg-dev
  - Checkout a copy of the svn repository (https://vdt.cs.wisc.edu/svn/certs)   
    svn co https://vdt.cs.wisc.edu/svn/certs/trunk/vdt-scripts/
  - cp vdt-scripts/build-debian-tools builddebiantools.sh
  - ./builddebiantools.sh
  - Source the setup.sh file from the installed debian tools directory  
    source ~/debian-build-tools/setup.sh

* Again verify that dpkg-deb, fakeroot, dpkg-scanpackages and debsigs are in your $PATH  
  which dpkg-deb fakeroot dpkg-scanpackages debsigs

6.Install an svn client. Version 1.4.x is strongly recommended. Don't use a version 1.5.x client. See http://www.collab.net/downloads/subversion/svn1.4.html.
* cd .. 
* yum install subversion

7.Verify that you have a version of openssl 1.x installed, to be used by mk-index.pl below.
* openssl version -v

8.Setup GPG with the private key of security@opensciencegrid.org
* Follow “PGP key generation” step from https://twiki.grid.iu.edu/bin/view/SecurityTeam/SecureEmailKeyManagement and send the public key to Jeny (as of 12/29/16)
* She will send OSG private key, encrypted using the public key
*	She will also send passphrase for OSG private key separately, encrypted using the public key
*	Decrypt both the files using this command 
 - gpg --output pathtooutputfile/outputfilename --decrypt pathtofile/file.gpg and then enter your passphrase
* Follow “PGP secret key import” step from: https://twiki.grid.iu.edu/bin/view/SecurityTeam/SecureEmailKeyManagement
 - gpg --import --allow-secret-key-import < pathtofile/file.asc

9.Install fetch-crl
* curl -sSLO http://dist.eugridpma.info/distribution/util/fetch-crl/fetch-crl-3.0.16.tar.gz
*	tar -zxvf fetch-crl-3.0.16.tar.gz
*	Then change the directory to fetch-crl
 - cd fetch-crl-3.0.16 
*	make install

10.Define variable for OSG PGP key
* export OSGSECKEYID=7FD42669 
* Verify the key id value with 
 - gpg --list-keys

11.Download, import, and verify the IGTF signing key (for example, by verifying the signature):
*	Download using 
 - wget -P targetfilepath https://dist.igtf.net/distribution/current/GPG-KEY-EUGridPMA-RPM-3
* Import using this 
 - gpg --import < targetfilepath/GPG-KEY-EUGridPMA-RPM-3
*	Verify using:
 - gpg --recv-key 3CDBBC71
 - gpg --check-sigs 3CDBBC71
 - gpg --default-key $OSGSECKEYID --lsign-key 3CDBBC71

12.Checkout a copy of the svn repository:
* svn co https://vdt.cs.wisc.edu/svn/certs

# Preparing for Multiple Caches: i.e. IGTFNEW and NEW 
* Repeat the following steps (till the announcement step) for each cache

## Updating to a new IGTF distribution
1.If the Jira ticket is not yet created, create a Jira ticket under OSG_software (https://jira.opensciencegrid.org/) using the following information:
Subject: Update CA certificates to IGTF 1.X 
Body: IGTF 1.X (http://dist.eugridpma.info/distribution/igtf/current/) was released on DATE. Please prepare the igtf-ca-certs and osg-ca-certs for release in OSG A.B. 
(Note: Coordinate the release with OSG Software team. You will find the next release dates [here] (https://twiki.grid.iu.edu/bin/view/SoftwareTeam/WebHome). Add Tim T. and Brian B. as watchers and coordinate testing using ticket. Set components to security. e.g. https://jira.opensciencegrid.org/browse/SOFTWARE-1712)

2.Change to an empty working directory and set $CAWORKDIR to the path
*	cd `mktemp -d`
*	export CAWORKDIR=`pwd`

3.Set $IGTF_CERTS_VERSION according to the release indicated
* export IGTF_CERTS_VERSION=1.X

4.Checkout or update the OSG svn directories
*	cd /certs/trunk/cadist/CA-Certificates-Base
*	svn update
*	export CABASEDIR=`pwd`

5.Set the OSG certificates distribution version 
* export OUR_CERTS_VERSION= n.xIGTFNEW 
(& export OUR_CERTS_VERSION= n.xNEW for a repeated process for OSG CA) 

6.Create a new distribution directory for the release
*	cd $CABASEDIR
*	mkdir -p $OUR_CERTS_VERSION/certificates
*	export CADIST=$CABASEDIR/$OUR_CERTS_VERSION/certificates

7.Download the new IGTF distribution tarball (and PGP signature) from http://dist.eugridpma.info/distribution/igtf/current/
* cd $CAWORKDIR
*	wget http://dist.eugridpma.info/distribution/igtf/current/igtf-policy-installation-bundle-$IGTF_CERTS_VERSION.tar.gz
*	wget http://dist.eugridpma.info/distribution/igtf/current/igtf-policy-installation-bundle-$IGTF_CERTS_VERSION.tar.gz.asc

8.Verify the PGP signature on the tarball
* gpg --verify igtf-policy-installation-bundle-$IGTF_CERTS_VERSION.tar.gz.asc

9.Unpack the certificates
* tar xzf igtf-policy-installation-bundle-$IGTF_CERTS_VERSION.tar.gz

10.Select the CAs and install to temporary location
*	cd igtf-policy-installation-bundle-$IGTF_CERTS_VERSION
*	./configure --prefix=$CADIST --with-profile=classic --with-profile=mics --with-profile=slcs --with-profile=iota
*	make install

11.Install the non-IGTF CAs. Don’t need to perform this step for regular release.
*need to add procedure*

12.Compare the difference with previous version
*	cd $CADIST
*	for ca in * ; do echo $ca; diff $ca $CABASEDIR/**previous**/certificates; done 
*	for ca in $CABASEDIR/**previous**/certificates/* ; do echo $ca; diff $ca . ; done
 - Where, previous = previous version of IGTFNEW (& NEW for a repeated process for OSG CA)
*	Make sure appropriate extra CA files from $CABASEDIR/non-igtf-certificates are included or removed from the distribution directory $CADIST

13.Generate the index files (requires openssl 1.x)
*	cd $CABASEDIR
*	For the location of openssl run command    
  which openssl
*	Then replace the **bold font** with the result of “which openssl” command  
	./mk-index.pl --version $OUR_CERTS_VERSION --dir $CADIST --out $CADIST/INDEX --ssl1 **~/svn/openssl1/bin/openssl** -format 1 --style new

14.Verify that $CADIST/INDEX.html[.txt] contains the right number of CAs
*	ls $CADIST/*.pem | wc 
 -	You should agree with the number of CAs listed in $CADIST/INDEX.html and $CADIST/INDEX.txt

15.Make MD5 checksum
*	cd $CABASEDIR/$OUR_CERTS_VERSION
*	( cd $CADIST; md5sum *.0 *.pem ) > cacerts_md5sum.txt
*	cp cacerts_md5sum.txt $CADIST

16.Update the $CADIST/CHANGES file 
* cp $CABASEDIR/**previous**/certificates/CHANGES $CADIST
 - Where, previous = previous version of IGTFNEW (& NEW for a repeated process for OSG CA)

17.Add new distribution to repository
*	cd $CADIST; chmod 644 * 
*	Make sure permissions are OK 
 - Run command ls -l and check rw- r-- r--
*	cd $CABASEDIR
*	svn add $OUR_CERTS_VERSION

18.Commit all the changes
* svn commit -m "Updated to IGTF version $IGTF_CERTS_VERSION, OSG version $OUR_CERTS_VERSION"

## Check the CA certificates and CRLs
1.Run fetch-crl
* yum -y install perl
* yum -y install cpan
* yum -y install perl-LWP-Protocol-https
* pushd $CADIST
* FETCH_CRL_lOCATION=`which fetch-crl`
* sudo $FETCH_CRL_lOCATION -l `pwd` --out `pwd`

2.Check for expired or near-expired CRLs
* yum -y install perl-Sys-Syslog
* cpan install Date::Parse
* $CABASEDIR/check-crl-expiry.pl *.r0

3.Check for expired or near-expired CAs
* $CABASEDIR/check-ca-expiry.pl *.pem

4.Cleanup
* rm *.r0
 - Hit y (for yes) to remove each individual files 
* popd

## Make the CA tarball distribution
1.Make sure the $CABASEDIR directory in your svn workspace is up-to-date and contains no local modifications
* cd $CABASEDIR
* svn status

2.Create the tarball
* cd $CABASEDIR/$OUR_CERTS_VERSION
* tar cvfz osg-certificates-$OUR_CERTS_VERSION.tar.gz --exclude .svn certificates 

3.Sign it with the security@opensciencegrid.org PGP key
* export OSGSECKEYID=7FD42669 
* Check you have both the variable correct
 - echo $OUR_CERTS_VERSION $OSGSECKEYID 
* gpg --default-key $OSGSECKEYID -b osg-certificates-$OUR_CERTS_VERSION.tar.gz
 - Refer step #8 from 'Setup the environment' for passphrase

## Make the DEB
1.Verify that $OUR_CERTS_VERSION and $IGTF_CERTS_VERSION are set correctly
* echo $OUR_CERTS_VERSION $IGTF_CERTS_VERSION

2.Make sure CWD is correct
* cd $CABASEDIR/$OUR_CERTS_VERSION

3.Run the make-deb script
* ../make-deb
 - Refer step #8 from 'Setup the environment' for passphrase

## Make manifest and save the distribution files in SVN
1.cd $CABASEDIR/$OUR_CERTS_VERSION

2.Make the manifest
* ../make-manifest 

3.Visually inspect the manifest file (ca-certs-version)

4.Set the svn release directory
* export SVNDIR=$CABASEDIR/../release

5.Copy the files to the svn release directory
* cd $CABASEDIR/$OUR_CERTS_VERSION
* cp osg-certificates-$OUR_CERTS_VERSION.tar.gz osg-certificates-$OUR_CERTS_VERSION.tar.gz.sig osg-ca-certs-$OUR_CERTS_VERSION-0.deb $SVNDIR
* cp ca-certs-version $SVNDIR/ca-certs-version-$OUR_CERTS_VERSION 
* cp cacerts_md5sum.txt $SVNDIR/cacerts_md5sum-$OUR_CERTS_VERSION.txt

6.Change to the svn release directory
* cd $SVNDIR 

7.Commit the files
* svn add osg-certificates-$OUR_CERTS_VERSION.tar.gz osg-certificates-$OUR_CERTS_VERSION.tar.gz.sig osg-ca-certs-$OUR_CERTS_VERSION-0.deb ca-certs-version-$OUR_CERTS_VERSION cacerts_md5sum-$OUR_CERTS_VERSION.txt;
* svn commit -m "OSG certificates distribution $OUR_CERTS_VERSION"

## Repeat the entire process till this point for OSG CA

# Update the web site
Update [this](https://twiki.grid.iu.edu/bin/view/Documentation/CaDistribution) if there are any significant changes to the contents of the distribution (beyond regular IGTF distribution updates).

# Creating a Release using Koji
## Setup/Preparation
* You need an environment where osg-build is installed and access to OSG development svn to get started
* Install EPEL (following command is for RHEL 7, CentOS 7, and SL 7) 
 - rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
* Install the Yum priorities package (following command is for RHEL 7, CentOS 7, and SL 7) 
 - yum install yum-plugin-priorities
* Ensure that /etc/yum.conf has the following line in the [main] section, thereby enabling Yum plugins, including the priorities one  
plugins=1
 - cat /etc/yum.conf 
* Install OSG Repositories (following command is for RHEL 7, CentOS 7, and SL 7)
 - rpm -Uvh https://repo.grid.iu.edu/osg/3.3/osg-3.3-el7-release-latest.rpm
* Install OSG and EPEL repos 
 - yum install osg-build 
* Check out the package source from subversion
 - svn co https://vdt.cs.wisc.edu/svn/native/redhat 

## Building RPM Packages
These steps assume that you have a working OSG RPM development environment and have access to the OSG development SVN.
1.Copy the tar balls to VDT upsteam machine
* On VDT machine (library.cs.wisc.edu) do: 
 - ssh library.cs.wisc.edu; 
 - mkdir /p/vdt/public/html/upstream/osg-ca-certs/n.nn/;   
   where, n.nn = version number of OSG CA
 - mkdir /p/vdt/public/html/upstream/igtf-ca-certs/m.mm;   
   where, m.mm = version number of IGTF CA
* On the machine where you build the packages 
 - In a same terminal (wherever you have done the previous steps) do  
   cd $SVNDIR;
 - scp osg-certificates-n.nnNEW.tar.gz *username*@library.cs.wisc.edu:/p/vdt/public/html/upstream/osg-ca-certs/n.nn/;   
   where, n.nn = version number of OSG CA
 - scp osg-certificates-n.nnIGTF*.tar.gz *username*@library.cs.wisc.edu:/p/vdt/public/html/upstream/igtf-ca-certs/m.mm/  
   where, n.nn = version number of OSG CA & m.mm = version number of IGTF CA

2.Do svn update (On a machine where osg build tools are installed) 
* cd /root/redhat/trunk/; 
* svn update;

3.Edit the spec and upstream files for both the rpm packages we produce to point to new release. The rpms to be updated include osg-ca-certs & igtf-ca-certs. For spec file you need to update Version, Release, Source0 and add comment in change log. For upstream file you need to update the tarball location.
* For osg-ca-certs: 
 - cd osg-ca-certs; 
 - nano osg/osg-ca-certs.spec   
   Edit Version to n.nn; release to 1; edit Source0 to osg-certificates-n.nnNEW.tar.gz; and add appropriate entry to changelog
 - nano upstream/osg-certificates-NEW.source;   
   Update location to osg-ca-certs/n.nn/osg-certificates-n.nnNEW.tar.gz;  
   where, n.nn = version number of OSG CA
 - Create a test build on local environment and Koji 
    - osg-build rpmbuild .; 
    - Create a hidden directory ‘globus’       
     mkdir /root/.globus
    - Export the OSG user certificate (.p12) from your local system and copy the same in this system (in 'globus' directory)  
    - Convert user certificate (.p12) file into userkey.pem file without the certificate   
     openssl pkcs12 -in /root/.globus/**user_certificate_and_key.p12** -out /root/.globus/userkey.pem -nodes -nocerts
    - Convert user certificate (.p12) file into usercert.pem file without the key    
     openssl pkcs12 -in /root/.globus/**user_certificate_and_key.p12** -out /root/.globus/usercert.pem -nodes -nokeys
    - grid-proxy-init 
    - osg-build --scratch koji .
* For igtf-ca-certs 
 - cd .. 
 - cd igtf-ca-certs; 
 - nano osg/igtf-ca-certs.spec   
   Edit Version to m.mm; edit Release to 1; edit Source0 to osg-certificates-n.nnIGTFNEW.tar.gz; and add appropriate entry to changelog
 - nano upstream/osg-certificates-IGTFNEW.source;   
   Update location to igtf-ca-certs/m.mm/osg-certificates-n.nnIGTFNEW.tar.gz; 
   where, n.nn = version number of OSG CA, m.mm = version number of IGTF CA
 - Create a test build on local environment and Koji
    - osg-build rpmbuild .; 
    - grid-proxy-init 
    - osg-build --scratch koji .

4.Check in the changes to SVN 
* cd /root/redhat/trunk/; 
* svn commit -m "OSG certificates distribution $OUR_CERTS_VERSION. (Jira Ticket: SOFTWARE-**NNNN**)"

5.Create official builds on Koji for EL6 and EL7
* Change to the default directory  
  cd /root/redhat/trunk/
* osg-build koji --el6 osg-ca-certs; osg-build koji --el7 osg-ca-certs; osg-build koji --el6 igtf-ca-certs; osg-build koji --el7 igtf-ca-certs;

6.Check in the changes to SVN 
* cd /root/redhat/trunk/; 
* svn commit -m "OSG certificates distribution $OUR_CERTS_VERSION. (Jira Ticket: SOFTWARE-**NNNN**)" 

7.Update the Jira ticket: Copy the result from Koji system  
* If the produced CA certificate tarball is not based on a current IGTF release - or is not meant to be eventually promoted to production - send an email to the osg-software mailing list. Give a general description of the contents of the CA tarball, how it differs from a standard IGTF one, any expected side-effects, the last "known good" version of the CA RPM, and the repositories where you plan to distribute this RPM.

8.Before promoting the Koji builds, perform extensive testing. On the fresh SL6 & SL7 VMs, perform the following  
 1. Make sure system is updated  
  * sudo yum update   
 2. Install yum-priorities     
  * sudo yum install yum-priorities  
 3. On SL6,  
  * sudo rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm  
  * sudo rpm -Uvh https://repo.grid.iu.edu/osg/3.3/osg-3.3-el6-release-latest.rpm  
  * sudo yum -y install fetch-crl    
 On SL7,  
  * sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm  
  * sudo rpm -Uvh http://repo.grid.iu.edu/osg/3.3/osg-3.3-el7-release-latest.rpm   
  * sudo yum install fetch-crl  
 4. sudo yum --enablerepo osg-development install osg-ca-certs     
    (& for IGTF, sudo yum --enablerepo osg-development install igtf-ca-certs)  
 5. Check the version number in certificates   
  * Go to cd /etc/grid-security/certificates   
  * Open any certificate with .info file i.e. cat TSU-GE.info and check version number  
  * Also, open cat INDEX.txt and check OSGversion at the end of the file  
 6. On SL6, 
  * sudo yum -y install 'perl(IO::Socket::SSL)'
  * /usr/sbin/fetch-crl    
 On SL7,
  * sudo yum -y install perl-LWP-Protocol-https 
  * /usr/sbin/fetch-crl
 7. Make sure no files are unreadable:
  * find /etc/grid-security/certificates \! -perm -a+r -print
 8. Check for expiring certs for new packages  
 for x in /etc/grid-security/certificates/*.pem  
 do  
  echo $(date -d "$(openssl x509 -in $x -noout -enddate | cut -d = -f 2)" +%Y-%m-%d) $x  
 done | sort -nr  
 9. Clean up
  * sudo yum -y remove osg-ca-certs    
    (& for IGTF, sudo yum -y remove igtf-ca-certs)
  * sudo rm -rf /etc/grid-security/certificates 
 10. Repeat 4-8 with igtf-ca-certs.
 11. Repeat 1-10 with SL7 VM, substitute SL7 for SL6, as appropriate.


Perform “developer tests”, which means that install the packages on test machines (SL6, SL7 VMs) and check that the packages install and update cleanly.
* Run this command and make sure which current release you are running in  
  cat /etc/redhat-release  
* Install the packages on test machines such as SL6 and SL7  
 - rpm -ivh http://repo.grid.iu.edu/osg/3.3/osg-3.3-el7-release-latest.rpm
 - rpm -ivh http://repo.grid.iu.edu/osg/3.3/osg-3.3-el6-release-latest.rpm  
   where -i = install a package, -v = verbose for a nicer display and -h = print hash marks as the package archive is unpacked
* Check an Installed RPM Package
 - rpm -q osg-release-3.3-5.osg33.el7.noarch
 - rpm -q osg-release-3.3-5.osg33.el6.noarch 
* Upgrade a RPM Package
 - rpm -Uvh http://repo.grid.iu.edu/osg/3.3/osg-3.3-el7-release-latest.rpm
 - rpm -Uvh http://repo.grid.iu.edu/osg/3.3/osg-3.3-el6-release-latest.rpm


Cross check the hash of new tarballs
* Go to /root/certs/trunk/cadist/release
* ls 
* Generate md5 hash for new tarballs
 - md5sum osg-certificates-1.**nn**NEW.tar.gz
 - md5sum osg-certificates-1.**nn**IGTFNEW.tar.gz
* Open md5 hash for new tarballs and verify
 - cat ca-certs-version-1.**nn**NEW 
 - cat ca-certs-version-1.**nn**IGTFNEW


Update Jira ticket, and let Brian L. know that you have done with the testing including Developer Test. He will give permission to promote build to osg-testing repository.

9.Once the build is successful, promote it to osg-testing repository
* Mark the JIRA ticket as Ready for testing  
  Change workflow from open/in progress -> Ready for Testing
* Release EL6 and EL7 builds for testing (cd to appropriate directory first)
 - In the system where you have built the packages,
 - cd /root/redhat/trunk/ 
 - grid-proxy-init
 - osg-promote osg-ca-certs igtf-ca-certs
 - Paste the output of promotions in the Jira ticket.
* Notify ITB coordinator (currently Suchandra) so he can coordinate the testing
