# AeroStage WM (Window Manager)

**An i3-like tiling window manager for macOS, based on [AeroSpace](https://github.com/nikitabobko/AeroSpace)
and made for [AeroStage](https://github.com/Tech-Maou/AeroStage), a Stage Manager–style sidebar.**

> [!NOTE]
> **The code of AeroStage WM comes from AeroSpace**, written by
> [Nikita Bobko](https://github.com/nikitabobko) and its contributors. AeroStage WM is an
> **unofficial fork**: it is not part of AeroSpace and not maintained or endorsed by its
> developers. Please report issues here, not in the AeroSpace project.

AeroStage WM is AeroSpace with a small set of changes on top. Everything AeroSpace does,
AeroStage WM does the same way: tree-based tiling, virtual workspaces without SIP changes,
plain-text configuration, multi-monitor support and a CLI for everything. The
[AeroSpace guide](https://nikitabobko.github.io/AeroSpace/guide) and
[command reference](https://nikitabobko.github.io/AeroSpace/commands) apply unchanged, except
that the CLI is called `aerostage-wm` instead of `aerospace`.

## What is different from AeroSpace

| | AeroSpace | AeroStage WM |
|---|---|---|
| App name / bundle ID | AeroSpace / `bobko.aerospace` | AeroStage WM / `io.github.tech-maou.AeroStageWM` |
| CLI | `aerospace` | `aerostage-wm` (inside the app at `Contents/Resources/bin`) |
| Socket, caches, login item | `bobko.aerospace…` | `io.github.tech-maou.AeroStageWM…` |
| Config file | `~/.aerospace.toml` | **the same file**, existing configs keep working |
| Build | Xcode | Command Line Tools are enough (`scripts/bundle.sh`) |
| `subscribe` events | 6 | 7: adds `workspace-windows-changed` (see below) |
| Menu bar item | always shown | can be hidden (user default `hideMenuBarItem`, set by AeroStage), stays visible while Accessibility permission is missing |
| Quitting | windows of hidden workspaces stay parked in the screen corner unless quit from the menu | windows return to the screen on every regular quit (menu, quit Apple Event, SIGTERM); macOS may not terminate it on its own |
| Menu shortcuts | ⌘Q quits, ⌘E enables/disables | no ⌘Q/⌘E, so it cannot be quit or disabled by accident |
| Closing its last window | quits the app (harmless while the menu bar item is shown) | never quits, so the Secure Input badge closing after a password field cannot end it |

All other code, commands and the JSON output of the CLI are unchanged.

## Why a fork?

AeroStage shows every workspace as a stage with live window thumbnails. To stay correct it
has to know when a window is **closed**, **minimized** or **moved** to another workspace, and
when a workspace becomes **empty**. AeroSpace's `subscribe` reports none of these.

- A `window-closed` event was proposed and declined upstream
  ([PR #2199](https://github.com/nikitabobko/AeroSpace/pull/2199)); the maintainer wants to keep
  window lifecycle details, such as all windows briefly "dying" during screen lock, internal.
  Other PRs for more events (#2116, #2162, #2181) were closed without review.
- AeroSpace does not accept issues directly. Ideas go through GitHub Discussions, where most
  of them get no answer. That is a legitimate choice for a one-person project, but it means
  AeroStage cannot rely on these events ever arriving upstream.
- Without them, AeroStage has to poll the window server as a workaround. A small fork that
  adds the events (carefully, so screen lock does not produce false "closed" events) is more
  reliable than any workaround.

### Why it is a *thin* fork

AeroStage WM keeps AeroSpace's full Git history and adds only a few, self-contained commits
on top of an AeroSpace release tag. New AeroSpace releases are taken over by rebasing these
commits onto the new tag. Internal identifiers, docs and help texts are deliberately left as
they are, because renaming them would make every update conflict. That is why the help
output still says `aerospace` in places.

### Why it has its own name

The MIT license covers AeroSpace's code, but it grants no rights to the name "AeroSpace" or
its logo. A modified app under the same name would look like the original or an official
build. Technically the original bundle ID, CLI name and socket path would also collide with
an installed AeroSpace and take over its Accessibility permission. AeroStage WM therefore
uses its own name, bundle ID, CLI name, paths and icon.

## The `workspace-windows-changed` event

```
{"_event":"workspace-windows-changed","windowIds":[123,456],"workspace":"2"}
```

Sent after a refresh whenever the windows on a workspace changed: a window appeared, was
closed, minimized, unminimized, moved to another workspace or switched between floating and
tiling. `windowIds` lists all windows now on that workspace; it is empty when the workspace became empty. A move fires the
event for both workspaces.

It describes AeroSpace's model after it has been reconciled, not raw accessibility
notifications, and it is **not sent while the screen is locked**. During a lock the
accessibility API makes all windows look closed and AeroSpace restores them on unlock; the
event simply skips that period, so subscribers never see phantom closes. This addresses the
concern that led to a `window-closed` event being declined upstream.

## Installation

AeroStage WM replaces AeroSpace; only one of them may run. Both read `~/.aerospace.toml`, so
your config carries over, and both would start at login. Remove AeroSpace first:

```bash
brew uninstall --cask aerospace   # keeps ~/.aerospace.toml
brew install --cask tech-maou/tap/aerostage-wm
```

Homebrew refuses to install or upgrade AeroStage WM while the `aerospace` cask is installed.
Installing [AeroStage](https://github.com/Tech-Maou/AeroStage) (`tech-maou/tap/aerostage`)
brings AeroStage WM along. The cask puts `aerostage-wm` on your `PATH`, and on
`brew upgrade` it quits AeroStage WM (its windows return to the screen) and opens it again.

The app is signed with a self-signed certificate and not notarized by Apple (no paid Apple
developer account), so the cask removes the quarantine attribute after installation.

Or build from source (Xcode is not required, the Command Line Tools are enough):

```bash
git clone https://github.com/Tech-Maou/AeroStage-WM.git
cd AeroStage-WM
scripts/bundle.sh
cp -R "build/AeroStage WM.app" /Applications/
```

Then launch AeroStage WM and allow it under **System Settings → Privacy & Security →
Accessibility**. `scripts/bundle.sh` signs with the certificate "AeroStage Release" or
"AeroStage Dev" if one exists (stable signatures keep the permission across rebuilds),
otherwise ad-hoc.

For the CLI on your `PATH` (a build from source only; the cask does this itself):

```bash
ln -s "/Applications/AeroStage WM.app/Contents/Resources/bin/aerostage-wm" /opt/homebrew/bin/aerostage-wm
```

## Versions and branches

- Versions name the AeroSpace release they are based on, e.g. `v0.21.3-stage.4` is the fourth
  AeroStage WM release on top of AeroSpace `v0.21.3-Beta`.
- `main` is the released state, `dev` is where changes are made and tested.
- `scripts/release.sh [version]` builds `dist/AeroStage-WM-v<version>.zip` for a GitHub release,
  prints its SHA256 and updates the cask in `../homebrew-tap` if it is checked out there.
- `scripts/publish.sh <version>` does the whole release: dev → main, tag, zip signed with the
  long-lived "AeroStage Release" certificate (keeps the Accessibility permission across
  updates), GitHub release with the notes from [CHANGELOG.md](CHANGELOG.md), Homebrew cask.

## Tests

AeroSpace's unit tests use XCTest, which only ships with Xcode. They are not changed by this
fork; run them with `./test.sh` on a machine with Xcode.

## License

AeroStage WM is licensed under the [MIT License](LICENSE.txt), the same license as AeroSpace.
The original copyright notice of Nikita Bobko is kept, with an added line for the
modifications made in this fork. Bundled third-party dependencies and their licenses are
listed in [legal/](legal/README.md) and are unchanged.

## Acknowledgements

All the hard work of a tiling window manager for macOS was done by Nikita Bobko and the
AeroSpace contributors. If you don't need AeroStage, use the original
[AeroSpace](https://github.com/nikitabobko/AeroSpace) and consider
[sponsoring its author](https://github.com/sponsors/nikitabobko).
