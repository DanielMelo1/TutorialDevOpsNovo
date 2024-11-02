#!/bin/bash

echo "Starting cleanup..."
if [ -d "/home/ec2-user/app/" ]; then
    echo "Removing files in /home/ec2-user/app/"
    rm -rf /home/ec2-user/app/*
else
    echo "Directory /home/ec2-user/app/ does not exist. Creating it now."
    mkdir -p /home/ec2-user/app
fi