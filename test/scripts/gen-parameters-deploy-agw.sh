#!/bin/bash

parametersPath=$1
githubUserName=$2
testbranchName=$3
adminVMName=$4
appGatewaySSLCertificateData=$5
appGatewaySSLCertificatePassword=$6
numberOfInstances=$7
location=$8
wlsPassword=$9
wlsUserName=${10}
wlsDomainName=${11}

cat <<EOF > ${parametersPath}
{
    "\$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "_artifactsLocation": {
            "value": "https://raw.githubusercontent.com/${githubUserName}/arm-oraclelinux-wls-cluster/${testbranchName}/arm-oraclelinux-wls-cluster/src/main/arm/"
        },
        "adminVMName": {
            "value": "${adminVMName}"
        },
        "appGatewaySSLCertificateData": {
            "value": "${appGatewaySSLCertificateData}"
        },
        "appGatewaySSLCertificatePassword": {
            "value": "${appGatewaySSLCertificatePassword}"
        },
        "numberOfInstances": {
            "value": ${numberOfInstances}
        },
        "location": {
            "value": "${location}"
        },
        "wlsDomainName": {
            "value": "${wlsDomainName}"
        },
        "wlsPassword": {
            "value": "${wlsPassword}"
        },
        "wlsUserName": {
            "value": "${wlsUserName}"
        }
    }
}
EOF
