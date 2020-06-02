#!/bin/bash

prefix="$1"
location="$2"
template="$3"
githubUserName="$4"
testbranchName="$5"
scriptsDir="$6"

groupName=${prefix}-preflight
keyVaultName=preflightkeyvault
certDataName=certData
certPasswordName=certPassword

# create Azure resources for preflight testing
az group create --verbose --name $groupName --location ${location}
az keyvault create -n ${keyVaultName} -g ${groupName} -l ${location}
az keyvault update -n ${keyVaultName} -g ${groupName} --enabled-for-template-deployment true
openssl genrsa -passout pass:GEN-UNIQUE -out privkey.pem 3072
openssl req -x509 -new -key privkey.pem -out privkey.pub -subj "/C=US"
openssl pkcs12 -passout pass:GEN-UNIQUE -export -in privkey.pub -inkey privkey.pem -out mycert.pfx
az keyvault secret set --vault-name ${keyVaultName} -n ${certDataName} --file mycert.pfx --encoding base64
az keyvault secret set --vault-name ${keyVaultName} -n ${certPasswordName} --value GEN-UNIQUE

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
bash ${scriptsDir}/gen-parameters-ag.sh ${scriptsDir}/parameters-ag.json $githubUserName $testbranchName \
    ${keyVaultName} ${groupName} ${certDataName} ${certPasswordName}
parametersList+=(${scriptsDir}/parameters-ag.json)

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
