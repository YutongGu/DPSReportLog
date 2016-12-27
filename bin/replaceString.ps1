$searchstring = "\|"
$newstring= "/"
$field = "Occurred"
foreach($case in $reportList){
    if($case.$field -match $searchstring){
        $case.$field
        #$case.$field = $case.$field -replace $searchstring,$newstring
    }
}