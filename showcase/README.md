# Galleon public showcase

This static Sites publication supplements the canonical Galleon front door. Product identity, positioning and copy derive from `galleonlabs.io/BRAND.md` and `galleonlabs.io/lib/work.ts`; the existing generated brand lockup remains the source.

The showcase contains only public products, release links, installation instructions and support/privacy routes. It contains no personal records, runtime state, internal ledgers, analytics, wallet connection or financial execution.

Plugin release availability and owner-account validation are separate from public directory approval. Update the publication statements only against actual submission/approval receipts. Profile publication is separate too: the approved Galleon bio returned “Profile update failed moderation” on 30 September 2026.

Prepared profile bio: `Galleon Labs: DeFi research, Boomkin and Peerlytics. https://galleonlabs.io · Receipts/support: https://peerlytics.xyz`

Before publishing, run the repository's `bash scripts/validate.sh`, verify showcase links and render desktop/mobile. Push the exact source to the configured Sites source repository, then run `bun scripts/build-showcase.ts` in a clean checkout of that same commit. Package generated `dist/` and `.openai/hosting.json`, then save and deploy that version. Record the returned project ID unchanged in `.openai/hosting.json`; reuse it on subsequent updates. Public audience is authorised specifically for this showcase. Verify the deployed page without authentication before adding it to the ChatGPT profile.

Andrew owns this public profile; the existing Galleon owner updates links when product releases change. Canonical product sources remain authoritative.
