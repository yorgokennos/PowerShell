$logPath = "XXXXXXX\Logs"
$searchString = "Required Updates are Available"

# Initialize an array to hold the resultsArr
$resultsArr = @()

# Get all .txt files
$txtFiles = Get-ChildItem -Path $logPath -Filter *.txt

Write-Output "Searching through each file...Please hold..."

# Loop through each file and search for the string
foreach ($file in $txtFiles) {
    $filePath = $file.FullName
    $fileContent = Get-Content -Path $filePath

    if ($fileContent -match $searchString) {
        # If the string is found, add the file name to the resultsArr
        $resultsArr += [PSCustomObject]@{
            FileName = $file.Name
            FilePath = $filePath
        }
    }
}

# Define the path for the CSV output
$outputCsvPath = "C:\temp\RequiredUpdatesFiles.csv"

# Export the resultsArrArr to a CSV file
$resultsArr | Export-Csv -Path $outputCsvPath -NoTypeInformation

Write-Output "CSV file has been created at $outputCsvPath"
