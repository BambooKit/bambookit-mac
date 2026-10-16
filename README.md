# BambooKit for macOS

BambooKit — AI coding on your Mac, with your phone as the remote. This is the macOS build of the
BambooKit desktop app (the same app as the Windows release, built from
[`bambookit-application`](https://github.com/BambooKit/bambookit-application)), for Apple Silicon and Intel Macs.

## Install (one command)

Open **Terminal** and run:

```bash
curl -fsSL https://raw.githubusercontent.com/BambooKit/bambookit-mac/main/install.sh | bash
```

The installer:

1. Picks the right build for your Mac (Apple Silicon `arm64` or Intel `x64`).
2. Downloads the latest DMG from [Releases](https://github.com/BambooKit/bambookit-mac/releases).
3. Installs **BambooKit.app** into `/Applications` (or `~/Applications` if you are not an admin), replacing an older version.
4. Removes the download quarantine flag, because the app is not notarized by Apple yet, and opens BambooKit.

Install a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/BambooKit/bambookit-mac/main/install.sh | BAMBOOKIT_VERSION=1.0.2 bash
```

### Manual install

Download `BambooKit-<version>-mac-arm64.dmg` (Apple Silicon) or `BambooKit-<version>-mac-x64.dmg` (Intel) from
[Releases](https://github.com/BambooKit/bambookit-mac/releases), drag **BambooKit** to **Applications**, then run once:

```bash
xattr -dr com.apple.quarantine /Applications/BambooKit.app
```

(or right-click BambooKit → **Open** → **Open**). Requires macOS 11 Big Sur or later.

### Uninstall

```bash
osascript -e 'quit app "BambooKit"'; rm -rf /Applications/BambooKit.app ~/Library/Application\ Support/com.bambookit.desktop
```

## Build from source

Requires macOS, [bun](https://bun.sh) 1.3.14 or newer, and Xcode Command Line Tools.

```bash
git clone https://github.com/BambooKit/bambookit-application.git
git clone https://github.com/BambooKit/bambookit-mac.git
cd bambookit-mac
scripts/build-mac.sh ../bambookit-application
```

DMGs, zips and `SHA256SUMS.txt` for both architectures are written to `release/`.

Sign-in uses the public client config in `bambookit-application/packages/desktop/.env.bambookit`
(copy `.env.bambookit.example`). Without it the app still builds, but shows **BambooKit not configured**.

Builds are ad-hoc signed and not notarized. With an Apple Developer ID, set `CSC_LINK`, `CSC_KEY_PASSWORD`,
`APPLE_ID`, `APPLE_APP_SPECIFIC_PASSWORD` and `APPLE_TEAM_ID` and run `scripts/build-mac.sh ../bambookit-application --notarize`.
After that the quarantine step is no longer needed.
