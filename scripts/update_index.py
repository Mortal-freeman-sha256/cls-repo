#!/usr/bin/env python3
import json, os, subprocess, time

REPO = "Mortal-freeman-sha256/cls-repo"
TAG = "repo-x86_64"
OUT_FILE = "x86_64/index.toml"

VERSIONS = {
    "git": "2.47.3", "htop": "3.3.0", "vim": "9.1.1000", "btop": "1.4.0",
    "neofetch": "7.1.0", "python3": "3.13.1", "openssh": "9.9p1", "lua": "5.4.7",
    "bash": "5.2.37", "sysutils": "0.3.0", "ntfs-3g": "2022.10.3", "fastfetch": "2.34.1",
    "kernel": "6.12.119", "base-gnu": "0.3.5", "lxde": "0.3.5", "sway": "0.3.5",
    "tmux": "3.5a", "flatpak": "1.15.10", "firefox": "160.0.1"
}

raw = subprocess.check_output(["gh", "api", f"repos/{REPO}/releases/tags/{TAG}"])
assets = json.loads(raw)["assets"]

os.makedirs("x86_64", exist_ok=True)
lines = ["# CLS package repository index", f"# generated {int(time.time())}", ""]

for a in assets:
    fn = a["name"]
    if not fn.endswith(".clp"):
        continue
    name = fn[:-4]
    ver = VERSIONS.get(name, "0.3.5")
    url = a["browser_download_url"]
    sha = (a.get("digest") or "").removeprefix("sha256:")
    lines.append(f'{name} = {{ name = "{name}", ver = "{ver}", sha = "{sha}", file = "{fn}", url = "{url}" }}')

with open(OUT_FILE, "w") as f:
    f.write("\n".join(lines) + "\n")
print(f"Updated {OUT_FILE} with {len(lines)-3} packages!")
