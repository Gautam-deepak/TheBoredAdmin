

--------------------------------------
do {
    Write-Host "`n============= Pick the Server environment=============="
    Write-Host "`ta. 'P' for the Prod servers"
    Write-Host "`tb. 'T' for the Test servers"
    Write-Host "`tc. 'D for the Dev Servers'"
    Write-Host "`td. 'Q to Quit'"
    Write-Host "========================================================"
    $choice = Read-Host "`nEnter Choice"
    } until (($choice -eq 'P') -or ($choice -eq 'T') -or ($choice -eq 'D') -or ($choice -eq 'Q') )
    switch ($choice) {
       'P'{
           Write-Host "`nYou have selected a Prod Environment"
       }
       'T'{
          Write-Host "`nYou have selected a Test Environment"
       }
       'D'{
           Write-Host "`nYou have selected a Dev Environment"
        }
        'Q'{
          Return
       }
    }
    
----------------------------------------------------------------------------------    
    using namespace System.Management.Automation.Host 
    $Prod = [ChoiceDescription]::new('&Prod', 'Environment:Prod') 
    $Test = [ChoiceDescription]::new('&Test', 'Environment:Test') 
    $Dev = [ChoiceDescription]::new('&Dev', 'Environment:Dev') 
    $Envs = [ChoiceDescription[]]($prod,$Test,$Dev) 
    $choice = $host.ui.PromptForChoice("Select Environment", "Prod , Dev , Test ", $envs, 0) 
    switch ($choice) { 
        0{ Write-Host "`nYou have selected a Prod Environment" } 
        1{ Write-Host "`nYou have selected a Test Environment" } 
        2{ Write-Host "`nYou have selected a Dev Environment" } 
    }
