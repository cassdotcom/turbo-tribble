
$h = New-Object psobject

# 
$h | Add-Member -MemberType NoteProperty -Name four_three_path -Value '\\\\scotia.sgngroup.net\\dfs\\shared\\Syn4.2.3'
$h | Add-Member -MemberType NoteProperty -Name backup_path -Value '\\\\shdwz500\\restore\$'
$h | Add-Member -MemberType NoteProperty -Name backup_drive -Value '\\shdwz500\restore$'
$h | Add-Member -MemberType NoteProperty -Name new_path -Value '\\vpoct502\Synergee-testspace'

$h | Add-Member -MemberType NoteProperty -Name fn_lib -Value "S:\TEST AREA\ac00418\reconversion\rev_i\scripts\function_library.ps1"
$h | Add-Member -MemberType NoteProperty -Name output_file -Value "S:\TEST AREA\ac00418\reconversion\rev_i\output\ultimate-find-models.txt"
$h | Add-Member -MemberType NoteProperty -Name np_db -Value "S:\TEST AREA\scripting\model_db\ModelDatabase.MDB"


#$h | Add-Member -MemberType NoteProperty -Name function_library -Value "C:\Users\ac00418\Documents\turbo-tribble\function-library.ps1"

#$h | Add-M


return $h
