# Auto Update V2 Installer

## Overview

`auto-update-v2-installer.sh` installs a background maintenance service
for Kali Linux using **systemd**.

After installation, the updater runs automatically after every boot
without requiring user interaction.

## Features

-   Automatic `apt update` and `full-upgrade`
-   Removes obsolete packages
-   Cleans APT cache
-   Updates Flatpak applications and runtimes (if installed)
-   Updates Snap packages (if installed)
-   Updates pipx applications (if installed)
-   Updates global npm packages (if installed)
-   Attempts to update local Git repositories
    -   Skips repositories that require authentication
    -   Never prompts for GitHub credentials
-   Cleans:
    -   `/tmp`
    -   `/var/tmp`
    -   User cache
    -   Trash
    -   Old system journal logs
-   Prevents multiple update jobs from running simultaneously
-   Runs with low CPU and I/O priority

## Installation

Place `auto-update-v2-installer.sh` in your Downloads folder and run:

``` bash
cd ~/Downloads
sudo bash auto-update-v2-installer.sh
```

## Useful Commands

Check the timer:

``` bash
systemctl status auto-update.timer
```

Check the update service:

``` bash
systemctl status auto-update.service
```

Run an update immediately:

``` bash
sudo systemctl start auto-update.service
```

Disable automatic updates:

``` bash
sudo systemctl disable --now auto-update.timer
```

Re-enable automatic updates:

``` bash
sudo systemctl enable --now auto-update.timer
```

## Notes

-   The updater does **not** reboot or shut down the system.
-   Private Git repositories that require credentials are skipped
    automatically.
-   Standalone AppImages generally cannot be updated automatically
    unless they provide their own update mechanism.

## Files Installed

-   `/usr/local/bin/auto-update`
-   `/etc/systemd/system/auto-update.service`
-   `/etc/systemd/system/auto-update.timer`

## Uninstall

``` bash
sudo systemctl disable --now auto-update.timer
sudo rm -f /etc/systemd/system/auto-update.timer
sudo rm -f /etc/systemd/system/auto-update.service
sudo rm -f /usr/local/bin/auto-update
sudo systemctl daemon-reload
```
