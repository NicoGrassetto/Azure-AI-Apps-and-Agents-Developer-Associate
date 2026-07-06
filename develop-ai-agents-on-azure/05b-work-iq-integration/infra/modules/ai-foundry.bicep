@description('Location for the Azure AI Foundry resources.')
param location string

@description('Tags to apply to all resources.')
param tags object = {}

@description('Name of the Azure AI Foundry (Cognitive Services AIServices) account.')
param aiFoundryName string

@description('Name of the Foundry project.')
param projectName string

param modelName string
param modelVersion string
param modelSkuName string
param modelCapacity int
param modelDeploymentName string

@description('Principal to grant data-plane access to. Leave empty to skip role assignments.')
param principalId string = ''

@allowed([
  'User'
  'ServicePrincipal'
])
param principalType string = 'User'

// Azure AI Foundry account (Cognitive Services, kind = AIServices) with project management enabled.
resource account 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: aiFoundryName
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: aiFoundryName
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

// Foundry project used to organize agents, models and data.
resource project 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  parent: account
  name: projectName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: projectName
    description: 'IT Support Agent lab project (mslearn-ai-agents exercise 01).'
  }
}

// Model deployment the agent uses to reason and call tools.
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = {
  parent: account
  name: modelDeploymentName
  sku: {
    name: modelSkuName
    capacity: modelCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: modelName
      version: modelVersion
    }
  }
}

// Built-in role definition IDs required for the signed-in developer to use the
// Agent Service data plane (create agents, upload files, run the Responses API).
var roleDefinitionIds = [
  '64702f94-c441-49e6-a78b-ef80e0188fee' // Azure AI Developer
  '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' // Cognitive Services OpenAI User
  'a97b65f3-24c7-4388-baec-2e87135dc908' // Cognitive Services User
]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleId in roleDefinitionIds: if (!empty(principalId)) {
    name: guid(account.id, principalId, roleId)
    scope: account
    properties: {
      principalId: principalId
      principalType: principalType
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    }
  }
]

output accountName string = account.name
output projectName string = project.name
output projectEndpoint string = 'https://${account.name}.services.ai.azure.com/api/projects/${project.name}'
