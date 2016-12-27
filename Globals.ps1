#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------
[System.Collections.IList]$global:errorList = new-object System.Collections.ArrayList
[System.Collections.IList]$global:reportList = new-object System.Collections.ArrayList
$global:searchList
$global:changed = $false
[string]$global:datasetFile = ""

$global:searchstate = $false
$global:editedsearch=$false
$global:mainDataTable = New-Object System.Data.DataTable
$global:table = @{ }
$global:histogram = @{ }
[string]$global:loaddirectory = ""
[string]$global:exportdirectory = ""
[string]$global:histogramdirectory = ""
#region Add Dialog
$global:addDialog = New-Object system.Windows.Forms.Form
$global:addDialogSave = New-Object System.Windows.Forms.Button
$global:addDialogCancel = New-Object System.Windows.Forms.Button
$global:addDialogLabel1 = New-Object System.Windows.Forms.Label
$global:addDialogLabel2 = New-Object System.Windows.Forms.Label
$global:addDialogLabel3 = New-Object System.Windows.Forms.Label
$global:addDialogLabel4 = New-Object System.Windows.Forms.Label
$global:addDialogLabel5 = New-Object System.Windows.Forms.Label
$global:addDialogLabel6 = New-Object System.Windows.Forms.Label
$global:addDialogLabel7 = New-Object System.Windows.Forms.Label
$global:addDialogLabel8 = New-Object System.Windows.Forms.Label
$global:addDialogField1 = New-Object System.Windows.Forms.TextBox
$global:addDialogField2 = New-Object System.Windows.Forms.TextBox
$global:addDialogField3 = New-Object System.Windows.Forms.TextBox
$global:addDialogField4 = New-Object System.Windows.Forms.TextBox
$global:addDialogField5 = New-Object System.Windows.Forms.TextBox
$global:addDialogField6 = New-Object System.Windows.Forms.TextBox
$global:addDialogField7 = New-Object System.Windows.Forms.TextBox
$global:addDialogField8 = New-Object System.Windows.Forms.TextBox

$global:addDialog.Text = "Add Report"
$global:addDialog.StartPosition = "CenterScreen"
$global:addDialog.FormBorderStyle = 'FixedDialog'
$global:addDialog.Size = New-Object System.Drawing.Size(500, 550)

$global:addDialogLabel1.Text = "File #: "
$global:addDialogLabel2.Text = "Report #:"
$global:addDialogLabel3.Text = "Reported: "
$global:addDialogLabel4.Text = "Occurred: "
$global:addDialogLabel5.Text = "Incident: "
$global:addDialogLabel6.Text = "Location: "
$global:addDialogLabel7.Text = "Disposition: "
$global:addDialogLabel8.Text = "Summary: "

$global:addDialogLabel1.Location = New-Object System.Drawing.Size(25, 10)
$global:addDialogLabel1.Size = New-Object System.Drawing.Size(425, 20)
$global:addDialogLabel2.Location = New-Object System.Drawing.Size(25, 60)
$global:addDialogLabel2.Size = New-Object System.Drawing.Size(425, 20)
$global:addDialogLabel3.Location = New-Object System.Drawing.Size(25, 110)
$global:addDialogLabel3.Size = New-Object System.Drawing.Size(425, 20)
$global:addDialogLabel4.Location = New-Object System.Drawing.Size(25, 160)
$global:addDialogLabel4.Size = New-Object System.Drawing.Size(425, 20)
$global:addDialogLabel5.Location = New-Object System.Drawing.Size(25, 210)
$global:addDialogLabel5.Size = New-Object System.Drawing.Size(425, 20)
$global:addDialogLabel6.Location = New-Object System.Drawing.Size(25, 260)
$global:addDialogLabel6.Size = New-Object System.Drawing.Size(425, 20)
$global:addDialogLabel7.Location = New-Object System.Drawing.Size(25, 310)
$global:addDialogLabel7.Size = New-Object System.Drawing.Size(425, 20)
$global:addDialogLabel8.Location = New-Object System.Drawing.Size(25, 360)
$global:addDialogLabel8.Size = New-Object System.Drawing.Size(425, 20)

