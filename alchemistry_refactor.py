import os
import re
import sys
import datetime
from pathlib import Path
from collections import defaultdict

DRY_RUN = False
PROJECT_ROOT = Path(".")
LOG_PATH = PROJECT_ROOT / "REFACTOR_LOG.txt"

SKIP_DIRS = {".git", ".import", ".godot", "__pycache__", "node_modules", ".gkanban", ".autoconverted"}

BINARY_EXTENSIONS = {
    ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".webp", ".tga",
    ".wav", ".ogg", ".mp3", ".flac", ".ttf", ".otf", ".woff", ".woff2",
    ".import", ".bin", ".pck", ".exe", ".so", ".dll", ".zip", ".tar", ".gz",
    ".blend", ".fbx", ".obj", ".glb", ".gltf", ".pdf", ".svg",
}

TEXT_EXTENSIONS = {
    ".gd", ".tscn", ".tres", ".cfg", ".godot", ".md", ".txt",
    ".json", ".csv", ".tsv", ".xml", ".html", ".shader", ".gdshader",
    ".toziuhasave", ".alchemsave", ".conf", ".ini",
}

IDENTITY_REPLACEMENTS = [
    (".toziuhasave", ".alchemsave", False),
    ("eldralis_woods", "grey_woods", True),
    ("eldralis woods", "Grey Woods", False),
    ("Eldralis_Woods", "Grey_Woods", True),
    ("Eldralis Woods", "Grey Woods", False),
    ("grijayla", "the_outpost", True),
    ("Grijayla", "The_Outpost", True),
    ("stralsund", "highwall", True),
    ("Stralsund", "Highwall", True),
    ("eztilia", "the_sinkhole", True),
    ("Eztilia", "The_Sinkhole", True),
    ("aridiah", "the_barrens", True),
    ("Aridiah", "The_Barrens", True),
    ("amerithia", "the_core", True),
    ("Amerithia", "The_Core", True),
    ("aqua_priestess", "the_diver", True),
    ("Aqua_Priestess", "The_Diver", True),
    ("aqua priestess", "the diver", False),
    ("Aqua Priestess", "The Diver", False),
    ("giant_bat", "the_screecher", True),
    ("Giant_Bat", "The_Screecher", True),
    ("giant bat", "the screecher", False),
    ("Giant Bat", "The Screecher", False),
    ("plasmoid", "vial", True),
    ("Plasmoid", "Vial", True),
    ("witiko", "the_stalker", True),
    ("Witiko", "The_Stalker", True),
    ("johannes", "john", True),
    ("Johannes", "John", True),
    ("alessandro", "al", True),
    ("Alessandro", "Al", True),
    ("annette", "annie", True),
    ("Annette", "Annie", True),
    ("dirian", "darryl", True),
    ("Dirian", "Darryl", True),
    ("elisia", "elsa", True),
    ("Elisia", "Elsa", True),
    ("isaac", "ike", True),
    ("Isaac", "Ike", True),
    ("sheal", "shay", True),
    ("Sheal", "Shay", True),
    ("xandria", "nabig", True),
    ("Xandria", "Nabig", True),
    ("XANDRIA", "NABIG", False),
]

CUSTOM_IDENTITY = [
    (re.compile(r"(?<![a-zA-Z_])eva(?![a-zA-Z_])"), "eve"),
    (re.compile(r"(?<![a-zA-Z_])Eva(?![a-zA-Z_])"), "Eve"),
    (re.compile(r"(?<![a-zA-Z_])death(?![a-zA-Z_])"), "endgame"),
    (re.compile(r"(?<![a-zA-Z_])Death(?![a-zA-Z_])"), "Endgame"),
]

SKIP_IN_STD = {"eva", "Eva", "death", "Death"}

