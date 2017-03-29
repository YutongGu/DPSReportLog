Function apicall{
    [CmdletBinding(DefaultParameterSetName='ByUserName')]
        param(
            [Parameter (
                mandatory=$True,
                valueFromPipeline=$True,
                valueFromPipelineByPropertyName=$True)]
            [string]$link,
            [Alias("projectpath")]
            [Parameter (
                mandatory=$True,
                valueFromPipeline=$True,
                valueFromPipelineByPropertyName=$True)]
            [string]$path,
            [switch]$quiet
        )
    $txtname=$link -split "/"
    $txtname=$txtname[$txtname.length-1]
    Write-Verbose "Extracted file name $txtname"
    $txtname=$txtname -replace ".pdf",".txt"
    Write-Verbose "File name converted to $txtname"
    $month=$txtname.substring(0,2)
    $year=$txtname.substring(4,2)
    $source= "`"$link`""
    $headers = @{"X-Oc-Api-Key"= "3a9d100d4a97d32823adec8077507055"; "Content-Type"= "application/json"}
    $json = "{
        `"input`": [{
            `"type`": `"remote`",
            `"source`": $source
        }],
        `"conversion`": [{
            `"target`": `"txt`",
            `"options`": {
                `"ocr`": true,
                `"language`": `"eng`"
            }
        }]
    }"
    $body= convertfrom-json $json
    try{
        $response = Invoke-WebRequest -Uri https://api2.online-convert.com/jobs -headers $headers -Body $json -Method Post
    }
    catch{
        Write-Error $_.exception.message
        return
    }
    $body = convertfrom-json $response.Content
    $id = $body.id
    write-verbose "Job ID is $id"
    while($code -ne "completed"){
        $response = Invoke-WebRequest -Uri https://api2.online-convert.com/jobs/$id -headers $headers -Method Get
        $body = convertfrom-json $response.Content
        $code= $body.status.code
        start-sleep -seconds 2
        write-verbose "Waiting for completion... Status code: $code"
    }

    $uri = $body.output.uri
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($uri,"$path\dpsreports\20$year\$month\$txtname")
    write-verbose "Downloaded file to $path\dpsreports\20$year\$month\$txtname"
    if(-not $quiet){
        return "$path\dpsreports\20$year\$month\$txtname"
    }
}    