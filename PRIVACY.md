# Privacy and data handling (MVP)

This note covers the current MVP and matches the in-app **Account → Privacy
& data** screen. It will be replaced by a full privacy policy before public
launch.

## Drafts stay on your device

While you write, your draft is saved encrypted on your device only. It is
never sent to our servers, and it is deleted when you seal it, discard it,
or sign out.

## Sealed messages

When you seal a message we store it with its opening time, time zone and
status. Access is enforced by the database (Row Level Security and column
grants), not just the app: only your account can see your messages, and
nobody, not even you, can read one before it opens. Messages are not
end-to-end encrypted.

## Notifications

A notification only says "A message is ready". It never contains what you
wrote, and Android lock screens hide it. To send it we keep a notification
address for your device from Firebase Cloud Messaging, removed when you
sign out.

## No tracking

Laternote has no analytics, ads or crash reporting. Server logs record
counts only, never message content or device addresses.

## Account deletion

This MVP does not yet have automated self-service account deletion. Until
then, deletion is a manual, documented process:

1. In the app, open **Account → Request account deletion**. This opens an
   email to `privacy@laternote.app` identifying your account.
2. You can also email that address directly from any client.
3. We delete your account, messages, and device addresses by hand, normally
   within a few business days, and confirm by email once it is done.

## Retention

Encrypted operational backups are retained for a limited period (target:
30 days) after which they age out. A deletion request made before a backup
ages out will be re-applied if that backup is ever restored.
