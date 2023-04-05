
param(
    [Parameter(Mandatory)] [String] $rg
)

$CWD = split-path $MyInvocation.MyCommand.path -Parent

try {
    $all = Import-Csv $CWD\secrets.csv -ErrorAction Stop
}
catch {
    Write-Error "Could not find secrets.csv in the script directory ERROR = $($_.Exception.Message)"
    exit -1
}

foreach ($item in $all){
    try {
        $pass = (ConvertTo-SecureString $item.value -AsPlainText)
        $splat = @{
            TemplateFile = "$CWD\kv-secrets.bicep"
            Mode = 'Incremental'
            ResourceGroupName = $rg
            Verbose = $false
            secretvalue = $pass
            kv_name = $item.kv
            keyname = $item.keyname
        }
        Write-Output "Creating secret in kv : $($item.kv) with name $($item.keyname) in rg: $rg"
        $result = New-AzResourceGroupDeployment @splat -ErrorAction Stop
        #$result = New-AzResourceGroupDeployment -TemplateFile $CWD\kv-secrets.bicep -Mode Incremental `
        #    -ResourceGroupName $rg -secretvalue $pass -kv_name $item.kv -keyname $item.keyname
    }
    catch {
        Write-Error "There was an error during deployment, ERROR = $($_.Exception.message)"
    }
}

man Set-AzKeyVaultSecret