FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-20H2

#Configure IIS and .NET in container 
RUN powershell -Command Add-WindowsFeature -Name Web-Asp-Net45
RUN powershell -Command Add-WindowsFeature -Name NET-Framework-45-ASPNET
RUN powershell "Set-Service -Name wuauserv -StartupType Manual; Start-Service wuauserv; Install-WindowsFeature -Name NET-Framework-Features -Verbose;"
RUN powershell "Import-Module WebAdministration; Set-ItemProperty IIS:\AppPools\DefaultAppPool -name processModel.identityType -value 0;"

WORKDIR /inetpub/wwwroot

EXPOSE 80
EXPOSE 443

#Move RockWeb Folder into wwwroot of Container
COPY . .

# Run Powershell Script to create an SSL cert for localhost and assign it to port 433
RUN powershell -Command ./create_SSL_Cert.ps1
