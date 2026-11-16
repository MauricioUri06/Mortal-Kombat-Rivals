"""Normalize the kick and crouch sheets in sprite_ref/ into 176x176 cells.

Run once after replacing those sheets, then: tools/test_game.ps1 -Reimport
Needs Pillow (pip install pillow); build_characters.py itself still uses only the standard library.

Sources (rows of eight poses, at a larger scale than the main atlas):
- Kick: "Patada Sub-Zero y Scorpion.webp" (row 0 Sub-Zero, row 1 Scorpion).
- Crouch: "Agacharse Sub-Zero y Scorpion.webp" (row 0 Sub-Zero, row 1 Scorpion).
  (The older "<Character> patada y agacharse.webp" sheets are no longer used.)
Every pose is separated by connected pixels (an extended kick crosses its grid cell), scaled so
the first pose of the row matches the existing stand sprite, and placed with the same feet and
body center, keeping the offsets between poses of the original sheet.
Output: "<Character> patada y agacharse.png", row 0 kick and row 1 crouch.
Baraka: "Baraka.webp" (row 0 idle, row 1 leap) -> "Baraka.png", feet on the baseline.
Goro: "Goro.webp" (row 0 walk, row 1 tackle, row 2 dazed) -> "Goro.png".
"""
import json
import re
from collections import deque
from pathlib import Path

from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
REF = ROOT / "sprite_ref"
CELL = 176
COLUMNS = 8
LABELS = {"subzero": "Sub-Zero", "scorpion": "Scorpion"}
KICK_SHEET = "Patada Sub-Zero y Scorpion.webp"
CROUCH_SHEET = "Agacharse Sub-Zero y Scorpion.webp"
BARAKA_SCALE = 0.48  # same drawing scale as the Sub-Zero sheets
GORO_SCALE = 0.6  # Goro is a giant: about 15% taller than the fighters
# character -> [(sheet, row in sheet)] for output rows 0 (kick) and 1 (crouch)
SOURCES = {
    "subzero": [(KICK_SHEET, 0), (CROUCH_SHEET, 0)],
    "scorpion": [(KICK_SHEET, 1), (CROUCH_SHEET, 1)],
}


def load_yy(path):
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", path.read_text(encoding="utf-8-sig")))


def opaque_box(image):
    return image.getchannel("A").point(lambda v: 255 if v > 128 else 0).getbbox()


def components(mask, width, height):
    """Yield the (x, y) pixel lists of each 8-connected opaque blob."""
    seen = bytearray(width * height)
    for start in range(width * height):
        if not mask[start] or seen[start]:
            continue
        seen[start] = 1
        queue = deque([start])
        pixels = []
        while queue:
            index = queue.popleft()
            x, y = index % width, index // width
            pixels.append((x, y))
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < width and 0 <= ny < height:
                        other = ny * width + nx
                        if mask[other] and not seen[other]:
                            seen[other] = 1
                            queue.append(other)
        yield pixels


