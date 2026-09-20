<!-- setup-godot-project:template=godot-architecture;version=2 -->
# Godot architecture standard

Apply this standard when adding, moving, or reviewing project-owned Godot files. Use the same organization rules across projects.

## Ownership and placement

Organize primarily by feature or domain. Keep each feature's related implementation together instead of separating all scripts, scenes, and resources into global folders.

| Location | Responsibility |
| --- | --- |
| `features/<feature>/` | Gameplay behavior, feature scenes, scripts, exclusive resources, UI, and feature tests. |
| `app/bootstrap/` | Separate startup helpers, when needed. A scene's attached script stays beside that scene. |
| `app/autoload/` | True application-wide services registered as Godot autoloads. |
| `app/config/` | Application configuration and input registration. |
| `core/<responsibility>/` | Genuinely reusable primitives, types, and interfaces without a gameplay owner. |
| `entities/<kind>/` | Physical world objects, such as players, NPCs, fish, and props. Keep their scenes, entity-specific scripts, and exclusive resources together. |
| `levels/<location>/` | Playable locations and their authored composition. |
| `ui/<responsibility>/` | Game-wide HUD, menus, common presentation, and themes. |
| `data/<domain>/` | Shared authored datasets, such as item catalogs and game-wide balance data. Feature-owned resource definitions and instances stay together in their feature. |
| `persistence/<responsibility>/` | Save/load boundaries, serializers, migrations, and stored-data models. |
| `assets/<kind>/` | Passive art, audio, fonts, materials, shaders, and animation content shared across features. |
| `tests/` | Integration tests, regression tests, fixtures, and setup validation infrastructure. |
| `docs/` | Architecture, decisions, conventions, and project documentation. |
| `addons/` | Third-party plugins. |
| `scenes/<composition>/` | Game-wide composition scenes and their attached scripts, such as `scenes/main/main.tscn` and `main.gd`. |

Create folders when actual files need them. The standard does not require every game to contain every category or example feature.

Reserve root `scenes/` for game-wide composition. Feature scenes remain with their features, playable locations remain in `levels/`, and reusable entity scenes remain in `entities/`.

## Feature boundaries

Keep a scene's primary attached script beside the scene and use the same base filename. For example, `main.tscn` uses `main.gd`. Shared behavior scripts retain their feature owner.

A feature owns a cohesive gameplay capability. Group its internals by responsibility, keeping related scenes, scripts, and resources together. Small features can remain flat.

Distinguish objects from activities. Entities represent things that occupy the game world. Features implement systems such as fishing, collecting, and dialogue. A player's controller belongs with the player; the fishing rules belong to Fishing, even when only the player fishes. Physical objects used by a system, such as its bobber, remain entities. Temporary interface feedback, such as a placement preview, stays with the feature that presents it.

Feature-specific presentation belongs in `features/<feature>/ui/`. The root `ui/` owns game-wide presentation. Presentation requests gameplay operations through feature contracts; gameplay rules remain in features.

Keep feature-specific assets and resources with their feature. Place a resource definition script beside its authored `.tres` instances, for example under `features/dialogue/resources/`. Use root `assets/` for shared passive content and root `data/` for shared authored datasets. A resource consumed by multiple features still has a domain owner; sharing alone does not require separating its definition from its instances.

Keep non-entity scenes that implement a feature inside that feature. Use `entities/` for world objects and `levels/` for playable locations. Keep each location's attached script beside its scene. Entity scripts can call feature contracts without duplicating system rules.

Only genuinely reusable primitives belong in `core/`. Several consumers do not automatically make a domain type a core primitive. A feature owns its concepts even when other features use them.

## Deep modules and contracts

Design deep modules: substantial behavior behind small, clear public contracts. Features communicate through public methods, signals, and deliberately exposed data types or resources.

Document the inputs, outputs, state changes, and failure behavior that callers need. Keep private helpers, internal node paths, and mutable implementation details inside the owning module.

Give each mutable state a clear owner. Other features request changes through that owner's contract. Composition wires explicit dependencies. Avoid speculative interfaces, generic routing layers, and empty service classes.

Application-wide scope alone does not require an autoload. Use `app/autoload/` only for registered autoload services. Application-owned objects with an existing scene lifecycle can stay under a descriptive `app/` subfolder. Folder migration must preserve their lifecycle.

## Tests and setup

Keep focused feature tests beside their feature, under a `tests/` subfolder. Keep tests spanning features under root `tests/integration/` or `tests/regression/`. Shared fixtures belong under `tests/fixtures/`.

Retain GUT and the public Just commands. Configure `test-all` to discover `test_*.gd` recursively under root `tests/` and `features/` when that directory exists. Keep setup smoke and runtime validation scripts at their configured root-test paths. A focused test command accepts the test's repository-relative path.

Setup publishes this fixed document and its `AGENTS.md` pointer. It does not move gameplay files, inspect layout deviations, or customize the standard to the existing layout.

## Migration and maintenance

Update literal and computed resource paths, scene references, project settings, tests, and documentation together when moving files. Preserve UIDs, authored node identities, saved-data identities, and runtime behavior.

A folder migration does not establish deep modules by itself. Preserve existing public contracts unless refactoring is separately authorized. Record temporary ownership compromises in project-specific documentation rather than changing this universal standard to fit them.
