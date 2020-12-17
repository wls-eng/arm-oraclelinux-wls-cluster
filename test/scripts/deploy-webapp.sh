#!/bin/bash

# Verifying admin server is accessible
isSuccess=false
maxAttempt=5
attempt=1
echo "Verifying http://#adminVMDNS#:7001/weblogic/ready"
while [ $attempt -le $maxAttempt ]
do
  echo "Attempt $attempt :- Checking WebLogic admin server is accessible"
  curl http://#adminVMDNS#:7001/weblogic/ready 
  if [ $? == 0 ]; then
     isSuccess=true
     break
  fi
  attempt=`expr $attempt + 1`
  sleep 2m
done

if [[ $isSuccess == "false" ]]; then
        echo "Failed : WebLogic admin server is not accessible"
        exit 1
else
        echo "WebLogic admin server is accessible"
fi

# Deploy webapp to weblogic server
curl -v \
--user #wlsUserName#:#wlsPassword# \
-H X-Requested-By:MyClient \
-H Accept:application/json \
-H Content-Type:multipart/form-data \
-F "model={
  name:    'weblogic-cafe',
  targets: [ { identity: [ 'clusters', 'cluster1' ] } ]
}" \
-F "sourcePath=@weblogic-on-azure/javaee/weblogic-cafe/target/weblogic-cafe.war" \
-X Prefer:respond-async \
-X POST http://#adminVMDNS#:7001/management/weblogic/latest/edit/appDeployments
exit 0
