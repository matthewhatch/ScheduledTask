<#
    .SYNOPSIS
        Enables Scheduled Task
        
    .DESCRIPTION
        Enables a schedule task that is passed to the Task parameter.  Use the ComputerName parameter to Enable task on a remote sever

    .PARAMETER ComputerName
        ComputerName of the server to Enable the task on

    .PARAMETER Credential
        Credential of the user to connect to the Server
        
    .PARAMETER Task
        Name of the Task to enable
        
    .Example
        Enable-ScheduledTask -Task 'SomeTaskName'
    
    .NOTES
        Wrapper Module for SchTasks... I know there's a similar Cmdlet for Windows 2012R2 Server, but this doesn't help with 2008R2

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