param(
    [Parameter(Mandatory)] [string] $orgname,
    [Parameter(Mandatory)] [string] $CN
)

$rootcert = Get-ChildItem -Path Cert:\CurrentUser\My | ?{$_.Subject -eq "CN=$($orgname)root"}
$croot = "$($orgname)root"

if (-not $rootcert){
    $rootcert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
        -Subject "CN=$croot" -KeyExportPolicy Exportable `
        -HashAlgorithm sha256 -KeyLength 2048 `
        -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign
    
    $c = New-SelfSignedCertificate -Type Custom -DnsName MBIT2411GW -KeySpec Signature `
        -Subject "CN=$CN" -KeyExportPolicy Exportable `
        -HashAlgorithm sha256 -KeyLength 2048 `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -Signer $rootcert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
    
    $CWD = split-path $MyInvocation.MyCommand.path -Parent
}

$rootcerFile = "$CWD\$($orgname)root.cer"

#Export-Certificate -Cert $rootcert -Type CER -FilePath $rootcerFile
#$tempfile = "$CWD\temp.cer"
##certutil -encode $rootcerFile $tempfile
#$cert2 = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($tempfile)
#$CertBase64 = [system.convert]::ToBase64String($cert2.RawData)
#rm $tempfile -Force
#rename-item -Path $tempfile "$orgname.cer"
#$key = (Get-Content "$CWD\$orgname.cer").replace("-----BEGIN CERTIFICATE-----","").Replace("-----END CERTIFICATE-----","")

rm "$CWD\temp2.cer" -Force -ErrorAction SilentlyContinue
rm "$CWD\temp.cer" -Force -ErrorAction SilentlyContinue

$certfind = Get-ChildItem -Path Cert:\CurrentUser\My | ?{$_.Subject -eq "CN=$($orgname)root"}
 
export-Certificate  -cert $certfind -FilePath "$CWD\temp.cer" -type CERT  -NoClobber | Out-Null
certutil -encode "$CWD\temp.cer" "$CWD\temp2.cer" | Out-Null
rm "$CWD\temp.cer" -Force | Out-Null

#Upload configuration changes to Azure VPN Gateway
#$P2SRootCertName = "mbitroot"
$filePathForCert = "$CWD\temp2.cer"

$cert2 = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($filePathForCert)
$CertBase64 = [system.convert]::ToBase64String($cert2.RawData)
$error.Clear()

return $CertBase64 #this value you must us in the bicep, we can pass it from the powershell script we alrady have.






#this part of the bicep deployment already, what is better? would be awesome if we can add the powershell code somehow, and make is a dynamic whole.
#$Gateway = Get-AzVirtualNetworkGateway -ResourceGroupName $RG -Name "mbit2411accgw"
#$VPNClientAddressPool = "10.0.25.0/26"
#Set-AzVirtualNetworkGateway -VirtualNetworkGateway $Gateway -VpnClientAddressPool $VPNClientAddressPool

#$p2srootcert = New-AzVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $CertBase64
#Add-AzVpnClientRootCertificate -VpnClientRootCertificateName $P2SRootCertName -VirtualNetworkGatewayname "mbit2411accgw" -ResourceGroupName "acc" -PublicCertData $CertBase64