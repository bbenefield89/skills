"""Applies a pixel-art look to a Blender character and saves the result as a new .blend.

Apply (never changes the input; writes <name>_pixel.blend and a test frame next to it):

    blender.exe -b <input.blend> --python apply_pixel_filter.py -- [switches]

Post-process rendered PNGs with the recipe saved in a _pixel.blend (alpha clip,
pixelate's point-sample down, the 16-color palette). Renders nothing, saves nothing:

    blender.exe -b <name>_pixel.blend --python apply_pixel_filter.py -- --postprocess <png or folder> [...] --post-out <folder>

With no switches, the result is the default style: low-res render at 128 x 128, full
palette, 2-tone cel shading, outer outline, three-quarter camera, top-left light.
Run with --help for the switches. Invalid combinations stop with a message that names the
fix. Notices (for example materials left unchanged) are printed and do not stop the run.
The last line is "APPLY PIXEL FILTER OK" (apply) or "POSTPROCESS OK" (post-process).

render_references.py imports this file and uses the same settings code.
"""
import argparse
import glob
import hashlib
import json
import math
import os
import shutil
import subprocess
import sys
import tempfile

import bpy
import numpy as np
from mathutils import Euler, Vector

# ---------------------------------------------------------------- the options

METHODS = ("lowres", "pixelate", "none")
PIXELS = (128, 192)
COLORS = ("full", "16")
SHADINGS = ("2tone", "3tone", "smooth", "flat")
OUTLINES = ("outer", "none")
# Camera presets: (azimuth, elevation) in degrees. Azimuth turns around world Z from the
# front (-Y); a positive azimuth shows the character's left side (+X).
CAMERAS = {
    "three-quarter": (35.0, 20.0),
    "side": (90.0, 0.0),
    "high": (35.0, 50.0),
    "isometric": (45.0, 30.0),
    "front": (0.0, 10.0),
}
LIGHTS = ("top-left", "top-right", "overhead")
DEFAULTS = {
    "method": "lowres", "pixels": 128, "colors": "full", "shading": "2tone", "outline": "outer",
    "camera": "three-quarter", "azimuth": None, "elevation": None, "light": "top-left",
    "frame_width": 2.1, "collection": None,
}
ELEVATION_RANGE = (0.0, 89.0)
FRAME_WIDTH_RANGE = (0.1, 100.0)

# ---------------------------------------------------------------- fixed style values

CAMERA_NAME = "PX_Camera"
SUN_NAME = "PX_Sun"
GROUP_NAME = "PX_CelShade"
CEL_NODE = "PX_CelShade"
WORLD_NAME = "PX_World"
LINESET_NAME = "PX_Outline"
RECIPE_KEY = "apply_pixel_filter"
RECIPE_VERSION = 1

# Color ramps of PX_CelShade: (interpolation, [(position, gray value)]).
RAMPS = {
    "2tone": ("CONSTANT", [(0.0, 0.62), (0.35, 1.0)]),
    "3tone": ("CONSTANT", [(0.0, 0.55), (0.25, 0.80), (0.60, 1.0)]),
    "smooth": ("LINEAR", [(0.12, 0.62), (0.95, 1.0)]),
    "flat": ("CONSTANT", [(0.0, 1.0), (0.35, 1.0)]),
}
PIXELATE_FACTOR = 8            # pixelate renders at 8x the pixel count, then point-samples down
SMOOTH_SAMPLES = 16            # taa_render_samples for pixelate and none
SMOOTH_FILTER = 1.5            # filter_size (px) for pixelate and none
OUTLINE_COLOR = (0.05, 0.035, 0.03)   # linear
SUN_ENERGY = 3.0
WORLD_COLOR = (0.05087608844041824, 0.05087608844041824, 0.05087608844041824, 1.0)  # Blender default gray
# Pixel-grid anchor: the camera centre is moved from this point in whole pixels only. It is
# the aim point of the approved CozySpaceSurvivor setup, so the default reproduces that setup
# pixel for pixel (shifted by whole pixels at most).
GRID_ANCHOR = (0.0, 0.0, 0.9)
CAMERA_DISTANCE = 10.0
EDGE_MARGIN_PX = 1.5           # geometry must stay this far inside each image edge
PALETTE_SIZE = 16
PREVIEW_FRAME_COUNT = 8
FILL_SRGB = "#3f3430"          # RGB under transparent pixels before the palette remap
EDGE_TYPES = ("silhouette", "border", "crease", "ridge_valley", "suggestive_contour",
              "material_boundary", "contour", "external_contour", "edge_mark")
GEOMETRY_TYPES = {"MESH", "CURVE", "SURFACE", "FONT", "META", "CURVES"}
EEVEE_FIXED = {   # EEVEE settings that change the look; the values are Blender's defaults
    "use_shadows": True, "shadow_ray_count": 1, "shadow_step_count": 6,
    "shadow_resolution_scale": 1.0, "use_raytracing": False, "light_threshold": 0.01,
    "use_volumetric_shadows": False, "use_overscan": False,
}


class PixelFilterError(Exception):
    """A problem the user must fix; the message names the fix."""


def camera_rotation(azimuth, elevation):
    """Rotation matrix of a camera at this azimuth/elevation. Columns: right, up, back."""
    return Euler((math.radians(90.0 - elevation), 0.0, math.radians(azimuth)), "XYZ").to_matrix()


