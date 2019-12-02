#============================================================================
#	Datei:		02 - Server einrichten.ps1
#
#	Summary:	Installation des Servers
#
#	Datum:		2019-12-02
#
#   Revisionen: yyyy-dd-mm
#                   - ...
#	Kunde:	    Kunde
#
#	Projekt:	PASS Camp 2019 Demo
#
#	PowerShell Version: 5.1
#------------------------------------------------------------------------------
#	Geschrieben von 
#       Frank Geisler, GDS Business Intelligence GmbH
#
#   Dieses Script ist nur zu Lehr- bzw. Lernzwecken gedacht
#
#   DIESER CODE UND DIE ENTHALTENEN INFORMATIONEN WERDEN OHNE GEWÄHR JEGLICHER
#   ART ZUR VERFÜGUNG GESTELLT, WEDER AUSDRÜCKLICH NOCH IMPLIZIT, EINSCHLIESSLICH,
#   ABER NICHT BESCHRÄNKT AUF FUNKTIONALITÄT ODER EIGNUNG FÜR EINEN BESTIMMTEN
#   ZWECK. SIE VERWENDEN DEN CODE AUF EIGENE GEFAHR.
#============================================================================*/

#----------------------------------------------------------------------------
# 01. Windows Updates einspielen
#----------------------------------------------------------------------------
Install-Module PSWindowsUpdate

Install-WindowsUpdate `
  -AcceptAll `
  -AutoReboot

#----------------------------------------------------------------------------
# 02. Chocolatey und Software installieren
#----------------------------------------------------------------------------
Set-ExecutionPolicy Bypass `
    -Scope Process `
    -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install googlechrome -y   
choco install sql-server-management-studio -y
choco install vscode -y 
choco install azure-data-studio -y
choco install visualstudio2019enterprise -y
choco install zoomit -y
choco install gitkraken -y
choco install git -y
choco install vscode-gitlens -y
