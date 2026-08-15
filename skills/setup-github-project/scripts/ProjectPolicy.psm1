Set-StrictMode -Version Latest

function Get-CanonicalMilestoneTitles {
    @(
        'Phase 1: Prototype'
        'Phase 2: Vertical Slice'
        'Phase 3: Alpha'
        'Phase 4: Beta'
        'Phase 5: Release'
    )
}

function Get-PropertyValue {
    param($Object, [string]$Name, $Default = $null)
    if ($null -eq $Object) { return $Default }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) { return $Default }
    return $property.Value
}

function Get-IssueLabelNames {
    param($Issue)
    @(
        Get-PropertyValue $Issue 'Labels' @() | ForEach-Object {
            if ($_ -is [string]) { $_ } else { Get-PropertyValue $_ 'Name' '' }
        } | Where-Object { $_ }
    )
}

function Test-IssueLabel {
    param($Issue, [string]$Name)
    return @((Get-IssueLabelNames $Issue) | Where-Object { $_ -ieq $Name }).Count -gt 0
}

function Get-BbMappingValue {
    param($BbContract, [string]$Name, [string]$Default)
    $mappings = Get-PropertyValue $BbContract 'Mappings'
    $value = Get-PropertyValue $mappings $Name
    if ($value) { return "$value" }
    return $Default
}

