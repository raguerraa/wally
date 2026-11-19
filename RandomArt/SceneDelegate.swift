import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var openingAnimation: WallpaperLaunchAnimationView?
    private var hasShownOpeningAnimation = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard scene is UIWindowScene else { return }
        // Main.storyboard still supplies the window and SideMenuSwift root controller.
        // Install the opaque opening view before the first active frame.
        prepareOpeningAnimation()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard !hasShownOpeningAnimation else { return }
        if openingAnimation == nil { prepareOpeningAnimation() }
        hasShownOpeningAnimation = true
        guard let window = window, let content = window.rootViewController?.view else {
            openingAnimation?.finishImmediately()
            openingAnimation = nil
            return
        }
        guard let opening = openingAnimation else { return }
        window.bringSubviewToFront(opening)
        opening.start(over: content) { [weak self, weak opening] in
            if self?.openingAnimation === opening {
                self?.openingAnimation = nil
            }
        }
    }

    private func prepareOpeningAnimation() {
        guard !hasShownOpeningAnimation, openingAnimation == nil, let window = window else { return }
        // Force the real root into the hierarchy before placing the animation above it.
        window.rootViewController?.loadViewIfNeeded()
        window.layoutIfNeeded()
        let opening = WallpaperLaunchAnimationView(frame: window.bounds)
        opening.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(opening)
        openingAnimation = opening
    }

    private func finishOpeningAnimation() {
        // An interrupted launch must never replay when the user returns to the app.
        hasShownOpeningAnimation = true
        openingAnimation?.finishImmediately()
        openingAnimation = nil
    }

    func sceneWillResignActive(_ scene: UIScene) { finishOpeningAnimation() }
    func sceneDidEnterBackground(_ scene: UIScene) { finishOpeningAnimation() }
    func sceneDidDisconnect(_ scene: UIScene) { finishOpeningAnimation() }
    func sceneWillEnterForeground(_ scene: UIScene) {}
}
