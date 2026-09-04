---
name: fsi-parallel-stack
description: Run a second (or third) FSI Docker stack from a git worktree at the same time as the standard-port stack, using a generated port-offset Compose override. Handles the three blockers — pinned container_name, fixed host ports, shared untagged image — plus the Compose `ports` append trap that needs `!override`, and the missing `.env` in a worktree. Use when asked to "run two FSI stacks", "start FSI on different ports", "spin up a parallel or second FSI stack", "run FSI from this worktree without killing the other one", or when `docker compose up` in an FSI worktree fails with "port is already allocated" or "container name is already in use".
---

# Parallel FSI stacks (worktree port override)

Two FSI stacks cannot run at once out of the box. This skill generates a throwaway Compose override that shifts one stack onto its own ports, container names, image tag, and log directory — so a worktree branch runs beside the standard `fsi` stack.

**Slot convention:** slot *N* offsets every host port by *N* × 100. Slot 0 is the standard layout — never generate an override for slot 0.

## Naming convention

The tag is `<branch-slug>-<interface port>`. Branch `FACS-824` at slot 3 gives **`facs-824-8376`**.

The tag names four things:

| Thing | Value for `facs-824-8376` |
|---|---|
| The seven container names | `redis-facs-824-8376`, `azurite-facs-824-8376`, and so on |
| The image | `fsiapi-facs-824-8376` |
| The log directory | `C:/logs/facs-824-8376` |
| The override file | `docker-compose.ports-facs-824-8376.yml` |

**Use a hyphen. Never a colon.** `facs-824:8376` breaks in three separate ways:

- Docker container names allow only `[a-zA-Z0-9][a-zA-Z0-9_.-]*`. A colon is rejected outright.
- In an image reference a colon separates the name from the tag, so `fsiapi-facs-824:8376` silently means image `fsiapi-facs-824`, tag `8376`. Two stacks would then share one image repository — the exact problem the tag exists to prevent.
- A colon is the drive separator on Windows, so `C:/logs/facs-824:8376` is not a legal path.

`-Tag` validates against Docker's character set, so a colon fails at parameter binding before anything is written.

The branch prefix stays in the slug on purpose. `FACS-824` and `FOO-824` must not produce the same tag, because container names are global to the Docker daemon and ignore the slot.

Pass `-Tag` to override the whole thing. An explicit tag is used verbatim, with no port appended.

## Quick start

Run from the worktree root.

```powershell
pwsh "<skill-dir>/scripts/New-FsiStackOverride.ps1" -Slot 1
```

`<skill-dir>` is this skill's directory (where this `SKILL.md` lives). The script:

1. Writes `docker-compose.ports-<tag>.yml` at the worktree root. See **Naming convention** for `<tag>`.
2. Adds that filename to the repo's untracked exclude file, so it can never be committed.
3. Probes every shifted host port and warns on any port that already listens.
4. Prints the port table and the exact `up` and `down` commands.

Then start the stack with the printed command and verify it. See **Verify**.

## How the agent runs it

1. Confirm the working directory is an FSI **worktree**, not the main checkout. In a worktree, `git rev-parse --git-common-dir` returns a path outside the current directory.
2. Pick the slot yourself. `-Slot` is mandatory and the script has no auto-pick, so choose before you run it: list the running stacks with `docker compose ls`, then take the lowest slot no stack is using. Ask the user if you cannot tell.
3. Run the script. Read its warnings. The script probes the ports *after* it writes the file, so a reported collision means you delete the file with `-Remove` and re-run with another slot.
4. **Verify the merge before you start the stack.** This is the cheap check that catches the `!override` trap:

   ```bash
   docker compose <all -f flags> config --format json
   ```

   Every service must show **exactly one** published port per target. Two published ports for one target mean the `!override` did not apply. See gotcha 1.
5. Start the stack with the printed `up` command.
6. Verify with `docker compose ls` (two projects, both running) and `docker ps` (no duplicate container names). Then make one real end-to-end call on the shifted Interface port.

## The three blockers, and what the override does about each

