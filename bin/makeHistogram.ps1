function generate-histogram ($filter, $field, $array){
    $histogram = @{}
    foreach($report in $array){
    
        $incident = $report.$field
        if($field -eq "Reported" -or $field -eq "Occurred"){
            $incident = $incident.split(" -")
        }
        else{
            $incident = $incident.split(" ")
        }
        $string = ""
        foreach ($word in $incident){
            if($word -cmatch $filter){
                $string += $word + " "
				if ($field -eq "Occurred") { break }
			}
		} #>
        #$string = $report.location
        if($histogram.Keys -contains $string){
            $histogram.$string++
        }
        else{
            $histogram.$string = 1
        }
    }
    return $histogram
}