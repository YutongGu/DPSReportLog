Function generateFrequencyTable{
    [CmdletBinding(DefaultParameterSetName='ByUserName')]
    param(
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
         [System.Collections.ArrayList] $inputArray,
         [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
         [string] $field,
         [string] $outfile 
        
    )
    $table=@{}
    if($inputArray[0].keys -contains $field){
        foreach($case in $inputArray.$field){
            
            if ($table.keys -contains $case){
                $table[$case]+=1
            }
            else {
                $table[$case]=1  
            }
        }
    }
    else{
        Write-Error "Report does not contain such field"
    }
    if($outfile){
        if(-not (Test-Path $outfile)){
            try{
                if($outfile -like "*.csv"){
                    $table.GetEnumerator() | sort-object name | export-csv $outfile
                }
                else{
                     Write-Error "File must be in .csv format"
                }
            }
            catch{
                Write-Error $_.Exception.message
            }
        }
        else {
            Write-Error "File already exists"
        }
    }

    return $table
}