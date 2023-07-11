#variables
param (
     # Parameter help description
     [Parameter(Mandatory=$true)]
     [string]
     $location
)
#variables

$date=get-date -format dd_MM_yy
$patching = "Patching_Report" + "_" + "$($date)"

# Importing required modules

import-module pscribo

$document = Document $patching -Verbose {
	DocumentOption -EnableSectionNumbering -PageSize 'A4' -DefaultFont 'Arial' -MarginLeftAndRight 71 -MarginTopAndBottom 71 -Orientation "Portrait"
    
    # Configure Heading and Font Styles
    Style -Name 'Title' -Size 24 -Color '0078D4' -Align Center
    Style -Name 'Title 2' -Size 18 -Color '00447C' -Align Center
    Style -Name 'Title 3' -Size 12 -Color '1F6BCF' -Align Left
    Style -Name 'Heading 1' -Size 16 -Color '0078D4'
    Style -Name 'Heading 2' -Size 14 -Color '00447C'
    Style -Name 'Heading 3' -Size 13 -Color '0081FF'
    Style -Name 'Heading 4' -Size 12 -Color '0077B7'
    Style -Name 'Heading 5' -Size 11 -Color '1A9BA3'
    Style -Name 'NO TOC Heading 5' -Size 11 -Color '1A9BA3'
    Style -Name 'Heading 6' -Size 10 -Color '505050'
    Style -Name 'NO TOC Heading 6' -Size 10 -Color '505050'
    Style -Name 'NO TOC Heading 7' -Size 10 -Color '551A4C' -Italic
    Style -Name 'Normal' -Size 10 -Color '565656' -Default
    Style -Name 'Caption' -Size 10 -Color '565656' -Italic -Align Center
    Style -Name 'Header' -Size 10 -Color '565656' -Align Center
    Style -Name 'Footer' -Size 10 -Color '565656' -Align Center
    Style -Name 'TOC' -Size 16 -Color '1F6BCF'
    Style -Name 'TableDefaultHeading' -Size 10 -Color 'FAFAFA' -BackgroundColor '0078D4'
    Style -Name 'TableDefaultRow' -Size 10 -Color '565656'
    Style -Name 'Critical' -Size 10 -BackgroundColor 'E81123' -Color 'FAFAFA'
    Style -Name 'Warning' -Size 10 -BackgroundColor 'FCD116'
    Style -Name 'Info' -Size 10 -BackgroundColor '0072C6'
    Style -Name 'OK' -Size 10 -BackgroundColor '7FBA00'

    # Configure Table Styles
    $TableDefaultProperties = @{
        Id = 'TableDefault'
        HeaderStyle = 'TableDefaultHeading'
        RowStyle = 'TableDefaultRow'
        BorderColor = '0078D4'
        Align = 'Left'
        CaptionStyle = 'Caption'
        CaptionLocation = 'Below'
        BorderWidth = 0.25
        PaddingTop = 1
        PaddingBottom = 1.5
        PaddingLeft = 2
        PaddingRight = 2
    }

    TableStyle @TableDefaultProperties -Default
    TableStyle -Id 'Borderless' -HeaderStyle Normal -RowStyle Normal -BorderWidth 0

    Header -Default {
        Paragraph -Style Header "Hyper-V - v1.0"
    }

    Footer -Default {
        Paragraph -Style Footer 'Page <!# PageNumber #!>'
    }
    BlankLine -Count 15
    Image -Text 'AsBuiltReport Logo' -Align 'Center' -Percent 45 -Base64 "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"
    
    BlankLine
    Paragraph -Style Title 'Windows Patching Report'
    BlankLine -Count 29
    Table -Name 'Cover Page' -List -Style Borderless -Width 0 -Hashtable ([Ordered] @{
        'Author:' = "Deepak Gautam"
        'Date:' = (Get-Date).ToLongDateString()
        'Version:' = "v1.0"
    })
            
	 pagebreak
	TOC -Name 'Table of Contents'
	pagebreak
            Paragraph -Style Heading1 'Summary of Windows Patching'
            LineBreak
            BlankLine
			# Section 1
			Paragrah -Style Heading3 '1. Hosts Information'
			blankline
			Section -Style Heading3 '1.1 All hosts'{
				Paragraph 'Details of all the hosts and their status in the Ansible Patching playbook.'
                BlankLine
				$failed=get-content $location/patching_status/failed_unreachable.txt
                $patched=get-content $location/patching_status/patched.txt
                $failco=foreach($fail in $failed){
                    [PSCustomObject]@{
                        Name = $fail
                        Status="Failure"
                    }
                }
                $patchco=foreach($patch in $patched){
                    [PSCustomObject]@{
                        Name = $patch
                        Status="Success"
                    }
                }
                $allhostco=$patchco+$failco
                Table -Name 'Allhosts' -InputObject $allhostco -Columns "Name","Status" `
                -ColumnWidths 70,30 -Headers "Name","Status" -Caption "Allhosts" 
			}
			
            Paragraph -Style Heading3 '2. Hotfixes information'
	        blankline
            Section -Style Heading2 "2.1 hotfixes information" {
                $csv = import-csv -path $location/results/final-hotfix.csv 
                Table -Name 'CSV' -InputObject $csv -Columns "PSComputername","description","hotfixID","InstalledBY","Installedon","LastBootUptime"`
                -ColumnWidths 15,15,20,20,15,15 -Headers "PSComputername","description","hotfixID","InstalledBY","Installedon","LastBootUptime" -Caption "csv"
            }
            
            Paragraph -Style Heading3 '3. Playbook Information'
	        blankline
            Section -Style Heading2 "3.1 Total time taken" {
                $allhosts=(Get-Content $location/patching_status/allhosts.txt).count
                # Read the content from the file
                $sec = Get-Content -Raw -Path $location/results/time_taken.txt
                
                # Parse the seconds as an integer
                $seconds = [int]$sec.Trim()
                
                # Calculate the hours, minutes, and remaining seconds
                $hours = [math]::Floor($seconds / 3600)
                $minutes = [math]::Floor(($seconds % 3600) / 60)
                $remainingSeconds = $seconds % 60
                
                # Format the hours, minutes, and remaining seconds
                $hoursFormatted = "{0:00}" -f $hours
                $minutesFormatted = "{0:00}" -f $minutes
                $secondsFormatted = "{0:00}" -f $remainingSeconds
                
                # Combine hours, minutes, and remaining seconds into a formatted string
                $duration = "${hoursFormatted}:${minutesFormatted}:${secondsFormatted}"
                
                Paragraph "Total time taken to patch $($allhosts) servers was $($duration) hrs."
            }
		}
		$document | Export-Document -Path $location -Format word -Verbose
