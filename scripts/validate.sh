#!/usr/bin/env bash
# Required check: the organisation profile still renders, every public URL this
# repository publishes still responds, and every Galleon Labs repository it links is
# still live under the name we advertise. The profile page is assembled by GitHub from
# profile/README.md and pulls its lockup from galleonlabs.io, so all three can break
# with no commit here. No repository secrets. No network except the extracted public
# URLs and the public GitHub API.
set -euo pipefail
cd "$(dirname "$0")/.."

export NO_COLOR=1

profile() {
  python3 - <<'PY'
import re
import sys
from pathlib import Path

PROFILE = Path("profile/README.md")

# GitHub renders the organisation page from this exact path. A rename or a move
# silently falls back to the bare repository README, so pin the path itself.
if not PROFILE.is_file():
    print(f"{PROFILE}: missing; the organisation profile renders from this exact path", file=sys.stderr)
    sys.exit(1)

body = PROFILE.read_text(encoding="utf-8")
if not body.strip():
    print(f"{PROFILE}: empty", file=sys.stderr)
    sys.exit(1)

images = re.findall(r'<img[^>]*\bsrc="([^"]+)"', body)
if not images:
    print(f"{PROFILE}: no <img> lockup found", file=sys.stderr)
    sys.exit(1)

print(f"{PROFILE}: {len(body.splitlines())} line(s), {len(images)} image(s)")
for src in images:
    print(f"  img {src}")
PY
}

links() {
  python3 - <<'PY'
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(".")
FILES = [
    ROOT / "README.md",
    ROOT / "SECURITY.md",
    ROOT / "profile/README.md",
]
ALLOWLIST = ROOT / "scripts/link-allowlist.txt"
USER_AGENT = "galleonlabs-dot-github-link-check/1.0"
URL_RE = re.compile(r"https?://[^\s<>\"'`)]+")
TRAILING = ".,;:)]}'\""

# Images carried by the profile header must come back as images. A host that
# answers 200 with an HTML error page would still break the rendered page.
IMAGE_RE = re.compile(r'<img[^>]*\bsrc="(https?://[^"]+)"')


def load_allowlist() -> set[str]:
    if not ALLOWLIST.is_file():
        return set()
    urls: set[str] = set()
    for raw in ALLOWLIST.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if line and not line.startswith("#"):
            urls.add(line)
    return urls


def extract() -> tuple[dict[str, list[str]], set[str]]:
    found: dict[str, list[str]] = {}
    images: set[str] = set()
    for path in FILES:
        if not path.is_file():
            print(f"{path}: missing", file=sys.stderr)
            sys.exit(1)
        text = path.read_text(encoding="utf-8")
        for match in URL_RE.finditer(text):
            url = match.group(0).rstrip(TRAILING)
            if url:
                found.setdefault(url, []).append(path.as_posix())
        images.update(IMAGE_RE.findall(text))
    return found, images


def probe(url: str) -> tuple[int, str]:
    request = urllib.request.Request(
        url,
        method="GET",
        headers={"User-Agent": USER_AGENT},
    )
    try:
        with urllib.request.urlopen(request, timeout=20) as response:
            return int(response.status), response.headers.get("Content-Type", "")
    except urllib.error.HTTPError as exc:
        return int(exc.code), exc.headers.get("Content-Type", "") if exc.headers else ""


allow = load_allowlist()
urls, images = extract()
if not urls:
    print("no http(s) URLs found in tracked markdown", file=sys.stderr)
    sys.exit(1)

failed = 0
for url in sorted(urls):
    sources = ", ".join(sorted(set(urls[url])))
    if url in allow:
        print(f"ALLOW {url}  ({sources})")
        continue
    try:
        code, content_type = probe(url)
    except Exception as exc:
        print(f"FAIL  {url}  ({sources})  {exc}", file=sys.stderr)
        failed += 1
        continue
    if not 200 <= code < 400:
        print(f"FAIL  {url}  ({sources})  HTTP {code}", file=sys.stderr)
        failed += 1
        continue
    if url in images and not content_type.startswith("image/"):
        print(
            f"FAIL  {url}  ({sources})  HTTP {code} served {content_type or 'no content-type'}, expected an image",
            file=sys.stderr,
        )
        failed += 1
        continue
    print(f"{code}   {url}  ({sources})")

print(f"checked {len(urls)} unique URL(s), {len(images)} as image(s); {failed} failed")
sys.exit(1 if failed else 0)
PY
}

