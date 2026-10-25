"""Builds the reference GIFs that show each pixel-filter option, without saving the .blend.

    blender.exe -b <file.blend> --python render_references.py -- [--out FOLDER] [--collection NAME] [--only GIF ...]

It uses the settings code of apply_pixel_filter.py (setup_scene and postprocess_file), so
every cell shows exactly what the apply command produces with the switch in its label.
Each variant is set up from scratch, so variants never stack. There is no save call.

Output (default folder: <name>_pixel_options next to the .blend): Pixelation_Method.gif,
Pixel_Density.gif, Colors.gif, Shading.gif, Outline.gif, Camera.gif and Light.gif.
Layout: 8 preview frames (for a 24-frame cycle starting at 1: 1, 4, 7, ..., 22), delays
12/13 cs that sum to 100 (one cycle per second), 384 x 384 cells on #b8b4ae, a title strip
and a two-line label under each cell (the option, then its switch). The default option's
label ends with "(default)". Pixel output is upscaled with nearest-neighbor; --method none
is resized smoothly.

Checks (an error names the GIF, option and frame): every cell keeps a transparent margin
(the whole character is in view); neighboring options differ; each GIF has 8 frames, the
expected size and delays that sum to 100. Prints a table with each GIF's size, then
REFERENCES OK. Scratch files go to the system temp folder.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile

import bpy
import numpy as np

sys.dont_write_bytecode = True   # keep the skill folder free of __pycache__
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import apply_pixel_filter as apf  # noqa: E402

DELAYS = [12, 13, 12, 13, 12, 13, 12, 13]   # centiseconds, sum 100
CELL = 384
BG = "#b8b4ae"
INK = "#2a2420"
GAP = 12
TITLE_H = 56
LABEL_H = 72

# (file stem, title, the switch that names the default, [(option name, overrides)]).
# The first option of each GIF is the default; its overrides are empty.
GIFS = [
    ("Pixelation_Method", "Pixelation method: how the pixels are made", "--method lowres", [
        ("Low-res render", {}),
        ("Big render, pixelated", {"method": "pixelate"}),
        ("Smooth, no pixel look", {"method": "none"}),
    ]),
    ("Pixel_Density", "Pixel count: how many pixels the character gets", "--pixels 128", [
        ("128 px", {}),
        ("192 px, same framing", {"pixels": 192}),
    ]),
    ("Colors", "Colors: how many colors the sprite uses", "--colors full", [
        ("Full palette", {}),
        ("Smooth shading, full palette", {"shading": "smooth"}),
        ("Smooth shading, 16 colors", {"shading": "smooth", "colors": "16"}),
    ]),
    ("Shading", "Shading: light and shadow drawn into the sprite", "--shading 2tone", [
        ("2 tones", {}),
        ("3 tones", {"shading": "3tone"}),
        ("Smooth", {"shading": "smooth"}),
        ("Flat, no shading", {"shading": "flat"}),
    ]),
    ("Outline", "Outline: a dark line around the character", "--outline outer", [
        ("Outer outline", {}),
        ("No outline", {"outline": "none"}),
    ]),
    ("Camera", "Camera: the angle the character is seen from", "--camera three-quarter", [
        ("Three-quarter", {}),
        ("Side", {"camera": "side"}),
        ("High", {"camera": "high"}),
        ("Isometric", {"camera": "isometric"}),
        ("Front", {"camera": "front"}),
    ]),
    ("Light", "Light: where the light comes from on screen", "--light top-left", [
        ("Top-left", {}),
        ("Top-right", {"light": "top-right"}),
        ("Overhead", {"light": "overhead"}),
    ]),
]


def log(*parts):
    print("[render-references]", *parts, flush=True)


def magick(*args):
    apf.magick(*args)


def cell(src, dst, smooth):
    scale = ["-resize", f"{CELL}x{CELL}"] if smooth else ["-filter", "point", "-resize", f"{CELL}x{CELL}"]
    magick(src, *scale, "-background", BG, "-alpha", "remove", "-alpha", "off", "+repage", "PNG24:" + dst)
    return dst


def text_png(text, w, h, size, path, bold=False):
    magick("-size", f"{w}x{h}", "-background", BG, "-fill", INK, "-gravity", "center",
           "-pointsize", str(size), "-font", "Arial-Bold" if bold else "Arial", "caption:" + text,
           "PNG24:" + path)
    return path


def gif_size(n):
    return n * CELL + (n + 1) * GAP, TITLE_H + CELL + LABEL_H + GAP


class VariantCache:
    """Renders each option set once: 8 post-processed frames, then 8 cells."""

    def __init__(self, tmp, base):
        self.tmp, self.base, self.done = tmp, base, {}

    def cells(self, opts):
        key = json.dumps({k: opts[k] for k in apf.DEFAULTS}, sort_keys=True)
        if key in self.done:
            return self.done[key]
        tag = f"v{len(self.done):02d}"
        info = apf.setup_scene(opts, self.tmp)
        recipe, frames = info["recipe"], info["frames"]["preview"]
        sc = bpy.context.scene
        cells = []
        try:
            for i, f in enumerate(frames):
                raw = apf.render_frame(f, os.path.join(self.tmp, f"{tag}_raw_{i}.png"))
                post = apf.postprocess_file(raw, os.path.join(self.tmp, f"{tag}_post_{i}.png"), recipe, self.tmp)
                margin = apf.opaque_margin(apf.read_rgba(post))
                if margin is None or margin < 1:
                    raise apf.PixelFilterError(f"{apf.switches_for(opts) or 'defaults'} frame {f}: the "
                                               f"character touches the edge (margin {margin} px)")
                cells.append(cell(post, os.path.join(self.tmp, f"{tag}_cell_{i}.png"), opts["method"] == "none"))
        finally:
            sc.frame_set(info["start_frame"])
        log(f"{apf.switches_for(opts) or 'defaults'}: frames {frames}, render {recipe['render_size']} px, "
            f"post: {apf.post_steps(recipe)}")
        self.done[key] = cells
        return cells


def check_different(stem, labels, columns):
    for i in range(len(columns) - 1):
        a = apf.read_rgba(columns[i][0]).astype(int)
        b = apf.read_rgba(columns[i + 1][0]).astype(int)
        changed = float(np.mean(np.any(a != b, axis=2)))
        if changed == 0.0:
            raise apf.PixelFilterError(f"{stem}: '{labels[i]}' and '{labels[i + 1]}' look the same")
        log(f"{stem}: '{labels[i]}' vs '{labels[i + 1]}': {changed:.1%} of frame-0 cell pixels differ")


def build_gif(stem, title, labels, columns, tmp, out):
    n = len(columns)
    width, height = gif_size(n)
    title_png = text_png(title, width, TITLE_H, 26, os.path.join(tmp, f"{stem}_title.png"), bold=True)
    label_pngs = [text_png(lab, CELL, LABEL_H, 19, os.path.join(tmp, f"{stem}_label{i}.png"))
                  for i, lab in enumerate(labels)]
    frames = []
    for fi in range(len(DELAYS)):
        cmd = ["-size", f"{width}x{height}", f"xc:{BG}", title_png, "-geometry", "+0+0", "-composite"]
        for ci, cells in enumerate(columns):
            x = GAP + ci * (CELL + GAP)
            cmd += [cells[fi], "-geometry", f"+{x}+{TITLE_H}", "-composite",
                    label_pngs[ci], "-geometry", f"+{x}+{TITLE_H + CELL}", "-composite"]
        path = os.path.join(tmp, f"{stem}_f{fi}.png")
        magick(*cmd, "+repage", "PNG24:" + path)
        frames.append(path)
    cmd = ["-loop", "0"]
    for f, d in zip(frames, DELAYS):
        cmd += ["-delay", str(d), f]
    magick(*cmd, "+repage", out)
    return check_gif(out, (width, height))


def check_gif(path, size):
    r = subprocess.run(["magick", "identify", "-format", "%w %h %T\n", path],
                       capture_output=True, text=True, check=True)
    rows = [line.split() for line in r.stdout.strip().splitlines()]
    sizes = {(int(w), int(h)) for w, h, _ in rows}
    delays = [int(d) for _, _, d in rows]
    name = os.path.basename(path)
    if len(delays) != len(DELAYS):
        raise apf.PixelFilterError(f"{name}: {len(delays)} frames, expected {len(DELAYS)}")
    if sizes != {size}:
        raise apf.PixelFilterError(f"{name}: frame sizes {sizes}, expected {size}")
    if sum(delays) != 100:
        raise apf.PixelFilterError(f"{name}: delays sum to {sum(delays)}, expected 100")
    return name, len(delays), size, delays, os.path.getsize(path)


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    p = argparse.ArgumentParser(prog="render_references.py",
                                description="Build the pixel-filter option GIFs for the open .blend.")
    p.add_argument("--out", help="output folder (default <name>_pixel_options next to the .blend)")
    p.add_argument("--collection", help="collection that holds the character (as in apply_pixel_filter.py)")
    p.add_argument("--only", nargs="+", choices=[g[0] for g in GIFS], help="build only these GIFs")
    args = p.parse_args(argv)
    try:
        if not shutil.which("magick"):
            raise apf.PixelFilterError("magick (ImageMagick) is needed to build the GIFs")
        if not bpy.data.filepath:
            raise apf.PixelFilterError("open a saved .blend")
        out_dir = os.path.abspath(args.out or os.path.splitext(bpy.data.filepath)[0] + "_pixel_options")
        os.makedirs(out_dir, exist_ok=True)
        base = {"collection": args.collection}
        rows = []
        with tempfile.TemporaryDirectory(prefix="apf_refs_") as tmp:
            cache = VariantCache(tmp, base)
            for stem, title, default_switch, options in GIFS:
                if args.only and stem not in args.only:
                    continue
                labels, columns = [], []
                for name, overrides in options:
                    opts = apf.make_options(**base, **overrides)
                    if overrides:
                        switch = apf.switches_for(opts)
                        if args.collection:
                            switch = switch.replace(f' --collection "{args.collection}"', "")
                        labels.append(f"{name}\n{switch}")
                    else:
                        labels.append(f"{name}\n{default_switch} (default)")
                    columns.append(cache.cells(opts))
                check_different(stem, [lab.replace("\n", " ") for lab in labels], columns)
                rows.append(build_gif(stem, title, labels, columns, tmp, os.path.join(out_dir, stem + ".gif")))
                log("[gif]", os.path.join(out_dir, stem + ".gif"))
    except apf.PixelFilterError as err:
        print(f"render_references.py: error: {err}", file=sys.stderr, flush=True)
        sys.exit(1)
    print(f"{'file':<22} | {'frames':>6} | {'size (px)':<11} | {'bytes':>9} | delays (1/100 s), sum")
    for name, n, size, delays, nbytes in rows:
        dims = f"{size[0]}x{size[1]}"
        print(f"{name:<22} | {n:>6} | {dims:<11} | {nbytes:>9} | {delays}, {sum(delays)}")
    print("REFERENCES OK", flush=True)


if __name__ == "__main__":
    main()
