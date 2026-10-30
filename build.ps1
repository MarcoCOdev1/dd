param([string]$Key)
$ErrorActionPreference = 'Stop'
if (-not $Key) { $Key = Read-Host 'Key' }
if (-not $Key) { throw 'bla key' }

$sha = [Security.Cryptography.SHA256]::Create()
$k   = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Key))

foreach ($p in @(@('src\install.ps1','p.bin'), @('src\uninstall.ps1','u.bin'))) {
    if (-not (Test-Path $p[0])) { throw "khas $($p[0])" }
    $raw = [Text.Encoding]::UTF8.GetBytes((Get-Content $p[0] -Raw))
    $a = [Security.Cryptography.Aes]::Create()
    $a.Mode = 'CBC'; $a.Padding = 'PKCS7'; $a.Key = $k
    $a.GenerateIV()
    $enc = $a.CreateEncryptor().TransformFinalBlock($raw, 0, $raw.Length)
    [Convert]::ToBase64String($a.IV + $enc) | Set-Content $p[1] -NoNewline -Encoding ascii
    Write-Host "ok $($p[1])  $((Get-Item $p[1]).Length) bytes"
}
Write-Host 'Push p.bin + u.bin + les loaders.' -ForegroundColor Green