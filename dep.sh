# Установка модуля Az, если он не установлен
if (-not (Get-Module -ListAvailable -Name Az)) {
    Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
}

# Убедитесь, что вы вошли в Azure
Connect-AzAccount

# Получаем список всех доступных локаций, где поддерживается Microsoft.Compute
$locations = Get-AzLocation | Where-Object { $_.Providers -contains "Microsoft.Compute" } | Select-Object -ExpandProperty Location

# Цикл по всем локациям
foreach ($location in $locations) {
    Write-Host "Развертывание в локации: $location"

    # Создаем уникальное имя группы ресурсов для каждой локации
    $resourceGroupName = "rg-vm-deploy-$location"

    try {
        # Создаем группу ресурсов
        Write-Host "Создание группы ресурсов: $resourceGroupName"
        New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

        # Развертываем шаблон
        Write-Host "Развертывание шаблона в группе ресурсов: $resourceGroupName"
        $deployment = New-AzResourceGroupDeployment `
            -ResourceGroupName $resourceGroupName `
            -TemplateUri "https://raw.githubusercontent.com/nokian5500/rdp/refs/heads/main/azuredeploy.json" `
            -Location $location

        # Выводим учетные данные
        $credentials = $deployment.Outputs.credentials.Value
        Write-Host "Учетные данные для $location $credentials"
    } catch {
        Write-Host "Ошибка при развертывании в локации $location: $_"
    }
}

Write-Host "Развертывание завершено во всех локациях." 
