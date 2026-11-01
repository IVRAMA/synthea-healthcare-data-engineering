$Bucket = "syntheacsvramaws"
$Profile = "synthea"

$Folders = @(
    "config/",
    "Gitrepo/synthea-healthcare-data-engineering/sql_scripts/csv_scripts/",
    "Gitrepo/synthea-healthcare-data-engineering/sql_scripts/json_scripts/",
    "csv_data/",
    "json_data/",
    "logs/",
    "logs/csv_logs/",
    "logs/json_logs/"
)

foreach ($Folder in $Folders) {
    aws s3api put-object `
        --bucket $Bucket `
        --key $Folder `
        --profile $Profile

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to create $Folder" -ForegroundColor Red
        exit 1
    }

    Write-Host "Created: $Folder" -ForegroundColor Green
}