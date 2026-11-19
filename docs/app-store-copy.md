# App Store copy

This file records the English copy prepared for **version 1.1 (build 2)**. The existing App Store listing name **iWalle** is preserved; the refreshed app and repository documentation use **iWallee**. The saved subtitle is **Wallpapers made with math**.

The App Store Connect draft passed Add for Review validation and is **Ready for Review**, with one draft submission and an item ready to submit. All five screenshots, release metadata, and App Review contact information are saved. The age-rating questionnaire is complete at **4+**, privacy remains **Data Not Collected**, and manual release is selected. The approved [privacy policy](https://github.com/raguerraa/wally/blob/master/docs/privacy-policy.md) is published and publicly verified.

**Submit for Review** remains the user’s action. If Apple approves the version, **Release This Version** remains a separate user action. The screenshot section below records how the uploaded assets were prepared.

## Suggested subtitle

Wallpapers made with math

## Suggested promotional text

Create colorful wallpapers from mathematical expressions. Explore the formulas, adjust complexity, and save the artwork you like.

## Description

Turn a little math into colorful wallpapers for your iPhone.

Choose a complexity, tap Generate, and explore abstract compositions made from mathematical expressions. Each image combines red, green, and blue functions evaluated across the canvas.

CREATE YOUR NEXT WALLPAPER
Generate a new composition and adjust complexity before your next creation. Explore different combinations of color, shape, and pattern.

SEE THE MATH BEHIND IT
Open View formula to inspect the red, green, and blue expressions used for your generated wallpaper. Copy all three formulas to explore them further.

SAVE THE ARTWORK
Save a fresh render of your wallpaper to Photos. Your saved image contains the artwork without the studio controls.

EXPLORE THE COLLECTION
Browse 70 bundled wallpapers. Filter by vivid or dark colors and by the collection's complexity categories, then preview and save a favorite.

Wallpaper generation happens on your device and does not require an account or internet connection.

After saving an image, choose it in your iPhone's Wallpaper settings to make it your Lock Screen or Home Screen background.

## What's New

A fresh look for your mathematical wallpaper studio:

- A redesigned purple and black interface with a new app icon.
- A short opening animation with stacking wallpaper cards.
- A formula view for exploring and copying the red, green, and blue expressions behind your generated artwork.
- Sharper wallpaper exports rendered from the same formulas as your preview.
- Improved generation and saving, with clearer progress and protection against repeated taps.

## Suggested keywords

wallpaper,abstract,math,generative,art,patterns,background,color,geometry

## App Review notes

This is version 1.1 (build 2), an update to the existing mathematical wallpaper app listed as iWalle. No account, login, or test credentials are needed.

To test the main flow:

1. Open Studio from the menu if needed.
2. Choose a complexity and tap Generate. Wait for the wallpaper to finish rendering.
3. Tap View formula to inspect its Red, Green, and Blue expressions. Copy all formulas copies the text to the clipboard after a user action.
4. Close the formula view and tap Save. The app requests permission to add the image to Photos when saving; it does not read the photo library.
5. Open the menu and choose Collection to browse, filter, preview, and save one of the 70 bundled wallpapers.
6. Tap Privacy Policy in the menu footer to open the published policy in the browser: https://github.com/raguerraa/wally/blob/master/docs/privacy-policy.md.

Wallpaper generation is performed on the device using mathematical expressions and works without an internet connection. It does not call an AI image-generation service. The separate privacy-policy link opens an external web page and requires a connection. The app has no analytics, advertising, or account service; its App Store privacy declaration is Data Not Collected.

Saving a generated wallpaper renders the same expressions at 1170 pixels wide, with the portrait aspect ratio of the canvas. The saved artwork excludes interface controls and preview shading.

The app saves images to Photos. It does not set the system wallpaper automatically; the user applies a saved image through iPhone Wallpaper settings.

## Internal accuracy notes

- The formula view applies to newly generated wallpapers. The bundled collection does not store the original formulas for its images.
- Generated equations remain in memory during the app session. There is no saved-seed or formula-replay feature.
- Avoid claims of 4K export, automatic wallpaper changes, AI image synthesis, or guaranteed one-of-a-kind results.
- The suggested listing copy does not change pricing, availability, age rating, privacy answers, or the product name.
- The reviewed source supports local generation, formula copying, Photos saving, and the 70-image bundled catalog. Recheck these claims if features or SDKs change before submission.

## Screenshot preparation

Five fresh iPhone 16 screenshot candidates are preserved in the repository at `docs/app-store/1.1/screenshots/`. Each is an opaque PNG at its native 1179 × 2556 resolution. They show the actual app with a 9:41 status bar. No screenshot was stretched or resized for upload. The alpha channel was removed while preserving the original dimensions. SHA-256 verification confirmed that these repository copies match the prepared upload files byte-for-byte.

| Order | File | Screen |
| --- | --- | --- |
| 1 | [01-studio.png](app-store/1.1/screenshots/01-studio.png) | A newly generated wallpaper and the studio controls |
| 2 | [02-formulas.png](app-store/1.1/screenshots/02-formulas.png) | The formula view for that same generated wallpaper |
| 3 | [03-collection.png](app-store/1.1/screenshots/03-collection.png) | The bundled wallpaper collection and its filters |
| 4 | [04-preview.png](app-store/1.1/screenshots/04-preview.png) | A collection wallpaper preview and Save to Photos action |
| 5 | [05-guide.png](app-store/1.1/screenshots/05-guide.png) | The guide explaining generation, saving, and applying a wallpaper |

The first four cover the main product flow; the fifth is optional. All five were visually inspected for readable controls, complete layouts, and absence of dialogs or unfinished transitions.

The older XCTest attachments exported at 1178 × 2556, including a whole-screen XCTest attempt. To avoid that one-pixel loss, the final capture flow used a temporary copy of the project. Its existing UI navigation test paused at each verified screen while the Mac captured a native PNG with `xcrun simctl io screenshot`. The flow passed. This temporary capture helper did not modify the actual app repository or application behavior. Full capture originals and logs remain under `/tmp/iwallee-app-store-assets`; the linked screenshot candidates above are preserved with the project.

Confirm the appropriate screenshot slot and validation in App Store Connect before uploading.
