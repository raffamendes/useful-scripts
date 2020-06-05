#!/bin/bash

namespace=$1
tenantName=$2
tenantEmail=$3
tenantPassword=$4
filename=$tenantName-tenant.xml

masterAccessToken=$(oc get secret system-seed -n $namespace -o json | jq -r .data.MASTER_ACCESS_TOKEN | base64 -d)
masterRoute="https://"$(oc get routes -n $namespace | grep master | awk '{print $2}')
#/master/api/"
#providers.xml


#echo $masterRoute

echo "---------------------------------"
echo "---------------------------------"
echo "Creating tenant "$tenantName" on namespace "$namespace
echo "---------------------------------"
echo "---------------------------------"

curl -X POST $masterRoute"/master/api/providers.xml" -d "access_token=$masterAccessToken" -d "org_name=$tenantName" -d "username=$tenantName-admin" --data-urlencode "email=$tenantEmail" -d "password=$tenantPassword" -k >> /tmp/$filename

accountID=$(xmllint /tmp/$filename --xpath 'string(//signup/account/id)')
userID=$(xmllint /tmp/$filename --xpath 'string(//users/user/id)')

echo "---------------------------------"
echo "---------------------------------"
echo "Activating Tenant "$tenantName
echo "---------------------------------"
echo "---------------------------------"

curl -X PUT $masterRoute"/admin/api/accounts/"$accountID"/users/"$userID"/activate.xml" -d "access_token=$masterAccessToken" -k -vv

echo "Printing routes created automatically by ZYNC"
echo "---------------------------------"
echo "---------------------------------"
for route in  $(oc get routes -n $namespace | grep $tenantName | awk '{print $2}'); 
  do
    echo "https://"$route
  done