$global:addDialogField1.Location = New-Object System.Drawing.Size(25, 30)
$global:addDialogField1.Size = New-Object System.Drawing.Size(425, 50)
$global:addDialogField2.Location = New-Object System.Drawing.Size(25, 80)
$global:addDialogField2.Size = New-Object System.Drawing.Size(425, 25)
$global:addDialogField3.Location = New-Object System.Drawing.Size(25, 130)
$global:addDialogField3.Size = New-Object System.Drawing.Size(425, 25)
$global:addDialogField4.Location = New-Object System.Drawing.Size(25, 180)
$global:addDialogField4.Size = New-Object System.Drawing.Size(425, 25)
$global:addDialogField5.Location = New-Object System.Drawing.Size(25, 230)
$global:addDialogField5.Size = New-Object System.Drawing.Size(425, 25)
$global:addDialogField6.Location = New-Object System.Drawing.Size(25, 280)
$global:addDialogField6.Size = New-Object System.Drawing.Size(425, 25)
$global:addDialogField7.Location = New-Object System.Drawing.Size(25, 330)
$global:addDialogField7.Size = New-Object System.Drawing.Size(425, 25)
$global:addDialogField8.Location = New-Object System.Drawing.Size(25, 380)
$global:addDialogField8.Size = New-Object System.Drawing.Size(425, 65)
$global:addDialogField8.Multiline = $true

$global:addDialogSave.Text = "Save"
$global:addDialogSave.Anchor = 'Bottom'
$global:addDialogSave.Location = New-Object System.Drawing.Size(150, 462)
$global:addDialogSave.add_MouseClick({
		$x1 = $global:addDialogField1.Text
		$x2 = $global:addDialogField2.Text
		$x3 = $global:addDialogField3.Text
		$x4 = $global:addDialogField4.Text
		$x5 = $global:addDialogField5.Text
		$x6 = $global:addDialogField6.Text
		$x7 = $global:addDialogField7.Text
		$x8 = $global:addDialogField8.Text
		[int]$i = 0
				<#Under Construction#>
		if ($x1 -ne "" -and $x2 -ne "" -and $x3 -ne "" -and $x4 -ne "" -and $x5 -ne "" -and $x6 -ne "" -and $x7 -ne "")
		{
			if (-not ($x2 -match "\D"))
			{
				$global:changed = $true
				
				[int]$newReportNum = [convert]::ToInt32($x2)
				[int]$lower = 0
				[int]$upper = $global:reportList.count - 1
				$i = ($lower + $upper)/2
				[int]$currReportNum = 0
				while ($reportList[$i]."Report #" -match "\D") { $i++ }
				while ($newReportNum -ne $currReportNum -and $upper -ne $lower)
				{
					$currReportNum = $reportList[$i]."Report #"
					if ($newReportNum -eq $currReportNum) { break }
					if ($newReportNum -gt $currReportNum) { $lower = $i }
					if ($newReportNum -lt $currReportNum) { $upper = $i }
					$i = ($lower + $upper)/2
					while ($reportList[$i]."Report #" -match "\D") { $i++ }
					if ($i -eq $lower -or $i -eq $upper) { break }
				}
				if ($i -eq $lower -or $i -eq $upper)
				{
					while ($reportList[$i] -ne $null -and $newReportNum -gt $reportList[$i]."Report #") { $i++ }
				}
			}
			else
			{
				[System.Windows.forms.MessageBox]::Show("Report # must be a valid number", "Error")
				return
			}
		}
		else
		{
			[System.Windows.forms.MessageBox]::Show("All fields must be filled", "Error")
			return
		}
		
		$report = @{ "File" = $x1; "Report #" = $x2; "Reported" = $x3; "Occurred" = $x4; "Incident" = $x5; "Location" = $x6; "Disposition" = $x7; "Summary" = $x8 }

		$report."Index" = $i
		
		$row = $global:mainDataTable.newRow()
		foreach ($key in $report.Keys)
		{
			if ($global:mainDataTable.Columns.Contains($key))
			{
				$row.Item($key) = $report[$key]
			}
		}
		
		[void]$global:reportList.insert($i, $report)
		$global:mainDataTable.Rows.insertAt($row, $i)
		$i++
		for ($i; $i -lt $global:reportList.count; $i++)
		{
			$global:reportList[$i]."Index" = [System.Convert]::ToInt32($global:reportList[$i]."Index") + 1
		}
		ConvertTo-DataTable -InputObject $global:reportList -Table $global:mainDataTable -RetainColumns
		Load-DataGridView -DataGridView $datagridviewResults -Item $global:mainDataTable
		$global:addDialog.Close()
	})

