<#
.SYNOPSIS

Installs the requested PowerShell modules into Azure Function 'Modules' folder

.DESCRIPTION
 
The script gets list of the required PowerShell modules and puts the modules' code into the 'Modules' folder. Later this folder is packed and deployed to the Azure Function App.

.EXAMPLE

build:
  stage: build
  image: 
    name: mcr.microsoft.com/azure-powershell:mariner-2
  script:
    - tdnf install zip -y
    - pwsh ./azure-function/Modules/installModules.ps1
    # Build the zip file with the code of the Azure Function
    - mkdir dist
    - cd ./azure-function
    - zip -r ../dist/azure-function.zip ./*
  artifacts:
    paths:
      - dist/azure-function.zip
    name: ${ARM_AZFUNC_NAME}_artifact

.INPUTS
    None

.OUTPUTS
    None

.NOTES
    Version: 0.1
    Author: Roman Kiprin
    Creation Date: 2024.11
#>


. azure-function/Modules/requiredModules.ps1


if ($null -eq $requiredModules) {
   Write-Host "The $requiredModules variables is empty. Nothing will be installed. To init the variable use ./azure-function/Modules/requiredModules.ps1 script file."
   return
}

$requiredModules.GetEnumerator() | ForEach-Object {
    Write-Host "Install $($_.key) version $($_.value)"
    Remove-Module -Name $_.key -ErrorAction SilentlyContinue
    Uninstall-Module -Name $_.key -AllowPrerelease -AllVersions
    Install-Module -Name $_.key -RequiredVersion $_.value -Scope CurrentUser -Force
}

Write-Host "Here is the list of all modules installed within the session:"
Get-Module -ListAvailable

Write-Host "Here is the list of files in the CurrentUser Modules folder:"
dir ~/.local/share/powershell/Modules

Write-Host "Lets copy ~/.local/share/powershell/Modules/* to azure-function/Modules"
Copy-Item -Path "~/.local/share/powershell/Modules/*" -Destination "azure-function/Modules" -Recurse

Write-Host "Here is the list of modules to be installed to the Azure Function App:"
dir azure-function/Modules