"""Build native GameMaker resources; atlas pixels are imported by import_atlases.ps1.

Run from the workspace: python tools/build_characters.py
Then: powershell -NoProfile -File tools/import_atlases.ps1
Existing .gml gameplay code is kept. No external Python packages are needed.
"""
import copy
import json
import re
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT
MANIFEST = ROOT / "tools" / "atlas_manifest.json"


def read(path):
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", path.read_text(encoding="utf-8-sig")))


def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def resource(kind, name, version="", **fields):
    return {f"${kind}": version, "%Name": name, "name": name,
            "resourceType": kind, "resourceVersion": "2.0", **fields}


def ref(kind, name):
    return {"name": name, "path": f"{kind}/{name}/{name}.yy"}


def folder(name):
    return {"name": name.split("/")[-1], "path": f"folders/{name}.yy"}


def uid():
    return str(uuid.uuid4())


resources = []
imports = []


def register(kind, name, data):
    write(PROJECT / kind / name / f"{name}.yy", data)
    resources.append({"id": ref(kind, name)})


def sprite(name, count, fps, parent, width=176, height=176, origin=(80, 168), bbox=None):
    frame_ids = [uid() for _ in range(count)]
    layer_id = uid()
    existing = PROJECT / "sprites" / name / f"{name}.yy"
    if existing.exists():
        old = read(existing)
        if len(old["frames"]) == count:
            frame_ids = [frame["name"] for frame in old["frames"]]
            layer_id = old["layers"][0]["name"]
    keys = []
    for i, frame in enumerate(frame_ids):
        keys.append({"$Keyframe<SpriteFrameKeyframe>": "", "Channels": {
            "0": {"$SpriteFrameKeyframe": "", "Id": {
                "name": frame, "path": f"sprites/{name}/{name}.yy"},
                "resourceType": "SpriteFrameKeyframe", "resourceVersion": "2.0"}},
            "Disabled": False, "id": uid(), "IsCreationKey": False, "Key": float(i),
            "Length": 1.0, "resourceType": "Keyframe<SpriteFrameKeyframe>",
            "resourceVersion": "2.0", "Stretch": False})
    track = {"$GMSpriteFramesTrack": "", "builtinName": 0, "events": [],
             "inheritsTrackColour": True, "interpolation": 1, "isCreationTrack": False,
             "keyframes": {"$KeyframeStore<SpriteFrameKeyframe>": "", "Keyframes": keys,
                           "resourceType": "KeyframeStore<SpriteFrameKeyframe>", "resourceVersion": "2.0"},
             "modifiers": [], "name": "frames", "resourceType": "GMSpriteFramesTrack",
             "resourceVersion": "2.0", "spriteId": None, "trackColour": 0,
             "tracks": [], "traits": 0}
    seq = resource("GMSequence", name, "v1", autoRecord=True, backdropHeight=768,
                   backdropImageOpacity=0.5, backdropImagePath="", backdropWidth=1366,
                   backdropXOffset=0.0, backdropYOffset=0.0,
                   events={"$KeyframeStore<MessageEventKeyframe>": "", "Keyframes": [],
                           "resourceType": "KeyframeStore<MessageEventKeyframe>", "resourceVersion": "2.0"},
                   eventStubScript=None, eventToFunction={}, length=float(count), lockOrigin=False,
                   moments={"$KeyframeStore<MomentsEventKeyframe>": "", "Keyframes": [],
                            "resourceType": "KeyframeStore<MomentsEventKeyframe>", "resourceVersion": "2.0"},
                   playback=1, playbackSpeed=float(fps), playbackSpeedType=0, showBackdrop=True,
                   showBackdropImage=False, timeUnits=1, tracks=[track], visibleRange=None,
                   volume=1.0, xorigin=origin[0], yorigin=origin[1])
    bounds = bbox or (0, 0, width - 1, height - 1)
    data = resource("GMSprite", name, "v2", bboxMode=2 if bbox else 0,
                    bbox_left=bounds[0], bbox_top=bounds[1], bbox_right=bounds[2], bbox_bottom=bounds[3],
                    collisionKind=1, collisionTolerance=0, DynamicTexturePage=False,
                    edgeFiltering=False, For3D=False,
                    frames=[resource("GMSpriteFrame", frame, "v1") for frame in frame_ids],
                    gridX=0, gridY=0, height=height, HTile=False,
                    layers=[resource("GMImageLayer", layer_id, blendMode=0, displayName="default",
                                     isLocked=False, opacity=100.0, visible=True)],
                    nineSlice=None, origin=9, parent=folder(parent), preMultiplyAlpha=False,
                    sequence=seq, swatchColours=None, swfPrecision=0.5,
                    textureGroupId={"name": "Default", "path": "texturegroups/Default"},
                    type=0, VTile=False, width=width)
    register("sprites", name, data)
    return {"name": name, "frames": frame_ids, "layer": layer_id,
            "width": width, "height": height, "origin": list(origin)}


