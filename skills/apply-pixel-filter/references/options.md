# Pixel filter options

This file is the full reference for `scripts/apply_pixel_filter.py`. `SKILL.md` gives the steps. The script is the source of truth for every value. Run it with `-- --help` for the switch list.

## Word map

Translate the user's words into switches with this table. Combine the switches of all groups that the user mentions.

| The user says | Switches |
|---|---|
| "pixel filter", "pixel-art look", "the default", "the usual" | none |
| "pixelate", "render big and pixelate", "pixelated post-filter" | `--method pixelate` |
| "no pixel look", "smooth", "HD", "not pixelated" (about the whole image) | `--method none` |
| "more pixels", "more detail", "higher resolution", "192" | `--pixels 192` |
| "fewer colors", "16 colors", "limited palette" | `--colors 16 --shading smooth` |
| "3 tones", "a mid tone", "softer cel shading" | `--shading 3tone` |
| "smooth shading", "gradient shading" | `--shading smooth` |
| "flat", "no shading", "no shadows" | `--shading flat` |
| "no outline", "no lines" | `--outline none` |
| "top-down", "action game", "three-quarter" | `--camera three-quarter` |
| "side view", "profile", "platformer" | `--camera side` |
| "RPG", "high angle", "more from above" | `--camera high` |
| "isometric", "iso tiles", "2:1" | `--camera isometric` |
| "front", "portrait", "menu", "facing the camera" | `--camera front` |
| an angle in degrees, for example "60 around, 25 up" | `--azimuth 60 --elevation 25` |
| "light from the right", "shadows on the left" | `--light top-right` |
| "light from above", "overhead light" | `--light overhead` |
| "the character is cut off", "zoom out" | `--frame-width <the value that the error message gives>` |
| "only the character", "only collection X" | `--collection "X"` |
| "save it as ..." | `--output "<path>.blend"` |

"Smooth" can mean `--method none` or `--shading smooth`. If the user does not say "shading" or "the whole image", ask which one.

## Options

Each option has a plain line. Use it when you explain the option to the user.

### Pixelation method: `--method`

| Value | Plain line | Exact settings |
|---|---|---|
| `lowres` (default) | Blender draws the character directly at sprite size, so every edge is a hard pixel step. | Render at the pixel count, `taa_render_samples` 1, `filter_size` 0.0, line thickness 1. Post-process: alpha clip at 50%. |
| `pixelate` | Blender draws a large, smooth image, and the script keeps one pixel from each block. Thin parts can look a little different. | Render at 8 x the pixel count, `taa_render_samples` 16, `filter_size` 1.5, line thickness 8. Post-process: `magick -sample NxN`, then alpha clip at 50%. |
| `none` | A smooth image with soft edges and no pixel look. This is an artistic choice for games that do not use pixel art. | Render at the pixel count, `taa_render_samples` 16, `filter_size` 1.5, line thickness 1. Post-process: none (partial alpha stays). |

### Pixel count: `--pixels`

| Value | Plain line | Exact settings |
|---|---|---|
| `128` (default) | The sprite is 128 x 128 pixels. | Resolution 128 x 128 at 100%. |
| `192` | The same framing with more pixels, so the character has more detail. | Resolution 192 x 192 at 100%. The frame width stays the same. |

### Colors: `--colors`

| Value | Plain line | Exact settings |
|---|---|---|
| `full` (default) | The sprite keeps every color that the render makes. | No color step. |
| `16` | The sprite uses only 16 colors, so smooth shading turns into visible bands. | A 16-color palette, no dither, built from the opaque pixels of the 8 preview frames after the alpha clip. The palette is stored in the recipe. Each render is remapped to it with `+dither -remap`, and the alpha is copied back. |

### Shading: `--shading`

The `PX_CelShade` color ramp turns the light on each surface into a brightness multiplier for the material color.

| Value | Plain line | Exact settings |
|---|---|---|
| `2tone` (default) | Each color has one lit tone and one shadow tone. | CONSTANT ramp: 0.0 is gray 0.62, 0.35 is white. |
| `3tone` | Each color has a shadow tone, a mid tone and a lit tone. | CONSTANT ramp: 0.0 is 0.55, 0.25 is 0.80, 0.60 is 1.0. |
| `smooth` | The light changes gradually from shadow to lit, with no hard steps. | LINEAR ramp: 0.12 is 0.62, 0.95 is 1.0. |
| `flat` | No light and no shadow. Every pixel is its exact material color. | CONSTANT ramp, both stops white (0.0 and 0.35). Never the default. |

### Outline: `--outline`

| Value | Plain line | Exact settings |
|---|---|---|
| `outer` (default) | A dark line, 1 pixel wide, goes around the outside of the character. | Freestyle on, ABSOLUTE thickness, first lineset by visibility and edge types, external contour only. Line color linear (0.05, 0.035, 0.03). |
| `none` | No line. The edge of the character is its fill color. | `render.use_freestyle = False`. |

### Camera: `--camera`, or `--azimuth` and `--elevation`

All cameras are orthographic `PX_Camera`. Azimuth turns around the character from the front. A positive azimuth shows the character's left side. Elevation is the angle above the horizon. The rotation is `(90 - elevation, 0, azimuth)` degrees.

