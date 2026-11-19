# Architecture

[Back to the README](../README.md) · [Algorithm](algorithm.md) · [Development](development.md)

iWallee is an offline UIKit app for portrait iPhone use. It follows MVC-inspired responsibilities: controllers coordinate interaction, expression trees model the mathematics, and views display results. Historical folder names mix these roles; `CanvasV` also owns rendering.

The product is **iWallee**; its workspace, scheme, and module retain the internal name **RandomArt**.

## Components and ownership

| Component | Responsibility |
| --- | --- |
| [AppDelegate](../RandomArt/AppDelegate.swift) and [SceneDelegate](../RandomArt/SceneDelegate.swift) | Configure the app, receive scene lifecycle events, and coordinate the opening animation. |
| [SideBarMenuVC](../RandomArt/ViewControllers/SideBarMenuVC.swift) | Register and select cached Studio, Collection, and Guide controllers through SideMenuSwift. |
| [CanvasVC](../RandomArt/ViewControllers/CanvasVC.swift) | Build the studio interface, translate slider input into depth, coordinate generation/export, name the artwork, and manage busy controls. |
| [CanvasV](../RandomArt/ViewControllers/CanvasV.swift) | Own the current RGB equations and serial rendering queue; produce preview/export bitmaps and expose the current formula snapshot. |
| [MathBinaryTree](../RandomArt/DataStructures/MathBinaryTree.swift) and [Node](../RandomArt/DataStructures/Node.swift) | Build, evaluate, and describe recursive expressions using the `MathOperation` enum. |
| [WallpaperFormulaVC](../RandomArt/ViewControllers/WallpaperFormulaVC.swift) | Display a read-only snapshot of the current red, green, and blue formulas; copy them on request. |
| [FreeCollectionVC](../RandomArt/ViewControllers/FreeCollectionVC.swift) and [DownloadVC](../RandomArt/ViewControllers/DownloadVC.swift) | Browse bundled wallpapers, filter/rearrange the visible collection, preview an image, and save it to Photos. |
| [PhotoLibrarySaving / PhotoLibrarySaver](../RandomArt/Extensions/DownloadExtension.swift) | Adapt UIKit's Photos callback into a completion-based interface that can be replaced in tests. |
| [StudioTheme](../RandomArt/StudioTheme.swift) | Centralize the palette, typography, logo treatment, and reusable button appearance. |
| [WallpaperLaunchAnimationView](../RandomArt/ViewControllers/WallpaperLaunchAnimationView.swift) | Present and clean up the opening card-stack animation. |

[Main](../RandomArt/StoryBoards/Base.lproj/Main.storyboard), [FreeCollection](../RandomArt/StoryBoards/FreeCollection.storyboard), and [HowToChangeWallpaper](../RandomArt/StoryBoards/HowToChangeWallpaper.storyboard) still provide controller identities and navigation entry points. The refreshed controllers construct their visible interfaces in `loadView()` with Auto Layout. Editing their old storyboard layouts alone therefore does not change those programmatic screens.

## Startup and navigation

The scene's storyboard provides its window and initial SideMenuSwift container. The menu caches controllers under the identifiers `canvas`, `freeCollection`, and `howToChangeWallpaper`. Returning to Studio reuses its controller and current equations, preserving the generated artwork during navigation.

The system launch storyboard presents the brand while the application starts. [Apple documents the launch screen as a restricted storyboard without code connections or custom classes](https://developer.apple.com/documentation/xcode/specifying-your-apps-launch-screen). The animated introduction therefore runs in a separate app view layered over the prepared scene:

- Four existing wallpaper cards arrive sequentially and form a stack.
- Normal timing is approximately **1.60 seconds**, including the exit fade.
- Reduce Motion uses the settled stack and a brief opacity fade.
- Skip dismisses the introduction early.
- The scene presents it once; returning from the background or another screen does not replay it.
- Interruption cleanup removes the overlay, cancels outstanding animation work, and restores underlying accessibility exposure.

The introduction is not a progress indicator. Generation and saving finish through their own completion callbacks.

## Generation and display

`CanvasVC` acquires its busy state before requesting generation, blocking duplicate Generate or Save actions, including queued actions.

`CanvasV` captures the selected depth and preview dimensions, then creates three trees on its serial queue, `iwallee.wallpaper.render`. For every pixel, the renderer evaluates those trees at normalized coordinates and writes an opaque RGBA byte buffer. A `CGContext` converts the buffer into a `CGImage`.

On the main queue, the successful result becomes `currentEquations`, its average color is sent to the naming delegate, and the image is assigned to `layer.contents`. The completion is delivered through a `CATransaction` completion block. The controller then stops the activity indicator and restores the controls.

There is no current `UIView.draw(_:)` implementation. The generated bitmap is displayed by the view's layer. Artwork names combine an approximate lookup from the average RGB value with a randomly chosen art term.

## Busy state and saving

The main screen follows this state flow:

~~~mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Generating: Generate
    Generating --> Idle: Image transaction completes or render fails
    Idle --> Exporting: Save
    Exporting --> Saving: Export image ready
    Exporting --> Idle: Export fails
    Saving --> Idle: Photos callback succeeds or fails
~~~

Generate, Save, the complexity slider, and the formula button remain unavailable while the studio is busy. The formula button also requires an existing successfully generated wallpaper.

Export captures the current equations and renders them again on the same queue. Its width is **1170 pixels**; height is `round(1170 × canvasHeight / canvasWidth)`. The preview instead uses the ceiling of the canvas dimensions in points. Export resolution is independent of the preview bitmap.

`PhotoLibrarySaver` retains each request's callback until `UIImageWriteToSavedPhotosAlbum` returns. The controller extension delivers completion and the result alert on the main queue. The studio stays busy through both export and the Photos write. The collection's `DownloadVC` has its own saving guard and disables Save and Close until its Photos callback.

## Formula consistency and visual overlays

`WallpaperEquations` holds the three trees and a `WallpaperFormulas` snapshot derived from those same trees. A failed render does not replace the current equations. Moving the slider only selects the depth for the next generation.

The formula sheet receives an immutable snapshot; it does not create fresh random trees. Preview, export, and the displayed formulas consequently describe the same composition.

The studio's dark gradient, titles, buttons, and panels are separate views above the canvas. They are not part of the exported bitmap. This explains why the saved image can be brighter than the app's preview around its top and bottom edges.

## Data and current boundaries

The Collection reads **70 bundled entries** from [wallpapers.json](../RandomArt/DataFiles/wallpapers.json) and their asset images. Selected vivid/dark flags are combined as filters; selected complexity values are alternatives. Drag reordering modifies the displayed array in memory. Applying filters rebuilds that array from the catalog.

The current generated equations survive navigation within the running app, but are not persisted across launches. Saving creates a photo; it does not add a formula record to a personal collection. The Core Data container in `AppDelegate` remains unused scaffolding; the app does not currently persist wallpaper formulas.

Rendering currently uses CPU recursion and has no cancellation, seed replay, or GPU path. The serial queue prevents overlapping pixel jobs within a canvas; the controller's busy guard prevents duplicate user requests.