def extract_poses(name, row_count=2):
    """Return {(row, column): (pose image, top-left in sheet, pitch)} for a sheet of equal rows."""
    sheet = Image.open(REF / name).convert("RGBA")
    width, height = sheet.size
    mask = bytes(1 if value > 32 else 0 for value in sheet.getchannel("A").tobytes())
    pitch = width / COLUMNS
    owner = {}
    for pixels in components(mask, width, height):
        if len(pixels) < 12:
            continue  # specks
        cx = sum(p[0] for p in pixels) / len(pixels)
        cy = sum(p[1] for p in pixels) / len(pixels)
        key = (min(row_count - 1, int(cy // (height / row_count))), min(COLUMNS - 1, int(cx // pitch)))
        owner.setdefault(key, []).extend(pixels)

    poses = {}
    source = sheet.load()
    for key, pixels in owner.items():
        layer = Image.new("RGBA", (width, height))
        target = layer.load()
        for x, y in pixels:
            target[x, y] = source[x, y]
        # Keep the soft edge pixels next to the blob, like the main atlas.
        box = opaque_box(layer)
        area = (box[0] - 2, box[1] - 2, box[2] + 2, box[3] + 2)
        halo_mask = layer.crop(area).getchannel("A").point(lambda v: 255 if v else 0)
        pose = Image.new("RGBA", (area[2] - area[0], area[3] - area[1]))
        pose.paste(sheet.crop(area), (0, 0), halo_mask.filter(ImageFilter.MaxFilter(5)))
        poses[key] = (pose, area[:2], pitch)
    return poses


def place_row(atlas, poses, row, out_row, scale, ref_cx, ref_bottom, cx0, bottom0):
    """Scale one sheet row into atlas row out_row, mapping (cx0, bottom0) to (ref_cx, ref_bottom)."""
    for column in range(COLUMNS):
        pose, (px, py), pitch = poses[(row, column)]
        scaled = pose.resize((max(1, round(pose.width * scale)), max(1, round(pose.height * scale))),
                             Image.LANCZOS)
        x = ref_cx + (px - (cx0 + column * pitch)) * scale
        y = ref_bottom + (py - bottom0) * scale
        cell = Image.new("RGBA", (CELL, CELL))
        cell.paste(scaled, (round(x), round(y)))  # cell is empty: plain copy, may overhang
        atlas.alpha_composite(cell, (column * CELL, out_row * CELL))


sheets = {}
for character, sources in SOURCES.items():
    stand_yy = load_yy(ROOT / "sprites" / f"s_{character}_stand" / f"s_{character}_stand.yy")
    stand = Image.open(ROOT / "sprites" / f"s_{character}_stand" / (stand_yy["frames"][0]["name"] + ".png"))
    ref = opaque_box(stand)
    ref_cx, ref_bottom = (ref[0] + ref[2]) / 2, ref[3]

    atlas = Image.new("RGBA", (CELL * COLUMNS, CELL * 2))
    for out_row, (name, row) in enumerate(sources):
        if name not in sheets:
            sheets[name] = extract_poses(name)
        poses = sheets[name]
        first, first_at, _ = poses[(row, 0)]
        first_box = opaque_box(first)
        scale = ((ref[3] - ref[1]) / (first_box[3] - first_box[1]) +
                 (ref[2] - ref[0]) / (first_box[2] - first_box[0])) / 2
        place_row(atlas, poses, row, out_row, scale, ref_cx, ref_bottom,
                  first_at[0] + (first_box[0] + first_box[2]) / 2, first_at[1] + first_box[3])
        print(f"{character} {('kick', 'crouch')[out_row]}: {name} row {row}, scale {scale:.3f}")
    atlas.save(REF / f"{LABELS[character]} patada y agacharse.png")

def enemy_sheet(name, row_count, scale):
    """Enemy sheet -> "<name>.png": feet on the baseline, every row centered on the first pose of row 0."""
    poses = extract_poses(f"{name}.webp", row_count)
    first, first_at, _ = poses[(0, 0)]
    first_box = opaque_box(first)
    cx0 = first_at[0] + (first_box[0] + first_box[2]) / 2
    atlas = Image.new("RGBA", (CELL * COLUMNS, CELL * row_count))
    for row in range(row_count):
        pose, at, _ = poses[(row, 0)]
        place_row(atlas, poses, row, row, scale, 80, 168, cx0, at[1] + opaque_box(pose)[3])
    atlas.save(REF / f"{name}.png")


# Baraka: row 0 idle, row 1 leap; same drawing scale as the fighters' sheets.
enemy_sheet("Baraka", 2, BARAKA_SCALE)
# Goro: row 0 walk, row 1 tackle, row 2 dazed; drawn a bit larger than the fighters.
enemy_sheet("Goro", 3, GORO_SCALE)
print("Normalized kick, crouch, Baraka and Goro sheets written to sprite_ref/.")
