<#
    BlankLine
    Document
    DocumentOption
    Export-Document
    Footer
    Header
    Image
    LineBreak
    PageBreak
    Paragraph
    Section
    Set-Style
    Style
    Table
    TableStyle
    Text
    TOC
    Write-PScriboMessage
#>

# Section Uses PS Scribo to Turn table in to HTML, TXT, DOC
$document = Document 'ReportDoc' -Verbose {
	TOC
	pagebreak
    # Section 1
    Style -Name 'HighUsage' -Color black -BackgroundColor Firebrick -Bold
    Paragraph -Style Heading1 'Summary Host Usage Report for All Locations'
    LineBreak
    Paragraph -Style Heading3 'Cell marked red means that there is not enough resource to handle a host failure'
	blankline
    Section -Style Heading2 "1.1 Get Processes details" {
		$proc = Get-Process | select-object -first 20
		Table -Name 'Proc Name' -InputObject $proc -Columns "Name","Id","PriorityClass","FileVersion","HandleCount" `
		-ColumnWidths 30,30,30,30,30 -Headers "Name","Id","PriorityClass","FileVersion","HandleCount" -Caption "test"
	}
}
$document | Export-Document -Path .\ -Format Word,Html,Text -Verbose