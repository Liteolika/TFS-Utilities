param(
	[string]$jsonFilePath = "",
	[string]$tokenPath = "",
	[string]$tokenValue = ""
)

if ($jsonFilePath -eq "") {
    throw "No JSON-file specified in param -jsonFilePath";
}
if ($tokenPath -eq "") {
    throw "No token path specified.";
}

if ($tokenValue -eq "") {
    throw "No token value specified.";
}


if(!(Test-Path $jsonFilePath)) {
	throw "The file " + $jsonFilePath + " does not exist.";
}

$jsonfile = Get-Content -Raw -Path $jsonFilePath;
$json = $jsonfile | ConvertFrom-Json;

# $json | Format-List | Out-String | % {Write-Host $_}

Write-Host "Changing token value for '$tokenPath' to '$tokenValue' in $jsonFilePath.";

try {

	$org = Invoke-Expression "`$json.$tokenPath` ";
	Invoke-Expression "`$json.$tokenPath = `$tokenValue";
	Write-Host "The token $tokenPath was changed from $org to $tokenValue";
    $json | ConvertTo-Json -Depth 999 |Out-File $jsonFilePath;
}

catch {
	Write-Host "Cannot find property $tokenPath. The property was left unchanged.";
}