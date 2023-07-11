$inObj = [ordered] @{
	'Computers' = 60
	'Servers' = 40
}

$sampleData = $inObj.GetEnumerator()

$exampleChart = New-Chart -Name UserAccountsinAD -Width 600 -Height 400

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
	Name      = 'ComputersObject'
	Text      = 'Computers Object Count'
	Font      = New-Object -TypeName 'System.Drawing.Font' -ArgumentList @('Arial', '12', [System.Drawing.FontStyle]::Bold)
}

Add-ChartTitle @addChartTitleParams

$chartFileItem = Export-Chart -Chart $exampleChart -Path (Get-Location).Path -Format "PNG" -PassThru

Image -Text 'Computers Object - Diagram' -Align 'Center' -Percent 100 -Path $chartFileItem