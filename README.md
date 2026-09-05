# .github

Organisation-wide GitHub files for [Galleon Labs](https://galleonlabs.io).

- `profile/README.md` — the organisation profile GitHub renders at
  [github.com/galleonlabs](https://github.com/galleonlabs). GitHub reads this exact
  path; moving or renaming it silently falls back to this file.
- `SECURITY.md` — the default security policy for every public repository in the
  organisation that does not ship its own.

## Validation

The `validate` workflow gates this repo: the profile renders from the path GitHub
reads and carries its lockup, every public URL in the tracked markdown still
responds, and every Galleon Labs repository the markdown links is still public,
unarchived, and named the way we link it. github.com answers `200` for an archived
repository and follows a rename, so the last check reads repository status from the
public GitHub API instead. The lockup, the product links, and those repositories all
live off this repository, so the check also runs daily and drift surfaces without
waiting for a commit. Run it locally with `bash scripts/validate.sh`. A passing merge
to `main` is the release.

Add a URL to `scripts/link-allowlist.txt` only when a host blocks automated
clients and the link is verified by hand.
