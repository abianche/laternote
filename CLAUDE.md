# Laternote

## Rules

- **No fallbacks or backward compatibility, ever.** Laternote is a new app with no legacy users, data, or APIs to support. Use only the current recommended approach for every library and service (e.g. Supabase publishable/secret keys, never legacy anon/service-role keys). Do not add fallback code paths, legacy aliases, deprecated options, compatibility shims, or migration code for old formats. When something changes, replace it outright.