VARIABLE_RENAMES = [
    (r"(?<![a-zA-Z_])max_hp(?![a-zA-Z_])", "max_health_points"),
    (r"(?<![a-zA-Z_])max_mp(?![a-zA-Z_])", "max_alchemy_gauge"),
    (r"(?<![a-zA-Z_])cur_hp(?![a-zA-Z_])", "current_health_points"),
    (r"(?<![a-zA-Z_])cur_mp(?![a-zA-Z_])", "current_alchemy_gauge"),
    (r"(?<![a-zA-Z_])mhp(?![a-zA-Z_])", "max_health_points"),
    (r"(?<![a-zA-Z_])mmp(?![a-zA-Z_])", "max_alchemy_gauge"),
    (r"(?<![a-zA-Z_])hp(?![a-zA-Z_])", "health_points"),
    (r"(?<![a-zA-Z_])mp(?![a-zA-Z_])", "alchemy_gauge"),
    (r"(?<![a-zA-Z_])atk(?![a-zA-Z_])", "attack_power"),
    (r"(?<![a-zA-Z_])def(?![a-zA-Z_])", "defense_rating"),
    (r"(?<![a-zA-Z_])spd(?![a-zA-Z_])", "movement_speed"),
    (r"(?<![a-zA-Z_])agi(?![a-zA-Z_])", "agility_stat"),
    (r"(?<![a-zA-Z_])lvl(?![a-zA-Z_])", "current_level"),
    (r"(?<![a-zA-Z_])xp(?![a-zA-Z_])", "experience_points"),
    (r"(?<![a-zA-Z_])dmg(?![a-zA-Z_])", "damage_amount"),
    (r"(?<![a-zA-Z_])cd(?![a-zA-Z_])", "cooldown_timer"),
    (r"(?<![a-zA-Z_])is_atk(?![a-zA-Z_])", "is_attacking"),
    (r"(?<![a-zA-Z_])is_dmg(?![a-zA-Z_])", "is_taking_damage"),
    (r"(?<![a-zA-Z_])is_inv(?![a-zA-Z_])", "is_invincible"),
    (r"(?<![a-zA-Z_])is_j(?![a-zA-Z_])", "is_jumping_active"),
    (r"(?<![a-zA-Z_])is_g(?![a-zA-Z_])", "is_grounded"),
    (r"(?<![a-zA-Z_])is_d(?![a-zA-Z_])", "is_dead"),
    (r"(?<![a-zA-Z_])is_a(?![a-zA-Z_])", "is_attacking"),
    (r"(?<![a-zA-Z_])is_m(?![a-zA-Z_])", "is_moving"),
    (r"(?<![a-zA-Z_])is_i(?![a-zA-Z_])", "is_invincible"),
    (r"(?<![a-zA-Z_])is_c(?![a-zA-Z_])", "is_crouching"),
    (r"(?<![a-zA-Z_])is_r(?![a-zA-Z_])", "is_running"),
    (r"(?<![a-zA-Z_])anim(?![a-zA-Z_])", "animation_player"),
    (r"(?<![a-zA-Z_])cam(?![a-zA-Z_])", "camera_node"),
    (r"(?<![a-zA-Z_])sm(?![a-zA-Z_])", "state_machine"),
    (r"(?<![a-zA-Z_])tgt(?![a-zA-Z_])", "target_node"),
    (r"(?<![a-zA-Z_])enm(?![a-zA-Z_])", "enemy_node"),
    (r"(?<![a-zA-Z_])plr(?![a-zA-Z_])", "player_node"),
    (r"(?<![a-zA-Z_])tmr(?![a-zA-Z_])", "timer_node"),
    (r"(?<![a-zA-Z_])sfx(?![a-zA-Z_])", "sound_effect_player"),
    (r"(?<![a-zA-Z_])mus(?![a-zA-Z_])", "music_player"),
    (r"(?<![a-zA-Z_])inv(?![a-zA-Z_])", "inventory_manager"),
    (r"(?<![a-zA-Z_])hud(?![a-zA-Z_])", "heads_up_display"),
    (r"(?<![a-zA-Z_])spwn(?![a-zA-Z_])", "spawn_point"),
    (r"(?<![a-zA-Z_])chkpt(?![a-zA-Z_])", "checkpoint_node"),
    (r"(?<![a-zA-Z_])cnt(?![a-zA-Z_])", "counter_value"),
    (r"(?<![a-zA-Z_])vel(?![a-zA-Z_])", "velocity_vector"),
    (r"(?<![a-zA-Z_])dt(?![a-zA-Z_])", "delta_time"),
]

