# App Store release preparation

[README](../README.md) · [Architecture](architecture.md) · [Development](development.md)

## Release identity

The prepared release is **1.1 (build 2)**. App Store Connect history was checked against the existing 1.0 (build 1) release before choosing these values. The 1.1 draft has passed Add for Review validation and is **Ready for Review**, with one draft submission whose item is ready to submit. **Submit for Review** is enabled and has been left for the user.

| Setting | Release value |
| --- | --- |
| App Store app | iWalle, Apple ID `1623764539` |
| Bundle identifier | `com.PandaApps.Walle` |
| Version | `1.1` |
| Build | `2` |
| Signing team | `J6522LJSM9` |
| Signing style | Automatic |

The original App Store listing uses `com.PandaApps.Walle`. Both application target configurations now match that identifier. Unit-test and UI-test target identifiers are unchanged. `CFBundleIdentifier` in [Info.plist](../RandomArt/Info.plist) expands `$(PRODUCT_BUNDLE_IDENTIFIER)` from the selected build configuration.

`CFBundleShortVersionString` and `CFBundleVersion` are defined directly in the app's Info.plist. Update those literal values for subsequent releases; changing unrelated Xcode marketing settings alone will not replace them.

## Privacy declaration

The app bundles [PrivacyInfo.xcprivacy](../RandomArt/PrivacyInfo.xcprivacy) in the main application target's Resources phase. It currently declares `NSPrivacyTracking` as `false`.

The reviewed app performs wallpaper rendering on the device, reads its bundled collection, saves selected images to Photos, and copies formulas only after a user action. The reviewed app and its two linked Pods contain no analytics, advertising, remote image-generation, or account service. The menu also provides a Privacy Policy button that asks iOS to open the published policy URL in the user’s browser. This external link does not add an app account or an app-operated network service. No collected-data entries or tracking domains are declared. Reassess this whenever a network service or SDK is added.

An unused `fileprivate` image-storage helper previously wrote to `UserDefaults`. It had no callers and has been removed, along with its supporting enum and file-path helper. The active Photos-saving implementation remains unchanged. Source review and a scan of the Release app's undefined symbols found no remaining matches for the covered API families checked, including user defaults, boot time, file timestamps, disk space, and active keyboards. The main app manifest therefore omits `NSPrivacyAccessedAPITypes` instead of supplying an empty array or an inaccurate reason.

Apple's [TN3181](https://developer.apple.com/documentation/technotes/tn3181-debugging-invalid-privacy-manifest) explains that empty accessed-API declarations should be removed and that a nontracking app can set `NSPrivacyTracking` to `false` while omitting tracking domains. [TN3184](https://developer.apple.com/documentation/technotes/tn3184-adding-data-collection-details-to-your-privacy-manifest) describes adding collected-data entries when data is collected. A syntactically valid plist still needs accurate keys and values.

The Photos purpose text in Info.plist says: “iWallee saves wallpapers you choose to your photo library.” Photos are added when the user requests a save; the app does not read their photo library.

The policy source is [docs/privacy-policy.md](privacy-policy.md). After the user approved its publication and contact information, it was published on public `master` in commit `6f8bc0be19c618b8aefebe990ff999debc9f5eaf`. An anonymous HTTP request returned 200 and verified the policy title, Photos and formula-copying sections, and approved contact information.

