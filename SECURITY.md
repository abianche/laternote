# Security Policy

## Supported versions

Laternote is in early development. Only the latest code on `main` receives security fixes.

## Reporting a vulnerability

Please do not open a public issue for security problems.

Report vulnerabilities privately through GitHub: go to the [Security tab](https://github.com/abianche/laternote/security) and select **Report a vulnerability**.

Include what you found, steps to reproduce it, and the impact you expect. You will receive an acknowledgement within a few days, and we will keep you updated until the issue is resolved.

## Scope

In scope:

- The Laternote Flutter app (Android and iOS)
- The GitHub Actions workflows in this repository

Especially relevant: anything that lets another app or person read letters stored on the device, or that leaks letter content off the device. Opening a letter early by changing the device clock or reading the app's own files is accepted (see docs/ARCHITECTURE.md).

Out of scope: vulnerabilities in third-party services (Apple, Google) themselves; report those to the respective vendor.