NAME_SUBS = [
    ("toziuhasave", "alchemsave"),
    ("eldralis_woods", "grey_woods"),
    ("grijayla", "the_outpost"),
    ("stralsund", "highwall"),
    ("eztilia", "the_sinkhole"),
    ("aridiah", "the_barrens"),
    ("amerithia", "the_core"),
    ("aqua_priestess", "the_diver"),
    ("giant_bat", "the_screecher"),
    ("plasmoid", "vial"),
    ("witiko", "the_stalker"),
    ("johannes", "john"),
    ("alessandro", "al"),
    ("annette", "annie"),
    ("dirian", "darryl"),
    ("elisia", "elsa"),
    ("eva", "eve"),
    ("isaac", "ike"),
    ("sheal", "shay"),
    ("death", "endgame"),
    ("xandria", "nabig"),
]

_log_lines = []
_stats = defaultdict(int)

def log(msg, level="INFO"):
    ts = datetime.datetime.now().strftime("%H:%M:%S")
    line = f"[{ts}] [{level}] {msg}"
    _log_lines.append(line)
    print(line)

def flush_log():
    with open(LOG_PATH, "w", encoding="utf-8") as fh:
        fh.write(f"ALCHEMISTRY REFACTOR LOG  {datetime.datetime.now()}\n")
        fh.write("=" * 70 + "\n\n")
        fh.write("\n".join(_log_lines))
        fh.write("\n\n" + "=" * 70 + "\nSUMMARY\n")
        for k, v in sorted(_stats.items()):
            fh.write(f"  {k:<42} {v}\n")
    print(f"\n  Full log -> {LOG_PATH}")

def is_binary(path):
    if path.suffix.lower() in BINARY_EXTENSIONS:
        return True
    try:
        return b"\x00" in path.read_bytes()[:8192]
    except OSError:
        return True

def read_text(path):
    for enc in ("utf-8", "utf-8-sig", "latin-1"):
        try:
            return path.read_text(encoding=enc)
        except (UnicodeDecodeError, OSError):
            continue
    return None

def write_text(path, content):
    try:
        if not DRY_RUN:
            path.write_text(content, encoding="utf-8")
        return True
    except OSError as e:
        log(f"WRITE ERROR {path}: {e}", "ERROR")
        _stats["errors"] += 1
        return False

def skip_dir(name):
    return name in SKIP_DIRS or name.startswith(".")

def build_std_pattern(old, wb):
    esc = re.escape(old)
    flags = re.IGNORECASE if old == old.lower() else 0
    return re.compile((r"\b" + esc + r"\b") if wb else esc, flags)

std_patterns = [
    (build_std_pattern(old, wb), new)
    for old, new, wb in IDENTITY_REPLACEMENTS
    if old not in SKIP_IN_STD
]

var_patterns = [(re.compile(pat), rep) for pat, rep in VARIABLE_RENAMES]
name_pats = [(re.compile(re.escape(old), re.IGNORECASE), new) for old, new in NAME_SUBS]

COMMENT_RE = re.compile(
    r"(\"\"\".*?\"\"\"|\"(?:[^\"\\]|\\.)*\"|\'\'\'.*?\'\'\'|\'(?:[^\'\\]|\\.)*\')|[ \t]*\#[^\n]*",
    re.DOTALL,
)

