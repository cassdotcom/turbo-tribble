
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")

#----------------------------------------------------------
# .section_SETUP
#----------------------------------------------------------
# Load from file
$settings = Import-Csv 'S:\TEST AREA\ac00418\reconversion\rev_i\settings\settings.csv'

# Assign
$headers = $settings | Where-Object { $_.TYPE -match 'HEADER' }
$fn_lib = $settings | Where-Object { $_.TYPE -match 'LIB' }

# Split into new objects
# functions
$f = New-Object psobject
foreach ( $fn in $fn_lib ) {
    
    Set-Alias $fn.SETTING $fn.VALUE

}

# headers
$h = New-Object psobject
foreach ( $s in $headers ) {

    Add-To-Object $h $s.SETTING $s.VALUE

}

# Modify console
Modify-GUI "Find Missing Models" $h

# .end_section_SETUP
#----------------------------------------------------------
#----------------------------------------------------------





#----------------------------------------------------------
# .section_GET-MODELS
#----------------------------------------------------------
$all_models = @()

# Get all missing FY1 model paths
$qry = "SELECT * FROM TESTCOPY WHERE FY1VALID = 'NO' "
$missing_fy1 = Query-DB $h.np_db $qry

 
if (!( $missing_fy1 -eq $null)) {

    
    foreach ( $m in $missing_fy1 ) {

        # Object container
        $this_model = New-Object psobject
        Add-To-Object $this_model "ID" $m.ID
        Add-To-Object $this_model "TITLE" $m.TITLE
        
        Write-Host "CURRENT MODEL: $($m.TITLE)"


        # Find the table entry for model
        $qry = "SELECT * FROM FY1MODELS WHERE FY1MODELS.ID = $($m.ID) "
        $fy1_details = Query-DB $h.np_db $qry



        if( ! ( $fy1_details -eq $null ) ) {

            $temp_folder = ($fy1_details.FOLDER)
            $backup_fy1 = $temp_folder -replace $h.four_three_path, $h.backup_drive            


            if ( Test-Path $backup_fy1 ) {
                
                # Backup folder does exist
                $result = Get-FileName $backup_fy1 ($($m.TITLE) + " BACKUP FY1")

                if ( $result.Length -eq 0 ) { 
                    
                    # CANCEL CONDITION - nothing found
                    # $result2 = Check-In-Folder $temp_folder ($m.TITLE + " ORIGINAL FY1")
                    $result2 = Get-FileName $temp_folder ($m.TITLE + " ORIGINAL FY1")

                    if ( $result2.Length -eq 0 ) {

                        # MISSING MODEL CONDITION
                        Add-To-Object $this_model "FY1MODEL" " "
                        Add-To-Object $this_model "FY1MODELNAME" " "
                        Add-To-Object $this_model "FY1VALID" "NO"
                    
                    } else {

                        # We now have original FY1, so copy to testspace
                        #$testspace_directory = (Split-Path $result2).replace($h.four_three_path, $h.new_path)
                        $testspace_directory = (Split-Path $result2) -replace $h.four_three_path, $h.new_path
                        $testspace_model_name = (Split-Path $result2 -Leaf)
                        if ( ! ( Test-Path $testspace_directory ) ) {New-Item $testspace_directory -ItemType Container}
                        Copy-Item $result2 -Destination $testspace_directory

                        Add-To-Object $this_model "FY1MODEL" ($testspace_directory + "\" + $testspace_model_name)
                        Add-To-Object $this_model "FY1MODELNAME" $testspace_model_name
                        Add-To-Object $this_model "FY1VALID" "YES"

                    }

                } else {

                    # GOT A MODEL - BACKUP COPY
                    #$testspace_directory = (Split-Path $result).replace($h.backup_path, $h.new_path)
                    $testspace_directory = (Split-Path $result) -replace $h.backup_path, $h.new_path
                    $testspace_model_name = (Split-Path $result -Leaf)
                    if ( ! ( Test-Path $testspace_directory ) ) {New-Item $testspace_directory -ItemType Container}
                    Copy-Item $result -Destination $testspace_directory

                    Add-To-Object $this_model "FY1MODEL" ($testspace_directory + "\" + $testspace_model_name)
                    Add-To-Object $this_model "FY1MODELNAME" $testspace_model_name
                    Add-To-Object $this_model "FY1VALID" "YES"
                
                }

            } else {
            
                # BACKUP FOLDER DOESN'T EXIST - go up a level and find
                $uplevel = Split-Path $backup_fy1
                $result = Get-FileName $uplevel ($m.TITLE + " BACKUP FY1")
                
                if ( $result.Length -eq 0 ) {

                    # CANCEL CONDITION - nothing found
                    $result2 = Get-FileName $temp_folder ($m.TITLE + " ORIGINAL FY1")
                    
                    if ( $result2.Length -eq 0 ) {

                        # MISSING MODEL CONDITION
                        Add-To-Object $this_model "FY1MODEL" " "
                        Add-To-Object $this_model "FY1MODELNAME" " "
                        Add-To-Object $this_model "FY1VALID" "NO"
                    
                    } else {

                        # We now have original FY1, so copy to testspace
                        #$testspace_directory = (Split-Path $result2).replace($h.four_three_path, $h.new_path)
                        $testspace_directory = (Split-Path $result2) -replace $h.four_three_path, $h.new_path
                        $testspace_model_name = (Split-Path $result2 -Leaf)
                        if ( ! ( Test-Path $testspace_directory ) ) {New-Item $testspace_directory -ItemType Container}
                        Copy-Item $result2 -Destination $testspace_directory

                        Add-To-Object $this_model "FY1MODEL" ($testspace_directory + "\" + $testspace_model_name)
                        Add-To-Object $this_model "FY1MODELNAME" $testspace_model_name
                        Add-To-Object $this_model "FY1VALID" "YES"

                    }

                } else {

                    # FOUND BACKUP
                    #$testspace_directory = (Split-Path $result).replace($h.backup_path, $h.new_path)
                    $testspace_directory = (Split-Path $result) -replace $h.backup_path, $h.new_path
                    $testspace_model_name = (Split-Path $result -Leaf)
                    if ( ! ( Test-Path $testspace_directory ) ) { New-Item $testspace_directory -ItemType Container }
                    Copy-Item $result -Destination $testspace_directory

                    Add-To-Object $this_model "FY1MODEL" ($testspace_directory + "\" + $testspace_model_name)
                    Add-To-Object $this_model "FY1MODELNAME" $testspace_model_name
                    Add-To-Object $this_model "FY1VALID" "YES"

                }

            }

        } else {

            # NOTHING RETURNED
            Write-Host "FY1MODELS QUERY FAILED"
            break

        }

        $all_models += $this_model

    }

} else {

    Write-Host "TESTCOPY QUERY FAILED"
    break

}

$all_models | Export-Csv $h.output_file -NoTypeInformation     
           