def _light_vectors():
    """Direction toward the light in camera space (right, up, toward the viewer).

    top-left is taken from the approved setup: PX_Sun at rotation (50, 0, -35) seen from the
    three-quarter camera. It is about (-0.72, 0.52, 0.47).
    """
    travel = Euler([math.radians(a) for a in (50.0, 0.0, -35.0)], "XYZ").to_matrix() @ Vector((0, 0, -1))
    toward = camera_rotation(*CAMERAS["three-quarter"]).transposed() @ -travel
    tl = tuple(toward.normalized())
    over = math.radians(20.0)   # overhead: from the top of the screen, 20 degrees toward the viewer
    return {"top-left": tl, "top-right": (-tl[0], tl[1], tl[2]),
            "overhead": (0.0, math.cos(over), math.sin(over))}


LIGHT_VECTORS = _light_vectors()


def log(*parts):
    print("[apply-pixel-filter]", *parts, flush=True)


# ---------------------------------------------------------------- options and rules

def make_options(**given):
    """Return the full option dict for these switches, or raise PixelFilterError.

    `given` holds only the switches the user set (None means not set).
    """
    given = {k: v for k, v in given.items() if v is not None}
    unknown = set(given) - set(DEFAULTS)
    if unknown:
        raise PixelFilterError(f"unknown options {sorted(unknown)}")
    opts = dict(DEFAULTS, **given)
    opts["light_given"] = "light" in given

    if opts["method"] not in METHODS:
        raise PixelFilterError(f"--method must be one of {', '.join(METHODS)}")
    if opts["pixels"] not in PIXELS:
        raise PixelFilterError(f"--pixels must be one of {', '.join(map(str, PIXELS))}")
    if opts["colors"] not in COLORS:
        raise PixelFilterError(f"--colors must be one of {', '.join(COLORS)}")
    if opts["shading"] not in SHADINGS:
        raise PixelFilterError(f"--shading must be one of {', '.join(SHADINGS)}")
    if opts["outline"] not in OUTLINES:
        raise PixelFilterError(f"--outline must be one of {', '.join(OUTLINES)}")
    if opts["light"] not in LIGHTS:
        raise PixelFilterError(f"--light must be one of {', '.join(LIGHTS)}")

    # Camera: a preset, or a custom angle from --azimuth and --elevation together.
    custom = [k for k in ("azimuth", "elevation") if k in given]
    if custom:
        if "camera" in given:
            raise PixelFilterError("use --camera <preset> or --azimuth/--elevation, not both")
        if len(custom) != 2:
            raise PixelFilterError("a custom camera angle needs both --azimuth and --elevation")
        lo, hi = ELEVATION_RANGE
        if not lo <= opts["elevation"] <= hi:
            raise PixelFilterError(f"--elevation must be from {lo:g} to {hi:g} degrees "
                                   "(0 is level with the character, 89 is almost straight down)")
        opts["camera"] = "custom"
        opts["azimuth"] = (opts["azimuth"] + 180.0) % 360.0 - 180.0
    else:
        if opts["camera"] not in CAMERAS:
            raise PixelFilterError(f"--camera must be one of {', '.join(CAMERAS)}")
        opts["azimuth"], opts["elevation"] = CAMERAS[opts["camera"]]

    lo, hi = FRAME_WIDTH_RANGE
    if not lo <= opts["frame_width"] <= hi:
        raise PixelFilterError(f"--frame-width must be from {lo:g} to {hi:g} m")

    # Combination rules.
    if opts["method"] == "none" and opts["colors"] != "full":
        raise PixelFilterError("--method none keeps the smooth render and allows no color reduction. "
                               "Use --colors full, or choose --method lowres or pixelate.")
    if opts["colors"] == "16" and opts["shading"] != "smooth":
        raise PixelFilterError(f"--colors 16 works only with --shading smooth (found --shading "
                               f"{opts['shading']}). Add --shading smooth, or use --colors full: "
                               "cel shading already uses few colors.")
    return opts


def option_notices(opts):
    notes = []
    if opts["shading"] == "flat":
        notes.append(("--light " + opts["light"] if opts["light_given"] else "The light")
                     + " has no effect with --shading flat: every pixel is its exact material color.")
    return notes


def switches_for(opts):
    """The switches that differ from the defaults, as a command-line string."""
    parts = []
    for key in ("method", "pixels", "colors", "shading", "outline"):
        if opts[key] != DEFAULTS[key]:
            parts.append(f"--{key} {opts[key]}")
    if opts["camera"] == "custom":
        parts.append(f"--azimuth {opts['azimuth']:g} --elevation {opts['elevation']:g}")
    elif opts["camera"] != DEFAULTS["camera"]:
        parts.append(f"--camera {opts['camera']}")
    if opts["light"] != DEFAULTS["light"]:
        parts.append(f"--light {opts['light']}")
    if opts["frame_width"] != DEFAULTS["frame_width"]:
        parts.append(f"--frame-width {opts['frame_width']:g}")
    if opts["collection"]:
        parts.append(f'--collection "{opts["collection"]}"')
    return " ".join(parts)


def render_size(opts):
    return opts["pixels"] * (PIXELATE_FACTOR if opts["method"] == "pixelate" else 1)


