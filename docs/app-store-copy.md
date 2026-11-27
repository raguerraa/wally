# App Store copy

This file records the English metadata saved for **version 1.1 (build 3)** of **iWalle** on November 26, 2026. The original App Store listing name and the corrected installed app name now match. The subtitle remains **Wallpapers made with math**.

Build 2 was rejected under Guideline 4.3(a) on November 25, 2026. Build 3 was signed and uploaded successfully; at the last verification, Apple was still processing it and build 2 remained attached. Updated metadata and reviewer evidence were saved, but no resubmission was performed. The existing age rating, privacy declaration and manual release settings were retained.

The screenshots below document the previous build. The screenshot test for build 3 stalled, so fresh captures remain outstanding. Any subsequent submission and manual release remain the owner’s actions.

## Saved subtitle

Wallpapers made with math

## Promotional text

Create mathematical artwork with iWalle. Explore RGB expressions, adjust complexity, and save the images you generate.

## Description

iWalle is a mathematical art studio that turns recursive expressions into artwork for your iPhone.

CREATE ART WITH MATH
Choose a complexity, tap Generate, and explore abstract compositions made from mathematical expressions. Each image combines three functions evaluated across the canvas: one for red, one for green, and one for blue.

EXPLORE THE EXPRESSIONS
Open View formula to inspect the exact red, green, and blue expressions behind your generated image. Learn how coordinates and mathematical values become colors. Copy the formulas to explore them further.

ADJUST COMPLEXITY
The complexity control changes the depth of the mathematical expressions used for your next composition.

SAVE YOUR CREATION
Save a fresh render of your artwork to Photos using the same mathematical expressions, without the studio controls.

EXPLORE THE COLLECTION
Browse 70 bundled wallpapers, filter by color and complexity, and preview and save a favorite.

Artwork generation runs on your device without an internet connection or an account. To use your saved artwork as a wallpaper, select it in your iPhone's Wallpaper settings.

## What's New

A fresh look for iWalle, our mathematical art studio:
• Consistent iWalle branding throughout the app, matching the existing App Store listing.
• A redesigned interface with a new app icon and a short opening animation.
• A formula view for inspecting and copying the mathematical expressions behind generated artwork.
• Sharper exports rendered using the same formulas as the preview.
• Improved generation and saving, with clearer progress and protection against repeated taps.

## Keywords

wallpaper,abstract,math,generative,art,patterns,background,color,geometry

## App Review notes

This is an update to the existing iWalle app (Apple ID 1623764539). The app's mathematical generator began as an adaptation of a classroom exercise into a native iOS app.

Development history: the August 2020 commit includes the original Swift expression-tree generator and RGB canvas renderer:
https://github.com/raguerraa/wally/commit/f89082e9aee25d7dc6305e845948d1cd0acdd1cd

Current implementation and documentation:
https://github.com/raguerraa/wally
https://github.com/raguerraa/wally/blob/master/docs/algorithm.md

The Studio creates artwork on the device by generating three mathematical expression trees and evaluating them across the image, one for each RGB channel. The formula viewer displays the expressions used for that specific image. This is not an AI image-generation service. The opening animation is custom UIKit code; the reusable UI libraries are NVActivityIndicatorView and SideMenuSwift.

Reviewer walkthrough (no account or login required):
1. Open Studio. Choose a complexity and tap Generate.
2. Once generation finishes, tap View formula. Inspect Red, Green and Blue, including the explanations of coordinates and color mapping. Tap Copy all formulas to copy the expressions as text.
3. Close the formula view, change complexity, and generate again to see a different composition and its formulas.
4. Tap Save to render the same expressions at 1170 pixels wide and add the artwork to Photos. The saved image excludes interface controls and preview shading. Users apply the wallpaper in iOS settings.
5. Collection is a separate gallery of 70 bundled wallpapers.
6. The main menu provides a Privacy Policy link.

Regarding Guideline 4.3(a), the original implementation and dated development history are provided above for assessment of the app's provenance and distinct mathematical creation workflow. The app name in the replacement build is standardized to iWalle, matching the existing listing. The underlying mathematical creation workflow is unchanged by this naming correction.

## Internal accuracy notes

- The formula view applies to newly generated wallpapers. The bundled collection does not store the original formulas for its images.
- Generated equations remain in memory during the app session. There is no saved-seed or formula-replay feature.
- Avoid claims of 4K export, automatic wallpaper changes, AI image synthesis, or guaranteed one-of-a-kind results.
- The suggested listing copy does not change pricing, availability, age rating, privacy answers, or the product name.
- The reviewed source supports local generation, formula copying, Photos saving, and the 70-image bundled catalog. Recheck these claims if features or SDKs change before submission.

## Screenshot preparation

Five original iPhone 16 screenshots from the submitted build 2 are preserved in the repository at `docs/app-store/1.1/screenshots/`. Each is an opaque PNG at its native 1179 × 2556 resolution. They are historical captures of the submitted build, before the naming correction, with a 9:41 status bar. Recapture the final build for any subsequent App Store submission. No screenshot was stretched or resized for upload. The alpha channel was removed while preserving the original dimensions. SHA-256 verification confirmed that these repository copies match the prepared upload files byte-for-byte.

| Order | File | Screen |
| --- | --- | --- |
| 1 | [01-studio.png](app-store/1.1/screenshots/01-studio.png) | A newly generated wallpaper and the studio controls |
| 2 | [02-formulas.png](app-store/1.1/screenshots/02-formulas.png) | The formula view for that same generated wallpaper |
| 3 | [03-collection.png](app-store/1.1/screenshots/03-collection.png) | The bundled wallpaper collection and its filters |
| 4 | [04-preview.png](app-store/1.1/screenshots/04-preview.png) | A collection wallpaper preview and Save to Photos action |
| 5 | [05-guide.png](app-store/1.1/screenshots/05-guide.png) | The guide explaining generation, saving, and applying a wallpaper |

The first four cover the main product flow; the fifth is optional. All five were visually inspected for readable controls, complete layouts, and absence of dialogs or unfinished transitions.

The older XCTest attachments exported at 1178 × 2556, including a whole-screen XCTest attempt. To avoid that one-pixel loss, the final capture flow used a temporary copy of the project. Its existing UI navigation test paused at each verified screen while the Mac captured a native PNG with `xcrun simctl io screenshot`. The flow passed. This temporary capture helper did not modify the actual app repository or application behavior. The linked original screenshots are preserved with the project as release evidence.

Confirm the appropriate screenshot slot and validation in App Store Connect before uploading.
