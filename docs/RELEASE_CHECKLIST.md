# Release checklist

Do the steps in order. Fix this file in a PR whenever a release shows it is wrong or missing something.

## Android

### 1. Version bump

- [ ] Set `version:` in `pubspec.yaml` ([scheme](environments.md#versioning)) and merge it through its own issue and PR. The first release is already `1.0.0+2`.
- [ ] The build number has never been uploaded to a store.

### 2. Signed build

- [ ] `git switch main && git pull`; `git status` is clean and CI is green on that commit.
- [ ] Note the commit (`git rev-parse HEAD`); it is the one to tag.
- [ ] `android/key.properties` points at the upload keystore ([setup](environments.md#release-signing)).
- [ ] Build:

  ```sh
  flutter clean && flutter pub get && flutter build appbundle --flavor production
  ```

- [ ] Verify the signature of `build/app/outputs/bundle/productionRelease/app-production-release.aab` ([how](environments.md#release-signing)).

### 3. Listing and screenshots

- [ ] Play Console name and short and full descriptions in English and Italian match [listing.md](store/listing.md), and the text still matches the app.
- [ ] App icon, 512×512 PNG:

  ```sh
  sips -z 512 512 assets/branding/icon-production.png --out build/play-icon.png
  ```

- [ ] [feature-graphic.png](store/feature-graphic.png) is uploaded as the feature graphic.
- [ ] Phone, 7-inch and 10-inch screenshots from `docs/store/screenshots/android/` are uploaded for both languages. Retake them if those screens changed.
- [ ] Contact email, category and privacy policy URL are set, and the URL loads.
- [ ] Data safety matches [privacy-forms.md](store/privacy-forms.md), and the release manifest still has only the permissions listed there:

  ```sh
  grep uses-permission -A1 build/app/intermediates/merged_manifests/productionRelease/processProductionReleaseManifest/AndroidManifest.xml
  ```

- [ ] The other "App content" declarations (ads, app access, content rating, target audience and any new ones) are complete.
- [ ] The build meets Play's [target API level](https://support.google.com/googleplay/android-developer/answer/11926878).

### 4. Submission

- [ ] Upload the AAB to the internal testing track (the first upload enrolls the app in Play App Signing) with release notes in English and Italian.
- [ ] Install it from Play on a device and check: compose, seal, the notification (also after a reboot), opening a message, export and import, and the app in Italian. For an update, install over the previous release and check that its messages are still there.
- [ ] Personal developer accounts created after 13 November 2023, first release only: run a [closed test](https://support.google.com/googleplay/android-developer/answer/14151465) with at least 12 testers opted in for 14 days in a row, then apply for production access.
- [ ] Promote the same build to production and send it for review.
- [ ] After approval, install the production release from Play.

If any build is rejected or needs a fix after upload, start again from step 1 with a new build number.

### 5. Tagging

- [ ] Tag the commit from step 2 as `v` plus the `pubspec.yaml` version, and push the tag:

  ```sh
  git tag -a v1.0.0+2 <commit> -m "Laternote 1.0.0+2"
  git push origin v1.0.0+2
  ```
