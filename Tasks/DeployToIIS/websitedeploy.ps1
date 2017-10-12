param(
	[string]$deployServer,
	[string]$contentPath,
	[string]$username,
	[string]$password,
	[string]$iisAppPath,
	[string]$iisApp
)

Write-Host "********************************************"
Write-Host " D E P L O Y - W E B S I T E"
Write-Host "Deploying to server $deployServer"
Write-Host "********************************************"


$MSDeployKey = 'HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy\3';
if(!(Test-Path $MSDeployKey)) {
	throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command";
}

$InstallPath = (Get-ItemProperty $MSDeployKey).InstallPath;
if(!$InstallPath -or !(Test-Path $InstallPath)) {
	throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command";
}

$msdeploy = Join-Path $InstallPath "msdeploy.exe";
if(!(Test-Path $MSDeploy)) {
	throw "Could not find MSDeploy. Use Web Platform Installer to install the 'Web Deployment Tool' and re-run this command";
}

$PublishUrl = "https://" + $deployServer + ":8172/msdeploy.axd";

$stopAppPoolArgs = [string[]]@(
	"-verb:sync",
	"-allowUntrusted",
	"-source:recycleApp",
	"-dest:recycleApp='$iisApp',recycleMode='StopAppPool',computerName='$PublishUrl',userName='$username',password='$Password',authtype='Basic'"
);

$startAppPoolArgs = [string[]]@(
	"-verb:sync",
	"-allowUntrusted",
	"-source:recycleApp",
	"-dest:recycleApp='$iisApp',recycleMode='StartAppPool',computerName='$PublishUrl',userName='$username',password='$Password',authtype='Basic'"
);

$deployArgs = [string[]]@(
    "-verb:sync",
	"-source:iisApp='$contentPath'",
	"-dest:iisApp='$iisAppPath',computerName='$PublishUrl',userName='$username',password='$Password',authtype='Basic',includeAcls='false'",
	"-disableLink:AppPoolExtension",
	"-disableLink:ContentExtension",
	"-disableLink:CertificateExtension",
    "-verbose",
	"-allowUntrusted");

Start-Process $msdeploy -ArgumentList $stopAppPoolArgs -NoNewWindow -Wait;
Start-Process $msdeploy -ArgumentList $deployArgs -NoNewWindow -Wait;
Start-Process $msdeploy -ArgumentList $startAppPoolArgs -NoNewWindow -Wait;

