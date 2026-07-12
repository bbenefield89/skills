<!-- setup-godot-project:template=gdscript;version=1;section=standards -->
# GDScript standards

Use concrete project types, explicit local types, typed enums, typed getters, typed exported node references, direct method calls, and native `##` documentation. Refresh Godot metadata before weakening an unresolved project type.

> If a Godot object is a stable, intentional part of the game world, author it in a scene. Create objects at runtime only when their existence or quantity is genuinely dynamic.

Runtime construction of stable world objects is an actionable review finding unless genuinely dynamic behavior is documented.
