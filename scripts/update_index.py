#!/usr/bin/env python3
import hashlib, json, os, subprocess, time, urllib.request

REPO = "Mortal-freeman-sha256/cls-repo"
TAG = "repo-x86_64"
OUT_FILE = "x86_64/index.toml"

VERSIONS = {
    "git": "2.47.3", "htop": "3.3.0", "vim": "9.1.1000", "btop": "1.4.0",
    "neofetch": "7.1.0", "python3": "3.13.1", "openssh": "9.9p1", "lua": "5.4.7",
    "bash": "5.2.37", "sysutils": "0.3.0", "ntfs-3g": "2022.10.3", "fastfetch": "2.34.1",
    "kernel": "6.12.119", "base-gnu": "0.3.5", "lxde": "0.3.5", "sway": "0.3.5",
    "tmux": "3.5a", "flatpak": "1.15.10", "firefox": "128.5.0esr"
}

# Берем уже известные хэши из старого index.toml, чтобы не качать старые файлы заново
known_sha = {}
if os.path.exists(OUT_FILE):
    with open(OUT_FILE) as f:
        for line in f:
            if 'sha = "' in line and 'file = "' in line:
                fn = line.split('file = "')[1].split('"')[0]
                sh = line.split('sha = "')[1].split('"')[0]
                known_sha[fn] = sh

raw = subprocess.check_output(["gh", "release", "view", TAG, "-R", REPO, "--json", "assets"])
assets = json.loads(raw)["assets"]

os.makedirs("x86_64", exist_ok=True)
lines = [
    "# CLS package repository index",
    f"# generated {int(time.time())}",
    ""
]

for a in assets:
    fn = a["name"]
    if not fn.endswith(".clp"):
        continue
    name = fn[:-4]
    ver = VERSIONS.get(name, "0.3.5")
    url = a["url"]
    if fn in known_sha:
        sha = known_sha[fn]
    else:
        print(f"Downloading {fn} to compute SHA-256...")
        h = hashlib.sha256()
        with urllib.request.urlopen(url) as resp:
            while chunk := resp.read(1048576):
                h.update(chunk)
        sha = h.hexdigest()
    lines.append(f'{name} = {{ name = "{name}", ver = "{ver}", sha = "{sha}", file = "{fn}", url = "{url}" }}')

with open(OUT_FILE, "w") as f:
    f.write("\n".join(lines) + "\n")
print(f"Updated {OUT_FILE} with {len(lines)-3} packages!")
