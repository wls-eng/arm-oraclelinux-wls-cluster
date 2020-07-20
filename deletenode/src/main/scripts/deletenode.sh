#!/bin/bash

#Function to output message to StdErr
function echo_stderr ()
{
    echo "$@" >&2
}

#Function to display usage message
function usage()
{
  echo_stderr "./deletenode.sh <wlsUserName> <wlsPassword> <managedServerNames> <managedVMNames> <forceShutDown> <wlsAdminHost> <wlsAdminPort> <oracleHome>"  
}

function validateInput()
{
    if [[ -z "$wlsUserName" || -z "$wlsPassword" ]]
    then
        echo_stderr "wlsUserName or wlsPassword is required. "
        exit 1
    fi	

    if [ -z "$managedServerNames" ];
    then
        echo_stderr "managedServerNames is required. "
    fi

    if [ -z "$managedVMNames" ];
    then
        echo_stderr "managedVMNames is required. "
    fi

    if [ -z "$wlsForceShutDown" ];
    then
        echo_stderr "wlsForceShutDown is required. "
    fi

    if [ -z "$wlsAdminHost" ];
    then
        echo_stderr "wlsAdminHost is required. "
    fi

    if [ -z "$wlsAdminPort" ];
    then
        echo_stderr "wlsAdminPort is required. "
    fi

    if [ -z "$oracleHome" ];
    then
        echo_stderr "oracleHome is required. "
    fi
}

#Function to cleanup all temporary files
function cleanup()
{
    echo "Cleaning up temporary files..."
    rm -f delete-server.py
    rm -f delete-machine.py
    echo "Cleanup completed."
}

#This function to delete machine for a given managed server
function delete_machine_model()
{
    echo "Deleting managed server name model for $managedServerNames"
    cat <<EOF >delete-server.py
connect('$wlsUserName','$wlsPassword','t3://$wlsAdminURL')
try:
    edit()
    startEdit()
EOF

arrServerNames=$(echo $managedServerNames | tr "," "\n")
for server in $arrServerNames
do
    echo "deleting name model for $server"
    cat <<EOF >>delete-server.py
    shutdown('$server', 'Server',ignoreSessions='true',force='$wlsForceShutDown')
    editService.getConfigurationManager().removeReferencesToBean(getMBean('/MigratableTargets/$server (migratable)'))
    cd('/')
    cmo.destroyMigratableTarget(getMBean('/MigratableTargets/$server (migratable)'))
    cd('/Servers/$server')
    cmo.setCluster(None)
    cmo.setMachine(None)
    editService.getConfigurationManager().removeReferencesToBean(getMBean('/Servers/$server'))
    cd('/')
    cmo.destroyServer(getMBean('/Servers/$server'))
EOF
done

cat <<EOF >>delete-server.py
    save()
    activate()
except:
    stopEdit('y')
    sys.exit(1)
   
disconnect()
EOF
}

#This function to delete managed server to admin node
function delete_ms_server_model()
{
    echo "Deleting managed server machine name model for $managedVMNames"
    cat <<EOF >delete-machine.py
connect('$wlsUserName','$wlsPassword','t3://$wlsAdminURL')
try:
    edit()
    startEdit()
EOF

    arrServerMachineNames=$(echo $managedVMNames | tr "," "\n")
    for machine in $arrServerMachineNames
    do
    echo "deleting name model for $machine"
    cat <<EOF >>delete-machine.py
    editService.getConfigurationManager().removeReferencesToBean(getMBean('/Machines/$machine'))
    cmo.destroyMachine(getMBean('/Machines/$machine'))
EOF
    done

    cat <<EOF >>delete-machine.py
    save()
    activate()
except:
    stopEdit('y')
    sys.exit(1)

disconnect()
EOF
}

#This function to check admin server status 
function wait_for_admin()
{
    #check admin server status
    count=1
    export CHECK_URL="http://$wlsAdminURL/weblogic/ready"
    status=`curl --insecure -ILs $CHECK_URL | tac | grep -m1 HTTP/1.1 | awk {'print $2'}`
    echo "Check admin server status"
    while [[ "$status" != "200" ]]
    do
    echo "."
    count=$((count+1))
    if [ $count -le 30 ];
    then
        sleep 1m
    else
        echo "Error : Maximum attempts exceeded while checking admin server status"
        exit 1
    fi
    status=`curl --insecure -ILs $CHECK_URL | tac | grep -m1 HTTP/1.1 | awk {'print $2'}`
    if [ "$status" == "200" ];
    then
        echo "WebLogic Server is running..."
        break
    fi
    done  
}

function delete_managed_server()
{
    . $oracleHome/oracle_common/common/bin/setWlstEnv.sh

    echo "Start to delete managed server $managedServerNames"
    java $WLST_ARGS weblogic.WLST delete-server.py
    if [[ $? != 0 ]]; then
            echo "Error : Deleting server $managedServerNames failed"
            exit 1
    fi
    echo "Complete deleting managed server $managedServerNames"

    echo "Start to delete managed server machine $managedServerNames"
    java $WLST_ARGS weblogic.WLST delete-machine.py
    if [[ $? != 0 ]]; then
            echo "Error : Deleting machine for managed server $managedServerNames failed"
            exit 1
    fi
    echo "Complete deleting managed server machine $managedServerNames"
}

#main script starts here

if [ $# -ne 8 ]
then
    usage
	exit 1
fi

export wlsUserName=$1
export wlsPassword=$2
export managedServerNames=$3
export managedVMNames=$4
export wlsForceShutDown=$5
export wlsAdminHost=$6
export wlsAdminPort=$7
export oracleHome=$8
export wlsAdminURL=$wlsAdminHost:$wlsAdminPort
export hostName=`hostname`

validateInput

cleanup

wait_for_admin

delete_machine_model

delete_ms_server_model

delete_managed_server

cleanup
