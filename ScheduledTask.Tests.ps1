Import-Module $PSScriptRoot\ScheduledTask -Force
Describe 'Get-ScheduledTask'{
    BeforeAll{
        #Add a fake task
        & SCHTASKS /Create /SC MONTHLY /MO first /D SUN /TN Pester /TR 'powershell Import-Module Pester'
    }

    AfterAll{
        & SCHTASKS /Delete /TN Pester /F
    }
    
    Context 'Get details for specific task'{
        $PesterTask = Get-ScheduledTask -TaskName Pester

        It 'Should get scheduled task' {
            $PesterTask.TaskName | Should Be '\Pester'
        }

        It 'Should have a status Ready' {
            $PesterTask.Status | Should Be 'Ready'
        }
    }
}