The accessible Privacy Policy button in the menu footer opens [the published policy](https://github.com/raguerraa/wally/blob/master/docs/privacy-policy.md) through `UIApplication.shared.open`. This URL is already included in the uploaded binary. The button has a VoiceOver hint and a minimum 44-point height. The browser and GitHub handle the resulting web request under their own privacy practices; the app does not append wallpapers, formulas, or user identifiers to the URL.

The bundled manifest, App Store Connect privacy questionnaire, and published privacy policy are separate release requirements. They must all reflect the final app’s behavior. Apple’s [privacy guidelines](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage) also require an easily accessible privacy-policy link in the app.

## Encryption declaration

`ITSAppUsesNonExemptEncryption` is `false`. A focused source review of the retained app, NVActivityIndicatorView, and SideMenuSwift found no custom cryptography or app-operated network-service implementation. The privacy-policy action hands its HTTPS URL to iOS for opening in the browser. Inspection of the Release app and embedded frameworks found the expected UI/system libraries and those two Pods, with no additional encryption library. This supports the declaration for the current implementation.

Apple's [property-list documentation](https://developer.apple.com/documentation/bundleresources/information-property-list/itsappusesnonexemptencryption) defines `false` for an app, including its linked third-party libraries, that uses no encryption or only exempt encryption. Reassess the declaration when adding networking, cryptography, authentication, or a new SDK.

## Archive and distribution

The final signed Release archive for generic iOS succeeded with Xcode 26.2 and the iOS 26.2 SDK after the Privacy Policy button was added. It contains bundle identifier `com.PandaApps.Walle`, version `1.1`, build `2`, the privacy manifest, the updated Photos purpose text, the encryption declaration, and the new menu link. The exact policy URL was verified in the compiled executable.

The archive uses the existing Apple Development identity and development provisioning profile. The subsequent App Store export and upload succeeded through the configured Xcode account and automatic-signing workflow. Xcode handles distribution signing during export; [cloud-managed signing](https://developer.apple.com/help/account/certificates/cloud-managed-certificates/) is also available through the Organizer distribution flow.

The final archive is `~/Library/Developer/Xcode/Archives/2026-11-18/iWallee-1.1-build2-final-20261118-222447.xcarchive`. Its build/upload logs, verification results, backups, and `ExportOptions.plist` are outside the repository in `~/Library/Developer/Xcode/iWalleeReleasePreparation/1.1-build2-final-20261118-222447/`. The path date follows the Mac’s local clock.

The completed export/upload used `method = app-store-connect`, `destination = upload`, automatic signing, the existing team, symbol upload, and `manageAppVersionAndBuildNumber = false` to preserve the chosen identifiers. Internal-only TestFlight distribution was disabled so the build remains eligible for an App Store release.

Xcode reported **Upload succeeded** and **EXPORT SUCCEEDED**, with exit code 0, on November 19, 2026 at 06:26 UTC. Apple subsequently processed the build, and **1.1 (2)** is selected in the App Store Connect draft. Add for Review validation passed. Apple’s review has not been submitted or completed.

The upload returned two future-requirement warnings: starting April 2027, it says uploads and distribution submissions must use the iOS 27 SDK included in Xcode 27 or later, and iOS apps must target iOS 15 or later. These warnings did not prevent this upload. Recheck Apple’s current requirements before a later release.

## Verification performed

- Property-list validation passed for the app manifest, app Info.plist, Xcode project, and prepared export options.
- The signed generic-iOS Release archive succeeded for 1.1 (2) with the original App Store bundle identifier.
- Deep, strict code-signature verification passed for the archived app and its embedded frameworks.
- The archived app and both embedded frameworks are arm64.
- The app bundle contains the expected privacy manifest, Photos purpose text, encryption declaration, and compiled privacy-policy URL.
- The menu source hash was unchanged during the final archive build.
- All configured icon sizes, including the 1024-pixel App Store icon, are present and opaque.
- Git’s whitespace check passed for the source/configuration changes.
- App Store Connect export/upload completed successfully, build processing completed, and build 2 is selected for version 1.1.
- The approved privacy policy was published and verified publicly with an anonymous HTTP 200 response.
- Five screenshots and the listing/review metadata persisted in App Store Connect.
- Add for Review validation passed; the draft submission item is ready to submit.

## Submission handoff

App Store Connect initially blocked new-version creation with an Agreement Update modal. The Apple Developer account subsequently showed that the updated agreement had been accepted on November 18, 2026. The agreement block was cleared, the iOS 1.1 draft was created, and the draft has now passed Add for Review validation.

The existing listing name **iWalle** was preserved. The subtitle is **Wallpapers made with math**. All five screenshots, the release metadata, and App Review contact details are saved in App Store Connect. The age-rating questionnaire is complete with a **4+** rating, the privacy declaration remains **Data Not Collected**, and **manual release** is selected. Private account and review-contact details are maintained in App Store Connect.

The live state is **Ready for Review**, with **Draft Submissions (1)** and an item marked **Ready to Submit**. **Submit for Review** is enabled and has not been clicked. The final review submission remains the user’s action. If Apple approves the version, manual release leaves **Release This Version** as a separate user action. No beta-group assignment has been performed.

Use the published policy URL above in the App Store Connect privacy-policy field. Rebuild and use a new build number if app content changes after the uploaded 1.1 (2) build.
