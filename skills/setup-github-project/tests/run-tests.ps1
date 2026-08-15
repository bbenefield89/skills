[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$skillRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $skillRoot 'scripts/ProjectPolicy.psm1') -Force
$fixturePath = Join-Path $PSScriptRoot 'fixtures/conforming.json'
$emptyMilestonesPath = Join-Path $PSScriptRoot 'fixtures/empty-milestones.json'
$script:passed = 0

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERT TRUE FAILED: $Message" }
    $script:passed++
}

function Assert-False {
    param([bool]$Condition, [string]$Message)
    Assert-True (-not $Condition) $Message
}

function Assert-Equal {
    param($Actual, $Expected, [string]$Message)
    if (($Actual | ConvertTo-Json -Compress -Depth 20) -cne ($Expected | ConvertTo-Json -Compress -Depth 20)) {
        throw "ASSERT EQUAL FAILED: $Message`nExpected: $($Expected | ConvertTo-Json -Compress -Depth 20)`nActual: $($Actual | ConvertTo-Json -Compress -Depth 20)"
    }
    $script:passed++
}

function Get-Fixture {
    Get-Content -Raw -LiteralPath $fixturePath | ConvertFrom-Json -Depth 50
}

function Copy-State {
    param($State)
    $State | ConvertTo-Json -Depth 50 | ConvertFrom-Json -Depth 50
}

$state = Get-Fixture
$result = Get-GitHubProjectAssessment -State $state -Repository 'octocat/game'
Assert-True $result.Conforms 'The conforming fixture must pass.'
Assert-Equal @($result.ProposedMutations) @() 'The conforming fixture must propose no mutations.'

$secondResult = Get-GitHubProjectAssessment -State (Copy-State $state) -Repository 'octocat/game'
Assert-True $secondResult.Conforms 'A second dry-run must remain conforming.'
Assert-Equal @($secondResult.ProposedMutations) @() 'A second dry-run must be idempotent.'

$bootstrap = Get-RepositoryBootstrapDecision -LocalRepositoryName 'game' -AuthenticatedAccounts @('octocat')
Assert-Equal $bootstrap.Repository 'octocat/game' 'A sole active account must supply the proposed owner.'
Assert-False $bootstrap.AccountSelectionRequired 'A sole active account must not require selection.'
$ambiguousAccounts = Get-RepositoryBootstrapDecision -LocalRepositoryName 'game' -AuthenticatedAccounts @('octocat', 'hubot')
Assert-True $ambiguousAccounts.AccountSelectionRequired 'Multiple authenticated accounts must require owner selection.'
Assert-Equal $ambiguousAccounts.Repository $null 'Multiple accounts must not produce an inferred repository.'
$ambiguousMilestones = Get-AmbiguousMilestoneTitles -ExistingMilestones @([pscustomobject]@{ Title='Prototype' })
Assert-Equal $ambiguousMilestones @('Prototype') 'An unnumbered canonical counterpart must block milestone creation.'
$duplicateMilestones = Get-DuplicateCanonicalMilestoneTitles -ExistingMilestones @(
    [pscustomobject]@{ Title='Phase 1: Prototype' },
    [pscustomobject]@{ Title='Phase 1: Prototype' }
)
Assert-Equal $duplicateMilestones @('Phase 1: Prototype') 'Duplicate canonical milestones must block reconciliation.'

$missingRepository = Copy-State $state
$missingRepository.Repository.Exists = $false
$result = Get-GitHubProjectAssessment -State $missingRepository -Repository 'octocat/game'
Assert-False $result.Conforms 'A missing repository must fail verification.'
Assert-True (@($result.ProposedMutations | Where-Object { $_ -match 'Create private GitHub repository' }).Count -eq 1) 'A missing repository must propose private creation.'

$duplicateLabel = Copy-State $state
$duplicateLabel.Labels += [pscustomobject]@{ Name='Ticket' }
$result = Get-GitHubProjectAssessment -State $duplicateLabel -Repository 'octocat/game'
Assert-True (@($result.Errors | Where-Object { $_ -match 'case-insensitive duplicates' }).Count -eq 1) 'Case-insensitive BB label duplicates must fail.'

$missingCanonicalMilestone = Copy-State $state
$missingCanonicalMilestone.Milestones = @($missingCanonicalMilestone.Milestones | Where-Object { $_.Title -ne 'Phase 5: Release' })
$result = Get-GitHubProjectAssessment -State $missingCanonicalMilestone -Repository 'octocat/game'
Assert-True (@($result.Errors | Where-Object { $_ -match "Phase 5: Release.*missing" }).Count -eq 1) 'A missing canonical milestone must fail.'

$missingBb = Copy-State $state
$missingBb.BbContract.Exists = $false
$missingBb.BbContract.Compatible = $false
$result = Get-GitHubProjectAssessment -State $missingBb -Repository 'octocat/game'
Assert-True (@($result.ProposedMutations | Where-Object { $_ -match 'setup-bb-skills' }).Count -gt 0) 'A missing BB contract must require BB coordination.'

