# S3 Bucket Tree Viewer
# Bucket: syntheacsvramaws
# Profile: synthea

$Bucket = "syntheacsvramaws"
$Profile = "synthea"

Write-Host ""
Write-Host "S3 Bucket: $Bucket" -ForegroundColor Cyan
Write-Host ""

# Retrieve all S3 object keys
$Keys = aws s3api list-objects-v2 `
    --bucket $Bucket `
    --profile $Profile `
    --query "Contents[].Key" `
    --output json | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to retrieve bucket contents." -ForegroundColor Red
    exit 1
}

if (-not $Keys) {
    Write-Host "(Bucket is empty)" -ForegroundColor Yellow
    exit 0
}

# Build a tree from the S3 keys
$Tree = @{}

foreach ($Key in $Keys) {
    $Parts = $Key -split "/"
    $Current = $Tree

    foreach ($Part in $Parts) {
        if ($Part -eq "") {
            continue
        }

        if (-not $Current.ContainsKey($Part)) {
            $Current[$Part] = @{}
        }

        $Current = $Current[$Part]
    }
}

function Show-Tree {
    param(
        [hashtable]$Node,
        [string]$Prefix = ""
    )

    $Names = @($Node.Keys | Sort-Object)

    for ($i = 0; $i -lt $Names.Count; $i++) {
        $Name = $Names[$i]
        $IsLast = ($i -eq $Names.Count - 1)

        if ($IsLast) {
            $Branch = "\--- "
            $NextPrefix = "$Prefix    "
        }
        else {
            $Branch = "+--- "
            $NextPrefix = "$Prefix|   "
        }

        if ($Node[$Name].Count -gt 0) {
            Write-Host "$Prefix$Branch$Name/" -ForegroundColor Cyan
            Show-Tree -Node $Node[$Name] -Prefix $NextPrefix
        }
        else {
            Write-Host "$Prefix$Branch$Name" -ForegroundColor White
        }
    }
}

Write-Host "$Bucket/" -ForegroundColor Green
Show-Tree -Node $Tree

Write-Host ""
Write-Host "Listing completed." -ForegroundColor Green
