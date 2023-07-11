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
$final_last_hotfix=import-csv -Path $location/results/final-last-hotfix.csv

# Functions
function get-timetaken {
    param (
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string]
        $location
    )
    
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
    return $duration
}

# Importing required modules

Import-module pscribo
Import-module mscatalog

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
    Style -Name 'TableDefaultHeading' -Size 10 -Color 'FAFAFA' -BackgroundColor '00b388'
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
        Paragraph -Style Header "Patch Level Report - v2.0"
    }

    Footer -Default {
        Paragraph -Style Footer 'Page <!# PageNumber #!>'
    }
    BlankLine -Count 15
    Image -Text 'AsBuiltReport Logo' -Align 'Center' -Percent 45 -Base64 "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"
    
    BlankLine
    Paragraph -Style Title 'Patch Level Report'
    BlankLine -Count 29
    Table -Name 'Cover Page' -List -Style Borderless -Width 0 -Hashtable ([Ordered] @{
        'Author:' = "Deepak Gautam"
        'Date:' = (Get-Date).ToLongDateString()
        'Version:' = "v2.0"
    })
            
	 pagebreak
    
    Paragraph -Style Heading1 'Revision Table:'
    BlankLine -Count 1
    Paragraph 'The table below provides an overview of the revision history for the documentation related to Windows patching automation. It includes the date of each revision, corresponding version numbers, a brief description of the changes made, and the name of the individual responsible for the revision.'
    $revision1=[PSCustomObject]@{
        "Date" = "01-May-2023"
        "Version" = "1.0"
        "Description" = "Initial Draft"
        "Revised By" = "Deepak Gautam"
    }
    $revision2=[PSCustomObject]@{
        "Date" = "10-May-2023"
        "Version" = "1.1"
        "Description" = "Added Last Boot Uptime column in 2.1"
        "Revised By" = "Deepak Gautam"
    }
    $revision3=[PSCustomObject]@{
        "Date" = "17-May-2023"
        "Version" = "1.2"
        "Description" = "Added Patch Level Pie Chart"
        "Revised By" = "Deepak Gautam"
    }
    $revision4=[PSCustomObject]@{
        "Date" = "22-May-2023"
        "Version" = "1.3"
        "Description" = "Added Cover Page for Patch Level Report"
        "Revised By" = "Deepak Gautam"
    }
    $revision5=[PSCustomObject]@{
        "Date" = "25-May-2023"
        "Version" = "1.4"
        "Description" = "Added Header and footers"
        "Revised By" = "Deepak Gautam"
    }
    $revision6=[PSCustomObject]@{
        "Date" = "28-May-2023"
        "Version" = "2.0"
        "Description" = "Added document revision table"
        "Revised By" = "Deepak Gautam"
    }
    # Combine all revision objects into an array
    $allRevisions = @($revision1, $revision2, $revision3,$revision4,$revision5,$revision6)
    BlankLine -Count 2
    Table -Name 'Revision Summary' -InputObject $allRevisions -Columns "Date","Version","Description","Revised By"`
    -ColumnWidths 15,10,50,25 -Headers "Date","Version","Description","Revised By" -Caption "Revision Table"
    PageBreak
    BlankLine
	TOC -Name 'Table of Contents'
    BlankLine -Count 2
	pagebreak
            Paragraph -Style Heading1 'Summary of Patch Level - '
            BlankLine
            Paragraph 'Quick summary of Windows Patch level is as follows: '
            BlankLine
            $final_last_hotfix=Import-Csv -Path $location\results\final-last-hotfix.csv
            $patch_level=foreach($item in $final_last_hotfix){
                [PSCustomObject]@{
                    "Patch_Level"=((Get-MSCatalogUpdate -Search $item.HotfixID | Select-Object -ExpandProperty lastupdated )[0]).Tostring("MMMM")
                }
            }
            $groupedData = $patch_level | Group-Object -Property Patch_Level -NoElement | `
                ForEach-Object {
                    [PSCustomObject]@{
                        name = $_.Name
                        value = $_.Count
                    }
                }

                $sampleData = $groupedData.GetEnumerator()
                
                $exampleChart = New-Chart -Name PatchLevelReport -Width 600 -Height 400
                
                  $addChartAreaParams = @{
                    Chart = $exampleChart
                    Name  = 'exampleChartArea'
                }
                $exampleChartArea = Add-ChartArea @addChartAreaParams -PassThru
                
                $addChartSeriesParams = @{
                    Chart             = $exampleChart
                    ChartArea         = $exampleChartArea
                    Name              = 'exampleChartSeries'
                    XField            = 'name'
                    YField            = 'value'
                    Palette           = 'Blue'
                    ColorPerDataPoint = $true
                }
                
                $exampleChartSeries = $sampleData | Add-PieChartSeries @addChartSeriesParams -PassThru
                
                $addChartLegendParams = @{
                    Chart             = $exampleChart
                    Name              = 'Category'
                    TitleAlignment    = 'Center'
                }
                
                Add-ChartLegend @addChartLegendParams
                
                $addChartTitleParams = @{
                    Chart     = $exampleChart
                    ChartArea = $exampleChartArea
                    Name      = 'Patch Level'
                    Text      = 'Patch Level Count '
                    Font      = New-Object -TypeName 'System.Drawing.Font' -ArgumentList @('Arial', '12', [System.Drawing.FontStyle]::Bold)
                }
                
                Add-ChartTitle @addChartTitleParams
                
                $chartFileItem = Export-Chart -Chart $exampleChart -Path (Get-Location).Path -Format "PNG" -PassThru
                
                Image -Text 'Patch Level - Diagram' -Align 'Center' -Percent 100 -Path $chartFileItem

            LineBreak
            BlankLine
			# Section 1
			Paragraph -Style Heading3 '1. Patch Level Information'
			blankline
			Section -Style Heading4 '.1 Patch Level'{
				Paragraph 'Details of all the CIs with their patch level.'
                BlankLine
                $patchlevelreport=foreach($item in $final_last_hotfix){
                    [PSCustomObject]@{
                        "Name" = $item.PSComputername
                        "Last KB"=$item.HotfixID
                        "InstalledOn"=$item.InstalledOn
                        "Patch Level"=((Get-MSCatalogUpdate -Search $item.HotfixID | Select-Object -ExpandProperty lastupdated )[0]).Tostring("MMMM")
                    }
                }
                Table -Name 'Patch Level Information' -InputObject $patchlevelreport -Columns "Name","Last KB","InstalledOn","Patch Level" `
                -ColumnWidths 25,25,25,25 -Headers "Name","Last KB","Installed On","Patch Level" -Caption "Patch Level Information" 
			}
			
            Paragraph -Style Heading3 '2. Patch Details'
	        blankline
            Section -Style Heading4 ".1 Installed hotfixes information" {
                $csv = import-csv -path $location/results/final-hotfix.csv 
                Table -Name 'Hotfixes Information' -InputObject $csv -Columns "PSComputername","Description","HotfixID",`
                "InstalledBY","Installedon","LastBootUptime"`
                -ColumnWidths 17,15,13,20,15,20 -Headers "Computer","Description","Hotfix ID","Installed BY",`
                "Installed On","Last Boot Time" -Caption "Hotfixes Information"
            }
		}
		$document | Export-Document -Path $location -Format word -Verbose
