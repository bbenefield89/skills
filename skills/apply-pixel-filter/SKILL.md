---
name: apply-pixel-filter
description: Applies a pixel-art look to a Blender character with one script, saves the result as a new _pixel.blend, and renders one test frame. Use when the user asks to apply a pixel filter or pixel-art look to a Blender model, or asks to see the pixel-art style options.
---

# Apply Pixel Filter

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

## How this skill works

The script `scripts/apply_pixel_filter.py` does all of the work. Your task is to translate the user's words into switches, run the script, and report. Change the look only through switches, so that each run gives the same result.

`<skill-dir>` is the folder of this `SKILL.md`. The script needs Blender 5 and ImageMagick (`magick` on PATH).

## Quick start

```bash
"C:/Program Files (x86)/Steam/steamapps/common/Blender/blender.exe" -b "<input.blend>" --python "<skill-dir>/scripts/apply_pixel_filter.py" -- [switches]
```

With no switches, the script applies the default style. It never changes the input file. The last line is `APPLY PIXEL FILTER OK`.

## Steps

1. If the user asks to see the options, go to [Show the options](#show-the-options).
2. Translate the user's words into switches with the word map in [references/options.md](references/options.md). Use no switch for a group that the user does not mention.
3. If a word has no match in the word map, ask the user. Do not guess a switch.
4. Run the command. If the script prints `apply_pixel_filter.py: error:`, tell the user the problem and the fix in plain words. Do not try other combinations yourself.
5. Report the output files, the switches, and every `NOTICE:` line. Send the enlarged test frame (`*_test_x8.png` or `*_test_x5.png`) to the user.

| Switch | Values (default first) |
|---|---|
| `--method` | `lowres`, `pixelate`, `none` |
| `--pixels` | `128`, `192` |
| `--colors` | `full`, `16` (only with `--shading smooth`) |
| `--shading` | `2tone`, `3tone`, `smooth`, `flat` |
| `--outline` | `outer`, `none` |
| `--camera` | `three-quarter`, `side`, `high`, `isometric`, `front`, or `--azimuth A --elevation E` |
| `--light` | `top-left`, `top-right`, `overhead` |
| `--frame-width` | `2.1` (m of world width in the frame) |
| `--collection` | the collection that holds the character (default: all rendered meshes) |
| `--output` | the output .blend (default: `<name>_pixel.blend` next to the input) |

The reference file gives the exact settings, the combination rules, and the framing rules.

## Plain words

The users are new to pixel art. For each option that you name, give one plain sentence about how it looks. Use the plain lines in the reference file. If you must use a pixel-art term, explain it in the same sentence.

## Show the options

1. Send the 7 GIFs in `<skill-dir>/assets/references/`. In Claude Code, use SendUserFile. In Codex, give the full path of each GIF.
2. For each GIF, give one plain line per option. The label under each cell shows the switch. The default option has "(default)" in its label.
3. Offer a preview on the user's own character. This command renders the same GIFs and does not save the .blend:

```bash
"C:/Program Files (x86)/Steam/steamapps/common/Blender/blender.exe" -b "<input.blend>" --python "<skill-dir>/scripts/render_references.py" -- --out "<folder>"
```

## Options that are not offered

If the user asks for one of these options, tell the user that it is left out on purpose and why. Then offer the nearest option.

- Averaged downscale: it makes soft, blurred pixels at the edges. Offer `--method pixelate`.
- 64 or 96 pixels: the character loses too much detail, for example the face. Offer `--pixels 128`.
- 8 colors: similar colors merge, for example hair, gloves and outline. Offer `--colors 16 --shading smooth`.
- Dithering (a pattern of mixed pixels): the pattern shimmers when the character walks. Offer `--colors 16 --shading smooth`.
- Lines on every part: the lines go across the small face. Offer `--outline outer`.

## Outputs

- `<name>_pixel.blend`: the input with the pixel-art setup. The scene custom property `apply_pixel_filter` holds the full recipe.
- `<name>_pixel_test.png`: one frame at sprite size, after the post-process steps.
- `<name>_pixel_test_x8.png` (`_x5` for 192 px): the same frame, enlarged with nearest-neighbor.

To change a switch, run the script again on the original .blend. The new run replaces the old `_pixel.blend`.

A later step renders PNGs from the `_pixel.blend`. Those PNGs need the post-process command in [references/options.md](references/options.md#post-process-command).

## Out of scope

This skill stops after the setup and the test frame. Sprite sheets, game-engine import and style recommendations are separate tasks.
