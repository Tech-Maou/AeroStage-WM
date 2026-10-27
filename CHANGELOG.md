# Changelog

AeroStage WM versions name the AeroSpace release they are based on.

## 0.21.3-stage.2

- The menu bar item can be hidden (user default `hideMenuBarItem`), so AeroStage can show its
  own item with the stage number. It stays visible while accessibility permission is missing.
- Signed with the long-lived "AeroStage Release" certificate, so the Accessibility permission
  survives future updates (one more approval when updating from 0.21.3-stage.1).

## 0.21.3-stage.1

First release, based on AeroSpace v0.21.3-Beta.

- Own name, bundle ID (`io.github.tech-maou.AeroStageWM`), CLI (`aerostage-wm`), socket and
  icon, so it never collides with an installed AeroSpace.
- New `subscribe` event `workspace-windows-changed`: sent when windows on a workspace are
  opened, closed, minimized, unminimized or moved, or when a workspace becomes empty. Not sent
  while the screen is locked.
- Builds with the Command Line Tools only (`scripts/bundle.sh`); release and publish scripts.
