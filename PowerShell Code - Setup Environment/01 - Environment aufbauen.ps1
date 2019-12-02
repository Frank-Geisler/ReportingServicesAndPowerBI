#============================================================================
#	Datei:		01 - Environment aufbauen.ps1
#
#	Summary:	Dieses Script erstellt die Umgebung für unseren Reporting 
#               Services Vortrag auf dem PASS Camp
#
#	Datum:		2019-12-02
#
#   Revisionen: yyyy-dd-mm
#                   - ...
#
#	Projekt:	Reporting Services auf dem PASS Camp
#
#	PowerShell Version: 5.1
#------------------------------------------------------------------------------
#	Geschrieben von 
#       Frank Geisler, GDS Business Intelligence GmbH
#       Tillmann Eitelberg, oh22information services GmbH 
#
#   Dieses Script ist nur zu Lehr- bzw. Lernzwecken gedacht
#
#   DIESER CODE UND DIE ENTHALTENEN INFORMATIONEN WERDEN OHNE GEWÄHR JEGLICHER
#   ART ZUR VERFÜGUNG GESTELLT, WEDER AUSDRÜCKLICH NOCH IMPLIZIT, EINSCHLIESSLICH,
#   ABER NICHT BESCHRÄNKT AUF FUNKTIONALITÄT ODER EIGNUNG FÜR EINEN BESTIMMTEN
#   ZWECK. SIE VERWENDEN DEN CODE AUF EIGENE GEFAHR.
#============================================================================*/

#----------------------------------------------------------------------------
# 00. Variablen
#----------------------------------------------------------------------------
$SubscriptionName = 'MVP Sponsorship'
$resourcegroupName = 'passcamp2019rs'
$location = 'North Europe'

# Storage
$storageName = 'passcamp2019rspbi'
$storageType = 'Standard_LRS'

# Netzwerk
$vnetName = 'vnet-passcamprs'
$subNetName = 'snet-default'
$VNetAddressPrefix = '10.0.0.0/16'
$VNetSubnetAddressPrefix = '10.0.0.0/24'

# User 
#$adminuser = 'dockerfred'
# pwd: !test1234567890 

# Compute für passssrsdemo
$passssrsdemo_publisherName = 'MicrosoftSQLServer'
$passssrsdemo_offer = 'sql2019-ws2019'
$passssrsdemo_sku = 'sqldev'
$passssrsdemo_os_Version = 'latest'
$passssrsdemo_VMName = 'passssrsdemo'
$passssrsdemo_VMSize = 'Standard_E4s_v3'
$passssrsdemo_OSDiskName = 'osdisk_'+$passssrsdemo_VMName
$passssrsdemo_InterfaceName = 'nic_'+$passssrsdemo_VMName
$passssrsdemo_PipName = 'pip_'+$passssrsdemo_VMName

#--------------------------------------------------------------------------
# 01. - Anmelden mit dem Benutzerkonto unter Azure
# -------------------------------------------------------------------------
Login-AzureRmAccount
Get-AzureRmSubscription `
   -SubscriptionName $SubscriptionName | Set-AzureRmContext

#--------------------------------------------------------------------------
# 02. - Ressourcengruppe erstellen
# -------------------------------------------------------------------------
New-AzureRmResourceGroup `
    -Name $resourcegroupName `
    -Location $location

#----------------------------------------------------------------------------
# 03. - Storage anlegen
#      Der Name für den Storage in $storageName muss eindeutig sein.
#----------------------------------------------------------------------------
$storageAccount = New-AzureRmStorageAccount `
                         -ResourceGroupName $resourcegroupName `
                         -Name $storageName `
                         -Type $StorageType `
                         -Location $location

#----------------------------------------------------------------------------
# 04. - VNet anlegen
#----------------------------------------------------------------------------
$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
                      -Name $subNetName `
                      -AddressPrefix $VNetSubnetAddressPrefix

$vn = New-AzureRmVirtualNetwork `
             -Name $VNetName `
             -ResourceGroupName $ResourceGroupName `
             -Location $Location `
             -AddressPrefix $VNetAddressPrefix `
             -Subnet $SubnetConfig
             
#----------------------------------------------------------------------------
# 05. - Allgemeines Credential für die virtuellen Maschinen abfragen. Da 
#       die Maschinen ja eh in die Domäne gehängt werden wird nur einmal das
#       Credential abgefragt und als lokaler Admin verwendet.
#----------------------------------------------------------------------------
$Credential = Get-Credential 

#--------------------------------------------------------------------------
# 06. - virtuelle Maschine passssrsdemo anlegen
# -------------------------------------------------------------------------

# Public IP-Adresse anlegen
$pip_passssrsdemo = New-AzureRmPublicIpAddress `
                -Name $passssrsdemo_PipName `
                -ResourceGroupName $resourcegroupName `
                -Location $location `
                -AllocationMethod Dynamic

# Netzwerk-Interface anlegen
$nic_passssrsdemo = New-AzureRmNetworkInterface `
                        -Name $passssrsdemo_InterfaceName `
                        -ResourceGroupName $resourcegroupName `
                        -Location $location `
                        -SubnetId $vn.Subnets[0].Id `
                        -PublicIpAddressId $pip_passssrsdemo.Id

# Jetzt wird die eigentliche VM angelegt
$vmConfig_passssrsdemo = New-AzureRmVMConfig `
                        -VMName $passssrsdemo_VMName `
                        -VMSize  $passssrsdemo_VMSize | `
                        Set-AzureRmVMOperatingSystem `
                            -Windows `
                            -ComputerName $passssrsdemo_VMName `
                            -Credential $Credential | `
                            Add-AzureRmVMNetworkInterface `
                                -Id $nic_passssrsdemo.Id | `
                                Set-AzureRmVMOSDisk `
                                    -Name $passssrsdemo_OSDiskName `
                                    -CreateOption FromImage | `
                                    Set-AzureRmVMBootDiagnostics `
                                        -Enable `
                                        -ResourceGroupName $resourcegroupName `
                                        -StorageAccountName $storageName ` |
                                        Set-AzureRmVMSourceImage `
                                            -PublisherName $passssrsdemo_publisherName `
                                            -Offer $passssrsdemo_offer `
                                            -Skus $passssrsdemo_sku `
                                            -Version $passssrsdemo_os_Version

# virtuelle Maschine erzeugen
New-AzureRmVM `
    -ResourceGroupName $resourcegroupName `^^
    -Location $location `
    -VM $vmConfig_passssrsdemo

