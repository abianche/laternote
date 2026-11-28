# Store privacy forms

Drafted answers. Check them again whenever a dependency, permission or data flow changes.

## Google Play: Data safety

| Question | Answer |
|----------|--------|
| Does your app collect or share any of the required user data types? | **No** |
| Privacy policy URL | https://althenos.com/laternote/privacy/ |

With "No", there are no data types to declare. The form and the policy are still required.

## Apple: App Privacy

| Question | Answer |
|----------|--------|
| Do you or your third-party partners collect data from this app? | **No** (shown as "Data Not Collected") |
| Privacy Policy URL | https://althenos.com/laternote/privacy/ |
| Tracking | None |

## Why

Both stores count data as collected only when it is sent off the device; data processed only on the device is not disclosed ([Google](https://support.google.com/googleplay/android-developer/answer/10787469), [Apple](https://developer.apple.com/app-store/app-privacy-details/)).

- The app has no accounts, servers, analytics, ads or crash reporting.
- The merged Android release manifest has no `INTERNET` permission. Its permissions are `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE` and the app's own internal receiver permission.
- Our reading, which neither page states outright: OS backups and exports the user saves or shares are not collection, because the developer never receives them.
