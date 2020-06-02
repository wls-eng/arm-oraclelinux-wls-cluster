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
bash ${scriptsDir}/gen-parameters.sh ${scriptsDir}/parameters.json $githubUserName $testbranchName
parametersList+=(${scriptsDir}/parameters.json)
bash ${scriptsDir}/gen-parameters-db.sh ${scriptsDir}/parameters-db.json $githubUserName $testbranchName
parametersList+=(${scriptsDir}/parameters-db.json)
bash ${scriptsDir}/gen-parameters-aad.sh ${scriptsDir}/parameters-aad.json $githubUserName $testbranchName
parametersList+=(${scriptsDir}/parameters-aad.json)
bash ${scriptsDir}/gen-parameters-db-aad.sh ${scriptsDir}/parameters-db-aad.json $githubUserName $testbranchName
parametersList+=(${scriptsDir}/parameters-db-aad.json)
bash ${scriptsDir}/gen-parameters-ag.sh ${scriptsDir}/parameters-ag.json $githubUserName $testbranchName 4 5 6 7
parametersList+=(${scriptsDir}/parameters-ag.json)

# create Azure resources for preflight testing
az group create --verbose --name $groupName --location ${location}

# run preflight tests
success=true
for parameters in "${parametersList[@]}";
do
    az deployment group validate -g ${groupName} -f ${template} -p @${parameters} --no-prompt
    if [[ $? != 0 ]]; then
        echo "deployment validation for ${parameters} failed!"
        success=false
    fi
done

# release Azure resources
az group delete --yes --no-wait --verbose --name $groupName

if [[ $success == "false" ]]; then
    exit 1
else
    exit 0
fi
