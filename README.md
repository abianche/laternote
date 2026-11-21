# Laternote

[![CI](https://github.com/abianche/laternote/actions/workflows/ci.yml/badge.svg)](https://github.com/abianche/laternote/actions/workflows/ci.yml)
[![License: PolyForm Shield](https://img.shields.io/badge/license-PolyForm%20Shield-blue)](LICENSE.md)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android-lightgrey)](#platforms)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=fff)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=fff)](https://supabase.com)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?logo=Firebase&logoColor=white)](https://firebase.google.com)
[![Claude](https://img.shields.io/badge/Claude-D97757?logo=claude&logoColor=fff)](https://claude.ai)

### A message to the person you'll become.

Laternote is a personal time-capsule app that lets you write messages to your future self.

Capture thoughts, preserve memories, record intentions, or leave advice for the person you'll become. Choose a future date, seal your message, and rediscover it when the time comes.

**Write now. Meet yourself later.**

---

## The idea

We write things down to remember them, but rarely give ourselves the opportunity to reconnect with who we were when we wrote them.

Laternote introduces a simple concept: messages with a future destination.

A thought written today can become a meaningful reminder next month, a surprising discovery next year, or a conversation with your past self ten years from now.

## Features

The initial version of Laternote aims to provide:

- **Personal messages** — Write anything you want to remember or revisit.
- **Scheduled delivery** — Choose when a message becomes accessible.
- **Sealed messages** — Keep future messages hidden until their delivery date.
- **Notifications** — Get notified when a message is ready.
- **Personal archive** — Revisit messages you've already received.
- **Privacy first** — Your messages are private by default.

## Roadmap

- [ ] Define brand identity and visual direction
- [x] Create initial Flutter application ([#1](https://github.com/abianche/laternote/issues/1))
- [ ] Design the core user experience
- [x] Register, sign in, and manage an account ([#2](https://github.com/abianche/laternote/issues/2))
- [x] Implement message creation and scheduling, with local drafts ([#3](https://github.com/abianche/laternote/issues/3), [#18](https://github.com/abianche/laternote/issues/18))
- [x] Implement sealed messages and delivery ([#5](https://github.com/abianche/laternote/issues/5), [#6](https://github.com/abianche/laternote/issues/6))
- [ ] Add notifications ([#7](https://github.com/abianche/laternote/issues/7))
- [ ] Build personal archive ([#8](https://github.com/abianche/laternote/issues/8), in review in [#25](https://github.com/abianche/laternote/pull/25))
- [ ] Prepare for iOS and Android release ([#10](https://github.com/abianche/laternote/issues/10))

## Platforms

Laternote is being developed for:

- iOS
- Android

## Languages

Initial language support:

- English
- Italian

## Built with

- Flutter
- Dart

## Architecture and environments

The MVP architecture, data access rules, delivery behavior, and development/production setup are documented in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/environments.md](docs/environments.md). Local backend configuration belongs in ignored `config/dev.json` and `config/prod.json`; start from the example files.

## Vision

Laternote is not another notes app or social network.

It is a place to leave pieces of yourself for the future.

A simple way to make a moment today meaningful again tomorrow, next year, or ten years from now.

---

**Laternote — Write now. Meet yourself later.**

## License

Laternote is **source-available** under the [PolyForm Shield License 1.0.0](LICENSE.md).

In plain terms:

- ✅ You can read, run, modify, and share the code.
- ✅ You can use it for personal projects, learning, and research, and inside your business, as long as you aren't competing with Laternote.
- ❌ You can't use it to build or sell a product that competes with Laternote. That includes re-publishing it, or a reskinned copy, on an app store, even for free.

This summary is for convenience only. The [LICENSE](LICENSE.md) is the binding text.

Not sure whether your use is allowed, or want a commercial license? Open an issue or contact abianche@protonmail.com.

