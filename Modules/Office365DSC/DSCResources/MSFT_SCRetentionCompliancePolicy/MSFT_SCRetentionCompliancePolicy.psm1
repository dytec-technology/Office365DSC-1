function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String[]]
        $DynamicScopeLocation,

        [Parameter()]
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [System.String[]]
        $ExchangeLocation = @(),

        [Parameter()]
        [System.String[]]
        $ExchangeLocationException = @(),

        [Parameter()]
        [System.String[]]
        $ModernGroupLocation = @(),

        [Parameter()]
        [System.String[]]
        $ModernGroupLocationException = @(),

        [Parameter()]
        [System.String[]]
        $OneDriveLocation = @(),

        [Parameter()]
        [System.String[]]
        $OneDriveLocationException = @(),

        [Parameter()]
        [System.String[]]
        $PublicFolderLocation = @(),

        [Parameter()]
        [System.Boolean]
        $RestrictiveRetention = $true,

        [Parameter()]
        [System.String[]]
        $SharePointLocation = @(),

        [Parameter()]
        [System.String[]]
        $SharePointLocationException = @(),

        [Parameter()]
        [System.String[]]
        $SkypeLocation = @(),

        [Parameter()]
        [System.String[]]
        $SkypeLocationException = @(),

        [Parameter()]
        [System.String[]]
        $TeamsChannelLocation = @(),

        [Parameter()]
        [System.String[]]
        $TeamsChannelLocationException = @(),

        [Parameter()]
        [System.String[]]
        $TeamsChatLocation = @(),

        [Parameter()]
        [System.String[]]
        $TeamsChatLocationException = @(),

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )

    Write-Verbose -Message "Getting configuration of RetentionCompliancePolicy for $Name"

    Test-MSCloudLogin -O365Credential $GlobalAdminAccount `
                      -Platform SecurityComplianceCenter

    $PolicyObject = Get-RetentionCompliancePolicy $Name

    if ($null -eq $PolicyObject)
    {
        Write-Verbose -Message "RetentionCompliancePolicy $($Name) does not exist."
        $result = $PSBoundParameters
        $result.Ensure = 'Absent'
        return $result
    }
    else
    {
        Write-Verbose "Found existing RetentionCompliancePolicy $($Name)"
        $result = @{
            Ensure                        = 'Present'
            Name                          = $PolicyObject.Name
            Comment                       = $PolicyObject.Comment
            DynamicScopeLocation          = $PolicyObject.DynamicScopeLocation
            Enabled                       = $PolicyObject.Enabled
            ExchangeLocation              = $PolicyObject.ExchangeLocation
            ExchangeLocationException     = $PolicyObject.ExchangeLocationException
            ModernGroupLocation           = $PolicyObject.ModernGroupLocation
            ModernGroupLocationException  = $PolicyObject.ModernGroupLocationException
            OneDriveLocation              = $PolicyObject.OneDriveLocation
            OneDriveLocationException     = $PolicyObject.OneDriveLocationException
            PublicFolderLocation          = $PolicyObject.PublicFolderLocation
            RestrictiveRetention          = $PolicyObject.RestrictiveRetention
            SharePointLocation            = $PolicyObject.SharePointLocation
            SharePointLocationException   = $PolicyObject.SharePointLocationException
            SkypeLocation                 = $PolicyObject.SkypeLocation
            SkypeLocationException        = $PolicyObject.SkypeLocationException
            TeamsChannelLocation          = $PolicyObject.TeamsChannelLocation
            TeamsChannelLocationException = $PolicyObject.TeamsChannelLocationException
            TeamsChatLocation             = $PolicyObject.TeamsChatLocation
            TeamsChatLocationException    = $PolicyObject.TeamsChatLocationException
        }

        Write-Verbose -Message "Found RetentionCompliancePolicy $($Name)"
        Write-Verbose -Message "Get-TargetResource Result: `n $(Convert-O365DscHashtableToString -Hashtable $result)"
        return $result
    }
}

