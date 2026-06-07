<div align="center">

![BambuStudio](https://user-images.githubusercontent.com/106916061/179006347-497d24c0-9bd6-45b7-8c49-d5cc8ecfe5d7.png)

# BambuStudio

**A Linux-first fork of [BambuLab/BambuStudio](https://github.com/bambulab/BambuStudio) with native packaging and automated, hardened build pipelines.**

[![Nightly](https://github.com/BenJule/BambuStudio/actions/workflows/cd-nightly.yml/badge.svg?branch=develop)](https://github.com/BenJule/BambuStudio/actions/workflows/cd-nightly.yml)
[![Release](https://github.com/BenJule/BambuStudio/actions/workflows/cd-release.yml/badge.svg)](https://github.com/BenJule/BambuStudio/actions/workflows/cd-release.yml)
[![CodeQL](https://github.com/BenJule/BambuStudio/actions/workflows/security-codeql.yml/badge.svg)](https://github.com/BenJule/BambuStudio/actions/workflows/security-codeql.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/BenJule/BambuStudio/badge)](https://securityscorecards.dev/viewer/?uri=github.com/BenJule/BambuStudio)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20macOS%20%7C%20Linux-informational)

[Installation](#-installation) · [Features](#-features) · [Building](#-building-from-source) · [Release Process](#-release-process) · [Security](#-security) · [Contributing](#-contributing)

</div>

---

Bambu Studio is a feature-rich slicing software. It offers project-based workflows, systematically optimized slicing algorithms, and an easy-to-use graphic interface, delivering a smooth printing experience.

This fork tracks BambuLab's upstream and adds what desktop and Linux users miss most: **native package distribution** across every major platform, **automated nightly and release builds**, and **hardened, fully reproducible CI/CD pipelines**. Prebuilt Windows, macOS and Linux binaries are published on the [releases page](https://github.com/BenJule/BambuStudio/releases/).

## ✨ What this fork adds

| Area | Details |
|------|---------|
| **Native packaging** | Signed **APT** repository, **Ubuntu PPA**, **AUR**, **Fedora COPR**, **Flatpak**, **AppImage**, **Homebrew** cask, and Windows **winget** |
| **Automated releases** | Nightly pre-releases from `develop`, GPG-signed release tags, automatic deployment to every package channel |
| **Hardened pipelines** | Pinned action SHAs, egress-audited runners, reproducible distro build containers mirrored to GHCR |
| **Continuous security** | CodeQL (security & quality), OpenSSF Scorecard, dependency review, signed commits required on `master` |
| **Quality gates** | A single aggregating status check guards `master`; every change lands through `develop` and a full-platform nightly first |

## 📦 Installation

| Platform | Method | Auto-updates |
|----------|--------|:---:|
| **Debian / Ubuntu** | APT repository | ✅ |
| **Ubuntu** | PPA (`ppa:benlue/bambu-studio`) | ✅ |
| **Fedora** | COPR (`benlue/bambu-studio`) | ✅ |
| **Arch Linux** | AUR (`bambu-studio-bin`) | ✅ |
| **macOS** | Homebrew cask | ✅ |
| **Windows** | winget | ✅ |
| **Any Linux** | AppImage / Flatpak | — |

<details open>
<summary><b>Debian / Ubuntu — APT (recommended)</b></summary>

```bash
curl -fsSL https://apt.s3-dev.ovh/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/bambustudio.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/bambustudio.gpg] https://apt.s3-dev.ovh stable main" | sudo tee /etc/apt/sources.list.d/bambustudio.list
sudo apt update && sudo apt install bambu-studio
```

Supports Debian 12+, Ubuntu 22.04 and 24.04. Update with `sudo apt upgrade`.
</details>

<details>
<summary><b>Ubuntu — PPA (Launchpad)</b></summary>

```bash
sudo add-apt-repository ppa:benlue/bambu-studio
sudo apt update && sudo apt install bambu-studio
```

Native `apt` updates from Canonical's Launchpad. Built for Ubuntu 22.04 (jammy) and 24.04 (noble). Update with `sudo apt upgrade`.
</details>

<details>
<summary><b>Fedora — COPR</b></summary>

```bash
sudo dnf copr enable benlue/bambu-studio
sudo dnf install bambu-studio
```

Native `dnf` updates from Fedora COPR. Update with `sudo dnf upgrade`.
</details>

<details>
<summary><b>Arch Linux — AUR</b></summary>

```bash
yay -S bambu-studio-bin
```

Works with any AUR helper (`paru`, `trizen`, …). The pre-built binary requires no compilation.
</details>

<details>
<summary><b>macOS — Homebrew</b></summary>

```bash
brew tap BenJule/homebrew-tap
brew install --cask bambu-studio
```

Supports macOS 13+ (Intel & Apple Silicon). Update with `brew upgrade --cask bambu-studio`.
</details>

<details>
<summary><b>Windows — winget</b></summary>

```powershell
winget install BenJule.BambuStudio
```

Requires Windows 10 or later. The `.exe` installer (x64 / ARM64) is also on the [releases page](https://github.com/BenJule/BambuStudio/releases/latest).
</details>

<details>
<summary><b>Any Linux — AppImage / Flatpak</b></summary>

Download the portable AppImage from the [releases page](https://github.com/BenJule/BambuStudio/releases/latest):

```bash
chmod +x BambuStudio_*.AppImage && ./BambuStudio_*.AppImage
```

A Flatpak build is also available for all distributions.
</details>

## 🚀 Features

**Core**

- Project-based workflow with GCode viewer
- Multiple plate management
- Remote control & monitoring
- Auto-arrange and auto-orient objects
- Normal / Tree / Hybrid and customized supports
- Multi-material printing with rich painting tools
- Global / object / part-level slicing parameters

**Advanced**

- Dynamic cooling logic controlling fan speed and print speed
- Auto brim based on mechanical analysis
- Arc path support (G2/G3) and STEP format
- Assembly & explosion view
- Flushing transition-filament into infill/object during filament change

## 🔧 Building from source

Supported build platforms (see the upstream compile guides):

- **Windows** 64-bit — [Compile Guide](https://github.com/bambulab/BambuStudio/wiki/Windows-Compile-Guide)
- **macOS** 64-bit — [Compile Guide](https://github.com/bambulab/BambuStudio/wiki/Mac-Compile-Guide)
- **Linux** — [Compile Guide](https://github.com/bambulab/BambuStudio/wiki/Linux-Compile-Guide)

On Linux, the distro packaging jobs build inside reproducible containers (Debian, Fedora, Arch) so a local `./BuildLinux.sh -dsi` reproduces CI exactly.

## 🔄 Release process

Changes flow through a controlled, automated pipeline:

```
fix/feat branch ──PR──▶ develop ──nightly (all platforms)──▶ master ──tag──▶ release
```

- Every PR targets **`develop`** and must pass the aggregating status check.
- The **nightly** builds `develop` on all platforms (Windows, macOS Intel/ARM, Linux) and publishes a pre-release with a 14-day rolling history.
- A green, stable `develop` is promoted to **`master`** — the release-ready snapshot.
- Tagged releases are GPG-signed and deployed to APT, AUR, Homebrew, winget and Flatpak automatically.

## 🔒 Security

- **CodeQL** static analysis (security & quality suite) on every change to `master`
- **OpenSSF Scorecard** and **dependency review** on every pull request
- **GPG-signed** commits and release tags; force-push and branch deletion blocked on `master`
- Action versions pinned by commit SHA; runners restricted with egress auditing

Found a vulnerability? Please follow the [security policy](https://github.com/BenJule/BambuStudio/security/policy) — do not open a public issue.

## 🤝 Contributing

Contributions are welcome. Every change follows **Issue → Branch → PR → Review → Merge**, opened against `develop`:

1. Open an issue describing the bug or feature.
2. Branch off `develop` as `fix/short-description` or `feat/short-description`.
3. Open a pull request to `develop` referencing the issue (`Closes #N`); CI runs automatically.
4. Once the status check is green, the change is squash-merged.

Report bugs and request features via the [issue tracker](https://github.com/BenJule/BambuStudio/issues/new/choose).

## 📄 License

Bambu Studio is licensed under the **GNU Affero General Public License, version 3**. Bambu Studio is based on [PrusaSlicer](https://github.com/prusa3d/PrusaSlicer) by Prusa Research, which is based on [Slic3r](https://github.com/Slic3r/Slic3r) by Alessandro Ranellucci and the RepRap community.

The AGPL-3.0 ensures that if you use any part of this software in any way (even behind a web server), your software must be released under the same license.

> The Bambu networking plugin is based on non-free libraries and is optional. Without it, you can still slice and print via SD card.

## 🙏 Acknowledgements

Built on the work of [BambuLab](https://github.com/bambulab/BambuStudio), [Prusa Research](https://github.com/prusa3d/PrusaSlicer), [Alessandro Ranellucci](https://github.com/Slic3r/Slic3r), and the RepRap community.
