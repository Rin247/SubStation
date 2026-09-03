#!/usr/bin/env powershell

param (
  [Parameter(Position = 0, Mandatory = $false)]
  [string]$BuildRoot = $null,
  [Parameter(Position = 1, Mandatory = $false)]
  [string]$SourceRoot = $null
)

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

# SubStation version scheme (fresh start, no carryover from the old SVN
# revision count):
#   tagged release:    v1.0.0, v1.0.1, v1.1.0, ...
#   N commits after:   v1.0.0-1, v1.0.0-2, ...
#
# The counter is the number of commits since the most recent vX.Y.Z tag.
# The very first tagged release of SubStation (e.g. v1.0.0) is the only one
# without a counter; subsequent commits become v1.0.0-1, v1.0.0-2, etc.
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
  $baseVersion = $latestSemverTag.Substring(1)  # strip the 'v'
} else {
  # No semver tags yet. SubStation is a fresh product; the first tagged
  # release will be v1.0.0. Until then, brand untagged builds as 1.0.0 too,
  # and use 0 as the commit counter so the very first release doesn't get
  # a -0 suffix.
  $baseVersion = '1.0.0'
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
  $version['RESOURCE_BASE_VERSION'] = $baseVersion.Split('.')
  $version['INSTALLER_VERSION'] = $baseVersion
  if ($gitRevision -eq 0) {
    $gitVersionShort = $baseVersion
  } else {
    $gitVersionShort = "$baseVersion-$gitRevision"
  }
  if ($gitRevision -eq 0) {
    $gitVersionString = $baseVersion
  } else {
    $gitVersionString = $gitVersionShort
    if ($gitBranch -and $gitHash) {
      $gitVersionString = "$gitVersionString-$gitBranch-$gitHash"
    }
  }
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