function Get-GitHubProjectAssessment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$State,
        [string]$Repository
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    $warnings = [System.Collections.Generic.List[string]]::new()
    $legacy = [System.Collections.Generic.List[string]]::new()
    $proposed = [System.Collections.Generic.List[string]]::new()
    $manual = [System.Collections.Generic.List[string]]::new()
    $canonicalMilestones = @(Get-CanonicalMilestoneTitles)

    $repositoryState = Get-PropertyValue $State 'Repository'
    $repositoryExists = [bool](Get-PropertyValue $repositoryState 'Exists' $false)
    $resolvedRepository = if ($Repository) { $Repository } else { Get-PropertyValue $repositoryState 'NameWithOwner' '' }
    if (-not $repositoryExists) {
        $errors.Add('The private GitHub repository does not exist.')
        $proposed.Add("Create private GitHub repository $resolvedRepository.")
    } elseif ((Get-PropertyValue $repositoryState 'Visibility' '') -ine 'PRIVATE') {
        $errors.Add('The GitHub repository is not private.')
        $proposed.Add("Set $resolvedRepository visibility to private.")
    }

    $bb = Get-PropertyValue $State 'BbContract'
    if (-not [bool](Get-PropertyValue $bb 'Exists' $false) -or -not [bool](Get-PropertyValue $bb 'Compatible' $false)) {
        $errors.Add('The BB tracker contract is missing or incompatible.')
        $proposed.Add('Coordinate setup-bb-skills through its independent approval gate.')
    }
    $ticketLabel = Get-BbMappingValue $bb 'Ticket' 'ticket'
    $taskLabel = Get-BbMappingValue $bb 'Task' 'task'
    $requiredLabels = @(Get-PropertyValue $bb 'RequiredLabels' @())
    $labelNames = @(
        Get-PropertyValue $State 'Labels' @() | ForEach-Object {
            if ($_ -is [string]) { $_ } else { Get-PropertyValue $_ 'Name' '' }
        } | Where-Object { $_ }
    )
    foreach ($requiredLabel in $requiredLabels) {
        $matchingLabelCount = @($labelNames | Where-Object { $_ -ieq $requiredLabel }).Count
        if ($matchingLabelCount -eq 0) {
            $errors.Add("BB-owned label '$requiredLabel' is missing.")
            $proposed.Add("Coordinate setup-bb-skills to reconcile label '$requiredLabel'.")
        } elseif ($matchingLabelCount -gt 1) {
            $errors.Add("BB-owned label '$requiredLabel' has case-insensitive duplicates.")
            $proposed.Add("Coordinate setup-bb-skills to resolve duplicate label '$requiredLabel'.")
        }
    }
    foreach ($legacyLabel in @('phase', 'epic', 'spec', 'Feature Ticket')) {
        if (@($labelNames | Where-Object { $_ -ieq $legacyLabel }).Count -gt 0) {
            $legacy.Add("Legacy label '$legacyLabel' exists.")
        }
    }

    $milestones = @(Get-PropertyValue $State 'Milestones' @())
    $milestoneTitles = @($milestones | ForEach-Object { Get-PropertyValue $_ 'Title' '' })
    foreach ($title in $canonicalMilestones) {
        $matchingMilestoneCount = @($milestoneTitles | Where-Object { $_ -ceq $title }).Count
        if ($matchingMilestoneCount -eq 0) {
            $errors.Add("Canonical milestone '$title' is missing.")
            $proposed.Add("Create and validate milestone '$title' in canonical order.")
        } elseif ($matchingMilestoneCount -gt 1) {
            $errors.Add("Canonical milestone '$title' exists more than once.")
            $proposed.Add("Resolve duplicate canonical milestone '$title' through an approved migration.")
        }
    }
    foreach ($milestoneTitle in $milestoneTitles) {
        if ($milestoneTitle -notin $canonicalMilestones -and $milestoneTitle -match '(?i)prototype|vertical slice|alpha|beta|release|gold|launch|phase') {
            $legacy.Add("Ambiguous or legacy milestone '$milestoneTitle' exists.")
        }
    }

    $issues = @(Get-PropertyValue $State 'Issues' @())
    $tickets = @($issues | Where-Object { Test-IssueLabel $_ $ticketLabel })
    $tasks = @($issues | Where-Object { Test-IssueLabel $_ $taskLabel })
    $project = Get-PropertyValue $State 'Project'
    $projectExists = [bool](Get-PropertyValue $project 'Exists' $false)
    $projectItemUrls = @(Get-PropertyValue $project 'ItemUrls' @())

    if (-not $projectExists) {
        $errors.Add('The repository-linked GitHub Project does not exist.')
        $proposed.Add('Create a private repository-linked GitHub Project.')
    } else {
        $expectedProjectTitle = if ($resolvedRepository -match '/') { $resolvedRepository.Split('/', 2)[1] } else { $resolvedRepository }
        if ((Get-PropertyValue $project 'Title' '') -cne $expectedProjectTitle) {
            $errors.Add("The GitHub Project title is not '$expectedProjectTitle'.")
            $proposed.Add("Set the GitHub Project title to '$expectedProjectTitle'.")
        }
        if ((Get-PropertyValue $project 'Visibility' '') -ine 'PRIVATE') {
            $errors.Add('The GitHub Project is not private.')
            $proposed.Add('Set the GitHub Project visibility to private.')
        }
        if (-not [bool](Get-PropertyValue $project 'LinkageVerifiable' $true)) {
            $manual.Add('Verify the Project is linked exclusively to the approved repository.')
        } else {
            $linkedRepositories = @(Get-PropertyValue $project 'LinkedRepositories' @())
            if ($linkedRepositories.Count -ne 1 -or $linkedRepositories[0] -ine $resolvedRepository) {
                $errors.Add('The GitHub Project is not linked exclusively to the approved repository.')
                $proposed.Add("Link the Project only to $resolvedRepository.")
            }
        }
    }

    foreach ($ticket in $tickets) {
        $url = Get-PropertyValue $ticket 'Url' ''
        $number = Get-PropertyValue $ticket 'Number' '?'
        $milestone = Get-PropertyValue $ticket 'Milestone'
        $milestoneTitle = Get-PropertyValue $milestone 'Title' ''
        if ($milestoneTitle -notin $canonicalMilestones) {
            $errors.Add("Ticket #$number does not have exactly one canonical milestone.")
        }
        if ($projectExists -and $url -notin $projectItemUrls) {
            $errors.Add("Ticket #$number is missing from the Project.")
            $proposed.Add("Add Ticket #$number to the Project.")
        }
    }

    if ($projectExists) {
        foreach ($itemUrl in $projectItemUrls) {
            $issue = $issues | Where-Object { (Get-PropertyValue $_ 'Url' '') -eq $itemUrl } | Select-Object -First 1
            if ($null -eq $issue -or -not (Test-IssueLabel $issue $ticketLabel)) {
                $errors.Add("Non-Ticket Project item '$itemUrl' is present.")
                $proposed.Add("Remove '$itemUrl' from Project membership without changing the issue.")
            }
        }
    }

    foreach ($task in $tasks) {
        $milestone = Get-PropertyValue $task 'Milestone'
        if ($null -ne $milestone -and (Get-PropertyValue $milestone 'Title' '')) {
            $errors.Add("Task #$(Get-PropertyValue $task 'Number' '?') duplicates release grouping with a milestone.")
        }
    }

    $customFields = @(Get-PropertyValue $project 'CustomFields' @())
    if ($customFields.Count -gt 0) {
        $errors.Add("Forbidden custom Project fields exist: $($customFields -join ', ').")
        $proposed.Add('Remove approved custom Project fields.')
    }
    $statusOptions = @(Get-PropertyValue $project 'StatusOptions' @())
    $expectedStatus = @('Todo', 'In Progress', 'Done')
    if (($statusOptions -join '|') -cne ($expectedStatus -join '|')) {
        $errors.Add('Status options are not exactly Todo, In Progress, and Done in order.')
        $proposed.Add('Reconcile the Status options.')
    }

    $views = @(Get-PropertyValue $project 'Views' @())
    if ($views.Count -ne 1) {
        $errors.Add("The Project has $($views.Count) saved views; exactly one is required.")
        $proposed.Add('Reconcile the Project to one Tickets view.')
    }
    if ($views.Count -ge 1) {
        $view = $views | Where-Object { (Get-PropertyValue $_ 'Name' '') -ceq 'Tickets' } | Select-Object -First 1
        if ($null -eq $view) {
            $errors.Add("The required 'Tickets' view is missing.")
            $proposed.Add("Create or rename the single view to 'Tickets'.")
        } else {
            $baseChecks = [ordered]@{
                Layout = 'board'
                Filter = 'label:"ticket"'
            }
            foreach ($entry in $baseChecks.GetEnumerator()) {
                if ((Get-PropertyValue $view $entry.Key '') -cne $entry.Value) {
                    $errors.Add("Tickets view $($entry.Key) is not '$($entry.Value)'.")
                    $proposed.Add("Set Tickets view $($entry.Key) to '$($entry.Value)'.")
                }
            }
            if (-not [bool](Get-PropertyValue $view 'PresentationVerifiable' $true)) {
                $manual.Add('Verify Tickets view Status columns, Milestone slice, no swimlanes, manual sort, Count field sum, and visible card fields in the Project UI.')
            } else {
                $presentationChecks = [ordered]@{
                    ColumnBy = 'Status'
                    SliceBy = 'Milestone'
                    Swimlanes = 'none'
                    SortBy = 'manual'
                    FieldSum = 'count'
                }
                foreach ($entry in $presentationChecks.GetEnumerator()) {
                    if ((Get-PropertyValue $view $entry.Key '') -cne $entry.Value) {
                        $errors.Add("Tickets view $($entry.Key) is not '$($entry.Value)'.")
                        $proposed.Add("Set Tickets view $($entry.Key) to '$($entry.Value)'.")
                    }
                }
                $visibleFields = @(Get-PropertyValue $view 'VisibleFields' @())
                foreach ($field in @('Title', 'Assignees', 'Labels', 'Sub-issues progress')) {
                    if ($field -notin $visibleFields) {
                        $errors.Add("Tickets view does not show '$field'.")
                        $proposed.Add("Show '$field' on Tickets cards.")
                    }
                }
            }
        }
    }

    $workflows = Get-PropertyValue $project 'Workflows'
    if ($null -eq $workflows -or -not [bool](Get-PropertyValue $workflows 'Verifiable' $false)) {
        $manual.Add('Verify auto-add, added, closed, reopened, and auto-add-sub-issues settings in the Project UI.')
    } else {
        $workflowChecks = [ordered]@{
            AutoAddFilter = 'label:"ticket"'
            AddedStatus = 'Todo'
            ClosedStatus = 'Done'
            ReopenedStatus = 'Todo'
            AutoAddSubIssues = $false
        }
        foreach ($entry in $workflowChecks.GetEnumerator()) {
            if ((Get-PropertyValue $workflows $entry.Key) -cne $entry.Value) {
                $errors.Add("Project workflow $($entry.Key) is not '$($entry.Value)'.")
                $proposed.Add("Reconcile Project workflow $($entry.Key).")
            }
        }
    }

    $githubContract = Get-PropertyValue $State 'GitHubProjectContract'
    if (-not [bool](Get-PropertyValue $githubContract 'Exists' $false)) {
        $errors.Add('docs/agents/github-project.md is missing.')
        $proposed.Add('Write docs/agents/github-project.md from the bundled template.')
    }
    foreach ($contract in @(@{ Name='BB'; Value=$bb }, @{ Name='GitHub Project'; Value=$githubContract })) {
        $pointerCount = [int](Get-PropertyValue $contract.Value 'PointerCount' 0)
        if ($pointerCount -ne 1) {
            $errors.Add("$($contract.Name) contract instruction pointer count is $pointerCount; expected 1.")
            $proposed.Add("Reconcile the $($contract.Name) contract instruction pointer exactly once.")
        }
    }

    foreach ($issue in $issues) {
        foreach ($legacyLabel in @('phase', 'epic', 'spec', 'Feature Ticket')) {
            if (Test-IssueLabel $issue $legacyLabel) {
                $legacy.Add("Issue #$(Get-PropertyValue $issue 'Number' '?') uses legacy classification '$legacyLabel'.")
            }
        }
    }

    [pscustomobject][ordered]@{
        Conforms = $errors.Count -eq 0 -and $proposed.Count -eq 0
        Errors = @($errors | Select-Object -Unique)
        Warnings = @($warnings | Select-Object -Unique)
        LegacyConflicts = @($legacy | Select-Object -Unique)
        ProposedMutations = @($proposed | Select-Object -Unique)
        ManualChecks = @($manual | Select-Object -Unique)
    }
}