| Blocker | Why it breaks | Override |
|---|---|---|
| Pinned `container_name` | `docker-compose.override.yml` pins seven names: `azurite`, `azurite-init`, `redis`, `wiremock-local`, `otel-collector`, `aspire-dashboard`, `openobserve`. Container names are global to the Docker daemon. Compose does **not** prefix them with the project name. The second stack fails with "name is already in use" even when every port is free. | Renames each name to `<name>-<tag>`. |
| Fixed host ports | 8000, 7071, 8076, 5341, 40000-40002, 6379, 9090, 4317, 4318, 18888, 18889, 5080. | `ports: !override` with the slot offset applied. |
| Shared untagged image | Base `docker-compose.yml` sets `image: fsiapi` with no tag, so two worktrees build over each other. The last build wins. You can run the other branch's code and not know it. | `image: fsiapi-<tag>`. |

**Not a problem:** named volumes and networks. Compose prefixes both with the project name, which it takes from the directory. You get `facs-824_redis_data` and `fsi_redis_data`.

**Also handled:** `C:/logs` is a shared host path. The override points this stack's `fsi.api` logs at `C:/logs/<tag>`.

## Gotchas

### 1. Compose APPENDS `ports`. It does not replace them

This is the one non-obvious thing. A second override that lists `ports: ["5441:80"]` does **not** replace `["5341:80"]`. Compose merges the two lists and tries to bind **both**:

```
Error response from daemon: ... Bind for 0.0.0.0:5341 failed: port is already allocated
```

The fix is the `!override` YAML tag on every `ports` list. It needs Compose **2.24+**. Verified on `v2.35.1-desktop.1`.

```yaml
ports: !override ["5441:80"]
```

### 2. You can rename `container_name`, but you cannot remove it

An override can set a value. It cannot unset one. So each pinned name gets an explicit `-<tag>` suffix instead of being dropped.

### 3. `.env` does not exist in a worktree

`.env` is at the main repo root, is gitignored, and holds `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, and `AZURE_CLIENT_SECRET`. `git worktree add` does not copy gitignored files, so a worktree has none.

The symptom is late and misleading. The stack starts correctly, then every FHIR call fails with

```
Unable to acquire access token: DefaultAzureCredential failed to retrieve a token
```

and a stack trace that ends in `Azure.Security.KeyVault.Keys.Cryptography.CryptographyClient.CreateRSA`. FSI cannot read the FHIR signing key, so it never mints the Epic client assertion. Downstream, that shows as `No patients found with given medical record number`.

Fix it without copying secrets into the worktree. Point Compose at the main repo's file. Every printed command includes this flag.

```
--env-file C:/repos/Fsi/.env
```

`RevCycleAccessToken` is a separate build arg. It comes from the shell environment, not from `.env`.

### 4. The func CLI mount is version-pinned

`docker-compose.headless.yml` mounts one specific Azure Functions Tools release. If that exact version is not installed locally, the Functions hosts do not start.

```bash
ls "$LOCALAPPDATA/AzureFunctionsTools/Releases"
```

### 5. Never commit the override, and never edit `.gitignore`

The generated file is throwaway. `.gitignore` is tracked, so a change to it is itself a commit-worthy change. Use the untracked per-repo exclude:

```bash
echo 'docker-compose.ports-facs-824-8376.yml' >> "$(git rev-parse --git-common-dir)/info/exclude"
```

`--git-common-dir` matters. In a worktree, `.git` is a file, and the real `info/exclude` is in the main repo's git directory. The script does this step for you. Verify with `git status --porcelain` (empty) and `git check-ignore -v <file>`.

## Port table

Slot *N* adds *N* × 100 to every host port. Slot 1 is shown.

| Service | slot 0 (standard) | slot 1 |
|---|---|---|
| FSI Interface | 8076 | 8176 |
| Fsi.Api | 8000 | 8100 |
| Orchestration | 7071 | 7171 |
| Azurite blob/queue/table | 40000-40002 | 40100-40102 |
| Redis | 6379 | 6479 |
| WireMock | 9090 | 9190 |
| Seq | 5341 | 5441 |
| Aspire | 18888/18889 | 18988/18989 |
| OpenObserve | 5080 | 5180 |
| OTEL collector | 4317/4318 | 4417/4418 |

## Start and stop

The script prints both commands with the real filename in place.

```bash
docker compose --env-file C:/repos/Fsi/.env -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.headless.yml -f docker-compose.ports-facs-824-8376.yml up -d
```

```bash
docker compose --env-file C:/repos/Fsi/.env -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.headless.yml -f docker-compose.ports-facs-824-8376.yml down --remove-orphans
```

Compose takes the project name from the worktree directory (`facs-824`), which is already distinct per branch. Pin `COMPOSE_PROJECT_NAME` if you want to be safe against a directory rename.

## Verify

```bash
docker compose ls          # two projects, both running
docker ps                  # no duplicate container names
```

Then make one real end-to-end call on the shifted port. A healthy Epic chain is `.well-known/smart-configuration` 200 → `oauth2/token` 200 → Patient 200 → Encounter 200 → EOB 200.

Request recipe for a shifted stack. Slot 1 is shown.

- `POST http://localhost:8176/api/v1/patients`, header `X-MS-CLIENT-PRINCIPAL-ID: local-dev`.
- Body fields: `contactSerialNumber`, `dateOfService`, `emrId`, `medicalRecordNumber`, `organizationId`, `outputDocumentFormatTypeCode`, `requestedPatientResources`.
- Poll `GET /api/v1/orchestration/{jobId}` with the same OID header.
- Add header `X-Capture-Fhir-Raw: true` to capture raw traffic. Captures land in Azurite container `fhir-raw-captures` as `{jobId}.json`. Read them against the shifted blob port. **Treat those blobs as sensitive.** They contain bearer tokens.
- Flush the cache first to force a fresh Epic token: `docker exec redis-facs-824-8376 redis-cli FLUSHALL`.
- Known-good Epic sandbox patient: MRN 202427, CSN 9961, DoS 2006-10-02, emrId 0, org 0.