def apply_identity(content):
    changes = 0
    for pat, new in std_patterns:
        content, n = pat.subn(new, content)
        changes += n
    for pat, new in CUSTOM_IDENTITY:
        content, n = pat.subn(new, content)
        changes += n
    return content, changes

def apply_var_renames(content):
    changes = 0
    for pat, new in var_patterns:
        content, n = pat.subn(new, content)
        changes += n
    return content, changes

def strip_comments(content):
    result = COMMENT_RE.sub(lambda m: m.group(1) if m.group(1) else "", content)
    return re.sub(r"\n{3,}", "\n\n", result)

def rename_basename(name):
    for pat, new in name_pats:
        name = pat.sub(new, name)
    return name

def plan_renames(root):
    plan = []
    for dirpath, dirnames, filenames in os.walk(root, topdown=False):
        dp = Path(dirpath)
        if any(skip_dir(p) for p in dp.parts):
            continue
        for fname in filenames:
            new_name = rename_basename(fname)
            if new_name != fname:
                plan.append((dp / fname, dp / new_name))
        if dp != root:
            new_dname = rename_basename(dp.name)
            if new_dname != dp.name:
                plan.append((dp, dp.parent / new_dname))
    return plan

def heal_res_paths(root, rename_map):
    if not rename_map:
        return
    heal_exts = {".tscn", ".tres", ".godot", ".cfg"}
    files, total = 0, 0
    for dirpath, dirnames, filenames in os.walk(root, topdown=True):
        dirnames[:] = [d for d in dirnames if not skip_dir(d)]
        for fname in filenames:
            if Path(fname).suffix.lower() not in heal_exts:
                continue
            fpath = Path(dirpath) / fname
            content = read_text(fpath)
            if content is None:
                continue
            new_content, n = content, 0
            for old_res, new_res in rename_map.items():
                result, count = re.subn(re.escape(old_res), new_res, new_content)
                if count:
                    new_content = result
                    n += count
            if n:
                files += 1
                total += n
                log(f"  [path] {fpath.relative_to(root)}  ({n} updates)")
                write_text(fpath, new_content)
    _stats["p3_path_files_healed"] = files
    _stats["p3_path_updates"] = total
    log(f"  -> {files} scene/resource files updated, {total} path corrections.")

def pass1(root):
    log("=" * 60)
    log("PASS 1 -- Identity & Rebranding")
    log("=" * 60)
    files, total = 0, 0
    for dirpath, dirnames, filenames in os.walk(root, topdown=True):
        dirnames[:] = [d for d in dirnames if not skip_dir(d)]
        for fname in filenames:
            fpath = Path(dirpath) / fname
            if fpath.suffix.lower() not in TEXT_EXTENSIONS or is_binary(fpath):
                continue
            content = read_text(fpath)
            if content is None:
                log(f"  SKIP (unreadable): {fpath}", "WARN")
                continue
            new_content, n = apply_identity(content)
            if n:
                files += 1
                total += n
                log(f"  [edit] {fpath.relative_to(root)}  ({n} subs)")
                write_text(fpath, new_content)
    _stats["p1_files_modified"] = files
    _stats["p1_total_substitutions"] = total
    log(f"\n  -> {files} files, {total} substitutions.")

def pass2(root):
    log("=" * 60)
    log("PASS 2 -- GDScript: variable renames + comment removal")
    log("=" * 60)
    var_files, var_total, cmt_files = 0, 0, 0
    for dirpath, dirnames, filenames in os.walk(root, topdown=True):
        dirnames[:] = [d for d in dirnames if not skip_dir(d)]
        for fname in filenames:
            if not fname.endswith(".gd"):
                continue
            fpath = Path(dirpath) / fname
            content = read_text(fpath)
            if content is None:
                continue
            content_v, n = apply_var_renames(content)
            if n:
                var_files += 1
                var_total += n
                log(f"  [vars] {fpath.relative_to(root)}  ({n} renames)")
            content_c = strip_comments(content_v)
            if content_c != content_v:
                cmt_files += 1
                log(f"  [cmt]  {fpath.relative_to(root)}")
            if content_c != content:
                write_text(fpath, content_c)
    _stats["p2a_files_var_renamed"] = var_files
    _stats["p2a_total_var_renames"] = var_total
    _stats["p2b_files_comments_removed"] = cmt_files
    log(f"\n  -> {var_files} files had variable renames ({var_total} total).")
    log(f"  -> {cmt_files} files had comments stripped.")

