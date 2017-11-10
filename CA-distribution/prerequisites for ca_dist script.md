1.You should have a user certificate + key in pkcs12 format from the OSG CA. [See CertificateUserGet for instructions](https://twiki.grid.iu.edu/bin/view/ReleaseDocumentation/CertificateUserGet).

2.You should have access to the svn repository i.e. https://vdt.cs.wisc.edu/svn/certs. 
*	Ask the OSG Software-Release team for the access   
*	Tim Theisen creates accounts for svn (as of 11/10/17)
*	Find more contact information [here](https://twiki.opensciencegrid.org/bin/view/SoftwareTeam/WebHome)

3.You should have access to the Koji build system
*	Ask the OSG Software team for the access 
*	Mat Selmeci grants access to the Koji build system (as of 11/10/17)

4.You should have the private key of security@opensciencegrid.org
*	Follow “PGP key generation” step from https://twiki.grid.iu.edu/bin/view/SecurityTeam/SecureEmailKeyManagement and send the public key to Jeny (as of 11/10/17)
*	She will send OSG private key, encrypted using the public key
*	She will also send passphrase for OSG private key separately, encrypted using the public key
*	Decrypt both the files using the following command  
gpg --output pathtooutputfile/outputfile --decrypt pathtofile/file.gpg and then enter your passphrase
*	Follow “PGP secret key import” step from: https://twiki.grid.iu.edu/bin/view/SecurityTeam/SecureEmailKeyManagement 
gpg --import --allow-secret-key-import < pathtofile/file.asc
