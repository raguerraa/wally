import UIKit

/// A brief, skippable introduction made from wallpapers already bundled with the app.
/// The system launch storyboard remains static; this view animates once the scene is ready.
final class WallpaperLaunchAnimationView: UIView {
    enum Configuration {
        static let assetNames = ["IMG_3", "IMG_12", "IMG_51", "IMG_66"]
        static let cardArrivalDuration: TimeInterval = 0.56
        static let cardStagger: TimeInterval = 0.18
        static let stackPause: TimeInterval = 0.24
        static let exitFadeDuration: TimeInterval = 0.26
        static let reducedMotionFadeDuration: TimeInterval = 0.18
    }

    private enum State { case ready, playing, dismissing, finished }
    private var state = State.ready
    private let cardStage = UIView()
    private var cards: [UIView] = []
    private var animators: [UIViewPropertyAnimator] = []
    private var dismissalWork: DispatchWorkItem?
    private var onFinish: (() -> Void)?
    private weak var underlyingContent: UIView?
    private var previousAccessibilityHidden = false
    private var usesReducedMotion = false
    private let glow = CAGradientLayer()
    private let titleLabel = StudioTheme.label("iWallee", size: 27, weight: .bold)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    deinit {
        dismissalWork?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    private func configureView() {
        backgroundColor = StudioTheme.background
        accessibilityIdentifier = "launchAnimationOverlay"
        accessibilityViewIsModal = true

        glow.type = .radial
        glow.colors = [
            StudioTheme.purple.withAlphaComponent(0.22).cgColor,
            StudioTheme.purple.withAlphaComponent(0.05).cgColor,
            UIColor.clear.cgColor
        ]
        glow.locations = [0, 0.52, 1]
        glow.startPoint = CGPoint(x: 0.5, y: 0.5)
        glow.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(glow)

        titleLabel.accessibilityTraits.insert(.header)
        let subtitle = StudioTheme.label("MATH INTO ART", size: 10, weight: .semibold,
                                         color: StudioTheme.lavender)
        let wordmark = UIStackView(arrangedSubviews: [titleLabel, subtitle])
        wordmark.axis = .vertical
        wordmark.spacing = 3
        let brand = UIStackView(arrangedSubviews: [StudioTheme.logoView(size: 48), wordmark])
        brand.spacing = 12
        brand.alignment = .center

        let headline = StudioTheme.label("An infinite canvas.", size: 23, weight: .semibold)
        let caption = StudioTheme.label("A little math. A lot of possibility.", size: 13,
                                        color: StudioTheme.secondaryText)
        for label in [headline, caption] {
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.8
        }
        let copy = UIStackView(arrangedSubviews: [headline, caption])
        copy.axis = .vertical
        copy.spacing = 8

        let skip = UIButton(type: .system)
        skip.setTitle("Skip", for: .normal)
        skip.titleLabel?.font = StudioTheme.font(14, weight: .semibold)
        skip.setTitleColor(StudioTheme.lavender, for: .normal)
        skip.accessibilityLabel = "Skip opening animation"
        skip.accessibilityIdentifier = "skipLaunchAnimationButton"
        skip.addTarget(self, action: #selector(skipAnimation), for: .touchUpInside)

        cardStage.isUserInteractionEnabled = false
        cardStage.isAccessibilityElement = false
        for assetName in Configuration.assetNames {
            guard let image = UIImage(named: assetName) else { continue }
            let card = makeCard(image: image)
            cardStage.addSubview(card)
            card.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                card.centerXAnchor.constraint(equalTo: cardStage.centerXAnchor),
                card.centerYAnchor.constraint(equalTo: cardStage.centerYAnchor),
                card.widthAnchor.constraint(equalTo: cardStage.widthAnchor),
                card.heightAnchor.constraint(equalTo: cardStage.heightAnchor)
            ])
            cards.append(card)
        }

        for child in [brand, cardStage, copy, skip] {
            child.translatesAutoresizingMaskIntoConstraints = false
            addSubview(child)
        }

        let preferredWidth = cardStage.widthAnchor.constraint(equalToConstant: 230)
        preferredWidth.priority = UILayoutPriority(748)
        let preferredCenter = cardStage.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10)
        preferredCenter.priority = UILayoutPriority(749)
        NSLayoutConstraint.activate([
            brand.centerXAnchor.constraint(equalTo: centerXAnchor),
            brand.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 28),
            brand.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            brand.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            cardStage.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardStage.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.60),
            cardStage.widthAnchor.constraint(lessThanOrEqualToConstant: 244),
            cardStage.heightAnchor.constraint(equalTo: cardStage.widthAnchor, multiplier: 1.42),
            cardStage.topAnchor.constraint(greaterThanOrEqualTo: brand.bottomAnchor, constant: 40),
            cardStage.bottomAnchor.constraint(lessThanOrEqualTo: copy.topAnchor, constant: -34),
            preferredWidth, preferredCenter,
            copy.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            copy.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            copy.bottomAnchor.constraint(equalTo: skip.topAnchor, constant: -32),
            skip.centerXAnchor.constraint(equalTo: centerXAnchor),
            skip.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            skip.heightAnchor.constraint(equalToConstant: 44),
            skip.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        for (index, card) in cards.enumerated() {
            card.alpha = 0
            card.transform = arrivalTransform(for: index)
        }
        NotificationCenter.default.addObserver(
            self, selector: #selector(reduceMotionChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil
        )
    }

    private func makeCard(image: UIImage) -> UIView {
        let card = UIView()
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.42
        card.layer.shadowRadius = 22
        card.layer.shadowOffset = CGSize(width: 0, height: 14)
        card.isAccessibilityElement = false

        let artwork = UIImageView(image: image)
        artwork.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        artwork.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        artwork.contentMode = .scaleAspectFill
        artwork.clipsToBounds = true
        artwork.layer.cornerRadius = 24
        artwork.layer.cornerCurve = .continuous
        artwork.layer.borderWidth = 1
        artwork.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        artwork.isAccessibilityElement = false
        artwork.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(artwork)
        NSLayoutConstraint.activate([
            artwork.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            artwork.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            artwork.topAnchor.constraint(equalTo: card.topAnchor),
            artwork.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        return card
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let side = min(bounds.width * 1.2, 500)
        glow.frame = CGRect(x: (bounds.width - side) / 2,
                            y: cardStage.center.y - side / 2,
                            width: side, height: side)
        for card in cards {
            card.layer.shadowPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: 24).cgPath
        }
        CATransaction.commit()
    }

    /// Called once, after the scene becomes active. Completion is delivered exactly once.
    func start(over contentView: UIView,
               reduceMotion: Bool = UIAccessibility.isReduceMotionEnabled,
               completion: @escaping () -> Void) {
        guard state == .ready else { return }
        state = .playing
        onFinish = completion
        underlyingContent = contentView
        previousAccessibilityHidden = contentView.accessibilityElementsHidden
        contentView.accessibilityElementsHidden = true
        usesReducedMotion = reduceMotion
        layoutIfNeeded()

        guard !cards.isEmpty else {
            finishImmediately()
            return
        }

        if reduceMotion {
            for (index, card) in cards.enumerated() {
                card.alpha = 1
                card.transform = settledTransform(for: index)
            }
            dismiss(animated: true)
            return
        }

        UIAccessibility.post(notification: .screenChanged, argument: titleLabel)
        for (index, card) in cards.enumerated() {
            let destination = settledTransform(for: index)
            let animator = UIViewPropertyAnimator(
                duration: Configuration.cardArrivalDuration, dampingRatio: 0.82
            ) {
                card.alpha = 1
                card.transform = destination
            }
            animators.append(animator)
            animator.startAnimation(afterDelay: Double(index) * Configuration.cardStagger)
        }

        let completedStack = Configuration.cardArrivalDuration
            + Double(max(0, cards.count - 1)) * Configuration.cardStagger
            + Configuration.stackPause
        let dismissal = DispatchWorkItem { [weak self] in self?.dismiss(animated: true) }
        dismissalWork = dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + completedStack, execute: dismissal)
    }

    private func arrivalTransform(for index: Int) -> CGAffineTransform {
        let direction: CGFloat = index.isMultiple(of: 2) ? -1 : 1
        return CGAffineTransform(translationX: direction * 110, y: -210)
            .rotated(by: direction * 0.34)
            .scaledBy(x: 0.88, y: 0.88)
    }

    private func settledTransform(for index: Int) -> CGAffineTransform {
        let positions: [(CGFloat, CGFloat, CGFloat)] = [
            (-24, -18, -0.16), (-9, -7, -0.065), (9, 5, 0.065), (25, 17, 0.15)
        ]
        let position = positions[index % positions.count]
        return CGAffineTransform(translationX: position.0, y: position.1).rotated(by: position.2)
    }

    @objc private func skipAnimation() { dismiss(animated: true) }

    @objc private func reduceMotionChanged() {
        guard UIAccessibility.isReduceMotionEnabled else { return }
        usesReducedMotion = true
        dismiss(animated: true)
    }

    private func dismiss(animated: Bool) {
        guard state != .dismissing && state != .finished else { return }
        state = .dismissing
        stopPendingAnimations()
        guard animated else {
            completeDismissal()
            return
        }
        let fade = UIViewPropertyAnimator(
            duration: usesReducedMotion ? Configuration.reducedMotionFadeDuration
                : Configuration.exitFadeDuration,
            curve: .easeOut
        ) { [weak self] in self?.alpha = 0 }
        fade.addCompletion { [weak self] _ in self?.completeDismissal() }
        animators.append(fade)
        fade.startAnimation()
    }

    /// Interruption cleanup is synchronous, including while the dismissal fade is running.
    func finishImmediately() {
        guard state != .finished else { return }
        state = .dismissing
        stopPendingAnimations()
        completeDismissal()
    }

    private func stopPendingAnimations() {
        dismissalWork?.cancel()
        dismissalWork = nil
        for animator in animators where animator.state == .active {
            animator.stopAnimation(true)
        }
        animators.removeAll()
        layer.removeAllAnimations()
        for card in cards { card.layer.removeAllAnimations() }
    }

    private func completeDismissal() {
        guard state != .finished else { return }
        state = .finished
        dismissalWork?.cancel()
        dismissalWork = nil
        animators.removeAll()
        underlyingContent?.accessibilityElementsHidden = previousAccessibilityHidden
        underlyingContent = nil
        NotificationCenter.default.removeObserver(self)
        removeFromSuperview()
        let completion = onFinish
        onFinish = nil
        completion?()
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
}
