# Laternote

Flutter app with a Supabase backend. Read `docs/ARCHITECTURE.md` before any task.

## Rules

- **No fallbacks or backward compatibility, ever.** Laternote is a new app with no legacy users, data, or APIs to support. Use only the current recommended approach for every library and service (e.g. Supabase publishable/secret keys, never legacy anon/service-role keys). Do not add fallback code paths, legacy aliases, deprecated options, compatibility shims, or migration code for old formats. When something changes, replace it outright.

## Workflow

- Every piece of work starts from a GitHub issue. No issue, no code.
- One issue = one branch = one PR. Branch name: `<type>/<issue#>-<short-slug>` (e.g. `feat/12-login-screen`).
- PR description must contain `Closes #<issue>`.
- Only the human merges. Bots never merge, force-push to `main`, or close issues by hand.

## Definition of done

1. `dart format .` leaves no changes
2. `flutter analyze` reports zero issues
3. `flutter test` passes
4. New logic has tests; every acceptance criterion in the issue is met
5. CI is green on the PR

## Hard rules

- Never commit secrets. Config comes from `--dart-define-from-file=config/dev.json` or `config/prod.json` (gitignored; see `docs/environments.md`).
- The Supabase secret key (`sb_secret_...`) never appears in app code. Only the publishable key (`sb_publishable_...`) ships in the app.
- Schema changes only via `supabase migration new <name>` in `supabase/migrations/`. Never edit the database only in the dashboard.
- New pub packages must be justified in the PR description.
- Don't touch code unrelated to the current issue.

## Keep it short

Usage is limited. Write short issues, PR descriptions and review comments. No restating the diff, no filler.
