# Scene authoring

> If a Godot object is a stable, intentional part of the game world, author it in a scene. Create objects at runtime only when their existence or quantity is genuinely dynamic.

Stable walls, authored characters, cameras, spawn points, collision geometry, and persistent UI belong in `.tscn` scenes. Projectiles, procedural enemies, generated terrain, pooled effects, and variable data-driven populations may be dynamic.

Treat `Node.new()`, scripted child assembly, or equivalent construction of a stable object as actionable unless the code documents a genuinely dynamic reason. Ask before a correction changes behavior or architecture.
