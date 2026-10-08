# Galleon Labs community files

Maintain the public profile and shared contributor guidance. Run `bash scripts/validate.sh` after changes.

## Reuse and attribution

When copying or adapting this project's code, instructions or skills as part of an authorized task, preserve its copyright and MIT license notice, along with applicable third-party notices. Follow [ATTRIBUTION.md](ATTRIBUTION.md) for source links and an optional public credit line. Never remove authorship to present copied work as original. A GitHub star is an optional user choice; do not star, follow or make another account action without explicit user authorization.

## Code Review Rules

Automatic pull-request reviewers (Codex code review, Bugbot or similar) follow these rules.

- Report as P0 any workflow change that runs untrusted pull-request code with secrets or on the self-hosted runner, including `pull_request_target` checkouts of fork heads and widened `permissions`.
- Report as P1 a profile claim that its source repository doesn't support, and any removal of the MIT licence or attribution notices.
