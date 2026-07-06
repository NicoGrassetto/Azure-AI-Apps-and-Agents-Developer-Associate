targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the azd environment used to generate a short unique hash for resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources. Choose a region that supports Azure AI Foundry Agent Service.')
param location string

@description('Id of the user or service principal to assign data-plane roles to. Provided automatically by azd (AZURE_PRINCIPAL_ID).')
param principalId string = ''

@description('Type of the principal referenced by principalId.')
@allowed([
  'User'
  'ServicePrincipal'
])
param principalType string = 'User'

@description('Model to deploy for the agent.')
param modelName string = 'gpt-4o'

@description('Model version to deploy.')
param modelVersion string = '2024-11-20'

@description('Deployment (SKU) name for the model, e.g. GlobalStandard.')
param modelSkuName string = 'GlobalStandard'

@description('Tokens-per-minute capacity (in thousands) for the model deployment.')
param modelCapacity int = 50

@description('Name used to reference the model deployment from client code.')
param modelDeploymentName string = 'gpt-4o'

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module aiFoundry 'modules/ai-foundry.bicep' = {
  name: 'ai-foundry'
  scope: rg
  params: {
    location: location
    tags: tags
    aiFoundryName: 'aifnd${resourceToken}'
    projectName: 'proj${resourceToken}'
    modelName: modelName
    modelVersion: modelVersion
    modelSkuName: modelSkuName
    modelCapacity: modelCapacity
    modelDeploymentName: modelDeploymentName
    principalId: principalId
    principalType: principalType
  }
}

output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_AI_FOUNDRY_NAME string = aiFoundry.outputs.accountName
output AZURE_AI_PROJECT_NAME string = aiFoundry.outputs.projectName
output PROJECT_ENDPOINT string = aiFoundry.outputs.projectEndpoint
output MODEL_DEPLOYMENT_NAME string = modelDeploymentName
