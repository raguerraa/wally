# Development guide

[Back to the README](../README.md) · [Architecture](architecture.md) · [Algorithm](algorithm.md)

## Open and run

The verified development environment uses Xcode **26.2**, the Apple Swift **6.2.3** compiler, and CocoaPods **1.16.2**. The app target uses **Swift 5 language mode**, targets **iOS 13.0**, and is configured for iPhone. The unit-test target requires iOS 13.6.

[Podfile.lock](../Podfile.lock) records:

| Dependency | Locked version | Use |
| --- | --- | --- |
| NVActivityIndicatorView | 5.1.1 | Studio activity animation |
| SideMenuSwift | 2.0.9 | Cached sidebar navigation |

Clone the repository, install the locked dependencies, and open the workspace:

~~~sh
git clone https://github.com/raguerraa/wally.git
cd wally
pod install --deployment
open RandomArt.xcworkspace
~~~

Select the **RandomArt** scheme and an installed iPhone simulator, then press **Command-R**. Physical devices also require signing and provisioning in Xcode.

The repository includes CocoaPods files, but **Xcode does not automatically install Pods**. Open `RandomArt.xcworkspace`, which includes both the app and Pods projects. The `--deployment` option prevents an incidental lockfile change. For an intentional dependency edit, run `pod install` and review the resulting Podfile/lockfile changes; do not use `pod update` as a general build fix.

The [Podfile](../Podfile) still declares iOS 11.0, and some generated Pod targets declare older minimums. Those settings can produce deployment-target warnings in newer Xcode versions. They do not change the app target's iOS 13.0 minimum. Align them deliberately during dependency maintenance rather than treating a warning as evidence of current iOS 9/11 app support.

## Test the changes

First list destinations available on your Mac:

~~~sh
xcodebuild -workspace RandomArt.xcworkspace \
  -scheme RandomArt -showdestinations
~~~

Use a simulator ID from that output:

~~~sh
IWALLEE_SIMULATOR_ID='<simulator UUID>'

xcodebuild -workspace RandomArt.xcworkspace \
  -scheme RandomArt \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$IWALLEE_SIMULATOR_ID" \
  CODE_SIGNING_ALLOWED=NO \
  -parallel-testing-enabled NO \
  test
~~~

Verified simulator: iPhone 16, iOS 18.5. Use an installed destination; simulator UUIDs are local.

[Unit tests](../RandomArtTests/RandomArtTests.swift) check RGB bounds, independent export dimensions, formula grouping and normalization, formula-snapshot lifetime, and controls during delayed success/failure callbacks. Four `WallpaperLaunchAnimationTests` cover automatic completion, Reduce Motion, Skip, and idempotent interruption with cancellation of delayed dismissal. They also verify restoration of the previous accessibility state. The Photos substitute avoids creating real photos.

[UI tests](../RandomArtUITests/RandomArtUITests.swift) exercise generation, the formula viewer's three channels, navigation, the bundled collection, preview, and returning to the existing artwork. Screenshot attachments help inspect layout. These tests do not save to Photos or copy to the clipboard.

For visual changes, also try a smaller iPhone and larger text. For the introduction, check a cold launch, Skip, Reduce Motion, and returning from the background. A successful build alone does not establish that an animation or layout looks correct.

## Where to make changes

| Change | Start here |
| --- | --- |
| Colors, fonts, common buttons | [StudioTheme.swift](../RandomArt/StudioTheme.swift) |
| Studio layout and action state | [CanvasVC.swift](../RandomArt/ViewControllers/CanvasVC.swift) |
| Opening cards and timing | `Configuration` in [WallpaperLaunchAnimationView.swift](../RandomArt/ViewControllers/WallpaperLaunchAnimationView.swift) |
| Startup/interruption policy | [SceneDelegate.swift](../RandomArt/SceneDelegate.swift) |
| Preview/export resolution | [CanvasV.swift](../RandomArt/ViewControllers/CanvasV.swift) |
| Mathematical operations | [MathBinaryTree.swift](../RandomArt/DataStructures/MathBinaryTree.swift) |
| Formula presentation | [WallpaperFormulaVC.swift](../RandomArt/ViewControllers/WallpaperFormulaVC.swift) |
| Bundled collection metadata | [wallpapers.json](../RandomArt/DataFiles/wallpapers.json) and [Assets.xcassets](../RandomArt/Assets.xcassets) |

The opening sequence uses `IMG_3`, `IMG_12`, `IMG_51`, and `IMG_66`. Its arrival duration, stagger, pause, and fade are centralized in `Configuration`. Use existing asset names or add properly registered assets. Keep the Reduce Motion path and interruption cleanup when changing the choreography.

When adding a mathematical operation, update the `MathOperation` case, its `isBinary` classification, evaluator, and formula formatter. Add notation definitions if the display introduces a custom helper. Include it in `generatedOperations` only when it is ready to appear in random trees.

Check the operation's entire input domain and compositions with other operations. The active operation set stays in `[0,1]`; experimental cases need individual analysis. A final clamp is insufficient protection against undefined calculations, non-finite values, or an unsafe integer conversion. Preserve unary children on `rightChild` and both children for binary operations. See the [algorithm guide](algorithm.md) for exact evaluation rules.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| `No such module NVActivityIndicatorView` or `SideMenuSwift` | Open the workspace, run the locked Pod installation, and verify the active scheme. |
| CocoaPods sandbox/lock mismatch | Run `pod install --deployment`; inspect the mismatch before changing the lockfile. |
| A storyboard edit does not change the screen | The refreshed controllers build their visible views in `loadView()`. |
| Preview looks darker than the exported photo | `StudioCanvasShade` is a preview overlay, separate from the renderer. |
| Save reports a permission error | Check the app's Photos permission and the add-to-library usage description in [Info.plist](../RandomArt/Info.plist). |
| High complexity takes longer | Keep pixel evaluation on the rendering queue; measure a release build before changing the algorithm or export resolution. |
| Formula button is disabled | Generate a wallpaper successfully and wait for any generation/save operation to finish. |

## Git hygiene

The root [.gitignore](../.gitignore) excludes macOS metadata, Xcode user settings, build/test output, Python environment/cache files, and common local signing or secret files. Shared Xcode schemes, the workspace, source files, app artwork, documentation, and dependency lockfiles remain versioned.

This repository already vendors its CocoaPods dependencies. Keep `Pods/` and its generated support files in the same commit as related Podfile/lockfile changes. Do not add a blanket `Pods/` ignore rule without deliberately changing that workflow.

Ignore rules apply to untracked files. To stop tracking a local-only file that is already committed, use `git rm --cached -- <path>`; this preserves the copy on your Mac. It removes the path from the next commit, not from earlier history.

Before committing, inspect `git status --short` and the staged diff. `git push` sends commits, so local edits must be staged and committed first.

## Contribution workflow

Preserve the repository's review policy: do not commit directly to `master` without approval. Use a branch and a pull request; at least one person should approve the review before integration into `master`.

Explain the problem, resulting behavior, and verification. Include screenshots for UI changes and regression coverage for state or algorithm changes. Review `git diff` and `git diff --check` before submitting. Keep authentication tokens, signing secrets, and machine-specific user settings out of the changes.
