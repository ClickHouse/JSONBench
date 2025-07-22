Write-Host "Select the dataset size to download:"
Write-Host "1) 1m (default)"
Write-Host "2) 10m"
Write-Host "3) 100m"
Write-Host "4) 1000m"
$choice = Read-Host "Enter the number corresponding to your choice"

$baseUrl = "https://clickhouse-public-datasets.s3.amazonaws.com/bluesky"
$destination = "C:\bluesky"

# Ensure destination directory exists
New-Item -ItemType Directory -Force -Path $destination | Out-Null

switch ($choice) {
    "2" {
        1..10 | ForEach-Object {
            $url = "$baseUrl/file_{0:D4}.json.gz" -f $_
            Invoke-WebRequest -Uri $url -OutFile (Join-Path $destination ("file_{0:D4}.json.gz" -f $_)) -UseBasicParsing
        }
    }
    "3" {
        1..100 | ForEach-Object {
            $url = "$baseUrl/file_{0:D4}.json.gz" -f $_
            Invoke-WebRequest -Uri $url -OutFile (Join-Path $destination ("file_{0:D4}.json.gz" -f $_)) -UseBasicParsing
        }
    }
    "4" {
        1..1000 | ForEach-Object {
            $url = "$baseUrl/file_{0:D4}.json.gz" -f $_
            Invoke-WebRequest -Uri $url -OutFile (Join-Path $destination ("file_{0:D4}.json.gz" -f $_)) -UseBasicParsing
        }
    }
    default {
        $url = "$baseUrl/file_0001.json.gz"
        Invoke-WebRequest -Uri $url -OutFile (Join-Path $destination "file_0001.json.gz") -UseBasicParsing
    }
}