function Get-MilestoneReconciliationPlan {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$ExistingMilestones)
    $existingTitles = @($ExistingMilestones | ForEach-Object { Get-PropertyValue $_ 'Title' '' })
    $sequence = 0
    @(
        foreach ($title in Get-CanonicalMilestoneTitles) {
            $sequence++
            [pscustomobject]@{
                Sequence = $sequence
                Title = $title
                Action = if ($title -cin $existingTitles) { 'ReuseAndValidate' } else { 'CreateAndValidate' }
            }
        }
    )
}

function Get-AmbiguousMilestoneTitles {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$ExistingMilestones)
    $canonical = @(Get-CanonicalMilestoneTitles)
    @(
        $ExistingMilestones | ForEach-Object { Get-MilestoneTitle $_ } | Where-Object {
            $_ -notin $canonical -and $_ -match '(?i)prototype|vertical slice|alpha|beta|release|gold|launch|phase'
        } | Select-Object -Unique
    )
}

function Get-DuplicateCanonicalMilestoneTitles {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$ExistingMilestones)
    $titles = @($ExistingMilestones | ForEach-Object { Get-MilestoneTitle $_ })
    @(
        Get-CanonicalMilestoneTitles | Where-Object {
            $canonicalTitle = $_
            @($titles | Where-Object { $_ -ceq $canonicalTitle }).Count -gt 1
        }
    )
}

