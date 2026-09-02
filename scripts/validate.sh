#!/usr/bin/env bash
# Required check: the organisation profile still renders and every public URL this
# repository publishes still responds. The profile page is assembled by GitHub from
# profile/README.md and pulls its lockup from galleonlabs.io, so both can break with
# no commit here. No repository secrets. No network except the extracted public URLs.
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

cmd=${1:-all}
case "$cmd" in
  profile) profile ;;
  links) links ;;
  all)
    profile
    links
    ;;
  *)
    echo "usage: $0 [all|profile|links]" >&2
    exit 2
    ;;
esac