repos() {
  python3 - <<'PY'
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(".")
FILES = [
    ROOT / "README.md",
    ROOT / "SECURITY.md",
    ROOT / "profile/README.md",
]
ORG = "galleonlabs"
USER_AGENT = "galleonlabs-dot-github-repo-check/1.0"
TRAILING = ".,;:)]}'\""
REPO_RE = re.compile(rf"https?://(?:www\.)?github\.com/{ORG}/([A-Za-z0-9._-]+)")

# github.com answers 200 for an archived repository and follows a rename, so link
# health alone cannot tell that the profile is advertising retired or stale work.
# The public API reports both, plus the canonical name to compare the link against.


def extract() -> dict[str, list[str]]:
    found: dict[str, list[str]] = {}
    for path in FILES:
        if not path.is_file():
            print(f"{path}: missing", file=sys.stderr)
            sys.exit(1)
        text = path.read_text(encoding="utf-8")
        for match in REPO_RE.finditer(text):
            name = match.group(1).rstrip(TRAILING)
            if name:
                found.setdefault(name, []).append(path.as_posix())
    return found


def fetch(name: str) -> dict:
    headers = {"User-Agent": USER_AGENT, "Accept": "application/vnd.github+json"}
    # Actions supplies GITHUB_TOKEN so the shared runner IP is not rate limited;
    # a local run without one still fits comfortably in the anonymous budget.
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(
        f"https://api.github.com/repos/{ORG}/{name}",
        method="GET",
        headers=headers,
    )
    with urllib.request.urlopen(request, timeout=20) as response:
        return json.load(response)


names = extract()
if not names:
    print(f"no github.com/{ORG} repository links found in tracked markdown", file=sys.stderr)
    sys.exit(1)

failed = 0
for name in sorted(names, key=str.lower):
    sources = ", ".join(sorted(set(names[name])))
    try:
        repo = fetch(name)
    except urllib.error.HTTPError as exc:
        # 404 covers deleted and private alike; either way the link is not public work.
        detail = "not public" if exc.code == 404 else f"HTTP {exc.code}"
        print(f"FAIL  {ORG}/{name}  ({sources})  {detail}", file=sys.stderr)
        failed += 1
        continue
    except Exception as exc:
        # An unreadable API is a reportable gap, never a silent pass.
        print(f"FAIL  {ORG}/{name}  ({sources})  repository status unavailable: {exc}", file=sys.stderr)
        failed += 1
        continue

    canonical = str(repo.get("full_name", ""))
    if canonical.lower() != f"{ORG}/{name}".lower():
        print(
            f"FAIL  {ORG}/{name}  ({sources})  renamed to {canonical or 'unknown'}; link the current name",
            file=sys.stderr,
        )
        failed += 1
        continue
    if repo.get("private"):
        print(f"FAIL  {ORG}/{name}  ({sources})  private", file=sys.stderr)
        failed += 1
        continue
    if repo.get("archived"):
        print(f"FAIL  {ORG}/{name}  ({sources})  archived; the profile lists it as live work", file=sys.stderr)
        failed += 1
        continue
    print(f"live  {ORG}/{name}  ({sources})")

print(f"checked {len(names)} linked {ORG} repositor{'y' if len(names) == 1 else 'ies'}; {failed} failed")
sys.exit(1 if failed else 0)
PY
}

cmd=${1:-all}
case "$cmd" in
  profile) profile ;;
  links) links ;;
  repos) repos ;;
  all)
    profile
    links
    repos
    ;;
  *)
    echo "usage: $0 [all|profile|links|repos]" >&2
    exit 2
    ;;
esac
