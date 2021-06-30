#!/usr/bin/env bash

set -euo pipefail

for ((i=0;i<=NUM_USERS-1;i++)); do
  printf "Creating Dynatrace Environment $DT_ENV_NAME_PREFIX-$i\n\n"

environment_body=$(cat <<EOF
{
  "name": "$DT_ENV_NAME_PREFIX-$i",
  "state": "ENABLED",
  "tags": [
    "$DT_TAGS"
  ],
  "trial": false
}
EOF
)

  DT_ENVIRONMENT_RESPONSE=$(curl -k -s --location --request POST "${DT_CLUSTER_URL}/api/cluster/v2/environments?createToken=true" \
  --header "Authorization: Api-Token $DT_CLUSTER_TOKEN" \
  --header "Content-Type: application/json" \
  --data-raw "${environment_body}")
  DT_ENVIRONMENT_ID=$(echo $DT_ENVIRONMENT_RESPONSE | jq -r '.id' )
  DT_ENVIRONMENT_TOKEN=$(echo $DT_ENVIRONMENT_RESPONSE | jq -r '.tokenManagementToken' )

  printf "Creating PAAS Token for Dynatrace Environment ${DT_CLUSTER_URL}/e/$DT_ENVIRONMENT_ID\n\n"

  paas_token_body='{
                      "scopes": [
                          "InstallerDownload"
                      ],
                      "name": "vhot-monaco-paas"
                    }'

  DT_PAAS_TOKEN_RESPONSE=$(curl -k -s --location --request POST "${DT_CLUSTER_URL}/e/$DT_ENVIRONMENT_ID/api/v2/apiTokens" \
  --header "Authorization: Api-Token $DT_ENVIRONMENT_TOKEN" \
  --header "Content-Type: application/json" \
  --data-raw "${paas_token_body}")
  DT_PAAS_TOKEN=$(echo $DT_PAAS_TOKEN_RESPONSE | jq -r '.token' )

  printf "Creating API Token for Dynatrace Environment ${DT_CLUSTER_URL}/e/$DT_ENVIRONMENT_ID\n\n"

  api_token_body='{
                    "scopes": [
                      "DataExport", "PluginUpload", "DcrumIntegration", "AdvancedSyntheticIntegration", "ExternalSyntheticIntegration", 
                      "LogExport", "ReadConfig", "WriteConfig", "DTAQLAccess", "UserSessionAnonymization", "DataPrivacy", "CaptureRequestData", 
                      "Davis", "DssFileManagement", "RumJavaScriptTagManagement", "TenantTokenManagement", "ActiveGateCertManagement", "RestRequestForwarding", 
                      "ReadSyntheticData", "DataImport", "auditLogs.read", "metrics.read", "metrics.write", "entities.read", "entities.write", "problems.read", 
                      "problems.write", "networkZones.read", "networkZones.write", "activeGates.read", "activeGates.write", "credentialVault.read", "credentialVault.write", 
                      "extensions.read", "extensions.write", "extensionConfigurations.read", "extensionConfigurations.write", "extensionEnvironment.read", "extensionEnvironment.write", 
                      "metrics.ingest", "securityProblems.read", "securityProblems.write", "syntheticLocations.read", "syntheticLocations.write", "settings.read", "settings.write", 
                      "tenantTokenRotation.write", "slo.read", "slo.write", "releases.read", "apiTokens.read", "apiTokens.write", "logs.read", "logs.ingest"
                    ],
                    "name": "vhot-monaco-api-token"
                  }'

  DT_API_TOKEN_RESPONSE=$(curl -k -s --location --request POST "${DT_CLUSTER_URL}/e/$DT_ENVIRONMENT_ID/api/v2/apiTokens" \
  --header "Authorization: Api-Token $DT_ENVIRONMENT_TOKEN" \
  --header "Content-Type: application/json" \
  --data-raw "${api_token_body}")
  DT_API_TOKEN=$(echo $DT_API_TOKEN_RESPONSE | jq -r '.token' )

environment_data=$(cat <<EOF
$i = {
        url = "${DT_CLUSTER_URL}/e/$DT_ENVIRONMENT_ID",
        paas_token = "$DT_PAAS_TOKEN",
        api_token = "$DT_API_TOKEN"
      }
EOF
)

  echo $environment_data >> dt_envs.txt

done