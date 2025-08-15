# Adiciona C:\terraform ao PATH do usuário no Windows
$terraformPath = "C:\\terraform"

# Obtém o PATH atual do usuário
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Adiciona o caminho se ainda não estiver presente
if ($currentPath -notlike "*$terraformPath*") {
    $newPath = "$currentPath;$terraformPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Caminho C:\\terraform adicionado ao PATH do usuário. Feche e reabra o terminal para aplicar."
} else {
    Write-Host "Caminho C:\\terraform já está no PATH do usuário."
}