$badMilestone = Copy-State $state
$badMilestone.Issues[0].Milestone.Title = 'Prototype'
$result = Get-GitHubProjectAssessment -State $badMilestone -Repository 'octocat/game'
Assert-True (@($result.Errors | Where-Object { $_ -match 'Ticket #11.*canonical milestone' }).Count -eq 1) 'A noncanonical Ticket milestone must fail.'

$missingMembership = Copy-State $state
$missingMembership.Project.ItemUrls = @('https://github.com/octocat/game/issues/21')
$result = Get-GitHubProjectAssessment -State $missingMembership -Repository 'octocat/game'
Assert-True (@($result.Errors | Where-Object { $_ -match 'Ticket #11 is missing' }).Count -eq 1) 'A Ticket missing from the Project must fail.'

$taskMembership = Copy-State $state
$taskMembership.Project.ItemUrls += 'https://github.com/octocat/game/issues/12'
$result = Get-GitHubProjectAssessment -State $taskMembership -Repository 'octocat/game'
Assert-True (@($result.Errors | Where-Object { $_ -match 'Non-Ticket Project item' }).Count -eq 1) 'Task Project membership must fail.'

$extraView = Copy-State $state
$extraView.Project.Views += [pscustomobject]@{ Name='Extra'; Layout='table' }
$result = Get-GitHubProjectAssessment -State $extraView -Repository 'octocat/game'
Assert-True (@($result.Errors | Where-Object { $_ -match 'exactly one is required' }).Count -eq 1) 'An extra view must fail.'

$customField = Copy-State $state
$customField.Project.CustomFields = @('Phase')
$result = Get-GitHubProjectAssessment -State $customField -Repository 'octocat/game'
Assert-True (@($result.Errors | Where-Object { $_ -match 'Forbidden custom Project fields' }).Count -eq 1) 'A forbidden custom field must fail.'

$legacy = Copy-State $state
$legacy.Labels += [pscustomobject]@{ Name='epic' }
$legacy.Issues += [pscustomobject]@{ Number=99; Url='https://github.com/octocat/game/issues/99'; Labels=@('spec'); Milestone=$null }
$result = Get-GitHubProjectAssessment -State $legacy -Repository 'octocat/game'
Assert-True ($result.LegacyConflicts.Count -ge 2) 'Known legacy labels and issues must be reported.'

$emptyFixture = Get-Content -Raw -LiteralPath $emptyMilestonesPath | ConvertFrom-Json -Depth 20
$sequence = Invoke-MilestoneReconciliation -ExistingMilestones $emptyFixture.Milestones -CreateMilestone {
    param($Title, $Sequence)
    [pscustomobject]@{ Title=$Title; State='open'; Number=$Sequence }
} -ReadMilestone {
    param($Title, $Sequence, $Milestones)
    $Milestones | Where-Object { $_.Title -ceq $Title } | Select-Object -First 1
}
$createdTitles = @($sequence.Operations | Where-Object { $_.Operation -eq 'Create' } | ForEach-Object { $_.Title })
Assert-Equal $createdTitles @(Get-CanonicalMilestoneTitles) 'Milestones must be created in strict canonical order.'
$operations = @($sequence.Operations)
for ($index = 1; $index -lt 5; $index++) {
    $previousValidation = [array]::FindIndex($operations, [Predicate[object]]{ param($item) $item.Title -eq (Get-CanonicalMilestoneTitles)[$index - 1] -and $item.Operation -eq 'Validate' })
    $nextInspect = [array]::FindIndex($operations, [Predicate[object]]{ param($item) $item.Title -eq (Get-CanonicalMilestoneTitles)[$index] -and $item.Operation -eq 'Inspect' })
    Assert-True ($previousValidation -lt $nextInspect) "Phase $index must validate before the next phase is inspected."
}

$failureOperations = @()
try {
    Invoke-MilestoneReconciliation -ExistingMilestones @() -CreateMilestone {
        param($Title, $Sequence)
        [pscustomobject]@{ Title=$Title; Number=$Sequence; State='open' }
    } -ReadMilestone {
        param($Title, $Sequence, $Milestones)
        if ($Title -ceq 'Phase 3: Alpha') { return $null }
        $Milestones | Where-Object { $_.Title -ceq $Title } | Select-Object -First 1
    } | Out-Null
    throw 'Expected milestone validation failure did not occur.'
} catch {
    $failureOperations = @($_.Exception.Data['Operations'])
}
Assert-True (@($failureOperations | Where-Object { $_.Title -eq 'Phase 3: Alpha' -and $_.Operation -eq 'Validate' }).Count -eq 1) 'Phase 3 validation must be attempted.'
Assert-True (@($failureOperations | Where-Object { $_.Title -eq 'Phase 4: Beta' }).Count -eq 0) 'A failed Phase 3 validation must prevent every Phase 4 operation.'

$parseErrors = @()
Get-ChildItem -LiteralPath (Join-Path $skillRoot 'scripts') -Filter '*.ps1' | ForEach-Object {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    $parseErrors += @($errors)
}
Assert-Equal $parseErrors.Count 0 'Every PowerShell script must parse successfully.'

[ordered]@{ Passed=$script:passed; Failed=0 } | ConvertTo-Json
