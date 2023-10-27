#! env pwsh
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$in,
    [Parameter(Mandatory = $true)]
    [string]$out
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$alerts = Get-Content $in | ConvertFrom-Json | Where-Object { ( $_.security_vulnerability.severity -eq "high" -or $_.security_vulnerability.severity -eq "critical" ) }

$list = [System.Collections.Generic.List[object]]::new()

# Add header When there are any ciritical or high vulnerabilities
if ($list.Count -gt 0) {
    $list.Add("| Severity | Description |")
    $list.Add("|---|---|")

    # loop over alerts
    $alerts | ForEach-Object {
        $severity = $_.security_vulnerability.severity
        $summary = $_.security_advisory.summary
        $link = $_.html_url
        $list.Add("| $severity | [$summary]($link) |")
    }
} else {
    $list.Add("No dependabot alerts found.")
}

$list | Out-String | Out-File -FilePath $out -Encoding utf8
