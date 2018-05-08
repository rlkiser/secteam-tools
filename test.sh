#!/bin/bash

#--------------------General checks for the script--------------------
#Make sure you have a reliable Internet conection before running this script
wget -q --spider http://google.com
if [ $? -ne 0 ];
then
    echo "You are offline."
    echo "Please make sure that you have a reliable Internet connection before running this script."
    exit
fi
