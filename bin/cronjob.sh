#!/bin/bash

# Add the kindlegen and kindlerb to PATH
export PATH=$PATH:/home/username/app/vendor/bin:/usr/local/bin

# Run the delivery processor
cd /home/username/app && bin/rails runner -e production "DeliveryProcessor.check"
