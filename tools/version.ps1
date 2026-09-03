#!/usr/bin/env powershell

param (
  [Parameter(Position = 0, Mandatory = $false)]
  [string]$BuildRoot = $null,
  [Parameter(Position = 1, Mandatory = $false)]
  [string]$SourceRoot = $null
)

$lastSvnRevision = 6962
$lastSvnHash = '16cd907fe7482cb54a7374cd28b8501f138116be'
$defineNumberMatch = [regex] '^#define\s+(\w+)\s+(\d+)$'
$defineStringMatch = [regex] "^#define\s+(\w+)\s+[`"']?(.+?)[`"']?$"
$semVerMatch = [regex] 'v?(\d+)\.(\d+).(\d+)(?:-(\w+))?'

$repositoryRootPath = Join-Path $PSScriptRoot .. | Resolve-Path
if (!(git -C $repositoryRootPath rev-parse --is-inside-work-tree 2>$null)) {
  throw "$repositoryRootPath is not a git repository"
}

if ($BuildRoot -eq $null -or $BuildRoot.Trim() -eq "")  {
  $BuildRoot = $repositoryRootPath
}

# support legacy in-tree builds
if ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine((pwd).Path, $BuildRoot)) -eq
  [System.IO.Path]::GetFullPath([System.IO.Path]::Combine((pwd).Path, $repositoryRootPath))) {
    $BuildRoot = Join-Path $repositoryRootPath 'build'
  }
$gitVersionHeaderPath = Join-Path $BuildRoot 'git_version.h'

$version = @{}
if (Test-Path $gitVersionHeaderPath) {
  Get-Content $gitVersionHeaderPath | %{$_.Trim()} | ?{$_} | %{
    switch -regex ($_) {
      $defineNumberMatch {
        $version[$Matches[1]] = [int]$Matches[2];
      }
      $defineStringMatch {
        $version[$Matches[1]] = $Matches[2];
      }
    }
  }
}

# Semver scheme (mirrors tools/version.sh):
#   tagged release:    v3.5.0
#   N commits after:   v3.5.0-N
# The counter is the number of commits since the most recent vX.Y.Z tag;
# any new semver tag resets the counter to 0 and the -0 suffix is dropped
# so the very next commit on top of a fresh tag is "v3.5.0" instead of
# "v3.5.0-0". If no semver tag exists yet, fall back to the original
# SVN baseline so the very first release still has a real-looking number.
$latestSemverTag = $null
foreach ($rev in (git -C $repositoryRootPath rev-list --tags 2>$null)) {
  $tag = git -C $repositoryRootPath describe --exact-match --tags $rev 2>$null
  if ($tag -match 'v(\d+)\.(\d+)\.(\d+)$') {
    $latestSemverTag = $tag
    break
  }
}

if ($latestSemverTag -and (git -C $repositoryRootPath cat-file -t $latestSemverTag 2>$null) -eq 'commit') {
  $gitRevision = (git -C $repositoryRootPath rev-list --count "$($latestSemverTag)..HEAD" 2>$null)
} elseif ((git -C $repositoryRootPath cat-file -t $lastSvnHash 2>$null) -eq 'commit') {
  $gitRevision = $lastSvnRevision + ((git -C $repositoryRootPath log --pretty=oneline "$($lastSvnHash)..HEAD" 2>$null | Measure-Object).Count)
} else {
  $gitRevision = 0
}

$gitBranch = git -C $repositoryRootPath symbolic-ref --short HEAD 2>$null
$gitHash = git -C $repositoryRootPath rev-parse --short HEAD 2>$null
$exactGitTag = git -C $repositoryRootPath describe --exact-match --tags 2>$null

if ($exactGitTag -match $semVerMatch) {
  $version['TAGGED_RELEASE'] = $true
  $version['RESOURCE_BASE_VERSION'] = $Matches[1..3]
  $joinedVersion = $Matches[1..3] -join '.'
  $version['INSTALLER_VERSION'] = $joinedVersion
  $gitVersionString = $joinedVersion
  $gitVersionShort = $joinedVersion
} else {
  $version['TAGGED_RELEASE'] = $false
  if ($latestSemverTag -match $semVerMatch) {
    $version['RESOURCE_BASE_VERSION'] = $Matches[1..3]
    $version['INSTALLER_VERSION'] = ($Matches[1..3] -join '.')
    $baseVersion = ($Matches[1..3] -join '.')
  } else {
    # No semver tags yet; fall back to the project version (set in
    # meson.build) so the installer name is always a real semver triple
    # instead of the meaningless 0.0.0 placeholder.
    $version['RESOURCE_BASE_VERSION'] = @(3, 5, 0)
    $version['INSTALLER_VERSION'] = '3.5.0'
    $baseVersion = '3.5.0'
  }
  if ($gitRevision -eq 0) {
    $gitVersionShort = $baseVersion
  } else {
    $gitVersionShort = "$baseVersion-$gitRevision"
  }
  $gitVersionString = "$gitVersionShort-$gitBranch-$gitHash"
}

$version['BUILD_GIT_VERSION_NUMBER'] = $gitRevision
$version['BUILD_GIT_VERSION_STRING'] = $gitVersionString
$version['BUILD_GIT_VERSION_SHORT'] = $gitVersionShort

if ($gitVersionString -eq $version['BUILD_GIT_VERSION_STRING'] -and (Test-Path $gitVersionHeaderPath)) {
  # If nothing about the version changed we still need to check whether
  # BUILD_GIT_VERSION_SHORT was already written.
  if ((Select-String -Path $gitVersionHeaderPath -Pattern 'BUILD_GIT_VERSION_SHORT' -Quiet)) {
    exit 0
  }
}

$version.GetEnumerator() | %{
  $type = $_.Value.GetType()
  $value = $_.Value
  $fmtValue = switch ($type) {
    ([string]) {"`"$value`""}
    ([int]) {$value.ToString()}
    ([bool]) {([int]$value).ToString()}
    ([object[]]) {$value -join ', '}
    default {
      Write-Host "no format known for type '$type' - trying default string conversion" -ForegroundColor Red
      {"`"$($value.ToString())`""}
    }
  }
  "`n#define $($_.Key) $($fmtValue)"
} | Out-File -FilePath $gitVersionHeaderPath -Encoding utf8
