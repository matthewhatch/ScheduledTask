<#
    .NOTES
        Start-ScheduledTask was created to support the running of Scheduled Tasks on demand for servers that don't support the new 
        ScheduleTasks Module/Cmdlets

        This is designed to be used in conjuction with constrained endpoints in order to give user accounts rights to start the task
#>
Function Start-ScheduledTask {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
       
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=0)]
        [System.String]
        $TaskName,

        [Parameter(ValueFromPipelineByPropertyName=$true,Position=1)]
        [System.String]
        $ComputerName = $env:COMPUTERNAME,

        [Parameter(ValueFromPipelineByPropertyName=$true,Position=2)]
        [PSCredential]
        $Credential
    )

    BEGIN{
        $StartTask = {
            param($TaskName)
            & schtasks /RUN /TN $TaskName
        }
    }
    PROCESS{
        
        if($PSCmdlet.ShouldProcess("$TaskName")){
            if($ComputerName -ne $env:COMPUTERNAME){
                $result = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ArgumentList $TaskName -ScriptBlock $StartTask
            }
            else{
                $result = & $StartTask -TaskName $TaskName
            }
        }

        Write-Verbose "$result on $ComputerName"
        
    }
    END{}
    

}

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
        $TaskName
    )

    BEGIN{
        $CodeBlock = {
            param($TaskName)
            & schtasks /Change /TN $TaskName /Disable
        }
    }
    PROCESS{
        if($ComputerName -eq $env:COMPUTERNAME){& $CodeBlock}
        else{Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $CodeBlock -ArgumentList $TaskName}
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
        $Credential,

        [System.String]
        $TaskName
    )

    Begin
    {
        $GetBlock = {
            param(
                $TaskName
            )
            
            $Query = '/QUERY /FO CSV'
            
            if($TaskName){& schtasks /QUERY /TN $TaskName /V /FO CSV }
            else{& schtasks /QUERY /V /FO CSV}
            
        }
    }
    Process
    {
        if($ComputerName -eq $env:COMPUTERNAME){$AllTasks = & $GetBlock -TaskName $TaskName}
        else{$AllTasks = Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock $GetBlock -ArgumentList $TaskName}

        $AllTasks | ConvertFrom-Csv

    }
    
    End{}
}