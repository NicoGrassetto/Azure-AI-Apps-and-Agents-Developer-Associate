@description('Name of the existing Azure AI Foundry (Cognitive Services) account.')
param accountName string

@description('Managed identity principal of the Azure AI Search service.')
param searchIdentityPrincipalId string

// Reference the already-created Foundry account so we can scope a role assignment to it.
resource account 'Microsoft.CognitiveServices/accounts@2025-06-01' existing = {
  name: accountName
}

// Allow the Search service managed identity to call the embedding model when the
// knowledge-base indexer vectorizes documents (integrated vectorization).
resource searchOpenAiUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(account.id, searchIdentityPrincipalId, 'cognitive-services-openai-user')
  scope: account
  properties: {
    principalId: searchIdentityPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  }
}