# Each row has its own baseline. The jump/fall offsets are kept from the atlas.
# Bounds around the extended fists and slide effects intentionally cross the nominal grid.
rows = [
    {"top": 0, "bottom": 151, "baseline": 141, "anchor": 72, "pitch": 143.5},
    {"top": 151, "bottom": 289, "baseline": 284, "anchor": 65, "pitch": 141.5},
    {"top": 289, "bottom": 438, "baseline": 432, "anchor": 60, "pitch": 142.5},
    {"top": 438, "bottom": 601, "baseline": 596, "anchor": 60, "pitch": 142},
    {"top": 601, "bottom": 744, "baseline": 734, "anchor": 65, "pitch": 142,
     "edges": [0, 140, 280, 420, 560, 710, 860, 990, 1122]},
    {"top": 744, "bottom": 888, "baseline": 877, "anchor": 65, "pitch": 142,
     "edges": [0, 140, 280, 420, 560, 712, 856, 994, 1122]},
    {"top": 888, "bottom": 1026, "baseline": 1017, "anchor": 65, "pitch": 142,
     "edges": [0, 140, 280, 420, 565, 710, 855, 990, 1122]},
    {"top": 1026, "bottom": 1171, "baseline": 1165, "anchor": 65, "pitch": 142},
    {"top": 1171, "bottom": 1321, "baseline": 1307, "anchor": 65, "pitch": 141},
    {"top": 1321, "bottom": 1402, "baseline": 1358, "anchor": 68, "pitch": 142},
]
animations = {
    "stand": (0, list(range(8)), 8),
    "run": (1, list(range(8)), 14),
    "jump_start": (2, [0, 1], 24),
    "jump": (2, list(range(2, 8)), 16),
    "fall": (3, list(range(6)), 16),
    "land": (3, [6, 7], 16),
    "punch": (4, list(range(8)), 20),
    "ranged": (5, list(range(8)), 18),
    "slide": (6, list(range(8)), 18),
    "hurt": (7, list(range(8)), 20),
    "death": (8, list(range(8)), 12),
    "projectile": (9, list(range(8)), 16),
}
atlases = {"subzero": next((ROOT / "sprite_ref").glob("*Sub-Zero*.png")),
           "scorpion": next((ROOT / "sprite_ref").glob("*Scorpion*.png"))}
for character, atlas in atlases.items():
    for animation, (row, columns, fps) in animations.items():
        projectile = animation == "projectile"
        entry = sprite(f"s_{character}_{animation}", len(columns), fps,
                       f"Sprites/{character}", width=144 if projectile else 176,
                       height=64 if projectile else 176,
                       origin=(72, 32) if projectile else (80, 168),
                       bbox=(24, 14, 126, 50) if projectile else None)
        entry.update(source=str(atlas.relative_to(ROOT)), row=rows[row], columns=columns)
        imports.append(entry)

for name, width, height, origin, bounds in [
        ("s_fighter_mask", 176, 176, (80, 168), (61, 43, 98, 167)),
        ("s_fighter_mask_slide", 176, 176, (80, 168), (52, 117, 108, 167)),
        ("s_solid", 32, 32, (0, 0), (0, 0, 31, 31))]:
    entry = sprite(name, 1, 0, "Sprites/system", width, height, origin, bounds)
    entry.update(primitive="rectangle", bounds=list(bounds))
    imports.append(entry)
write(MANIFEST, imports)


def obj(name, parent=None, spr=None, solid=False, visible=True):
    events = []
    directory = PROJECT / "objects" / name
    directory.mkdir(parents=True, exist_ok=True)
    event_types = {"Create": 0, "Destroy": 1, "Alarm": 2, "Step": 3,
                   "Collision": 4, "Other": 7, "Draw": 8, "CleanUp": 12}
    for event_file in sorted(directory.glob("*.gml")):
        event, number = event_file.stem.split("_", 1)
        events.append(resource("GMEvent", "", "v1", collisionObjectId=None,
                               eventNum=int(number), eventType=event_types[event], isDnD=False))
    data = resource("GMObject", name, eventList=events, managed=True, overriddenProperties=[],
                    parent=folder("Objects/characters" if "fighter" in name or name in ("o_subzero", "o_scorpion", "o_player_sc", "o_player_sz")
                                  else "Objects/combat" if name in ("o_att", "o_hitbox", "o_projectile", "o_iceball", "o_spear")
                                  else "Objects/level"),
                    parentObjectId=ref("objects", parent) if parent else None,
                    persistent=False, physicsAngularDamping=0.1, physicsDensity=0.5,
                    physicsFriction=0.2, physicsGroup=1, physicsKinematic=False,
                    physicsLinearDamping=0.1, physicsObject=False, physicsRestitution=0.1,
                    physicsSensor=False, physicsShape=1, physicsShapePoints=[], physicsStartAwake=True,
                    properties=[], solid=solid, spriteId=ref("sprites", spr) if spr else None,
                    spriteMaskId=ref("sprites", "s_fighter_mask") if name == "o_fighter" else None,
                    visible=visible)
    register("objects", name, data)