# ---------------------------------------------------------------- the character

def render_visible_objects():
    """Objects that render in the active view layer (collections not excluded or hidden)."""
    found = []

    def walk(layer_coll, hidden):
        if layer_coll.exclude:
            return
        hidden = hidden or layer_coll.collection.hide_render
        if not hidden:
            for obj in layer_coll.collection.objects:
                if not obj.hide_render and obj not in found:
                    found.append(obj)
        for child in layer_coll.children:
            walk(child, hidden)

    walk(bpy.context.view_layer.layer_collection, False)
    return found


def character_objects(collection_name):
    """(character objects, objects hidden from render because they are outside --collection)."""
    visible = [o for o in render_visible_objects() if o.type in GEOMETRY_TYPES]
    if collection_name is None:
        if not visible:
            raise PixelFilterError("the scene has no rendered mesh objects")
        return visible, []
    coll = bpy.data.collections.get(collection_name)
    if coll is None:
        names = ", ".join(sorted(c.name for c in bpy.data.collections)) or "none"
        raise PixelFilterError(f'--collection "{collection_name}" does not exist (collections: {names})')
    members = set(coll.all_objects)
    chars = [o for o in visible if o in members]
    if not chars:
        raise PixelFilterError(f'--collection "{collection_name}" has no rendered mesh objects')
    others = [o for o in visible if o not in members]
    for obj in others:
        obj.hide_render = True
    return chars, others


def find_actions(chars):
    """Actions that move the character: on the objects, their parents and armature targets."""
    found = []

    def add(obj):
        ad = obj.animation_data
        if ad and ad.action and ad.action not in found:
            found.append(ad.action)

    for obj in chars:
        add(obj)
        parent = obj.parent
        while parent:
            add(parent)
            parent = parent.parent
        for mod in obj.modifiers:
            if mod.type == "ARMATURE" and mod.object:
                add(mod.object)
    return found


