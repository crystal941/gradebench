param location string = resourceGroup().location
param appServicePlanName string = 'gradebench-plan'
param webAppName string = 'gradebench-app'
param acrName string = 'gradebench'
param acrLoginServer string = 'gradebench.azurecr.io'
param acrImage string = 'gradebench:latest'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'  // or F1 free plan
    tier: 'Basic'
    size: 'B1'
    capacity: 1
  }
}

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '3838' // your app port
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://'+acrLoginServer
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: '<your-acr-username>'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: '<your-acr-password>'
        }
      ]
      linuxFxVersion: 'DOCKER|' + acrLoginServer + '/' + acrImage
    }
  }
}
