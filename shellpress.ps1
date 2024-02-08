function Copy-ToFtp {
    param(
        [string]$ftpServer,  
        [string]$ftpUser,    
        [string]$ftpPassword, 
        [string]$localPath,  
        [string]$remotePath    
    )
    
    $ftp = "ftp://$ftpServer/$remotePath" 
    $webclient = New-Object System.Net.WebClient   
    $webclient.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPassword) 
    $Files = Get-ChildItem -Path $localPath 
    foreach ($file in $Files) {
        $uri = New-Object System.Uri($ftp + $file.Name)
        $webclient.UploadFile($uri, $file.FullName) 
    }
}
function Publish-Portal {
    param(
        [switch]$Statistics, 
        [string]$Destination, 
        [string[]]$FileNames  
    )

    $outputDirectory = Join-Path (Get-Location) "site" 
    if (-not (Test-Path $outputDirectory)) {
        New-Item -ItemType Directory -Path $outputDirectory 
    }

    # Loading Markdown files
    if ($FileNames.Count -eq 0) { 
        $Files = (Get-ChildItem -Path "." | where {$_.Extension -in ".markdown", ".md"})
    }
    else {
        $Files = $FileNames | ForEach-Object { Get-ChildItem -Path $_ } 
    }

    # generating HTML files from Markdown
    foreach ($file in $Files) {
        $htmlFile = [IO.Path]::ChangeExtension($file.Name, ".html") # changing .markdown to .html
        $outputPath = Join-Path $outputDirectory $htmlFile 
        $content = Get-Content $file.FullName 
        $content | Write-Output
        $titleLine = $content | Select-String '^# .+' -AllMatches | Select-Object -First 1 
        $title = if ($titleLine) { $titleLine.Matches.Value.TrimStart('#').Trim() } else { "Default headline" } 
        pandoc -f markdown -t html5 -s $file.FullName --metadata title="$title" -o $outputPath
    }

    # Creating an index page
    $indexContent = "<h1>Index of articles</h1><ul>"  
    foreach ($file in $Files) {
        $htmlFile = [IO.Path]::ChangeExtension($file.Name, ".html")
        $content = Get-Content $file.FullName 
        $title = $content | Select-String '^# .+' -AllMatches | Select-Object -First 1 | % { $_.Matches } | % { $_.Value.TrimStart('#').Trim() } 
        $timeOfLastModification = $file.LastWriteTime.ToString("g") 
        $indexContent += "<li><a href='./$htmlFile'>$title</a></li> -  Time of last madification: $timeOfLastModification</li>" 
    }
    $indexContent += "</ul>" 
    Set-Content -Path (Join-Path $outputDirectory "index.html") -Value $indexContent 

   
    if ($Statistics) {
        $totalWords = 0 
        foreach ($file in $Files) {
            $words = (Get-Content $file.FullName | Measure-Object -Word).Words 
            $totalWords += $words
        }
        $statsContent = "<h1>Statistics</h1><p>Count of articles: $($Files.Count)</p><p>Count of words: $totalWords</p>" 
        Set-Content -Path (Join-Path $outputDirectory "stats.html") -Value $statsContent 
    }

    # Use Copy-ToFtp to upload to an FTP server if a destination is specified
    if ($Destination) {
        Copy-ToFtp -ftpServer "your_ftp_server" -ftpUser "your_user" -ftpPassword "your_password" -localPath $outputDirectory -remotePath "target_directory_on_server"
    }
}