def pass3(root):
    log("=" * 60)
    log("PASS 3 -- Physical Renames + res:// Healing")
    log("=" * 60)
    plan = plan_renames(root)
    if not plan:
        log("  (no files or directories require renaming)")
        _stats["p3_renames"] = 0
        return
    root_str = str(root.resolve())
    rename_map = {}
    for old_abs, new_abs in plan:
        old_rel = str(old_abs.resolve()).replace(root_str, "").replace("\\", "/")
        new_rel = str(new_abs.resolve()).replace(root_str, "").replace("\\", "/")
        if not old_rel.startswith("/"):
            old_rel = "/" + old_rel
        if not new_rel.startswith("/"):
            new_rel = "/" + new_rel
        rename_map["res:/" + old_rel] = "res:/" + new_rel
    log(f"  {len(plan)} renames planned -- healing res:// paths first ...")
    heal_res_paths(root, rename_map)
    success = 0
    for old_path, new_path in plan:
        if not old_path.exists():
            log(f"  SKIP (already moved?): {old_path}", "WARN")
            continue
        if new_path.exists() and new_path != old_path:
            log(f"  CONFLICT (target exists): {new_path}", "WARN")
            _stats["errors"] += 1
            continue
        log(f"  [rename] {old_path.relative_to(root)}  ->  {new_path.name}")
        try:
            if not DRY_RUN:
                old_path.rename(new_path)
            success += 1
        except OSError as e:
            log(f"  RENAME ERROR: {old_path}: {e}", "ERROR")
            _stats["errors"] += 1
    _stats["p3_renames"] = success
    log(f"\n  -> {success} / {len(plan)} renames completed.")

def main():
    root = PROJECT_ROOT.resolve()
    print()
    print("=" * 66)
    print("  ALCHEMISTRY: LEAD N IRON -- Clean-Room Refactor  v3")
    print("=" * 66)
    print(f"  Project root : {root}")
    print(f"  Godot target : 3.6.1")
    print(f"  Dry-run      : {'YES -- no files will be changed' if DRY_RUN else 'NO  -- changes are live'}")
    print()
    if not (root / "project.godot").exists():
        ans = input("  WARNING: No project.godot found here.\n  Are you sure this is the Godot project root? [y/N]: ").strip().lower()
        if ans != "y":
            print("  Aborted.")
            sys.exit(1)
    start = datetime.datetime.now()
    pass1(root)
    pass2(root)
    pass3(root)
    elapsed = (datetime.datetime.now() - start).total_seconds()
    _stats["elapsed_seconds"] = round(elapsed, 2)
    print()
    print("=" * 66)
    print("  REFACTOR COMPLETE")
    print("=" * 66)
    for k, v in sorted(_stats.items()):
        print(f"  {k:<44} {v}")
    print(f"\n  Elapsed: {elapsed:.1f}s")
    flush_log()
    errors = _stats.get("errors", 0)
    if errors:
        print(f"\n  WARNING: {errors} errors -- check REFACTOR_LOG.txt before opening Godot.")
        sys.exit(2)
    else:
        print("\n  All passes completed without errors.")
        print("\n  Next steps:")
        print("    1. Open project in Godot 3.6.1 -- check the Output panel for any errors.")
        print("    2. Press Play and confirm the game launches.")
        print("    3. git add -A && git commit -m 'chore: alchemistry clean-room refactor'")

if __name__ == "__main__":
    main()
