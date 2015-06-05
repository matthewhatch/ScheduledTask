<#
    .SYNOPSIS
        Enable/Disable Scheduled Tasks

    .DESCRIPTION
        See Synopsis

    .PARAMETER ComputerName

    .PARAMETER Credential

    .PARAMETER Task

    .NOTES
        Wrapper Module for SchTasks

#>
Function Enable-ScheduledTask{
    [CmdletBinding()]
    param(
        [System.String]
        $ComputerName = $env:COMPUTERNAME,

        [PSCredential]
        $Credential,

        [System.String]
        $Task
    )

    BEGIN{
        $CodeBlock = {
            param($Task)
            & schtasks /Change /TN $Task /Enable
        }
    }
    PROCESS{
        if($ComputerName -eq $env:COMPUTERNAME){& $CodeBlock}
        else{Invoke-Command -ComputerName $ComputerName -ScriptBlock $CodeBlock -ArgumentList $Task -Credential $Credential}    
    }
    END{}
}


Function Disable-ScheduledTask{
    [CmdletBinding()]
    param(
        [System.String]
        $ComputerName = $env:COMPUTERNAME,

        [PSCredential]
        $Credential,

        [System.String]
        $Task
    )

    BEGIN{
        $CodeBlock = {
            param($Task)
            & schtasks /Change /TN $Task /Disable
        }
    }
    PROCESS{
        if($ComputerName -eq $env:COMPUTERNAME){& $CodeBlock}
        else{Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $CodeBlock -ArgumentList $Task}
    }
    END{}
}

<#
    .SYNOPSIS
        Get Scheduled Tasks

    .PARAMETER ComputerName

    .PARAMETER Credential


#>
function Get-ScheduledTask
{
    [CmdletBinding()]
    [OutputType([PSobject])]
    Param
    (
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=0)]
        $ComputerName = $env:COMPUTERNAME,

        [PSCredential]
        $Credential
    )

    Begin
    {
        $GetBlock = {& schtasks /QUERY /FO CSV}
        $RemoteBlock = {
            param($ComputerName,$User,$Password)
            & schtasks /QUERY /FO CSV /V /S $ComputerName /U $User /P $Password
        }
    }
    Process
    {
        if($ComputerName -eq $env:COMPUTERNAME){
            & $GetBlock
        }
        else{
            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $GetBlock
            #& $RemoteBlock -ComputerName $ComputerName -User $Credential.UserName -Password $Credential.GetNetworkCredential().Password 
        }
    }
    End
    {
    }
}