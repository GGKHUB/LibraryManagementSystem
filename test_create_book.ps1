$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$page = Invoke-WebRequest 'http://localhost:5000/Books/Create' -WebSession $session -UseBasicParsing
if ($page.Content -match 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"') {
    $token = $matches[1]
    $body = @{
        '__RequestVerificationToken' = $token
        'Title' = 'Automated Test Book 2'
        'Author' = 'Copilot'
        'ISBN' = 'TEST-002'
        'Location' = 'Home'
        'Description' = 'Created by automated test.'
    }
    $resp = Invoke-WebRequest -Uri 'http://localhost:5000/Books/Create' -Method Post -Body $body -WebSession $session -UseBasicParsing -ErrorAction Stop
    Write-Output $resp.StatusCode
    $list = Invoke-WebRequest 'http://localhost:5000/Books' -WebSession $session -UseBasicParsing
    if ($list.Content -match 'Automated Test Book 2') { Write-Output 'Test book present' } else { Write-Output 'Test book NOT FOUND' }
} else { Write-Output 'Token not found'; exit 1 }
