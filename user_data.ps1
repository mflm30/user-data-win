<powershell>
$path = 'HKLM:\Software\UserData'

if(!(Get-Item $Path -ErrorAction SilentlyContinue)) {
New-Item $Path
New-ItemProperty -Path $Path -Name RunCount -Value 0 -PropertyType dword
}

$runCount = Get-ItemProperty -Path $path -Name Runcount -ErrorAction SilentlyContinue |
Select-Object -ExpandProperty RunCount

if($runCount -ge 0) {

switch($runCount) {
0 {

#Increment the RunCount
Set-ItemProperty -Path $Path -Name RunCount -Value 1

#Enable user data
$EC2SettingsFile = "$env:ProgramFiles\Amazon\Ec2ConfigService\Settings\Config.xml"
$xml = [xml](Get-Content $EC2SettingsFile)
$xmlElement = $xml.get_DocumentElement()
$xmlElementToModify = $xmlElement.Plugins

foreach ($element in $xmlElementToModify.Plugin)
{
if ($element.name -eq "Ec2HandleUserData")
{
$element.State="Enabled"
}
}
$xml.Save($EC2SettingsFile)

#Install Docker
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Confirm
Restart-Computer -Force
}
1 {
#Increment the RunCount
Set-ItemProperty -Path $Path -Name RunCount -Value 2

#Enable user data
$EC2SettingsFile = "$env:ProgramFiles\Amazon\Ec2ConfigService\Settings\Config.xml"
$xml = [xml](Get-Content $EC2SettingsFile)
$xmlElement = $xml.get_DocumentElement()
$xmlElementToModify = $xmlElement.Plugins

foreach ($element in $xmlElementToModify.Plugin)
{
if ($element.name -eq "Ec2HandleUserData")
{
$element.State="Enabled"
}
}
$xml.Save($EC2SettingsFile)

# Install AWS Tools CLI
Import-Module AWSPowerShell
Restart-Computer
}
2 {
# Get Secrets
$password = ((Get-SECSecretValue -SecretId 'credentials').SecretString | ConvertFrom-Json).Password
docker pull dockerhub_id/image_name:tag
sudo docker run -e ENV_PASS=$password --name container_name dockerhub_id/image_name:tag
}
}
}
</powershell>
