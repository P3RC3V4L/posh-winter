$iteration = 1

function Build-OmpTheme 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [String] $Theme,
        [Parameter(Mandatory)]
        [String] $Variant,
        [String] $Root = $env:POSH_THEMES_PATH
    )

    Write-Host("Building theme: $Theme-$Variant...")

    $resultTheme = "$Theme-$Variant.omp.json"
    $resultTheme = Join-Path $Root $resultTheme 

    $themeFolder = Join-Path $Root 'omp.templates' $Theme
    $themeTemplate = Join-Path $themeFolder "$Theme.omp.template"

    $variantFolder = Join-Path $themeFolder $Variant

    $tempFile = Join-Path $themeFolder "$Theme.omp.build"
    if (Test-Path $tempFile)
    {
        Remove-Item $tempFile
    }
    Copy-Item $themeTemplate $tempFile

    Write-Verbose("theme   = $themeTemplate")
    Write-Verbose("variant = $variantFolder")
    Write-Verbose("temp    = $tempFile")
    Write-Verbose("result  = $resultTheme")
    
    $replaceCount = Merge-Template $tempFile $variantFolder
    Write-Verbose("Theme compiled using $replaceCount chunks.")

    Write-Host('Finalizing theme:')
    Move-Item $tempFile $resultTheme -Force

    return $resultTheme
}

function Merge-Template 
{
    param 
    (
        [Parameter(Mandatory)]
        [String] $ThemeTemplate,
        [Parameter(Mandatory)]
        [String] $VariantFolder
    )
    $replaced = Join-Content $ThemeTemplate $VariantFolder
    $replaceCount = $replaced.count

    if ($replaceCount -gt 0) 
    {
        $msg  = "$iteration. Iteration | Replacing:" + [Environment]::NewLine
        $msg += $replaced -Join [Environment]::NewLine
        Write-Verbose($msg)
        $iteration++
        $replaceCount += Merge-Template $ThemeTemplate $VariantFolder
    }
    return $replaceCount
}

function Join-Content 
{
    param (
        [Parameter(Mandatory)]
        [String] $ThemeTemplate,
        [Parameter(Mandatory)]
        [String] $VariantFolder
    )

    $replaced = @()
    $data = Get-Content $ThemeTemplate -Raw
    $allmatches = [regex]::Matches($data, '(?<spaces>[ \t]*)<<(?<fname>[^<>]+)>>')
    foreach ($match in $allmatches) 
    {
        $fname = $match.Groups['fname'].Value
        $fpath = Join-Path $VariantFolder $fname
        $spaces = $match.Groups['spaces'].Value
        $inject = Get-Content $fpath -Raw
        $find = "$spaces<<$fname>>"
        $data = $data.Replace($find, $inject)
        $replaced += "             $fname"
    }
    Set-Content $ThemeTemplate $data
    return $replaced
}

Export-ModuleMember -Function Build-OmpTheme