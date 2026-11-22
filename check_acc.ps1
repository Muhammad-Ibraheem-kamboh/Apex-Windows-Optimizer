Get-ChildItem 'HKCU:\Software\Microsoft\OneDrive\Accounts' -ErrorAction SilentlyContinue | ForEach-Object {
    $props = Get-ItemProperty $_.PSPath
    [PSCustomObject]@{
        AccountType = $_.PSChildName
        UserEmail   = $props.UserEmail
        UserName    = $props.UserName
        DisplayName = $props.DisplayName
        UserFolder  = $props.UserFolder
    }
} | Format-List
