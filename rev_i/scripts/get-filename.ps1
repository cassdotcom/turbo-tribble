Param(
	[Parameter(Position = 0, Mandatory = $true)]
	[System.String]
	$initialDirectory,
	[Parameter(Position = 1, Mandatory = $false)]
	[System.String]
	$title="Select File...."
) 
	
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.title = $title
$OpenFileDialog.filter = "Synergee Models (*.MDB)| *.MDB"
$OpenFileDialog.ShowDialog() | Out-Null
$OpenFileDialog.
$OpenFileDialog.filename
