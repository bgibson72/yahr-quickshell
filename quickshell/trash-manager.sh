#!/bin/bash
# trash-manager.sh
# Manages the freedesktop.org XDG trash spec directory (~/.local/share/Trash)
# directly, since `gio trash --list/--restore` require the trash:// GVFS
# backend (gvfsd-trash), which isn't installed in this environment. This is
# also what Thunar (and any other spec-compliant file manager) uses, so
# trashed files show up here regardless of which app deleted them.
#
# Subcommands:
#   list                 -> JSON array of trashed items
#   restore <name>       -> move an item back to its original location
#   delete <name>         -> permanently delete a single trashed item
#   empty                -> permanently delete everything in the trash

TRASH_DIR="$HOME/.local/share/Trash"
FILES_DIR="$TRASH_DIR/files"
INFO_DIR="$TRASH_DIR/info"

mkdir -p "$FILES_DIR" "$INFO_DIR"

case "$1" in
  list)
    python3 - "$FILES_DIR" "$INFO_DIR" << 'PYEOF'
import json, os, sys, urllib.parse

files_dir, info_dir = sys.argv[1], sys.argv[2]
items = []
for entry in sorted(os.listdir(info_dir)):
    if not entry.endswith(".trashinfo"):
        continue
    name = entry[:-len(".trashinfo")]
    info_path = os.path.join(info_dir, entry)
    orig_path = ""
    deletion_date = ""
    try:
        with open(info_path, encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if line.startswith("Path="):
                    orig_path = urllib.parse.unquote(line[len("Path="):])
                elif line.startswith("DeletionDate="):
                    deletion_date = line[len("DeletionDate="):]
    except OSError:
        continue

    trashed_path = os.path.join(files_dir, name)
    if not os.path.exists(trashed_path):
        # Orphaned info file (files entry missing) -- skip it
        continue
    is_dir = os.path.isdir(trashed_path)
    size = 0
    try:
        if is_dir:
            for root, _dirs, fnames in os.walk(trashed_path):
                for fn in fnames:
                    fp = os.path.join(root, fn)
                    try:
                        size += os.path.getsize(fp)
                    except OSError:
                        pass
        else:
            size = os.path.getsize(trashed_path)
    except OSError:
        pass

    items.append({
        "name": name,
        "origPath": orig_path,
        "deletionDate": deletion_date,
        "isDir": is_dir,
        "size": size,
    })

items.sort(key=lambda x: x["deletionDate"], reverse=True)
print(json.dumps(items))
PYEOF
    ;;

  restore)
    name="$2"
    if [[ -z "$name" ]]; then
        echo '{"error":"missing name"}'
        exit 1
    fi
    python3 - "$FILES_DIR" "$INFO_DIR" "$name" << 'PYEOF'
import json, os, shutil, sys, urllib.parse

files_dir, info_dir, name = sys.argv[1], sys.argv[2], sys.argv[3]
info_path = os.path.join(info_dir, name + ".trashinfo")
trashed_path = os.path.join(files_dir, name)

if not os.path.isfile(info_path) or not os.path.exists(trashed_path):
    print(json.dumps({"error": "not found"}))
    sys.exit(1)

orig_path = ""
with open(info_path, encoding="utf-8", errors="replace") as f:
    for line in f:
        line = line.strip()
        if line.startswith("Path="):
            orig_path = urllib.parse.unquote(line[len("Path="):])
            break

if not orig_path:
    print(json.dumps({"error": "no original path recorded"}))
    sys.exit(1)
if not os.path.isabs(orig_path):
    orig_path = os.path.join(os.path.expanduser("~"), orig_path)
if os.path.exists(orig_path):
    print(json.dumps({"error": "destination already exists: " + orig_path}))
    sys.exit(1)

os.makedirs(os.path.dirname(orig_path), exist_ok=True)
shutil.move(trashed_path, orig_path)
os.remove(info_path)
print(json.dumps({"ok": True, "path": orig_path}))
PYEOF
    ;;

  delete)
    name="$2"
    if [[ -z "$name" ]]; then
        echo '{"error":"missing name"}'
        exit 1
    fi
    rm -rf -- "${FILES_DIR:?}/$name"
    rm -f -- "$INFO_DIR/$name.trashinfo"
    echo '{"ok": true}'
    ;;

  empty)
    find "$FILES_DIR" -mindepth 1 -delete 2>/dev/null
    find "$INFO_DIR" -mindepth 1 -delete 2>/dev/null
    echo '{"ok": true}'
    ;;

  *)
    echo '{"error":"unknown command"}'
    exit 1
    ;;
esac
