# Galleon Labs on GitHub

**The shared profile and community files for Galleon Labs.**

[Organisation](https://github.com/galleonlabs) · [Website](https://galleonlabs.io) · [Contributing](CONTRIBUTING.md) · [Security](SECURITY.md)

## What lives here

| File | Purpose |
| --- | --- |
| [profile/README.md](profile/README.md) | The public organisation profile shown at [github.com/galleonlabs](https://github.com/galleonlabs) |
| [SECURITY.md](SECURITY.md) | Default security reporting guidance for public repositories without their own policy |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Shared contributor guidance; individual repositories can provide their own |
| [scripts/validate.sh](scripts/validate.sh) | Profile structure, images, public links and linked repository status |

GitHub reads the organisation profile from the exact path `profile/README.md`. Keep that path and the lockup image intact when updating the introduction or work list.

## Make a change

Use the current product name, a short factual description and its canonical public link. Product-specific setup instructions belong in the product repository. The shared visual identity lives in the [public brand kit](https://galleonlabs.io/brand).

Run validation before sending a pull request:

```bash
bash scripts/validate.sh
```

The check verifies the profile file, its lockup image and public URLs. It also uses GitHub's API to confirm that linked Galleon repositories are public, unarchived and named correctly; a successful redirect alone does not establish that. CI runs on changes and daily, since external images and links can break without a repository edit. Add an exception to `scripts/link-allowlist.txt` only when a host blocks automated clients and the link has been verified manually.

A passing change on `main` is the release. Check the rendered [organisation page](https://github.com/galleonlabs) after publishing profile changes.

## Get involved

Start with [Boomkin](https://github.com/galleonlabs/boomkin) for a Hermes DeFi agent, or [crypto-defi-skills](https://github.com/galleonlabs/crypto-defi-skills) for individual skill packs. Bug reports, documentation improvements and focused pull requests are welcome in the relevant repository.

These shared files are [MIT licensed](LICENSE). For general feedback, contact [gm@galleonlabs.io](mailto:gm@galleonlabs.io).

## License and credit

[MIT licensed](LICENSE), with the copyright and permission notice retained when reusing copies or substantial portions. Created by [Andrew Wilkinson](https://andrewwilkinson.io) and [Galleon Labs](https://github.com/galleonlabs).

See [reuse and attribution](ATTRIBUTION.md) for a ready-to-copy credit line. If Galleon Labs community files helps your work, [a star on the original repository](https://github.com/galleonlabs/.github) is appreciated and entirely optional.
