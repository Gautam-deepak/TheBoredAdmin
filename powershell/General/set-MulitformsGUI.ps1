[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework")
[void] [Reflection.Assembly]::LoadWithPartialName("PresentationCore")
 
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Test Form"
$Form.Size = New-Object System.Drawing.Size(630,840)
$Form.StartPosition = "CenterScreen"
$Form.ShowInTaskbar = $True
$Form.KeyPreview = $True
$Form.AutoSize = $True
$Form.FormBorderStyle = 'Fixed3D'
$Form.MaximizeBox = $False
$Form.MinimizeBox = $False
$Form.ControlBox = $True
$Form.Icon = $Icon
$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
 
$FormTabControl = New-object System.Windows.Forms.TabControl
$FormTabControl.Size = "630,840"
$FormTabControl.Location = "0,0"
$FormTabControl.Font = [System.Drawing.Font]::new("Arial", 13, [System.Drawing.FontStyle]::Regular)
 
$Tab1 = New-object System.Windows.Forms.Tabpage
$Tab1.DataBindings.DefaultDataSourceUpdateMode = 0
$Tab1.UseVisualStyleBackColor = $True
$Tab1.Name = "TAB1"
$Tab1.Text = "TAB1-NAME"
$Tab1.Font = [System.Drawing.Font]::new("Arial", 9, [System.Drawing.FontStyle]::Regular)
 
# Tab1 - Close button 1
$t1_Button1 = New-Object System.Windows.Forms.Button
$t1_Button1.Location = New-Object System.Drawing.Size(500,720)
$t1_Button1.Size = New-Object System.Drawing.Size(100,33)
$t1_Button1.Text = "CLOSE"
$t1_button1.Font = [System.Drawing.Font]::new("Arial", 9, [System.Drawing.FontStyle]::Regular)
$t1_Button1.Add_Click($t1_button_click1)
 
$Tab2 = New-object System.Windows.Forms.Tabpage
$Tab2.DataBindings.DefaultDataSourceUpdateMode = 0
$Tab2.UseVisualStyleBackColor = $True
$Tab2.Name = "TAB2"
$Tab2.Text = "TAB2-NAME"
$Tab2.Font = [System.Drawing.Font]::new("Arial", 9, [System.Drawing.FontStyle]::Regular)
 
# Tab2 - Close button 1
$t2_Button1 = New-Object System.Windows.Forms.Button
$t2_Button1.Location = New-Object System.Drawing.Size(500,720)
$t2_Button1.Size = New-Object System.Drawing.Size(100,33)
$t2_Button1.Text = "CLOSE"
$t2_button1.Font = [System.Drawing.Font]::new("Arial", 9, [System.Drawing.FontStyle]::Regular)
$t2_Button1.Add_Click($t2_button_click1)
 
#add more tabs
 
#add code
 
# Tab1 - Button1 - Close
$t1_button_click1 = {  
 
 [System.Windows.Forms.MessageBox]::Show("Tab 1")
 
}
 
# Tab2 - Button1 - Close
$t2_button_click1 = {  
 
 [System.Windows.Forms.MessageBox]::Show("Tab 2")
 
}
 
#Add Controls
 
$Form.Controls.Add($FormTabControl)
$FormTabControl.Controls.Add($Tab1)
$FormTabControl.Controls.Add($Tab2)
 
$Tab1.Controls.Add($t1_Button1)
$Tab2.Controls.Add($t2_Button1)
 
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()