Function convertpdf{
    [CmdletBinding(DefaultParameterSetName='ByUserName')]
    param(
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
        [string]$link,
        [Parameter (
            mandatory=$True,
            valueFromPipeline=$True,
            valueFromPipelineByPropertyName=$True)]
        [string]$path
    )
    $txtname=$link -split "/"
    $txtname=$txtname[$txtname.length-1]
    Write-Verbose "Extracted file name $txtname"
    $txtname=$txtname -replace ".pdf",".txt"
    Write-Verbose "File name converted to $txtname"
    $site= Invoke-WebRequest http://document.online-convert.com/convert-to-txt -SessionVariable sesh 
    $Form=$site.Forms[1]
    $Form.Fields["external_url"]=$link
    try{
    $site= Invoke-WebRequest $form.Action -WebSession $sesh -Body $Form -Method Post
    }
    catch{
        Write-Error "Error has occured at Invoke-WebRequest Post Method: $_"
        return
    }
    $downloadlink= $site.links[25].href 
    $success=1
    Write-Verbose "Attempting to pull .txt from $downloadlink"
    $WebClient = New-Object System.Net.WebClient
    $month=$txtname.substring(0,2)
    $year=$txtname.substring(4,2)
    while($success -eq 1){
        try{
            Start-sleep -Seconds 5   
            $WebClient.DownloadFile("$downloadlink","$path\dpsreports\20$year\$month\$txtname")
        }
        catch{
            Write-Verbose "No server response from server."
            Write-Verbose "Trying again."
            continue
        }
       
        Write-output "Successfully created $txtname"
        $success=0
    }
   
    
}