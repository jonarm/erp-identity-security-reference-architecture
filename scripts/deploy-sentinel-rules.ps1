# scripts/deploy-sentinel-rules.ps1
# Deploys all Sentinel analytics rules via ARM template

param(
    [string]$ResourceGroupName = "rg-erp-security-lab",
    [string]$WorkspaceName = "law-erp-sentinel",
    [string]$SubscriptionId = "02905c0c-a44b-4263-aeb5-66c62cfb3c1c"
)

# Set subscription context
az account set --subscription $SubscriptionId

# Get the rules directory
$rulesPath = Join-Path $PSScriptRoot "..\sentinel\analytics-rules"
$rules = Get-ChildItem -Path $rulesPath -Filter "*.json"

Write-Host "Deploying $($rules.Count) Sentinel analytics rules..." -ForegroundColor Cyan

foreach ($rule in $rules) {
    Write-Host "Deploying: $($rule.Name)" -ForegroundColor Yellow

    az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file $rule.FullName `
        --parameters workspaceName=$WorkspaceName `
        --mode Incremental

    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: $($rule.Name)" -ForegroundColor Green
    } else {
        Write-Host "FAILED: $($rule.Name)" -ForegroundColor Red
    }
}

Write-Host "Deployment complete." -ForegroundColor Cyan