## Scripts that hardcode the standard ports

Pass explicit arguments when you drive a shifted stack.

- `MockData/Generate-WireMockStubs.ps1` — `-InterfaceUrl`, `-AzuriteUrl`
- `Fsi.LoadTests/Run-LoadTest.ps1` — `-Url`
- WireMock admin check — `http://localhost:<shifted wiremock port>/__admin/mappings`
- The `fsi-smoke-test` skill assumes 8076. Override its base URL, or it smoke-tests the *other* stack.

## Teardown

Remove the override file and its exclude line:

```powershell
pwsh "<skill-dir>/scripts/New-FsiStackOverride.ps1" -Slot 1 -Remove
```

**Pass the same `-Slot` you generated with.** The tag carries the interface port, so the slot decides the filename. A different slot computes a different tag and removes nothing. The script says `No override file at <path>` when that happens — read that message as "wrong slot", not "already clean".

`down` keeps named volumes and the built image. Remove the Docker leftovers too. Project name and tag come from your slot.

```bash
docker volume rm facs-824_azurite_data facs-824_redis_data facs-824_seq_data facs-824_openobserve_data
```

```bash
docker image rm fsiapi-facs-824-8376:latest
```

## Do not touch the other stack

The standard-port `fsi` project usually belongs to another branch or another agent. Never `down` a project you did not start. Confirm which project is yours with `docker compose ls` before any teardown.

## If this should become a permanent repo feature

This is a design sketch only. It is not implemented. Raise it as a ticket instead of doing it inside another task.

1. Delete all seven `container_name` lines from `docker-compose.override.yml`.
2. Parameterise every host port with today's value as the default — `ports: ["${FSI_API_PORT:-8000}:80"]` — so existing workflows do not change.
3. Use `image: fsiapi:${FSI_IMAGE_TAG:-latest}` and `${FSI_LOG_DIR:-C:/logs}:/app/logs`.
4. Add a `Start-FsiStack.ps1` that takes a slot from a stable hash of the branch name (mod 10), computes `offset = slot * 100`, writes `.env` in the worktree (already gitignored), sets `COMPOSE_PROJECT_NAME`, probes each port and increments the slot on a collision, then prints the URL table. Slot 0 must reproduce today's layout, so `main` behaves as it always has. Compose has no arithmetic in interpolation, so the script must expand the offset.
5. Update the three hardcoded-port scripts to read `.env` or `docker compose port`.

Deterministic-by-branch is better than random host ports (`ports: ["80"]`). A random port changes at every restart and breaks bookmarks.
