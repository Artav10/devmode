function Update-ArgsInString {
    param (
        [string]$jsonContent,
        [string[]]$argsFromProfile
    )

    if ($argsFromProfile.Count -gt 0) {
        $jsonContent = $jsonContent -replace '\$\{argsFromProfile\}', $argsFromProfile[0]
    }
    for ($i = 0; $i -lt $argsFromProfile.Count; $i++) {
        $jsonContent = $jsonContent -replace "\$\{argsFromProfile_$i\}", $argsFromProfile[$i]
    }

    return $jsonContent
}