function Get-RepositoryBootstrapDecision {
    [CmdletBinding()]
    param(
        [string]$ResolvedRepository,
        [Parameter(Mandatory)][string]$LocalRepositoryName,
        [Parameter(Mandatory)]$AuthenticatedAccounts
    )

    $accounts = @($AuthenticatedAccounts | Where-Object { $_ } | Select-Object -Unique)
    if ($ResolvedRepository) {
        return [pscustomobject]@{
            Repository = $ResolvedRepository
            SelectedOwner = $ResolvedRepository.Split('/', 2)[0]
            AccountSelectionRequired = $false
        }
    }
    if ($accounts.Count -eq 1) {
        return [pscustomobject]@{
            Repository = "$($accounts[0])/$LocalRepositoryName"
            SelectedOwner = $accounts[0]
            AccountSelectionRequired = $false
        }
    }
    return [pscustomobject]@{
        Repository = $null
        SelectedOwner = $null
        AccountSelectionRequired = $accounts.Count -gt 1
    }
}

function Get-MilestoneTitle {
    param($Milestone)
    $title = Get-PropertyValue $Milestone 'Title'
    if (-not $title) { $title = Get-PropertyValue $Milestone 'title' '' }
    return "$title"
}

function Get-MilestoneNumber {
    param($Milestone)
    $number = Get-PropertyValue $Milestone 'Number'
    if ($null -eq $number) { $number = Get-PropertyValue $Milestone 'number' }
    return $number
}

