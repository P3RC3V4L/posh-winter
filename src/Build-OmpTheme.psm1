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

    Write-Host("building...")

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

    if ($Verbose)
    {
        Write-Host("theme: $themeTemplate")
        Write-Host("variant: $variantFolder")
        Write-Host("temp: $tempFile")
        Write-Host("result: $resultFile")
    }
    Merge-Template $tempFile $variantFolder

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

    $replaceCount = Join-Content $ThemeTemplate $VariantFolder

    if ($replaceCount -gt 0) 
    {
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

    $replaceCount = 0
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
        $replaceCount++
    }
    Set-Content $ThemeTemplate $data
    return $replaceCount
}

Export-ModuleMember -Function Build-OmpTheme