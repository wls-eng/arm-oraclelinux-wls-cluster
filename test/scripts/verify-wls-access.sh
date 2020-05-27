echo "Wait for few minutes"
sleep 3m 
# Verifying admin server is accessible
echo "Verifying http://#adminVMName#:7001/weblogic/ready"
curl http://#adminVMName#:7001/weblogic/ready 
if [ $? != 0 ]; then
  echo "Weblogic admin server is not accessible"
  exit 1
fi

#Verifying whether managed servers are up/running
export managedServers="#managedServers#"
for managedServer in $managedServers
do
  echo "Verifying managed server : $managedServer"
  curl --user #wlsUserName#:#wlspassword# -X GET -H 'X-Requested-By: MyClient' -H 'Content-Type: application/json' -H 'Accept: application/json'  -i "http://#adminVMName#:7001/management/weblogic/latest/domainRuntime/serverRuntimes/$managedServer" | grep "\"state\": \"RUNNING\""
  if [ $? != 0 ]; then
    echo "$managedServer managed server is not in RUNNING state"
    exit 1
fi
done
exit 0
