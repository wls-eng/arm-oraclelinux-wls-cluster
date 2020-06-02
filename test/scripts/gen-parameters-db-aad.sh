#!/bin/sh

parametersPath=$1
githubUserName=$2
testbranchName=$3

cat <<EOF > ${parametersPath}
{
    "\$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "_artifactsLocation": {
            "value": "https://raw.githubusercontent.com/${githubUserName}/arm-oraclelinux-wls-cluster/${testbranchName}/arm-oraclelinux-wls-cluster/src/main/arm/"
        },
        "_artifactsLocationSasToken": {
            "value": ""
        },
        "aadsPortNumber": {
            "value": "636"
        },
        "acceptOTNLicenseAgreement": {
            "value": "Y"
        },
        "addsPublicIP": {
            "value": "GEN-UNIQUE"
        },
        "addsServerHost": {
            "value": "GEN-UNIQUE"
        },
        "adminPasswordOrKey": {
            "value": "GEN-UNIQUE"
        },
        "adminUsername": {
            "value": "GEN-UNIQUE"
        },
        "connectToDatabase": {
            "value": true
        },
        "databaseType": {
            "value": "postgresql"
        },
        "dsConnectionURL": {
            "value": "GEN-UNIQUE"
        },
        "dsPassword": {
            "value": "GEN-UNIQUE"
        },
        "dsUser": {
            "value": "GEN-UNIQUE"
        },
        "enableAAD": {
            "value": true
        },
        "enableAppGateway": {
            "value": false
        },
        "jdbcDataSourceName": {
            "value": "jdbc/postgresql"
        },
        "numberOfInstances": {
            "value": 4
        },
        "otnAccountPassword": {
            "value": "GEN-UNIQUE"
        },
        "otnAccountUsername": {
            "value": "GEN-UNIQUE"
        },
        "wlsLDAPGroupBaseDN": {
            "value": "GEN-UNIQUE"
        },
        "wlsLDAPPrincipal": {
            "value": "GEN-UNIQUE"
        },
        "wlsLDAPPrincipalPassword": {
            "value": "GEN-UNIQUE"
        },
        "wlsLDAPProviderName": {
            "value": "AzureActiveDirectoryProvider"
        },
        "wlsLDAPSSLCertificate": {
            "value": "GEN-UNIQUE"
        },
        "wlsLDAPUserBaseDN": {
            "value": "GEN-UNIQUE"
        },
        "wlsPassword": {
            "value": "GEN-UNIQUE"
        },
        "wlsUserName": {
            "value": "GEN-UNIQUE"
        }
    }
}
EOF
