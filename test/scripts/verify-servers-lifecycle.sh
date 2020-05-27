export managedServers="#managedServers#"
for managedServer in $managedServers
do
  echo "Shut down managed server : $managedServer"
  curl --user #wlsUserName#:#wlspassword# -X POST -H 'X-Requested-By: MyClient' -H 'Content-Type: application/json' -H 'Accept: application/json'  -i "http://#adminVMName#:7001/management/weblogic/latest/domainRuntime/serverRuntimes/$managedServer/shutdown" --data '{}'
  sleep 30s
  curl --user #wlsUserName#:#wlspassword# -X GET -H 'X-Requested-By: MyClient' -H 'Content-Type: application/json' -H 'Accept: application/json'  -i "http://#adminVMName#:7001/management/weblogic/latest/domainRuntime/serverLifeCycleRuntimes/$managedServer" | grep "\"state\": \"SHUTDOWN\""
  if [ $? != 0 ]; then
    echo "$managedServer managed server is not in SHUTDOWN state"
    exit 1
  fi   
  curl --user #wlsUserName#:#wlspassword# -X POST -H 'X-Requested-By: MyClient' -H 'Content-Type: application/json' -H 'Accept: application/json'  -i "http://#adminVMName#:7001/management/weblogic/latest/domainRuntime/serverLifeCycleRuntimes/$managedServer/start" --data '{}'
  curl --user #wlsUserName#:#wlspassword# -X GET -H 'X-Requested-By: MyClient' -H 'Content-Type: application/json' -H 'Accept: application/json'  -i "http://#adminVMName#:7001/management/weblogic/latest/domainRuntime/serverRuntimes/$managedServer" | grep "\"state\": \"RUNNING\""
  if [ $? != 0 ]; then
    echo "$managedServer managed server is not in RUNNING state"
    exit 1
  fi   
done  

exit 0
