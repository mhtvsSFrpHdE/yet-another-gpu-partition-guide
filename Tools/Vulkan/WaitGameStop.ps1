param($GameFileNameWithoutExtension)

while($true){
    try
    {
        (Get-Process "$GameFileNameWithoutExtension" -ErrorAction Stop) | Wait-Process
        break
    }
    catch
    {
        #Write-Host "Process not found, still waiting..."
        Start-Sleep -Milliseconds 500
    }
}
