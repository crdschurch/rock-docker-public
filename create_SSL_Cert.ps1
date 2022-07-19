Import-Module WebAdministration;

#Create a new localhost cert and save the thumbprint in a hash for future steps
$localhostCert = New-SelfSignedCertificate -Subject "localhost" -TextExtension @("2.5.29.17={text}DNS=localhost&IPAddress=127.0.0.1&IPAddress=::1") | Select-Object Thumbprint;
$localhostThumbprint = $localhostCert.Thumbprint.ToString();


#Assign Web binding to Default Web Site for port 443
Set-Location IIS:;
New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https;

#Connect the new cert to the web binding
Set-Location IIS:\SslBindings;
get-item cert:\LocalMachine\MY\$localhostThumbprint | new-item 0.0.0.0!443