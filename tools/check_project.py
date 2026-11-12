"""Validate native resource references and sprite frame files (standard library only)."""
import json
import re
import struct
from pathlib import Path

root = Path(__file__).resolve().parents[1]
errors = []
count = 0


def load(path):
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", path.read_text(encoding="utf-8-sig")))


def check(condition, label):
    if not condition:
        errors.append(label)


def refs(data):
    if isinstance(data, dict):
        path = data.get("path", "")
        if path.endswith(".yy") and not path.startswith(("folders/", "texturegroups/", "audiogroups/")):
            check((root / path).is_file(), f"Missing reference: {path}")
        for value in data.values():
            refs(value)
    elif isinstance(data, list):
        for item in data:
            refs(item)


project = load(root / "MortalKombatRivals.yyp")
refs(project)
registered = {entry["id"]["path"] for entry in project["resources"]}
for entry in project["resources"]:
    resource_path = root / entry["id"]["path"]
    data = load(resource_path)
    refs(data)
    count += 1
    if data["resourceType"] == "GMSprite":
        frames = data["frames"]
        check(len(frames) == data["sequence"]["length"], f"Sequence length: {data['name']}")
        check(len(frames) == len(data["sequence"]["tracks"][0]["keyframes"]["Keyframes"]),
              f"Keyframe count: {data['name']}")
        for frame in frames:
            path = resource_path.parent / (frame["name"] + ".png")
            check(path.is_file(), f"Missing frame: {path}")
            if path.is_file():
                header = path.read_bytes()[:33]
                check(header[:8] == b"\x89PNG\r\n\x1a\n", f"Invalid PNG: {path}")
                w, h = struct.unpack(">II", header[16:24])
                check((w, h) == (data["width"], data["height"]), f"PNG dimensions: {path}")
                check(header[25] == 6, f"Frame is not RGBA: {path}")
            for layer in data["layers"]:
                layer_path = resource_path.parent / "layers" / frame["name"] / (layer["name"] + ".png")
                check(layer_path.is_file(), f"Missing editor layer: {layer_path}")
                if path.is_file() and layer_path.is_file():
                    check(path.read_bytes() == layer_path.read_bytes(), f"Editor/compiled pixels differ: {path}")
    elif data["resourceType"] == "GMObject":
        event_type = {0: "Create", 1: "Destroy", 2: "Alarm", 3: "Step", 7: "Other", 8: "Draw", 12: "CleanUp"}
        for event in data["eventList"]:
            event_path = resource_path.parent / f"{event_type[event['eventType']]}_{event['eventNum']}.gml"
            check(event_path.is_file(), f"Missing event code: {event_path}")

for yy in root.glob("**/*.yy"):
    if yy.parts[-3] not in ("options",) and yy.parent.parent.name in ("objects", "sprites", "scripts", "rooms"):
        check(yy.relative_to(root).as_posix() in registered, f"Unregistered resource: {yy}")

if errors:
    raise SystemExit("\n".join(errors))
print(f"OK: {count} resources; references, PNG frames, alpha channels, editor layers and event files valid.")
