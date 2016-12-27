function Check-Reports{
    [CmdletBinding(DefaultParameterSetName='ByUserName')]
    param(
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
        [System.Collections.ArrayList]$array,
        [switch] $removeDuplicates
    )
    [System.collections.arraylist]$missingreports = new-object System.Collections.ArrayList
    [System.collections.arraylist]$repeatedreports = new-object System.Collections.ArrayList
    [System.Collections.ArrayList]$errors= new-object System.Collections.ArrayList
    $reportnumbers=@()
    $filteredReportNumbers=@()
    $lastvalidindex=0

    
    for ($i=0; $i -lt $array.count; $i++){
        $value=$array[$i]."Report #"
        if($value -match "\w"){
            $reportnumbers+=$value
        }
    }
    #$reportnumbers.count
    $reportnumbers = $reportnumbers |sort-object

    for ($i=0; $i -lt $reportnumbers.count; $i++){
        $value=$reportnumbers[$i]
        if($value -eq $reportnumbers[$i+1]){
            if($repeatedreports -notcontains $value){
                
                #write-output "added repeat "$value
                
                [void]$repeatedreports.add($value)
            }
        }
        else{
            $filteredReportNumbers+=$value
        }
    }
    #$filteredReportNumbers.count
    [int]$start=$filteredReportNumbers[0]
    [int]$end=$filteredReportNumbers[$filteredReportNumbers.count-1]
    $counter=0
    for($i=$start; $i -lt $end; $i++){
        
        $value= $filteredReportNumbers[$counter]
        if($value-$filteredReportNumbers[$counter-1] -gt 1000){
            $i=[int]$value
        }
        #write-output $i"-"$value
        if($i -eq $value){
            $counter++
        }
        else{
            #write-output "added missing "$i
            [void]$missingreports.add($i)
        }
    }
    [void]$errors.add($missingReports)
    [void]$errors.add($repeatedReports)

    if($removeDuplicates){
        $currentval="";
        for($i=0; $i -lt $array.count; $i++){
    
            $currentval=$array[$i]."Report #"
            if($errors[1] -contains $currentval){
                $errors[1].remove($currentval)
                $array.RemoveAt($i)
                $i--
        
            }
        }
    }
    return $errors

}