Install-Module -Name Az -AllowClobber -Force

# Убедитесь, что вы вошли в Azure
Connect-AzAccount

# Получаем список всех доступных локаций
$locations = Get-AzLocation | Where-Object { $_.Providers -contains "Microsoft.Compute" } | Select-Object -ExpandProperty Location

# Цикл по всем локациям
foreach ($location in $locations) {
    Write-Host "Развертывание в локации: $location"

    # Создаем уникальное имя группы ресурсов для каждой локации
    $resourceGroupName = "rg-vm-deploy-$location"

    # Создаем группу ресурсов
    New-AzResourceGroup -Name $resourceGroupName -Location $location

    # Развертываем шаблон
    $deployment = New-AzResourceGroupDeployment `
        -ResourceGroupName $resourceGroupName `
        -TemplateUri "deploy.json" `
        -Location $location

    # Выводим учетные данные
    $credentials = $deployment.Outputs.credentials.Value
    Write-Host "Учетные данные для $location: $credentials"
}

Write-Host "Развертывание завершено во всех локациях."
