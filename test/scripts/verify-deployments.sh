#!/bin/bash

groupNamePrefix="$1"
groupName=${groupNamePrefix}-preflight
location="$2"
template="$3"
githubUserName="$4"
testbranchName="$5"
scriptsDir="$6"

# generate parameters for testing differnt cases
parametersList=()
sh ${scriptsDir}/gen-parameters.sh ${scriptsDir}/parameters.json $githubUserName $testbranchName
parametersList+=(${scriptsDir}/parameters.json)
sh ${scriptsDir}/gen-parameters-db.sh ${scriptsDir}/parameters-db.json $githubUserName $testbranchName
parametersList+=(${scriptsDir}/parameters-db.json)
sh ${scriptsDir}/gen-parameters-aad.sh ${scriptsDir}/parameters-aad.json $githubUserName $testbranchName
parametersList+=(${scriptsDir}/parameters-aad.json)
sh ${scriptsDir}/gen-parameters-db-aad.sh ${scriptsDir}/parameters-db-aad.json $githubUserName $testbranchName
parametersList+=(${scriptsDir}/parameters-db-aad.json)

# create Azure resources for preflight testing
az group create --verbose --name $groupName --location ${location}

# run preflight tests
for parameters in "${parametersList[@]}";
do
    az deployment group validate -g ${groupName} -f ${template} -p @${parameters} --no-prompt
done

# release Azure resources
az group delete --yes --no-wait --verbose --name $groupName
