@description('Location for the Azure AI Search and Storage resources.')
param location string

@description('Tags to apply to all resources.')
param tags object = {}

@description('Name of the Azure AI Search service.')
param searchServiceName string

@description('SKU for the Azure AI Search service. "standard" supports semantic ranking used by Foundry IQ.')
@allowed([
  'basic'
  'standard'
  'standard2'
  'standard3'
])
param searchSkuName string = 'standard'

@description('Name of the Storage account that holds the knowledge-base source documents.')
param storageAccountName string

@description('Name of the blob container that holds the product documents.')
param blobContainerName string = 'product-data'

@description('Signed-in user/service principal to grant data-plane access to.')
param principalId string = ''

@allowed([
  'User'
  'ServicePrincipal'
])
param principalType string = 'User'

@description('Managed identity principal of the Foundry project, granted read access to Search so the agent can query the knowledge base.')
param projectPrincipalId string = ''

// Azure AI Search service (system-assigned identity so it can pull from Storage
// and call the embedding model with managed identity when indexing).
resource search 'Microsoft.Search/searchServices@2024-06-01-preview' = {
  name: searchServiceName
  location: location
  tags: tags
  sku: {
    name: searchSkuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    semanticSearch: 'standard'
    publicNetworkAccess: 'enabled'
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
  }
}

// Storage account + blob container for the knowledge-base source documents.
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storage
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: blobContainerName
  properties: {
    publicAccess: 'None'
  }
}

// Built-in role definition IDs.
var searchServiceContributor = '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
var searchIndexDataContributor = '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
var searchIndexDataReader = '1407120a-92aa-4202-b7e9-c0e197c71c8f'
var storageBlobDataContributor = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageBlobDataReader = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

// --- Signed-in user grants (so the portal Foundry IQ wizard and CLI can manage everything) ---
resource userSearchServiceContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(search.id, principalId, searchServiceContributor)
  scope: search
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchServiceContributor)
  }
}

resource userSearchIndexDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(search.id, principalId, searchIndexDataContributor)
  scope: search
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataContributor)
  }
}

resource userStorageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(storage.id, principalId, storageBlobDataContributor)
  scope: storage
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributor)
  }
}

// --- Search service identity -> read documents from Storage (indexer pull) ---
resource searchReadStorage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storage.id, search.id, storageBlobDataReader)
  scope: storage
  properties: {
    principalId: search.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataReader)
  }
}

// --- Foundry project identity -> query the Search index (agent retrieval) ---
resource projectSearchReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(projectPrincipalId)) {
  name: guid(search.id, projectPrincipalId, searchIndexDataReader)
  scope: search
  properties: {
    principalId: projectPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataReader)
  }
}

resource projectSearchServiceContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(projectPrincipalId)) {
  name: guid(search.id, projectPrincipalId, searchServiceContributor)
  scope: search
  properties: {
    principalId: projectPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchServiceContributor)
  }
}

output searchServiceName string = search.name
output searchEndpoint string = 'https://${search.name}.search.windows.net'
output searchIdentityPrincipalId string = search.identity.principalId
output storageAccountName string = storage.name
output blobContainerName string = container.name
output blobEndpoint string = storage.properties.primaryEndpoints.blob
