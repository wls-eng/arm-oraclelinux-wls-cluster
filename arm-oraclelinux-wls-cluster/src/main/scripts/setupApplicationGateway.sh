#Function to output message to StdErr
function echo_stderr()
{
    echo "$@" >&2
}

#Function to display usage message
function usage()
{
  echo_stderr "./setupApplicationGateway.sh <wlsAdminServerName> <wlsUserName> <wlsPassword> <wlsAdminHost> <wlsAdminPort> <AppGWHostName> <oracleHome>"
}

#Function to validate input
function validateInput()
{
     if [ -z "$wlsAdminServerName" ];
    then
        echo_stderr "wlsAdminServerName is required. "
    fi

    if [[ -z "$wlsUserName" || -z "$wlsPassword" ]]
    then
        echo_stderr "wlsUserName or wlsPassword is required. "
        exit 1
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

#Function to setup application gateway
#Set cluster frontend host
#Create channels for managed server
function setupApplicationGateway()
{
    cat <<EOF >$SCRIPT_PWD/setup-app-gateway.py
connect('$wlsUserName','$wlsPassword','t3://$wlsAdminURL')

edit("$wlsAdminServerName")
startEdit()
cd('/')

cd('/Clusters/cluster1')
cmo.setFrontendHTTPPort($AppGWHttpPort)
cmo.setFrontendHTTPSPort($AppGWHttpsPort)
cmo.setFrontendHost('$AppGWHostName')

servers=cmo.getServers()
for server in servers:
    print "Creating T3 channel Port on managed server: + server.getName()"
    serverPath="/Servers/"+server.getName()
    cd(serverPath)
    create('T3Channel','NetworkAccessPoint')
    cd(serverPath+"/NetworkAccessPoints/T3Channel")
    set('Protocol','t3')
    set('ListenAddress','')
    set('ListenPort',$channelPort)
    set('PublicAddress', '$AppGWHostName')
    set('PublicPort', $channelPort)
    set('Enabled','true')

    cd(serverPath)
    create('HTTPChannel','NetworkAccessPoint')
    cd(serverPath+"/NetworkAccessPoints/HTTPChannel")
    set('Protocol','http')
    set('ListenAddress','')
    set('ListenPort',$channelPort)
    set('PublicAddress', '$AppGWHostName')
    set('PublicPort', $channelPort)
    set('Enabled','true')

save()
resolve()
activate()
destroyEditSession("$wlsAdminServerName")
disconnect()
EOF

    . $oracleHome/oracle_common/common/bin/setWlstEnv.sh
    java $WLST_ARGS weblogic.WLST ${SCRIPT_PWD}/setup-app-gateway.py

    if [[ $? != 0 ]]; then
        echo "Error : Fail to cofigure application gateway."
        exit 1
    fi

}

function restartManagedServers()
{
    echo "Restart managed servers"
    cat <<EOF >${SCRIPT_PWD}/restart-managedServer.py
connect('$wlsUserName','$wlsPassword','t3://$wlsAdminURL')
servers=cmo.getServers()
domainRuntime()
print "Restart the servers which are in RUNNING status"
for server in servers:
    bean="/ServerLifeCycleRuntimes/"+server.getName()
    serverbean=getMBean(bean)
    if (serverbean.getState() in ("RUNNING")) and (server.getName() != '${wlsAdminServerName}'):
        try:
            print "Stop the Server ",server.getName()
            shutdown(server.getName(),server.getType(),ignoreSessions='true',force='true')
            print "Start the Server ",server.getName()
            start(server.getName(),server.getType())
        except:
            print "Failed restarting managed server ", server.getName()
            dumpStack()
serverConfig()
disconnect()
EOF
    . $oracleHome/oracle_common/common/bin/setWlstEnv.sh
    java $WLST_ARGS weblogic.WLST ${SCRIPT_PWD}/restart-managedServer.py 

    if [[ $? != 0 ]]; then
        echo "Error : Fail to restart managed server."
        exit 1
    fi
}

SCRIPT_PWD=`pwd`

if [ $# -ne 7 ]
then
    usage
	exit 1
fi

wlsAdminServerName=$1
wlsUserName=$2
wlsPassword=$3
wlsAdminHost=$4
wlsAdminPort=$5
AppGWHostName=$6
oracleHome=$7
export wlsAdminURL=$wlsAdminHost:$wlsAdminPort

export channelPort=8501
export AppGWHttpPort=80
export AppGWHttpsPort=443

validateInput

setupApplicationGateway

restartManagedServers