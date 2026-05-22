# nixpkg-antigravity

Nix flake for [Antigravity CLI](https://github.com/google-antigravity/antigravity-cli) (`agy`) — Google's terminal AI coding agent.

## Install

```bash
nix profile install github:RogerNavelsaker/nixpkg-antigravity
```

Or with flox:

```bash
flox install github:RogerNavelsaker/nixpkg-antigravity
```

## Run

```bash
agy           # or: antigravity
```

## Platforms

`x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin` (glibc only — musl variant not packaged).

## Notes

- Pinned to upstream version **1.0.1**. Upstream binary self-updates at runtime by writing next to itself; under Nix this is blocked because `/nix/store` is read-only. Bump `version` + `sha512` in `flake.nix` to upgrade.
- License: proprietary (Google Antigravity ToS).
- Manifest source: `https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/<platform>.json`.

## Update procedure

```bash
curl -fsSL "https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_amd64.json"
# repeat for linux_arm64, darwin_amd64, darwin_arm64
# patch version + url + sha512 in flake.nix
```