for args in [
    ("o_fighter", None, "s_subzero_stand"),
    ("o_subzero", "o_fighter", "s_subzero_stand"),
    ("o_scorpion", "o_fighter", "s_scorpion_stand"),
    ("o_player_sc", "o_scorpion", "s_scorpion_stand"),
    ("o_player_sz", "o_subzero", "s_subzero_stand"),
    ("o_att",), ("o_hitbox", "o_att"), ("o_projectile", "o_att"),
    ("o_iceball", "o_projectile", "s_subzero_projectile"),
    ("o_spear", "o_projectile", "s_scorpion_projectile"),
    ("o_terrain",), ("o_solid", "o_terrain", "s_solid", True), ("o_control",)]:
    obj(*args)

for script in sorted((PROJECT / "scripts").glob("*/*.gml")):
    register("scripts", script.stem,
             resource("GMScript", script.stem, isCompatibility=False, isDnD=False, parent=folder("Scripts")))

room_path = PROJECT / "rooms" / "Room1" / "Room1.yy"
room = read(room_path)
base_layer = next(layer for layer in room["layers"] if layer["resourceType"] == "GMRInstanceLayer")


def layer(name, depth):
    result = copy.deepcopy(base_layer)
    result.update(name=name, **{"%Name": name}, depth=depth, instances=[])
    return result


layers = [layer("att", -100), layer("Instances", 0), layer("terrain", 100)]
order = []


def instance(layer_index, name, object_name, x, y, sx=1.0, sy=1.0):
    inst = resource("GMRInstance", name, "v4", colour=4294967295, frozen=False,
                    hasCreationCode=False, ignore=False, imageIndex=0, imageSpeed=1.0,
                    inheritCode=False, inheritedItemId=None, inheritItemSettings=False,
                    isDnd=False, objectId=ref("objects", object_name), properties=[],
                    rotation=0.0, scaleX=sx, scaleY=sy, x=float(x), y=float(y))
    layers[layer_index]["instances"].append(inst)
    order.append({"name": name, "path": "rooms/Room1/Room1.yy"})


instance(1, "inst_control", "o_control", 0, 0)
instance(2, "inst_ground", "o_solid", 0, 592, 40, 4)
instance(2, "inst_platform_left", "o_solid", 112, 432, 6, 0.5)
instance(2, "inst_platform_right", "o_solid", 976, 432, 6, 0.5)
background = next(layer for layer in room["layers"] if layer["resourceType"] == "GMRBackgroundLayer")
background.update(depth=300, colour=4280094479)
room.update(layers=layers + [background], instanceCreationOrder=order,
            roomSettings={"Height": 720, "inheritRoomSettings": False, "persistent": False, "Width": 1280})
for view in room["views"]:
    view.update(wport=1280, hport=720, wview=1280, hview=720)
write(room_path, room)

project_path = PROJECT / "MortalKombatRivals.yyp"
project = read(project_path)
resources.append({"id": ref("rooms", "Room1")})
project.update(defaultScriptType=1, resources=resources)
names = ["Sprites", "Sprites/subzero", "Sprites/scorpion", "Sprites/system", "Objects",
         "Objects/characters", "Objects/combat", "Objects/level", "Scripts"]
project["Folders"] = [resource("GMFolder", name.split("/")[-1], folderPath=f"folders/{name}.yy")
                      for name in names]
write(project_path, project)
options_path = PROJECT / "options" / "windows" / "options_windows.yy"
options = read(options_path)
options.update(option_windows_interpolate_pixels=False, option_windows_display_name="Mortal Kombat Rivals",
               option_windows_executable_name="MortalKombatRivals.exe",
               option_windows_product_info="MortalKombatRivals")
write(options_path, options)
write(PROJECT / "MortalKombatRivals.resource_order", {"FolderOrderSettings": [], "ResourceOrderSettings": []})

# Local asset viewer: consumes the exact PNG frames used by GameMaker.
preview_data = []
for entry in imports:
    if "source" in entry:
        sprite_data = read(PROJECT / "sprites" / entry["name"] / (entry["name"] + ".yy"))
        preview_data.append({"name": entry["name"], "frames": [
            f"../sprites/{entry['name']}/{frame}.png" for frame in entry["frames"]],
            "fps": sprite_data["sequence"]["playbackSpeed"], "origin": entry["origin"],
            "width": entry["width"], "height": entry["height"]})
preview_template = (ROOT / "tools" / "preview_template.html").read_text(encoding="utf-8")
preview_dir = ROOT / "preview"
preview_dir.mkdir(exist_ok=True)
(preview_dir / "animaciones.html").write_text(
    preview_template.replace("__SPRITE_DATA__", json.dumps(preview_data)), encoding="utf-8")
print(f"Prepared {len(resources)} native resources and {sum(len(i['frames']) for i in imports)} PNG frames.")