$global:addDialogCancel.Text = "Cancel"
$global:addDialogCancel.Anchor = 'Bottom'
$global:addDialogCancel.Location = New-Object System.Drawing.Size(250, 462)
$global:addDialogCancel.add_MouseClick({
		$global:addDialog.Close()
	})

$global:addDialog.Controls.Add($global:addDialogLabel1)
$global:addDialog.Controls.Add($global:addDialogLabel2)
$global:addDialog.Controls.Add($global:addDialogLabel3)
$global:addDialog.Controls.Add($global:addDialogLabel4)
$global:addDialog.Controls.Add($global:addDialogLabel5)
$global:addDialog.Controls.Add($global:addDialogLabel6)
$global:addDialog.Controls.Add($global:addDialogLabel7)
$global:addDialog.Controls.Add($global:addDialogLabel8)
$global:addDialog.Controls.Add($global:addDialogField1)
$global:addDialog.Controls.Add($global:addDialogField2)
$global:addDialog.Controls.Add($global:addDialogField3)
$global:addDialog.Controls.Add($global:addDialogField4)
$global:addDialog.Controls.Add($global:addDialogField5)
$global:addDialog.Controls.Add($global:addDialogField6)
$global:addDialog.Controls.Add($global:addDialogField7)
$global:addDialog.Controls.Add($global:addDialogField8)
$global:addDialog.Controls.add($global:addDialogSave)
$global:addDialog.Controls.add($global:addDialogCancel)
#endregion

#region Full Report Dialog
$global:reportDialog = New-Object system.Windows.Forms.Form
$global:reportDialogOkay = New-Object System.Windows.Forms.Button
$global:reportDialogLabel1 = New-Object System.Windows.Forms.Label
$global:reportDialogLabel2 = New-Object System.Windows.Forms.Label
$global:reportDialogLabel3 = New-Object System.Windows.Forms.Label
$global:reportDialogLabel4 = New-Object System.Windows.Forms.Label
$global:reportDialogLabel5 = New-Object System.Windows.Forms.Label
$global:reportDialogLabel6 = New-Object System.Windows.Forms.Label
$global:reportDialogLabel7 = New-Object System.Windows.Forms.Label

$global:reportDialog.StartPosition = "CenterScreen"
$global:reportDialog.FormBorderStyle = 'FixedDialog'
$global:reportDialog.Size = New-Object System.Drawing.Size(500, 370)

$global:reportDialogOkay.Location
$global:reportDialogOkay.Text = "Okay"
$global:reportDialogOkay.Location = New-Object System.Drawing.Size(150, 280)
$global:reportDialogOkay.Size = New-Object System.Drawing.Size(200, 30)
$global:reportDialogOkay.add_MouseClick({
		$global:reportDialog.Close()
	})
$reportDialogOkay.DialogResult = 'OK'
$global:reportDialog.AcceptButton = $global:reportDialogOkay

$global:reportDialogLabel1.Location = New-Object System.Drawing.Size(25, 20)
$global:reportDialogLabel1.Size = New-Object System.Drawing.Size(425, 30)
$global:reportDialogLabel2.Location = New-Object System.Drawing.Size(25, 55)
$global:reportDialogLabel2.Size = New-Object System.Drawing.Size(425, 30)
$global:reportDialogLabel3.Location = New-Object System.Drawing.Size(25, 90)
$global:reportDialogLabel3.Size = New-Object System.Drawing.Size(425, 30)
$global:reportDialogLabel4.Location = New-Object System.Drawing.Size(25, 125)
$global:reportDialogLabel4.Size = New-Object System.Drawing.Size(425, 30)
$global:reportDialogLabel5.Location = New-Object System.Drawing.Size(25, 160)
$global:reportDialogLabel5.Size = New-Object System.Drawing.Size(425, 30)
$global:reportDialogLabel6.Location = New-Object System.Drawing.Size(25, 195)
$global:reportDialogLabel6.Size = New-Object System.Drawing.Size(425, 80)