| Value | Azimuth / elevation | Plain line |
|---|---|---|
| `three-quarter` (default) | 35 / 20 | Seen from the front-left and a little from above. Used for top-down action games. |
| `side` | 90 / 0 | Seen exactly from the side, in profile. Used for platformers. |
| `high` | 35 / 50 | Seen more from above. Used for classic top-down RPGs. |
| `isometric` | 45 / 30 | Seen diagonally from above. Floor lines become 2:1 pixel steps, which match isometric tiles. |
| `front` | 0 / 10 | Seen from the front. Used for portraits and menus. |
| custom | `--azimuth A --elevation E` | Any angle. Elevation is 0 to 89. |

### Light: `--light`

The light turns with the camera. Its direction is fixed on the screen, so the shadows fall on the same side at every camera angle. The light is `PX_Sun`: a sun, energy 3.0, angle 0.

| Value | Direction toward the light in camera space (right, up, toward the viewer) | Plain line |
|---|---|---|
| `top-left` (default) | (-0.720, 0.514, 0.466) | The light comes from the upper left of the screen, the usual pixel-art direction. |
| `top-right` | (0.720, 0.514, 0.466) | The light comes from the upper right, so the shadows go to the left. |
| `overhead` | (0, 0.940, 0.342) | The light comes from the top of the screen, a little toward the viewer. |

`top-left` comes from the approved setup: with the default camera, `PX_Sun` has the rotation (50, 0, -35) degrees.

## Combination rules

The script checks these rules before it changes anything. An error stops the run with exit code 1 and writes no file.

| Rule | Result |
|---|---|
| `--colors 16` without `--shading smooth` | Error. Cel shading already uses few colors. |
| `--method none` with `--colors 16` | Error. `none` keeps the smooth render: no alpha clip and no color step. |
| `--camera` with `--azimuth` or `--elevation` | Error. Use one or the other. |
| `--azimuth` without `--elevation`, or the opposite | Error. A custom angle needs both. |
| `--elevation` outside 0 to 89 | Error. |
| `--frame-width` outside 0.1 to 100 | Error. |
| The character does not fit in the frame | Error. The message gives the `--frame-width` value that fits. |
| `--collection` does not exist or has no rendered mesh | Error. |
| `--output` is the input file | Error. The skill never changes the input. |
| `--shading flat` | Notice: the light has no effect. The run continues. |

## Framing

- The camera centers on the character. The script reads the evaluated mesh vertices at every frame of the character's action range. Without an action, it uses the current frame.
- The camera moves only in whole pixels from a fixed grid anchor at world (0, 0, 0.9). This anchor is the aim point of the approved setup, so the default matches that setup pixel for pixel. The CozySpaceSurvivor default is 5 px lower than the old setup, because it is centered now.
- The frame width (`ortho_scale`) is 2.1 m at every pixel count. Characters of one game then have the same pixel size. Use the same `--frame-width` for all characters of one game.
- The character must stay 1.5 px inside each edge. If not, the run stops and names the `--frame-width` value that fits.
- The test frame is the first frame of the action, or the current frame without an action.
- The 8 preview frames (palette and reference GIFs) divide the action evenly. For a cyclic action of 24 frames from frame 1, they are 1, 4, 7, 10, 13, 16, 19 and 22.

## What else the script sets

The script sets these values on every run, so the result does not depend on the earlier state of the file:

- EEVEE, transparent film, Standard view transform, look None, exposure 0, gamma 1, PNG RGBA 8 bit.
- `dither_intensity` 0. Pixel art needs exact colors. Blender's default noise dither changes about 2,500 pixels by 1 level and makes extra colors.
- Compositing and sequencer off. Only the active view layer renders.
- The world `PX_World`: a uniform gray background (Blender's default, linear 0.0509) for the ambient light.
- Other lights are hidden from render. `PX_Sun` is the only light.
- With `--collection`, rendered objects outside the collection are hidden from render.
- Materials: each Principled BSDF Base Color feeds the `PX_CelShade` group. A plain color is copied. A texture link is connected to the group. Materials without a Principled BSDF stay unchanged. The script lists them in a notice.
- The `PX_CelShade` group, `PX_Camera` and `PX_Sun` keep their names and are rebuilt on each run.

## Post-process command

Some steps happen after the render: the point-sample of `pixelate`, the alpha clip, and the 16-color remap. The recipe in the scene custom property `apply_pixel_filter` stores them. Use this command for every PNG that is rendered from a `_pixel.blend`:

```bash
"C:/Program Files (x86)/Steam/steamapps/common/Blender/blender.exe" -b "<name>_pixel.blend" --python "<skill-dir>/scripts/apply_pixel_filter.py" -- --postprocess "<png or folder>" [...] --post-out "<folder>"
```

The command renders nothing and saves nothing. It writes each PNG with the same file name into `--post-out`. The input PNG must have the render size of the recipe. The test frame goes through the same steps. The last line is `POSTPROCESS OK`.

## Reference GIFs

`assets/references/` holds 7 GIFs from `CozySpaceSurvivor.blend`: `Pixelation_Method`, `Pixel_Density`, `Colors`, `Shading`, `Outline`, `Camera` and `Light`. Each GIF shows the 8 preview frames, one walk cycle per second, in 384 x 384 cells. Each label shows the option and its switch. The default option's label ends with "(default)". Only offered options appear.

`scripts/render_references.py` builds them with the same settings code as the apply script. It never saves the .blend. To rebuild the shipped GIFs, run it on a copy of `CozySpaceSurvivor.blend` with `--out "<skill-dir>/assets/references"`.