function Set-TargetResource
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String[]]
        $DynamicScopeLocation,

        [Parameter()]
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [System.String[]]
        $ExchangeLocation,

        [Parameter()]
        [System.String[]]
        $ExchangeLocationException,

        [Parameter()]
        [System.String[]]
        $ModernGroupLocation,

        [Parameter()]
        [System.String[]]
        $ModernGroupLocationException,

        [Parameter()]
        [System.String[]]
        $OneDriveLocation,

        [Parameter()]
        [System.String[]]
        $OneDriveLocationException,

        [Parameter()]
        [System.String[]]
        $PublicFolderLocation,

        [Parameter()]
        [System.Boolean]
        $RestrictiveRetention = $true,

        [Parameter()]
        [System.String[]]
        $SharePointLocation,

        [Parameter()]
        [System.String[]]
        $SharePointLocationException,

        [Parameter()]
        [System.String[]]
        $SkypeLocation,

        [Parameter()]
        [System.String[]]
        $SkypeLocationException,

        [Parameter()]
        [System.String[]]
        $TeamsChannelLocation,

        [Parameter()]
        [System.String[]]
        $TeamsChannelLocationException,

        [Parameter()]
        [System.String[]]
        $TeamsChatLocation,

        [Parameter()]
        [System.String[]]
        $TeamsChatLocationException ,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )

    Write-Verbose -Message "Setting configuration of RetentionCompliancePolicy for $Name"

    Test-MSCloudLogin -O365Credential $GlobalAdminAccount `
                      -Platform SecurityComplianceCenter

    $CurrentPolicy = Get-TargetResource @PSBoundParameters

    if (('Present' -eq $Ensure) -and ('Absent' -eq $CurrentPolicy.Ensure))
    {
        $CreationParams = $PSBoundParameters
        $CreationParams.Remove("GlobalAdminAccount")
        $CreationParams.Remove("Ensure")
        New-RetentionCompliancePolicy @CreationParams
    }
    elseif (('Present' -eq $Ensure) -and ('Present' -eq $CurrentPolicy.Ensure))
    {
        $CreationParams = $PSBoundParameters
        $CreationParams.Remove("GlobalAdminAccount")
        $CreationParams.Remove("Ensure")
        $CreationParams.Remove("Name")
        $CreationParams.Add("Identity", $Name)
        $CreationParams.Remove("TeamsChannelLocation")
        $CreationParams.Remove("TeamsChannelLocationException")
        $CreationParams.Remove("TeamsChatLocation")
        $CreationParams.Remove("TeamsChatLocationException")
        $CreationParams.Remove("DynamicScopeLocation")

        # Exchange Location is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.ExchangeLocation -or `
            $null -ne $ExchangeLocation)
        {
            $ToBeRemoved = $CreationParams.ExchangeLocation | `
                                Where {$ExchangeLocation -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemoveExchangeLocation", $ToBeRemoved)
            }

            $ToBeAdded = $ExchangeLocation | `
                                Where {$CreationParams.ExchangeLocation -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddExchangeLocation", $ToBeAdded)
            }

            $CreationParams.Remove("ExchangeLocation")
        }

        # Exchange Location Exception is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.ExchangeLocationException -or `
            $null -ne $ExchangeLocationException)
        {
            $ToBeRemoved = $CreationParams.ExchangeLocationException | `
                                Where {$ExchangeLocationException -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemoveExchangeLocationException", $ToBeRemoved)
            }

            $ToBeAdded = $ExchangeLocationException | `
                                Where {$CreationParams.ExchangeLocationException -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddExchangeLocationException", $ToBeAdded)
            }
            $CreationParams.Remove("ExchangeLocationException")
        }

        # Modern Group Location is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.ModernGroupLocation -or `
            $null -ne $ModernGroupLocation)
        {
            $ToBeRemoved = $CreationParams.ModernGroupLocation | `
                                Where {$ModernGroupLocation -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemoveModernGroupLocation", $ToBeRemoved)
            }

            $ToBeAdded = $ModernGroupLocation | `
                                Where {$CreationParams.ModernGroupLocation -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddModernGroupLocation", $ToBeAdded)
            }
            $CreationParams.Remove("ModernGroupLocation")
        }

        # Modern Group Location Exception is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.ModernGroupLocationException -or `
            $null -ne $ModernGroupLocationException)
        {
            $ToBeRemoved = $CreationParams.ModernGroupLocationException | `
                                Where {$ModernGroupLocationException -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemoveModernGroupLocationException", $ToBeRemoved)
            }

            $ToBeAdded = $ModernGroupLocationException | `
                                Where {$CreationParams.ModernGroupLocationException -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddModernGroupLocationException", $ToBeAdded)
            }
            $CreationParams.Remove("ModernGroupLocationException")
        }

        # OneDrive Location is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.OneDriveLocation -or `
            $null -ne $OneDriveLocation)
        {
            $ToBeRemoved = $CreationParams.OneDriveLocation | `
                                Where {$OneDriveLocation -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemoveOneDriveLocation", $ToBeRemoved)
            }

            $ToBeAdded = $OneDriveLocation | `
                                Where {$CreationParams.OneDriveLocation -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddOneDriveLocation", $ToBeAdded)
            }
            $CreationParams.Remove("OneDriveLocation")
        }

        # OneDrive Location Exception is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.OneDriveLocationException -or `
            $null -ne $OneDriveLocationException)
        {
            $ToBeRemoved = $CreationParams.OneDriveLocationException | `
                                Where {$OneDriveLocationException -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemoveOneDriveLocationException", $ToBeRemoved)
            }

            $ToBeAdded = $OneDriveLocationException | `
                                Where {$CreationParams.OneDriveLocationException -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddOneDriveLocationException", $ToBeAdded)
            }
            $CreationParams.Remove("OneDriveLocationException")
        }

        # Public Folder Location is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.PublicFolderLocation -or `
            $null -ne $PublicFolderLocation)
        {
            $ToBeRemoved = $CreationParams.PublicFolderLocation | `
                                Where {$PublicFolderLocation -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemovePublicFolderLocation", $ToBeRemoved)
            }

            $ToBeAdded = $PublicFolderLocation | `
                                Where {$CreationParams.PublicFolderLocation -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddPublicFolderLocation", $ToBeAdded)
            }
            $CreationParams.Remove("PublicFolderLocation")
        }

        # SharePoint Location is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.SharePointLocation -or `
            $null -ne $SharePointLocation)
        {
            $ToBeRemoved = $CreationParams.SharePointLocation | `
                                Where {$SharePointLocation -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemoveSharePointLocation", $ToBeRemoved)
            }

            $ToBeAdded = $SharePointLocation | `
                                Where {$CreationParams.SharePointLocation -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddSharePointLocation", $ToBeAdded)
            }
            $CreationParams.Remove("SharePointLocation")
        }

        # SharePoint Location Exception is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.SharePointLocationException -or `
            $null -ne $SharePointLocationException)
        {
            $ToBeRemoved = $CreationParams.SharePointLocationException | `
                                Where {$SharePointLocationException -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemoveSharePointLocationException", $ToBeRemoved)
            }

            $ToBeAdded = $SharePointLocationException | `
                                Where {$CreationParams.SharePointLocationException -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddSharePointLocationException", $ToBeAdded)
            }
            $CreationParams.Remove("SharePointLocationException")
        }

        # Skype Location is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.SkypeLocation -or `
            $null -ne $SkypeLocation)
        {
            $ToBeRemoved = $CreationParams.SkypeLocation | `
                                Where {$SkypeLocation -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemoveSkypeLocation", $ToBeRemoved)
            }

            $ToBeAdded = $SkypeLocation | `
                                Where {$CreationParams.SkypeLocation -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddSkypeLocation", $ToBeAdded)
            }
            $CreationParams.Remove("SkypeLocation")
        }

        # Skype Location Exception is specified or already existing, we need to determine
        # the delta.
        if ($null -ne $CreationParams.SkypeLocationException -or `
            $null -ne $SkypeLocationException)
        {
            $ToBeRemoved = $CreationParams.SkypeLocationException | `
                                Where {$SkypeLocationException -NotContains $_}
            if ($null -ne $ToBeRemoved)
            {
                $CreationParams.Add("RemoveSkypeLocationException", $ToBeRemoved)
            }

            $ToBeAdded = $SkypeLocationException | `
                                Where {$CreationParams.SkypeLocationException -NotContains $_}
            if ($null -ne $ToBeAdded)
            {
                $CreationParams.Add("AddSkypeLocationException", $ToBeAdded)
            }
            $CreationParams.Remove("SkypeLocationException")
        }

        Write-Verbose "Updating Policy with values: $(Convert-O365DscHashtableToString -Hashtable $CreationParams)"
        Set-RetentionCompliancePolicy @CreationParams
    }
    elseif (('Absent' -eq $Ensure) -and ('Present' -eq $CurrentPolicy.Ensure))
    {
        # If the Policy exists and it shouldn't, simply remove it;
        Remove-RetentionCompliancePolicy -Identity $Name
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String[]]
        $DynamicScopeLocation,

        [Parameter()]
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [System.String[]]
        $ExchangeLocation = @(),

        [Parameter()]
        [System.String[]]
        $ExchangeLocationException = @(),

        [Parameter()]
        [System.String[]]
        $ModernGroupLocation = @(),

        [Parameter()]
        [System.String[]]
        $ModernGroupLocationException = @(),

        [Parameter()]
        [System.String[]]
        $OneDriveLocation = @(),

        [Parameter()]
        [System.String[]]
        $OneDriveLocationException = @(),

        [Parameter()]
        [System.String[]]
        $PublicFolderLocation = @(),

        [Parameter()]
        [System.Boolean]
        $RestrictiveRetention = $true,

        [Parameter()]
        [System.String[]]
        $SharePointLocation = @(),

        [Parameter()]
        [System.String[]]
        $SharePointLocationException = @(),

        [Parameter()]
        [System.String[]]
        $SkypeLocation = @(),

        [Parameter()]
        [System.String[]]
        $SkypeLocationException = @(),

        [Parameter()]
        [System.String[]]
        $TeamsChannelLocation = @(),

        [Parameter()]
        [System.String[]]
        $TeamsChannelLocationException = @(),

        [Parameter()]
        [System.String[]]
        $TeamsChatLocation = @(),

        [Parameter()]
        [System.String[]]
        $TeamsChatLocationException = @(),

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )

    Write-Verbose -Message "Testing configuration of RetentionCompliancePolicy for $Name"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-O365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-O365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck = $PSBoundParameters
    $ValuesToCheck.Remove('GlobalAdminAccount') | Out-Null

    $TestResult = Test-Office365DSCParameterState -CurrentValues $CurrentValues `
                                                  -DesiredValues $PSBoundParameters `
                                                  -ValuesToCheck $ValuesToCheck.Keys

    Write-Verbose -Message "Test-TargetResource returned $TestResult"

    return $TestResult
}

function Export-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )
    $result = Get-TargetResource @PSBoundParameters
    $result.GlobalAdminAccount = Resolve-Credentials -UserName "globaladmin"
    $content = "        SCRetentionCompliancePolicy " + (New-GUID).ToString() + "`r`n"
    $content += "        {`r`n"
    $currentDSCBlock = Get-DSCBlock -Params $result -ModulePath $PSScriptRoot
    $content += Convert-DSCStringParamToVariable -DSCBlock $currentDSCBlock -ParameterName "GlobalAdminAccount"
    $content += "        }`r`n"
    return $content
}

Export-ModuleMember -Function *-TargetResource
