#!/bin/bash
#Generate parameters with value for deployment

parametersPath=$1
location=$2
adminPasswordOrKey=$3
wlsdomainname=$4
wlsusername=$5
wlspassword=$6
managedserverprefix=$7
numinstances=$8
adminvmname=$9
linuxImageOfferSKU=${10}
testbranchName=${11}
gitUserName=${12}

export linuxImageVersion="1.1.1"

#Use 1.1.6 for owls-122130-8u131-ol73
if [ ${linuxImageOfferSKU} == "owls-122130-8u131-ol73" ];
then
    linuxImageVersion="1.1.6"
fi

#Clean up parameters.json
if [[ -f "$parametersPath" ]]; then
    rm -f ${parametersPath}
fi

cat <<EOF > ${parametersPath}
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "adminUsername": {
      "value": "weblogic"
    },
    "adminPasswordOrKey": {
      "value": "$adminPasswordOrKey"
    },
    "dnsLabelPrefix": {
      "value": "wls"
    },
    "wlsDomainName": {
      "value": "$wlsdomainname"
    },
    "wlsUserName": {
      "value": "$wlsusername"
    },
    "wlsPassword": {
      "value": "$wlspassword"
    },
    "managedServerPrefix":{
      "value": "$managedserverprefix"
    },
    "numberOfInstances": {
      "value": $numinstances
    },
    "adminVMName": {
      "value": "$adminvmname"
    },
    "vmSizeSelect": {
      "value": "Standard_A3"
    },
    "location": {
      "value": "$location"
    },
    "linuxImageOfferSKU": {
      "value": "$linuxImageOfferSKU"
    },
    "linuxImageVersion": {
      "value":"$linuxImageVersion"
    },
    "_artifactsLocation": {
      "value": "https://raw.githubusercontent.com/${gitUserName}/arm-oraclelinux-wls-cluster/${testbranchName}/arm-oraclelinux-wls-cluster/src/main/arm/"
    }
  }
}
EOF
