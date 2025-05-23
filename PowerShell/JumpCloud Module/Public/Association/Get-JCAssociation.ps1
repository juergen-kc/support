Function Get-JCAssociation {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][System.String]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Bypass user prompts and dynamic ValidateSet.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    DynamicParam {
        $Action = 'get'
        $RuntimeParameterDictionary = If ($Type) {
            Get-DynamicParamAssociation -Action:($Action) -Force:($Force) -Type:($Type)
        } Else {
            Get-DynamicParamAssociation -Action:($Action) -Force:($Force)
        }
        Return $RuntimeParameterDictionary
    }
    Begin {
        Connect-JCOnline -force | Out-Null
        # Debug message for parameter call
        $PSBoundParameters | Out-DebugParameter | Write-Debug
        $Results = @()
    }
    Process {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        # Create hash table to store variables
        $FunctionParameters = [ordered]@{ }
        # Add input parameters from function in to hash table and filter out unnecessary parameters
        $PSBoundParameters.GetEnumerator() | Where-Object { -not [System.String]::IsNullOrEmpty($_.Value) } | ForEach-Object { $FunctionParameters.Add($_.Key, $_.Value) | Out-Null }
        # Add action
        ($FunctionParameters).Add('Action', $Action) | Out-Null
        # Run the command
        $Results += Invoke-JCAssociation @FunctionParameters
    }
    End {
        Return $Results
    }
}