$global:reportDialog.Controls.add($global:reportDialogOkay)
$global:reportDialog.Controls.add($global:reportDialogLabel1)
$global:reportDialog.Controls.add($global:reportDialogLabel2)
$global:reportDialog.Controls.add($global:reportDialogLabel3)
$global:reportDialog.Controls.add($global:reportDialogLabel4)
$global:reportDialog.Controls.add($global:reportDialogLabel5)
$global:reportDialog.Controls.add($global:reportDialogLabel6)

$global:comboboxval = ""
$global:filterval = ""
#endregion

#region generateHistogram
#----------------------------------------------
#region Generated Form Objects
#----------------------------------------------
[System.Windows.Forms.Application]::EnableVisualStyles()
$formGenerateHistogram = New-Object 'System.Windows.Forms.Form'
$Divider1 = New-Object 'System.Windows.Forms.Label'
$buttonSave = New-Object 'System.Windows.Forms.Button'
$labelval5 = New-Object 'System.Windows.Forms.Label'
$labelkey5 = New-Object 'System.Windows.Forms.Label'
$labelval4 = New-Object 'System.Windows.Forms.Label'
$labelkey4 = New-Object 'System.Windows.Forms.Label'
$labelval3 = New-Object 'System.Windows.Forms.Label'
$labelkey3 = New-Object 'System.Windows.Forms.Label'
$labelval2 = New-Object 'System.Windows.Forms.Label'
$labelkey2 = New-Object 'System.Windows.Forms.Label'
$labelval1 = New-Object 'System.Windows.Forms.Label'
$labelkey1 = New-Object 'System.Windows.Forms.Label'
$labelTop5Results = New-Object 'System.Windows.Forms.Label'
$labelExplanation = New-Object 'System.Windows.Forms.Label'
$labelFilter = New-Object 'System.Windows.Forms.Label'
$buttonOK = New-Object 'System.Windows.Forms.Button'
$labelField = New-Object 'System.Windows.Forms.Label'
$combobox = New-Object 'System.Windows.Forms.ComboBox'
$Filter = New-Object 'System.Windows.Forms.TextBox'
#endregion Generated Form Objects

