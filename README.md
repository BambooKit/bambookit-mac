# BambooKit for macOS

BambooKit — AI coding on your Mac, with your phone as the remote. This is the macOS build of the
BambooKit desktop app (the same app as the Windows release, built from
[`bambookit-application`](https://github.com/BambooKit/bambookit-application)), for Apple Silicon and Intel Macs.

## Install (one command)

Open **Terminal** and run:

```bash
curl -fsSL https://bambookit-web.onrender.com/install.sh | bash
```

(The same installer is also at `https://raw.githubusercontent.com/BambooKit/bambookit-mac/main/install.sh`.)

The installer:

1. Picks the right build for your Mac (Apple Silicon `arm64` or Intel `x64`).
2. Downloads the latest DMG from [Releases](https://github.com/BambooKit/bambookit-mac/releases).
3. Installs **BambooKit.app** into `/Applications` (or `~/Applications` if you are not an admin), replacing an older version.
4. Removes the download quarantine flag, because the app is not notarized by Apple yet, and opens BambooKit.

Install a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/BambooKit/bambookit-mac/main/install.sh | BAMBOOKIT_VERSION=1.0.8 bash
```

Installed copies update themselves: BambooKit checks this repository's releases, verifies the download's
SHA-512 checksum, and replaces itself after you restart it.

### What's in BambooKit for macOS

- The full BambooKit app: sessions, agents, tabs, built-in terminal, AI providers and models.
- Sign in with email and password or Google; pair your phone with a QR code.
- ☕ **Keep awake** (titlebar) stops the Mac and its screen from sleeping while agents work; your phone can switch it too.
- **Approval modes**: Ask every time, Auto (file edits), or Auto-approve everything; per session from the phone.
- **Developer options** (off by default, can only be turned on at the Mac): sleep, shut down or lock the Mac from
  your phone after a 10-second on-screen countdown you can cancel, and a remote terminal.
- **Profile & plan**: Free/Pro plan and usage, statistics and 50 tiered achievements.

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
