#!/bin/bash

# Verifying webapp deployment
echo "Verifying WebLogic Cafe is deployed as expected"
curl --verbose http://#appGatewayURL#/weblogic-cafe/rest/coffees
if [[ $? != 0 ]]; then
   echo "WebLogic Cafe is not accessible"
   exit 1
else
   echo "WebLogic Cafe is accessible"
fi
if [[ $? != 0 ]]; then
   echo "WebLogic admin console is not accessible"
   exit 1
else
   echo "WebLogic admin console is accessible"
fi