#
# formGenerateHistogram
#
$formGenerateHistogram.Controls.Add($Divider1)
$formGenerateHistogram.Controls.Add($buttonSave)
$formGenerateHistogram.Controls.Add($labelval5)
$formGenerateHistogram.Controls.Add($labelkey5)
$formGenerateHistogram.Controls.Add($labelval4)
$formGenerateHistogram.Controls.Add($labelkey4)
$formGenerateHistogram.Controls.Add($labelval3)
$formGenerateHistogram.Controls.Add($labelkey3)
$formGenerateHistogram.Controls.Add($labelval2)
$formGenerateHistogram.Controls.Add($labelkey2)
$formGenerateHistogram.Controls.Add($labelval1)
$formGenerateHistogram.Controls.Add($labelkey1)
$formGenerateHistogram.Controls.Add($labelTop5Results)
$formGenerateHistogram.Controls.Add($labelExplanation)
$formGenerateHistogram.Controls.Add($labelFilter)
$formGenerateHistogram.Controls.Add($buttonOK)
$formGenerateHistogram.Controls.Add($labelField)
$formGenerateHistogram.Controls.Add($combobox)
$formGenerateHistogram.Controls.Add($Filter)
$formGenerateHistogram.AcceptButton = $buttonOK
$formGenerateHistogram.AutoScaleDimensions = '8, 17'
$formGenerateHistogram.AutoScaleMode = 'Font'
$formGenerateHistogram.ClientSize = '416, 387'
$formGenerateHistogram.FormBorderStyle = 'FixedDialog'
$formGenerateHistogram.Margin = '5, 5, 5, 5'
$formGenerateHistogram.MaximizeBox = $False
$formGenerateHistogram.MinimizeBox = $False
$formGenerateHistogram.Name = 'formGenerateHistogram'
$formGenerateHistogram.StartPosition = 'CenterScreen'
$formGenerateHistogram.Text = 'Generate Histogram'
#
# Divider1
#
$Divider1.Anchor = 'Top'
$Divider1.Font = 'Microsoft Sans Serif, 10pt'
$Divider1.Location = '38, 153'
$Divider1.Margin = '4, 4, 4, 4'
$Divider1.Name = 'Divider1'
$Divider1.Size = '344, 20'
$Divider1.TabIndex = 15
$Divider1.Text = '_________________________________'
$Divider1.TextAlign = 'BottomCenter'
#
# buttonSave
#
$buttonSave.Anchor = 'Bottom, Right'
$buttonSave.Location = '75, 344'
$buttonSave.Margin = '4, 4, 4, 4'
$buttonSave.Name = 'buttonSave'
$buttonSave.Size = '100, 30'
$buttonSave.TabIndex = 14
$buttonSave.Text = '&Save'
$buttonSave.UseVisualStyleBackColor = $True
$buttonSave.add_click({
		if ($global:histogram -ne $null -and $global:histogram.count -ne 0)
		{
			[System.Windows.Forms.SaveFileDialog]$filedialog = New-Object System.Windows.Forms.SaveFileDialog
			if ($global:histogramdirectory -eq "")
			{
				$filedialog.InitialDirectory = "$ScriptDirectory\data"
			}
			else
			{
				$filedialog.InitialDirectory = $global:histogramdirectory
			}
			$filedialog.Title = "Export Dataset"
			$filedialog.CheckFileExists = $false
			$filedialog.CheckPathExists = $true
			$filedialog.AddExtension = $true
			$filedialog.DefaultExt = ".csv"
			$filedialog.Filter = "CSV File (*.csv)|*.csv"
			$output = $filedialog.ShowDialog()
			if ($filedialog.filename -eq "")
			{
				return
			}
			else
			{
				$global:histogram | Export-Csv $filedialog.FileName
			}
			$filePath = $filedialog.FileName
			$fileDir = $filePath.Split(0, $filePath.LastIndexOf("\"))
			if ($global:histogramdirectory -ne $fileDir)
			{
				$global:histogramdirectory = $fileDir
			}
		}
		else
		{
			[System.Windows.forms.MessageBox]::Show("No histogram has been made. Please press 'Okay' to generate histogram.", "Error")
		}
	})
#
# labelval5
#
$labelval5.Anchor = 'Top'
$labelval5.Font = 'Microsoft Sans Serif, 10pt'
$labelval5.Location = '338, 310'
$labelval5.Margin = '4, 4, 4, 4'
$labelval5.Name = 'labelval5'
$labelval5.Size = '55, 18'
$labelval5.TabIndex = 13
$labelval5.Text = '0'
#
# labelkey5
#
$labelkey5.Anchor = 'Top'
$labelkey5.Font = 'Microsoft Sans Serif, 10pt'
$labelkey5.Location = '38, 310'
$labelkey5.Margin = '4, 4, 4, 4'
$labelkey5.Name = 'labelkey5'
$labelkey5.Size = '292, 18'
$labelkey5.TabIndex = 12
$labelkey5.Text = 'Example5'
#
# labelval4
#
$labelval4.Anchor = 'Top'
$labelval4.Font = 'Microsoft Sans Serif, 10pt'
$labelval4.Location = '338, 284'
$labelval4.Margin = '4, 4, 4, 4'
$labelval4.Name = 'labelval4'
$labelval4.Size = '55, 18'
$labelval4.TabIndex = 11
$labelval4.Text = '0'
#
# labelkey4
#
$labelkey4.Anchor = 'Top'
$labelkey4.Font = 'Microsoft Sans Serif, 10pt'
$labelkey4.Location = '38, 284'
$labelkey4.Margin = '4, 4, 4, 4'
$labelkey4.Name = 'labelkey4'
$labelkey4.Size = '292, 18'
$labelkey4.TabIndex = 10
$labelkey4.Text = 'Example4'
#
# labelval3
#
$labelval3.Anchor = 'Top'
$labelval3.Font = 'Microsoft Sans Serif, 10pt'
$labelval3.Location = '338, 258'
$labelval3.Margin = '4, 4, 4, 4'
$labelval3.Name = 'labelval3'
$labelval3.Size = '55, 18'
$labelval3.TabIndex = 9
$labelval3.Text = '0'
#
# labelkey3
#
$labelkey3.Anchor = 'Top'
$labelkey3.Font = 'Microsoft Sans Serif, 10pt'
$labelkey3.Location = '38, 258'
$labelkey3.Margin = '4, 4, 4, 4'
$labelkey3.Name = 'labelkey3'
$labelkey3.Size = '292, 18'
$labelkey3.TabIndex = 8
$labelkey3.Text = 'Example3'
#
# labelval2
#
$labelval2.Anchor = 'Top'
$labelval2.Font = 'Microsoft Sans Serif, 10pt'
$labelval2.Location = '338, 232'
$labelval2.Margin = '4, 4, 4, 4'
$labelval2.Name = 'labelval2'
$labelval2.Size = '55, 18'
$labelval2.TabIndex = 7
$labelval2.Text = '0'
#
# labelkey2
#
$labelkey2.Anchor = 'Top'
$labelkey2.Font = 'Microsoft Sans Serif, 10pt'
$labelkey2.Location = '38, 232'
$labelkey2.Margin = '4, 4, 4, 4'
$labelkey2.Name = 'labelkey2'
$labelkey2.Size = '292, 18'
$labelkey2.TabIndex = 6
$labelkey2.Text = 'Example2'
#
# labelval1
#
$labelval1.Anchor = 'Top'
$labelval1.Font = 'Microsoft Sans Serif, 10pt'
$labelval1.Location = '338, 206'
$labelval1.Margin = '4, 4, 4, 4'
$labelval1.Name = 'labelval1'
$labelval1.Size = '55, 18'
$labelval1.TabIndex = 5
$labelval1.Text = '0'
#
# labelkey1
#
$labelkey1.Anchor = 'Top'
$labelkey1.Font = 'Microsoft Sans Serif, 10pt'
$labelkey1.Location = '38, 206'
$labelkey1.Margin = '4, 4, 4, 4'
$labelkey1.Name = 'labelkey1'
$labelkey1.Size = '292, 18'
$labelkey1.TabIndex = 4
$labelkey1.Text = 'Example1'
#
# labelTop5Results
#
$labelTop5Results.Anchor = 'Top'
$labelTop5Results.Font = 'Microsoft Sans Serif, 10pt'
$labelTop5Results.Location = '155, 181'
$labelTop5Results.Margin = '4, 4, 4, 4'
$labelTop5Results.Name = 'labelTop5Results'
$labelTop5Results.Size = '115, 26'
$labelTop5Results.TabIndex = 3
$labelTop5Results.Text = 'Top 5 results'
#
# labelExplanation
#
$labelExplanation.Anchor = 'Top'
$labelExplanation.AutoSize = $True
$labelExplanation.Location = '75, 119'
$labelExplanation.Margin = '4, 4, 4, 4'
$labelExplanation.MaximumSize = '300, 0'
$labelExplanation.Name = 'labelExplanation'
$labelExplanation.Size = '291, 34'
$labelExplanation.TabIndex = 2
$labelExplanation.Text = '*Uses regular expressions to only find words that match. This option is optional.'
$labelExplanation.UseWaitCursor = $True
#
# labelFilter
#
$labelFilter.Anchor = 'Top'
$labelFilter.Font = 'Microsoft Sans Serif, 10pt'
$labelFilter.Location = '59, 89'
$labelFilter.Margin = '4, 4, 4, 4'
$labelFilter.Name = 'labelFilter'
$labelFilter.Size = '57, 18'
$labelFilter.TabIndex = 1
$labelFilter.Text = 'Filter:'
#
# buttonOK
#
$buttonOK.Anchor = 'Bottom, Right'
$buttonOK.Location = '239, 344'
$buttonOK.Margin = '4, 4, 4, 4'
$buttonOK.Name = 'buttonOK'
$buttonOK.Size = '100, 30'
$buttonOK.TabIndex = 0
$buttonOK.Text = '&OK'
$buttonOK.UseVisualStyleBackColor = $True
$buttonOK.add_Click({
		if ($combobox.SelectedIndex -ne -1)
		{
			$global:comboboxval = $combobox.SelectedItem.ToString()
		}
		else
		{
			$global:comboboxval = ""
		}
		$count = $global:reportList.count
		$global:filterval = $Filter.Text
		if ($global:searchstate)
		{
			$count = $global:searchList.count
			$global:histogram = @{ }
			$global:histogram = generate-histogram -filter $global:filterval -field $global:comboboxval -array $global:searchList
		}
		else
		{
			$global:histogram = @{ }
			$global:histogram = generate-histogram -filter $global:filterval -field $global:comboboxval -array $global:reportList
		}
		if ($global:histogram -ne $null -and $global:histogram.count -ne 0)
		{
			$global:histogram = $global:histogram.getEnumerator() | Sort-Object -Property value -Descending
			
			for ($i = 0; $i -lt 5; $i++)
			{
				$key = $global:histogram[$i].name
				$value = $global:histogram[$i].value
				if ($i -eq 0)
				{
					$labelkey1.Text = $key
					$labelval1.Text = [System.Convert]::ToString([math]::Round($value * 100/$count,1)) + "%"
				}
				if ($i -eq 1)
				{
					$labelkey2.Text = $key
					$labelval2.Text = [System.Convert]::ToString([math]::Round($value * 100/$count, 1)) + "%"
				}
				if ($i -eq 2)
				{
					$labelkey3.Text = $key
					$labelval3.Text = [System.Convert]::ToString([math]::Round($value * 100/$count, 1)) + "%"
				}
				if ($i -eq 3)
				{
					$labelkey4.Text = $key
					$labelval4.Text = [System.Convert]::ToString([math]::Round($value * 100/$count, 1)) + "%"
				}
				if ($i -eq 4)
				{
					$labelkey5.Text = $key
					$labelval5.Text = [System.Convert]::ToString([math]::Round($value * 100/$count, 1)) + "%"
				}
			}
		}
		else
		{
			$labelval1.Text = '0'
			$labelval2.Text = '0'
			$labelval3.Text = '0'
			$labelval4.Text = '0'
			$labelval5.Text = '0'
			$labelkey1.Text = 'Example1'
			$labelkey2.Text = 'Example2'
			$labelkey3.Text = 'Example3'
			$labelkey4.Text = 'Example4'
			$labelkey5.Text = 'Example5'
		}
		
	})
#
# labelField
#
$labelField.Anchor = 'Top'
$labelField.Font = 'Microsoft Sans Serif, 10pt'
$labelField.Location = '59, 42'
$labelField.Margin = '4, 4, 4, 4'
$labelField.Name = 'labelField'
$labelField.Size = '57, 18'
$labelField.TabIndex = 0
$labelField.Text = 'Field:'
#
# combobox
#
$combobox.AutoCompleteMode = 'Suggest'
$combobox.Location = '124, 41'
$combobox.Margin = '4, 4, 4, 4'
$combobox.Name = 'combobox'
$combobox.Size = '226, 25'
$combobox.TabIndex = 0

$combobox.DropDownStyle =
[System.Windows.Forms.ComboBoxStyle]::DropDownList;
$combobox.items.add("Incident")
$combobox.items.add("Location")
$combobox.items.add("Reported")
$combobox.items.add("Occurred")
$combobox.SelectedIndex = 0
#
# Filter
#
$Filter.Anchor = 'Top'
$Filter.Location = '124, 88'
$Filter.Margin = '4, 4, 4, 4'
$Filter.Name = 'Filter'
$Filter.Size = '226, 23'
$Filter.TabIndex = 0

$formGenerateHistogram.add_Closing({
		$labelval1.Text = '0'
		$labelval2.Text = '0'
		$labelval3.Text = '0'
		$labelval4.Text = '0'
		$labelval5.Text = '0'
		$labelkey1.Text = 'Example1'
		$labelkey2.Text = 'Example2'
		$labelkey3.Text = 'Example3'
		$labelkey4.Text = 'Example4'
		$labelkey5.Text = 'Example5'
		$global:histogram = @{}
	})
#endregion


#Sample function that provides the location of the script
function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	[OutputType([string])]
	param ()
	if ($null -ne $hostinvocation)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

#Sample variable that provides the location of the script
[string]$global:ScriptDirectory = Get-ScriptDirectory