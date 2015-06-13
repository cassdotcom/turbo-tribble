
# Load headers
$h = .\headers.ps1

# Load function library
.($h.function_library)




$all_models = @()

$qry = "SELECT * FROM TESTCOPY WHERE FY1VALID = 'NO' "
$missing_fy1 = query-db $np_db $qry
    
if (!( $missing_fy1 -eq $null)) {

    foreach ( $m in $missing_fy1 ) {

        $this_model = New-Object psobject
        add-to-object $this_model "ID" $m.ID
        add-to-object $this_model "TITLE" $m.TITLE

        $qry = "SELECT * FROM FY1MODELS WHERE FY1MODELS.ID = $($m.ID) "
        $fy1_details = query-db $np_db $qry

        if( ! ( $fy1_details -eq $null ) ) {

            $temp_folder = ($fy1_details.FOLDER)
            $backup_fy1 = $temp_folder -replace $four_three_path, $backup_drive
            

            if ( Test-Path $backup_fy1 ) {
                
                $result = Get-FileName $backup_fy1 ($m.TITLE + " BACKUP FY1")

                if ( $result.Length -eq 0 ) { 
                    
                    # CANCEL CONDITION - nothing found
                    $result2 = Get-FileName $temp_folder ($m.TITLE + " ORIGINAL FY1")

                    if ( $result2.Length -eq 0 ) {

                        # MISSING MODEL CONDITION
                        add-to-object $this_model "FY1MODEL" " "
                        add-to-object $this_model "FY1MODELNAME" " "
                        add-to-object $this_model "FY1VALID" "NO"
                    
                    } else {

                        # We now have original FY1, so copy to testspace
                        #$testspace_directory = (Split-Path $result2).replace($four_three_path, $new_path)
                        $testspace_directory = (Split-Path $result2) -replace $four_three_path, $new_path
                        $testspace_model_name = (Split-Path $result2 -Leaf)
                        if ( ! ( Test-Path $testspace_directory ) ) {New-Item $testspace_directory -ItemType Container}
                        Copy-Item $result2 -Destination $testspace_directory

                        add-to-object $this_model "FY1MODEL" ($testspace_directory + "\" + $testspace_model_name)
                        add-to-object $this_model "FY1MODELNAME" $testspace_model_name
                        add-to-object $this_model "FY1VALID" "YES"

                    }

                } else {

                    # GOT A MODEL - BACKUP COPY
                    #$testspace_directory = (Split-Path $result).replace($backup_path, $new_path)
                    $testspace_directory = (Split-Path $result) -replace $backup_path, $new_path
                    $testspace_model_name = (Split-Path $result -Leaf)
                    if ( ! ( Test-Path $testspace_directory ) ) {New-Item $testspace_directory -ItemType Container}
                    Copy-Item $result -Destination $testspace_directory

                    add-to-object $this_model "FY1MODEL" ($testspace_directory + "\" + $testspace_model_name)
                    add-to-object $this_model "FY1MODELNAME" $testspace_model_name
                    add-to-object $this_model "FY1VALID" "YES"
                
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
                        add-to-object $this_model "FY1MODEL" " "
                        add-to-object $this_model "FY1MODELNAME" " "
                        add-to-object $this_model "FY1VALID" "NO"
                    
                    } else {

                        # We now have original FY1, so copy to testspace
                        #$testspace_directory = (Split-Path $result2).replace($four_three_path, $new_path)
                        $testspace_directory = (Split-Path $result2) -replace $four_three_path, $new_path
                        $testspace_model_name = (Split-Path $result2 -Leaf)
                        if ( ! ( Test-Path $testspace_directory ) ) {New-Item $testspace_directory -ItemType Container}
                        Copy-Item $result2 -Destination $testspace_directory

                        add-to-object $this_model "FY1MODEL" ($testspace_directory + "\" + $testspace_model_name)
                        add-to-object $this_model "FY1MODELNAME" $testspace_model_name
                        add-to-object $this_model "FY1VALID" "YES"

                    }

                } else {

                    # FOUND BACKUP
                    #$testspace_directory = (Split-Path $result).replace($backup_path, $new_path)
                    $testspace_directory = (Split-Path $result) -replace $backup_path, $new_path
                    $testspace_model_name = (Split-Path $result -Leaf)
                    if ( ! ( Test-Path $testspace_directory ) ) { New-Item $testspace_directory -ItemType Container }
                    Copy-Item $result -Destination $testspace_directory

                    add-to-object $this_model "FY1MODEL" ($testspace_directory + "\" + $testspace_model_name)
                    add-to-object $this_model "FY1MODELNAME" $testspace_model_name
                    add-to-object $this_model "FY1VALID" "YES"

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


$all_models | Export-Csv $output_file -NoTypeInformation                    