function Get-MilestoneState {
    param($Milestone)
    $state = Get-PropertyValue $Milestone 'State'
    if (-not $state) { $state = Get-PropertyValue $Milestone 'state' '' }
    return "$state"
}

function Invoke-MilestoneReconciliation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$ExistingMilestones,
        [Parameter(Mandatory)][scriptblock]$CreateMilestone,
        [Parameter(Mandatory)][scriptblock]$ReadMilestone
    )

    $existing = @($ExistingMilestones)
    $operations = [System.Collections.Generic.List[object]]::new()
    $sequence = 0
    try {
        foreach ($title in Get-CanonicalMilestoneTitles) {
            $sequence++
            $operations.Add([pscustomobject]@{ Sequence=$sequence; Title=$title; Operation='Inspect' })
            $match = $existing | Where-Object { (Get-MilestoneTitle $_) -ceq $title } | Select-Object -First 1
            if (-not $match) {
                $operations.Add([pscustomobject]@{ Sequence=$sequence; Title=$title; Operation='Create' })
                $created = & $CreateMilestone $title $sequence
                if ($created) { $existing += $created }
            } else {
                $operations.Add([pscustomobject]@{ Sequence=$sequence; Title=$title; Operation='Reuse' })
            }

            $operations.Add([pscustomobject]@{ Sequence=$sequence; Title=$title; Operation='Validate' })
            $readBack = & $ReadMilestone $title $sequence $existing
            $readBackState = Get-MilestoneState $readBack
            if (-not $readBack -or
                (Get-MilestoneTitle $readBack) -cne $title -or
                $null -eq (Get-MilestoneNumber $readBack) -or
                $readBackState -notin @('open', 'closed')) {
                throw "Milestone '$title' could not be validated after reconciliation."
            }
        }
    } catch {
        $_.Exception.Data['Operations'] = @($operations)
        throw
    }

    return [pscustomobject]@{ Completed=$true; Operations=@($operations); Milestones=@($existing) }
}

Export-ModuleMember -Function Get-CanonicalMilestoneTitles, Get-AmbiguousMilestoneTitles, Get-DuplicateCanonicalMilestoneTitles, Get-GitHubProjectAssessment, Get-MilestoneReconciliationPlan, Get-RepositoryBootstrapDecision, Invoke-MilestoneReconciliation
