targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the azd environment used to generate a short unique hash for resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources. Choose a region that supports Azure AI Foundry Agent Service and Azure AI Search.')
param location string

@description('Id of the user or service principal to assign data-plane roles to. Provided automatically by azd (AZURE_PRINCIPAL_ID).')
param principalId string = ''

@description('Type of the principal referenced by principalId.')
@allowed([
  'User'
  'ServicePrincipal'
])
param principalType string = 'User'

@description('Chat model to deploy for the agent.')
param modelName string = 'gpt-4o'
param modelVersion string = '2024-11-20'
param modelSkuName string = 'GlobalStandard'
param modelCapacity int = 50
param modelDeploymentName string = 'gpt-4o'

@description('Embedding model used by the Foundry IQ knowledge base.')
param embeddingModelName string = 'text-embedding-3-small'
param embeddingModelVersion string = '1'
param embeddingModelCapacity int = 50
param embeddingModelDeploymentName string = 'text-embedding-3-small'

@description('SKU for the Azure AI Search service.')
param searchSkuName string = 'standard'

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
    embeddingModelName: embeddingModelName
    embeddingModelVersion: embeddingModelVersion
    embeddingModelCapacity: embeddingModelCapacity
    embeddingModelDeploymentName: embeddingModelDeploymentName
    principalId: principalId
    principalType: principalType
  }
}

module search 'modules/search.bicep' = {
  name: 'search'
  scope: rg
  params: {
    location: location
    tags: tags
    searchServiceName: 'srch${resourceToken}'
    searchSkuName: searchSkuName
    storageAccountName: 'st${resourceToken}'
    principalId: principalId
    principalType: principalType
    projectPrincipalId: aiFoundry.outputs.projectPrincipalId
  }
}

// Grant the Search managed identity access to the embedding model (integrated vectorization).
module searchEmbeddingGrant 'modules/search-embedding-grant.bicep' = {
  name: 'search-embedding-grant'
  scope: rg
  params: {
    accountName: aiFoundry.outputs.accountName
    searchIdentityPrincipalId: search.outputs.searchIdentityPrincipalId
  }
}

output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_AI_FOUNDRY_NAME string = aiFoundry.outputs.accountName
output AZURE_AI_PROJECT_NAME string = aiFoundry.outputs.projectName
output PROJECT_ENDPOINT string = aiFoundry.outputs.projectEndpoint
output MODEL_DEPLOYMENT_NAME string = modelDeploymentName
output EMBEDDING_DEPLOYMENT_NAME string = aiFoundry.outputs.embeddingDeploymentName
output SEARCH_SERVICE_NAME string = search.outputs.searchServiceName
output SEARCH_ENDPOINT string = search.outputs.searchEndpoint
output STORAGE_ACCOUNT_NAME string = search.outputs.storageAccountName
output BLOB_CONTAINER_NAME string = search.outputs.blobContainerName
output BLOB_ENDPOINT string = search.outputs.blobEndpoint