def frame_info(chars):
    """Frame range used for framing, the 8 preview frames, and the test frame."""
    actions = find_actions(chars)
    sc = bpy.context.scene
    if not actions:
        f = sc.frame_current
        return {"actions": [], "start": f, "end": f, "test": f, "preview": [f] * PREVIEW_FRAME_COUNT}
    start = min(int(math.floor(a.frame_range[0])) for a in actions)
    end = max(int(math.ceil(a.frame_range[1])) for a in actions)
    cyclic = all(getattr(a, "use_cyclic", False) for a in actions)
    length = max(1, end - start if cyclic and end > start else end - start + 1)
    preview = [start + (k * length) // PREVIEW_FRAME_COUNT for k in range(PREVIEW_FRAME_COUNT)]
    return {"actions": [a.name for a in actions], "start": start, "end": end, "test": start,
            "preview": preview}


def projected_bounds(chars, frames, rot):
    """Min and max of the character's evaluated vertices over the frames, in camera axes
    (right, up, back) measured from GRID_ANCHOR."""
    sc = bpy.context.scene
    axes = np.array([list(rot.col[i]) for i in range(3)])   # rows: right, up, back
    anchor = np.array(GRID_ANCHOR)
    lo = np.full(3, np.inf)
    hi = np.full(3, -np.inf)
    for f in frames:
        sc.frame_set(f)
        dg = bpy.context.evaluated_depsgraph_get()
        for obj in chars:
            ev = obj.evaluated_get(dg)
            try:
                me = ev.to_mesh()
            except RuntimeError:
                continue
            n = len(me.vertices)
            if n:
                co = np.empty(n * 3)
                me.vertices.foreach_get("co", co)
                mw = np.array(ev.matrix_world)
                world = co.reshape(-1, 3) @ mw[:3, :3].T + mw[:3, 3]
                cam = (world - anchor) @ axes.T
                lo = np.minimum(lo, cam.min(axis=0))
                hi = np.maximum(hi, cam.max(axis=0))
            ev.to_mesh_clear()
    if not np.isfinite(lo).all():
        raise PixelFilterError("the character objects have no vertices to frame")
    return lo, hi


# ---------------------------------------------------------------- materials

def socket(sockets, identifier):
    return next(s for s in sockets if s.identifier == identifier)


def set_ramp(ramp, spec):
    interp, stops = spec
    ramp.interpolation = interp
    ramp.color_mode = "RGB"
    while len(ramp.elements) > 1:
        ramp.elements.remove(ramp.elements[-1])
    ramp.elements[0].position = stops[0][0]
    ramp.elements[0].color = (stops[0][1],) * 3 + (1.0,)
    for pos, gray in stops[1:]:
        ramp.elements.new(pos).color = (gray,) * 3 + (1.0,)


def cel_group(shading):
    """PX_CelShade: Color in, cel-shaded emission out. Rebuilt on every run so it is exact."""
    group = bpy.data.node_groups.get(GROUP_NAME)
    if group is None:
        group = bpy.data.node_groups.new(GROUP_NAME, "ShaderNodeTree")
    items = {(i.in_out, i.name, i.socket_type) for i in group.interface.items_tree if i.item_type == "SOCKET"}
    if items != {("INPUT", "Color", "NodeSocketColor"), ("OUTPUT", "Shader", "NodeSocketShader")}:
        group.interface.clear()
        group.interface.new_socket("Color", in_out="INPUT", socket_type="NodeSocketColor")
        group.interface.new_socket("Shader", in_out="OUTPUT", socket_type="NodeSocketShader")
    nodes, links = group.nodes, group.links
    nodes.clear()
    gin = nodes.new("NodeGroupInput")
    gout = nodes.new("NodeGroupOutput")
    diffuse = nodes.new("ShaderNodeBsdfDiffuse")
    diffuse.inputs["Color"].default_value = (1, 1, 1, 1)
    to_rgb = nodes.new("ShaderNodeShaderToRGB")
    ramp = nodes.new("ShaderNodeValToRGB")
    set_ramp(ramp.color_ramp, RAMPS[shading])
    mix = nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.blend_type = "MULTIPLY"
    socket(mix.inputs, "Factor_Float").default_value = 1.0
    emission = nodes.new("ShaderNodeEmission")
    links.new(diffuse.outputs["BSDF"], to_rgb.inputs["Shader"])
    links.new(to_rgb.outputs["Color"], ramp.inputs["Fac"])
    links.new(gin.outputs["Color"], socket(mix.inputs, "A_Color"))
    links.new(ramp.outputs["Color"], socket(mix.inputs, "B_Color"))
    links.new(socket(mix.outputs, "Result_Color"), emission.inputs["Color"])
    links.new(emission.outputs["Emission"], gout.inputs["Shader"])
    for i, node in enumerate((gin, diffuse, to_rgb, ramp, mix, emission, gout)):
        node.location = (i * 220, 0)
    return group


def character_materials(chars):
    mats, bare = [], []
    for obj in chars:
        slots = [s.material for s in obj.material_slots if s.material]
        if not slots:
            bare.append(obj.name)
        for m in slots:
            if m not in mats:
                mats.append(m)
    return mats, bare


def apply_cel(group, mats):
    """Wire PX_CelShade to each material's output, fed from its Principled BSDF Base Color.

    Returns (changed material names, unchanged material names)."""
    changed, unchanged = [], []
    for mat in mats:
        tree = mat.node_tree
        if tree is None:
            unchanged.append(mat.name)
            continue
        nodes, links = tree.nodes, tree.links
        outputs = [n for n in nodes if n.type == "OUTPUT_MATERIAL"]
        output = next((n for n in outputs if n.is_active_output), outputs[0] if outputs else None)
        bsdfs = [n for n in nodes if n.type == "BSDF_PRINCIPLED"]
        if output is None or not bsdfs:
            unchanged.append(mat.name)
            continue
        linked = [b for b in bsdfs if any(l.to_node == output for l in b.outputs["BSDF"].links)]
        named = nodes.get("Principled BSDF")
        bsdf = linked[0] if linked else (named if named in bsdfs else bsdfs[0])
        cel = nodes.get(CEL_NODE)
        if cel is None or cel.type != "GROUP":
            cel = nodes.new("ShaderNodeGroup")
            cel.name = CEL_NODE
        cel.label = CEL_NODE
        cel.node_tree = group
        cel.location = (bsdf.location.x, bsdf.location.y + 260)
        base = bsdf.inputs["Base Color"]
        color_in = cel.inputs["Color"]
        for link in list(color_in.links):
            links.remove(link)
        color_in.default_value = base.default_value
        if base.is_linked:
            links.new(base.links[0].from_socket, color_in)
        links.new(cel.outputs["Shader"], output.inputs["Surface"])
        changed.append(mat.name)
    return changed, unchanged


# ---------------------------------------------------------------- scene settings

def setup_world():
    world = bpy.data.worlds.get(WORLD_NAME) or bpy.data.worlds.new(WORLD_NAME)
    if world.node_tree is None and hasattr(world, "use_nodes"):
        world.use_nodes = True
    tree = world.node_tree
    tree.nodes.clear()
    bg = tree.nodes.new("ShaderNodeBackground")
    bg.inputs["Color"].default_value = WORLD_COLOR
    bg.inputs["Strength"].default_value = 1.0
    out = tree.nodes.new("ShaderNodeOutputWorld")
    out.location = (300, 0)
    tree.links.new(bg.outputs["Background"], out.inputs["Surface"])
    world.color = WORLD_COLOR[:3]
    bpy.context.scene.world = world


def hide_other_lights():
    hidden = []
    for obj in render_visible_objects():
        if obj.type == "LIGHT" and obj.name != SUN_NAME:
            obj.hide_render = True
            hidden.append(obj.name)
    return hidden


def setup_render(opts):
    sc = bpy.context.scene
    r = sc.render
    smooth = opts["method"] != "lowres"
    r.engine = "BLENDER_EEVEE"
    sc.eevee.taa_render_samples = SMOOTH_SAMPLES if smooth else 1
    for key, value in EEVEE_FIXED.items():
        if hasattr(sc.eevee, key):
            setattr(sc.eevee, key, value)
    r.filter_size = SMOOTH_FILTER if smooth else 0.0
    r.resolution_x = r.resolution_y = render_size(opts)
    r.resolution_percentage = 100
    r.pixel_aspect_x = r.pixel_aspect_y = 1.0
    r.use_border = False
    r.film_transparent = True
    r.dither_intensity = 0.0
    r.use_motion_blur = False
    r.use_compositing = False
    r.use_sequencer = False
    vs = sc.view_settings
    vs.view_transform = "Standard"
    vs.look = "None"
    vs.exposure = 0.0
    vs.gamma = 1.0
    vs.use_curve_mapping = False
    sc.display_settings.display_device = "sRGB"
    img = r.image_settings
    img.file_format = "PNG"
    img.color_mode = "RGBA"
    img.color_depth = "8"
    r.use_file_extension = True
    active = bpy.context.view_layer
    for layer in sc.view_layers:
        layer.use = layer == active


def setup_outline(opts):
    sc = bpy.context.scene
    r = sc.render
    r.use_freestyle = opts["outline"] == "outer"
    r.line_thickness_mode = "ABSOLUTE"
    r.line_thickness = float(PIXELATE_FACTOR) if opts["method"] == "pixelate" else 1.0
    layer = bpy.context.view_layer
    layer.use_freestyle = True
    fs = layer.freestyle_settings
    fs.mode = "EDITOR"
    fs.as_render_pass = False
    fs.use_culling = False
    fs.use_smoothness = False
    ls = fs.linesets[0] if len(fs.linesets) else fs.linesets.new(LINESET_NAME)
    for other in list(fs.linesets)[1:]:
        other.show_render = False
    ls.show_render = True
    ls.select_by_visibility = True
    ls.visibility = "VISIBLE"
    ls.select_by_edge_types = True
    ls.select_by_face_marks = False
    ls.select_by_collection = False
    ls.select_by_image_border = True
    ls.edge_type_negation = "INCLUSIVE"
    ls.edge_type_combination = "OR"
    for edge in EDGE_TYPES:
        setattr(ls, "select_" + edge, edge == "external_contour")
        setattr(ls, "exclude_" + edge, False)
    style = ls.linestyle or bpy.data.linestyles.new("PX_LineStyle")
    ls.linestyle = style
    style.color = OUTLINE_COLOR
    style.alpha = 1.0
    style.thickness = 1.0
    style.thickness_position = "CENTER"
    style.use_chaining = True
    style.chaining = "PLAIN"
    style.caps = "BUTT"
    for mods in (style.color_modifiers, style.alpha_modifiers, style.thickness_modifiers):
        for mod in list(mods):
            mods.remove(mod)


def get_object(name, data):
    sc = bpy.context.scene
    obj = bpy.data.objects.get(name)
    if obj is None:
        obj = bpy.data.objects.new(name, data)
    if obj.name not in sc.objects:
        sc.collection.objects.link(obj)
    obj.parent = None
    obj.rotation_mode = "XYZ"
    obj.scale = (1, 1, 1)
    obj.hide_render = False
    return obj


def setup_camera(opts, chars, frames):
    """Place PX_Camera, centred on the character in whole pixels. Returns framing info."""
    az, el, width, n = opts["azimuth"], opts["elevation"], opts["frame_width"], opts["pixels"]
    rot = camera_rotation(az, el)
    right, up, back = (Vector(rot.col[i]) for i in range(3))
    lo, hi = projected_bounds(chars, range(frames["start"], frames["end"] + 1), rot)
    px = width / n
    shift = [int(round((lo[i] + hi[i]) / 2.0 / px)) for i in range(2)]
    half = width / 2.0
    margins = []
    for i in range(2):
        margins += [(half + lo[i] - shift[i] * px) / px, (half - hi[i] + shift[i] * px) / px]
    margin = min(margins)
    if margin < EDGE_MARGIN_PX:
        extent = max((hi[i] - lo[i]) / 2.0 for i in range(2))
        need = math.ceil(extent / (0.5 - (EDGE_MARGIN_PX + 0.5) / n) * 10.0) / 10.0
        raise PixelFilterError(
            f"the character does not fit in the frame at this camera angle (it would be clipped; "
            f"edge margin {margin:.1f} px, need {EDGE_MARGIN_PX:g}). Widen the frame with "
            f"--frame-width {need:g} (now {width:g} m). A wider frame makes the character smaller "
            f"in pixels, so use the same width for every character of one game.")
    target = Vector(GRID_ANCHOR) + right * (shift[0] * px) + up * (shift[1] * px)
    dist = max(CAMERA_DISTANCE, hi[2] + 2.0)

    data = bpy.data.cameras.get(CAMERA_NAME) or bpy.data.cameras.new(CAMERA_NAME)
    cam = get_object(CAMERA_NAME, data)
    cam.data = data
    data.type = "ORTHO"
    data.ortho_scale = width
    data.sensor_fit = "AUTO"
    data.shift_x = data.shift_y = 0.0
    data.clip_start = 0.1
    data.clip_end = max(50.0, dist - lo[2] + 10.0)
    cam.location = target + back * dist
    cam.rotation_euler = (math.radians(90.0 - el), 0.0, math.radians(az))
    bpy.context.scene.camera = cam
    return {"shift_px": shift, "margin_px": round(margin, 2), "target": [round(v, 5) for v in target],
            "location": [round(v, 5) for v in cam.location]}


def sun_rotation(opts):
    """Euler (degrees) of a sun whose camera-space direction toward the light is the preset."""
    rot = camera_rotation(opts["azimuth"], opts["elevation"])
    travel = -(rot @ Vector(LIGHT_VECTORS[opts["light"]])).normalized()
    a = math.acos(max(-1.0, min(1.0, -travel.z)))
    c = math.atan2(-travel.x, travel.y) if math.sin(a) > 1e-9 else 0.0
    return (math.degrees(a), 0.0, math.degrees(c))


def setup_sun(opts):
    data = bpy.data.lights.get(SUN_NAME)
    if data is None or data.type != "SUN":
        data = bpy.data.lights.new(SUN_NAME, "SUN")
    sun = get_object(SUN_NAME, data)
    sun.data = data
    data.energy = SUN_ENERGY
    data.angle = 0.0
    data.color = (1.0, 1.0, 1.0)
    data.use_shadow = True
    data.diffuse_factor = data.specular_factor = data.volume_factor = 1.0
    sun.rotation_euler = [math.radians(a) for a in sun_rotation(opts)]
    return sun


# ---------------------------------------------------------------- image steps

def magick(*args, capture=False):
    run = subprocess.run(["magick", *args], capture_output=True, check=False)
    if run.returncode != 0:
        raise PixelFilterError(f"magick {' '.join(args)} failed: {run.stderr.decode(errors='replace').strip()}")
    return run.stdout if capture else None


def read_rgba(path):
    """uint8 array [rows top-down, cols, 4]."""
    w, h = map(int, magick("identify", "-format", "%w %h", path + "[0]", capture=True).split())
    data = magick(path + "[0]", "-depth", "8", "rgba:-", capture=True)
    return np.frombuffer(data, np.uint8).reshape(h, w, 4)


def palette_png(palette, tmp):
    path = os.path.join(tmp, "palette_" + hashlib.sha1("".join(palette).encode()).hexdigest()[:10] + ".png")
    if not os.path.exists(path):
        magick(*[f"xc:{c}" for c in palette], "+append", "PNG24:" + path)
    return path


def postprocess_file(src, dst, recipe, tmp):
    """The recipe's post-render steps: point-sample down, alpha clip, palette remap."""
    post = recipe["post"]
    size = recipe["render_size"]
    px = read_rgba(src)
    if px.shape[:2] != (size, size):
        raise PixelFilterError(f"{src}: {px.shape[1]}x{px.shape[0]} px, the recipe expects a "
                               f"{size}x{size} render from the _pixel.blend")
    args = [src]
    if post["sample_to"]:
        args += ["-sample", f"{post['sample_to']}x{post['sample_to']}"]
    if post["alpha_clip"]:
        args += ["-channel", "A", "-threshold", "50%", "+channel"]
    if not post["palette"]:
        magick(*args, "PNG32:" + dst)
        return dst
    stem = os.path.join(tmp, "post_" + hashlib.sha1(dst.encode()).hexdigest()[:10])
    clipped, rgb = stem + "_clip.png", stem + "_rgb.png"
    magick(*args, "PNG32:" + clipped)
    pal = palette_png(post["palette"], tmp)
    magick(clipped, "-background", FILL_SRGB, "-alpha", "remove", "-alpha", "off", "+dither",
           "-remap", pal, "PNG24:" + rgb)
    magick(rgb, "(", clipped, "-alpha", "extract", ")", "-alpha", "off", "-compose", "CopyOpacity",
           "-composite", "PNG32:" + dst)
    out = read_rgba(dst)
    used = {"#%02x%02x%02x" % tuple(c) for c in np.unique(out[out[..., 3] > 0][:, :3], axis=0)}
    extra = used - set(post["palette"])
    if extra:
        raise PixelFilterError(f"{dst}: {len(extra)} colors outside the palette after the remap")
    return dst


def build_palette(paths, n):
    """n-color palette (no dither) from the opaque pixels of all the clipped frames."""
    stack = np.concatenate([px[px[..., 3] == 255][:, :3] for px in map(read_rgba, paths)])
    if not len(stack):
        raise PixelFilterError("no opaque pixels to build the palette from")
    with tempfile.NamedTemporaryFile(suffix=".rgb", delete=False) as fh:
        fh.write(np.ascontiguousarray(stack).tobytes())
        raw = fh.name
    try:
        data = magick("-size", f"{len(stack)}x1", "-depth", "8", "rgb:" + raw, "+dither", "-colors",
                      str(n), "-unique-colors", "-depth", "8", "rgb:-", capture=True)
    finally:
        os.remove(raw)
    colors = np.frombuffer(data, np.uint8).reshape(-1, 3)
    return ["#%02x%02x%02x" % tuple(c) for c in colors]


def upscale(src, dst, factor):
    magick(src, "-filter", "point", "-resize", f"{factor * 100}%", "PNG32:" + dst)
    return dst


def render_frame(frame, path):
    sc = bpy.context.scene
    sc.frame_set(frame)
    sc.render.filepath = path
    bpy.ops.render.render(write_still=True)
    if not os.path.exists(path):
        raise PixelFilterError(f"Blender did not write the render {path}")
    return path


def opaque_margin(px):
    rows, cols = np.where(px[..., 3] > 0)
    if rows.size == 0:
        return None
    h, w = px.shape[:2]
    return int(min(cols.min(), rows.min(), w - 1 - cols.max(), h - 1 - rows.max()))


# ---------------------------------------------------------------- whole setup

def setup_scene(opts, tmp):
    """Configure the open scene for these options (absolute, so runs never stack).

    Renders the palette frames for --colors 16. Stores the recipe as a scene custom
    property. Returns a dict with the recipe, frames, framing and notices.
    """
    sc = bpy.context.scene
    start_frame = sc.frame_current
    notices = option_notices(opts)
    chars, hidden_objs = character_objects(opts["collection"])
    if hidden_objs:
        notices.append("Hidden from render (outside --collection): " + ", ".join(o.name for o in hidden_objs))
    mats, bare = character_materials(chars)
    changed, unchanged = apply_cel(cel_group(opts["shading"]), mats)
    if unchanged:
        notices.append("Materials left unchanged (no Principled BSDF), so they are not cel-shaded: "
                       + ", ".join(unchanged))
    if bare:
        notices.append("Objects with no material (they render in Blender's default gray): " + ", ".join(bare))
    setup_world()
    lights = hide_other_lights()
    if lights:
        notices.append("Other lights hidden from render (PX_Sun is the only light): " + ", ".join(lights))
    setup_render(opts)
    setup_outline(opts)
    frames = frame_info(chars)
    try:
        framing = setup_camera(opts, chars, frames)
    finally:
        sc.frame_set(start_frame)
    setup_sun(opts)

    recipe = {
        "skill": "apply-pixel-filter",
        "version": RECIPE_VERSION,
        "options": {k: opts[k] for k in DEFAULTS},
        "switches": switches_for(opts),
        "render_size": render_size(opts),
        "pixels": opts["pixels"],
        "post": {
            "sample_to": opts["pixels"] if opts["method"] == "pixelate" else None,
            "alpha_clip": opts["method"] != "none",
            "palette": None,
        },
        "frames": frames,
    }
    if opts["colors"] == "16":
        clipped = []
        for i, f in enumerate(frames["preview"]):
            raw = render_frame(f, os.path.join(tmp, f"palette_raw_{i}.png"))
            clipped.append(postprocess_file(raw, os.path.join(tmp, f"palette_clip_{i}.png"), recipe, tmp))
        sc.frame_set(start_frame)
        recipe["post"]["palette"] = build_palette(clipped, PALETTE_SIZE)
    sc[RECIPE_KEY] = json.dumps(recipe)
    return {"recipe": recipe, "frames": frames, "framing": framing, "notices": notices,
            "characters": [o.name for o in chars], "materials": changed, "start_frame": start_frame}


def load_recipe():
    raw = bpy.context.scene.get(RECIPE_KEY)
    if raw is None:
        raise PixelFilterError(f"{bpy.data.filepath} has no apply-pixel-filter recipe. Run the apply "
                               "command first and pass the _pixel.blend it saves.")
    recipe = json.loads(raw)
    if recipe.get("version") != RECIPE_VERSION:
        raise PixelFilterError(f"recipe version {recipe.get('version')} is not {RECIPE_VERSION}; "
                               "run the apply command again")
    return recipe


# ---------------------------------------------------------------- command line

def file_hash(path):
    digest = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_args(argv):
    p = argparse.ArgumentParser(
        prog="apply_pixel_filter.py",
        description="Apply a pixel-art look to the open .blend and save it as a new file. "
                    "Pass the switches after '--' on the Blender command line.")
    p.add_argument("--method", choices=METHODS, help="lowres (default): render at sprite size; "
                   "pixelate: big smooth render, point-sampled down; none: smooth render, no pixel look")
    p.add_argument("--pixels", type=int, choices=PIXELS, help="sprite size in px (default 128)")
    p.add_argument("--colors", choices=COLORS, help="full (default) or 16 (needs --shading smooth)")
    p.add_argument("--shading", choices=SHADINGS, help="2tone (default), 3tone, smooth or flat")
    p.add_argument("--outline", choices=OUTLINES, help="outer (default) or none")
    p.add_argument("--camera", choices=tuple(CAMERAS), help="camera preset (default three-quarter)")
    p.add_argument("--azimuth", type=float, help="custom camera angle around the character, degrees "
                   "(0 front, positive shows the character's left); needs --elevation")
    p.add_argument("--elevation", type=float, help="custom camera height angle, 0 to 89 degrees; "
                   "needs --azimuth")
    p.add_argument("--light", choices=LIGHTS, help="light direction on screen (default top-left)")
    p.add_argument("--frame-width", dest="frame_width", type=float,
                   help="world width of the frame in m (default 2.1); same for all characters of a game")
    p.add_argument("--collection", help="collection that holds the character; other objects are "
                   "hidden from render (default: every rendered mesh object)")
    p.add_argument("--output", help="output .blend (default <input>_pixel.blend next to the input)")
    p.add_argument("--postprocess", nargs="+", metavar="PNG",
                   help="post-process mode: PNG files or folders rendered from a _pixel.blend")
    p.add_argument("--post-out", dest="post_out", metavar="FOLDER", help="output folder for --postprocess")
    return p, p.parse_args(argv)


def run_postprocess(args):
    recipe = load_recipe()
    if not args.post_out:
        raise PixelFilterError("--postprocess needs --post-out <folder>")
    sources = []
    for item in args.postprocess:
        if os.path.isdir(item):
            sources += sorted(glob.glob(os.path.join(item, "*.png")))
        elif os.path.isfile(item):
            sources.append(item)
        else:
            raise PixelFilterError(f"{item}: no such file or folder")
    if not sources:
        raise PixelFilterError("no PNG files to post-process")
    out_dir = os.path.abspath(args.post_out)
    os.makedirs(out_dir, exist_ok=True)
    log(f"recipe from {bpy.data.filepath}: {recipe['switches'] or 'defaults'}; "
        f"steps: {post_steps(recipe)}")
    with tempfile.TemporaryDirectory(prefix="apf_post_") as tmp:
        for src in sources:
            dst = os.path.join(out_dir, os.path.basename(src))
            if os.path.normcase(os.path.abspath(src)) == os.path.normcase(dst):
                raise PixelFilterError(f"{src}: --post-out would overwrite the input; choose another folder")
            postprocess_file(os.path.abspath(src), dst, recipe, tmp)
            log("[post]", dst)
    print("POSTPROCESS OK", flush=True)


def post_steps(recipe):
    post = recipe["post"]
    steps = []
    if post["sample_to"]:
        steps.append(f"point-sample {recipe['render_size']} -> {post['sample_to']} px")
    if post["alpha_clip"]:
        steps.append("alpha clip at 50%")
    if post["palette"]:
        steps.append(f"remap to the {len(post['palette'])}-color palette, no dither")
    return ", ".join(steps) or "none (copy as RGBA PNG)"


def run_apply(args):
    src = bpy.data.filepath
    if not src:
        raise PixelFilterError("open a saved .blend: blender.exe -b <input.blend> --python ...")
    opts = make_options(method=args.method, pixels=args.pixels, colors=args.colors,
                        shading=args.shading, outline=args.outline, camera=args.camera,
                        azimuth=args.azimuth, elevation=args.elevation, light=args.light,
                        frame_width=args.frame_width, collection=args.collection)
    out = os.path.abspath(args.output) if args.output else os.path.splitext(src)[0] + "_pixel.blend"
    if not out.lower().endswith(".blend"):
        raise PixelFilterError("--output must end with .blend")
    if os.path.normcase(out) == os.path.normcase(os.path.abspath(src)):
        raise PixelFilterError("--output is the input file; the skill never changes the input")
    src_hash = file_hash(src)
    log(f"input {src}")
    log(f"options: {switches_for(opts) or 'defaults'}")

    sc = bpy.context.scene
    render_path = sc.render.filepath
    with tempfile.TemporaryDirectory(prefix="apf_") as tmp:
        info = setup_scene(opts, tmp)
        recipe = info["recipe"]
        sc.frame_set(info["start_frame"])
        sc.render.filepath = render_path
        os.makedirs(os.path.dirname(out), exist_ok=True)
        bpy.ops.wm.save_as_mainfile(filepath=out, check_existing=False)
        log("[saved]", out)

        stem = os.path.splitext(out)[0]
        test = stem + "_test.png"
        factor = max(1, 1024 // opts["pixels"])
        test_big = stem + f"_test_x{factor}.png"
        raw = render_frame(info["frames"]["test"], os.path.join(tmp, "test_raw.png"))
        sc.frame_set(info["start_frame"])
        postprocess_file(raw, test, recipe, tmp)
        upscale(test, test_big, factor)
        px = read_rgba(test)
        margin = opaque_margin(px)
        log("[test frame]", test, f"(frame {info['frames']['test']}, {px.shape[1]}x{px.shape[0]}, "
            f"transparent margin {margin} px)")
        log("[test frame x%d]" % factor, test_big)
        if margin is None:
            info["notices"].append("The test frame has no opaque pixels: check the camera and --collection.")

    if file_hash(src) != src_hash:
        raise PixelFilterError(f"the input file changed during the run: {src}")
    frames = info["frames"]
    log(f"character: {len(info['characters'])} objects; cel-shaded materials: {len(info['materials'])}")
    log(f"actions: {', '.join(frames['actions']) or 'none (current frame)'}; framed over frames "
        f"{frames['start']}-{frames['end']}; camera shift from the grid anchor "
        f"{info['framing']['shift_px']} px; edge margin {info['framing']['margin_px']} px")
    log(f"camera azimuth {opts['azimuth']:g}, elevation {opts['elevation']:g}; light {opts['light']}; "
        f"render {recipe['render_size']} px; post-process: {post_steps(recipe)}")
    if recipe["post"]["palette"]:
        log("palette:", " ".join(recipe["post"]["palette"]))
    for note in info["notices"]:
        log("NOTICE:", note)
    log("input unchanged (sha256 checked)")
    print("APPLY PIXEL FILTER OK", flush=True)


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    parser, args = parse_args(argv)
    try:
        if args.postprocess:
            style = [k for k in ("method", "pixels", "colors", "shading", "outline", "camera", "azimuth",
                                 "elevation", "light", "frame_width", "collection", "output")
                     if getattr(args, k) is not None]
            if style:
                raise PixelFilterError("--postprocess uses the recipe saved in the .blend; remove "
                                       + ", ".join("--" + k.replace("_", "-") for k in style))
            run_postprocess(args)
        else:
            if args.post_out:
                raise PixelFilterError("--post-out works only with --postprocess")
            run_apply(args)
    except PixelFilterError as err:
        print(f"apply_pixel_filter.py: error: {err}", file=sys.stderr, flush=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
