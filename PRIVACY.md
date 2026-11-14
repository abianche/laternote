# Privacy and data handling (MVP)

This note covers the current MVP. It will be replaced by a full privacy
policy before public launch.

## What is stored

- The messages you write, their scheduled delivery time, and their
  delivery status.
- A device token used to send you a notification when a message becomes
  available, tied to your account.

Only you can access your own messages and device tokens; access is
enforced by the database (Row Level Security), not just the app.

## Account deletion

This MVP does not yet have automated self-service account deletion
(that lands with a later access-control change). Until then, deletion is a
manual, documented process:

1. In the app, open **Account → Request account deletion**. This opens an
   email to `privacy@laternote.app` identifying your account.
2. You can also email that address directly from any client.
3. We delete your account, messages, and device tokens by hand, normally
   within a few business days, and confirm by email once it is done.

## Retention

Encrypted operational backups are retained for a limited period (target:
30 days) after which they age out. A deletion request made before a backup
ages out will be re-applied if that backup is ever restored.
