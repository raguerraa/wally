import UIKit

/// An immutable snapshot of the expressions that produced the visible wallpaper.
final class WallpaperFormulaVC: UIViewController {
    private let formulas: WallpaperFormulas
    private let wallpaperName: String
    private let channelPicker = UISegmentedControl(items: ["Red", "Green", "Blue"])
    private let expressionView = UITextView()
    private let copyButton = StudioPrimaryButton(frame: .zero)
    private var copyFeedbackReset: DispatchWorkItem?

    private static let coordinateNotes = """
    x = column / image width
    y = row / image height
    0 ≤ x,y < 1

    x runs from left to right. y runs from top to bottom.
    """

    private static let colorNotes = """
    Each function gives one color's strength at a pixel. The app converts that value to a color byte:

    byte(v) = round(255 × min(1, max(0, v)))

    The red, green, and blue bytes combine to make the pixel you see.
    """

    private static let notationNotes = """
    × means multiply. abs(v) is the absolute value of v. π is pi; trigonometric functions use radians.
    """

    init(formulas: WallpaperFormulas, wallpaperName: String) {
        self.formulas = formulas
        self.wallpaperName = wallpaperName
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            sheetPresentationController?.detents = [.large()]
            sheetPresentationController?.prefersGrabberVisible = true
            sheetPresentationController?.preferredCornerRadius = 28
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(formulas:wallpaperName:)")
    }

    deinit { copyFeedbackReset?.cancel() }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func loadView() {
        let root = UIView()
        root.backgroundColor = StudioTheme.background
        view = root
        overrideUserInterfaceStyle = .dark

        let eyebrow = StudioTheme.label("MATH INTO ART", size: 10, weight: .semibold,
                                         color: StudioTheme.lavender)
        let close = StudioTheme.iconButton("xmark", accessibilityLabel: "Close formulas")
        close.accessibilityIdentifier = "formulaCloseButton"
        close.addTarget(self, action: #selector(closeFormulas), for: .touchUpInside)

        let title = StudioTheme.label("The math behind it", size: 27, weight: .bold)
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.75
        title.accessibilityTraits.insert(.header)
        title.accessibilityIdentifier = "formulaTitle"

        let name = StudioTheme.label(wallpaperName.isEmpty ? "Your wallpaper" : wallpaperName,
                                      size: 14, color: StudioTheme.secondaryText)
        name.numberOfLines = 2
        name.setContentCompressionResistancePriority(.required, for: .vertical)

        channelPicker.selectedSegmentIndex = 0
        channelPicker.backgroundColor = StudioTheme.surface
        channelPicker.selectedSegmentTintColor = StudioTheme.purple
        channelPicker.setTitleTextAttributes([
            .font: StudioTheme.font(14, weight: .semibold),
            .foregroundColor: StudioTheme.secondaryText
        ], for: .normal)
        channelPicker.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        channelPicker.accessibilityIdentifier = "formulaChannelPicker"
        channelPicker.addTarget(self, action: #selector(changeChannel), for: .valueChanged)

        expressionView.backgroundColor = StudioTheme.surface
        expressionView.layer.cornerRadius = 20
        expressionView.layer.cornerCurve = .continuous
        expressionView.layer.borderWidth = 1
        expressionView.layer.borderColor = StudioTheme.border.cgColor
        expressionView.tintColor = StudioTheme.lavender
        expressionView.isEditable = false
        expressionView.isSelectable = true
        expressionView.isScrollEnabled = true
        expressionView.alwaysBounceVertical = true
        expressionView.adjustsFontForContentSizeCategory = true
        expressionView.textContainerInset = UIEdgeInsets(top: 20, left: 18, bottom: 24, right: 18)
        expressionView.textContainer.lineFragmentPadding = 0
        expressionView.textContainer.lineBreakMode = .byCharWrapping
        expressionView.textContainer.maximumNumberOfLines = 0
        expressionView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        expressionView.accessibilityIdentifier = "formulaExpression"
        expressionView.accessibilityHint = "Scroll to read the complete formula and its notation. Text can be selected."

        copyButton.setTitle("Copy all formulas", for: .normal)
        copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        copyButton.accessibilityIdentifier = "copyFormulasButton"
        copyButton.addTarget(self, action: #selector(copyAllFormulas), for: .touchUpInside)

        let hint = StudioTheme.label("Select text to inspect or copy a part.", size: 11,
                                      color: StudioTheme.mutedText)
        hint.textAlignment = .center
        hint.adjustsFontSizeToFitWidth = true
        hint.minimumScaleFactor = 0.75

        for child in [eyebrow, close, title, name, channelPicker, expressionView, copyButton, hint] {
            child.translatesAutoresizingMaskIntoConstraints = false
            root.addSubview(child)
        }

        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: root.safeAreaLayoutGuide.topAnchor, constant: 20),
            close.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            eyebrow.leadingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            eyebrow.centerYAnchor.constraint(equalTo: close.centerYAnchor),
            eyebrow.trailingAnchor.constraint(lessThanOrEqualTo: close.leadingAnchor, constant: -12),
            title.leadingAnchor.constraint(equalTo: eyebrow.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: close.trailingAnchor),
            title.topAnchor.constraint(equalTo: close.bottomAnchor, constant: 12),
            name.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            name.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            name.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            channelPicker.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            channelPicker.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            channelPicker.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20),
            channelPicker.heightAnchor.constraint(equalToConstant: 44),
            expressionView.topAnchor.constraint(equalTo: channelPicker.bottomAnchor, constant: 16),
            expressionView.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            expressionView.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            expressionView.bottomAnchor.constraint(equalTo: copyButton.topAnchor, constant: -16),
            copyButton.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            copyButton.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            copyButton.heightAnchor.constraint(equalToConstant: 54),
            copyButton.bottomAnchor.constraint(equalTo: hint.topAnchor, constant: -10),
            hint.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            hint.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            hint.bottomAnchor.constraint(equalTo: root.safeAreaLayoutGuide.bottomAnchor, constant: -14)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateDisplayedFormula()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory,
           isViewLoaded {
            updateDisplayedFormula()
        }
    }

    @objc private func changeChannel() {
        updateDisplayedFormula()
    }

    private func updateDisplayedFormula() {
        let index = max(0, min(2, channelPicker.selectedSegmentIndex))
        let symbols = ["R", "G", "B"]
        let channels = ["Red", "Green", "Blue"]
        let expressions = [formulas.red, formulas.green, formulas.blue]
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        paragraph.lineBreakMode = .byCharWrapping

        let formulaFont = UIFontMetrics(forTextStyle: .body).scaledFont(
            for: UIFont.monospacedSystemFont(ofSize: 15, weight: .regular),
            maximumPointSize: 22
        )
        let text = NSMutableAttributedString(
            string: "\(symbols[index])(x,y) = \(expressions[index])",
            attributes: [.font: formulaFont, .foregroundColor: StudioTheme.lavender,
                         .paragraphStyle: paragraph]
        )

        appendSection("COORDINATES", body: Self.coordinateNotes, to: text)
        appendSection("FROM NUMBERS TO COLOR", body: Self.colorNotes, to: text)
        let definitions = ([Self.notationNotes] + formulas.definitions).joined(separator: "\n\n")
        appendSection("NOTATION", body: definitions, to: text)

        expressionView.attributedText = text
        expressionView.accessibilityLabel = "\(channels[index]) channel formula"
        expressionView.selectedRange = NSRange(location: 0, length: 0)
        expressionView.setContentOffset(.zero, animated: false)
    }

    private func appendSection(_ heading: String, body: String,
                               to text: NSMutableAttributedString) {
        text.append(NSAttributedString(
            string: "\n\n\n\(heading)\n\n",
            attributes: [.font: StudioTheme.font(10, weight: .semibold),
                         .foregroundColor: StudioTheme.lavender]
        ))
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        paragraph.lineBreakMode = .byWordWrapping
        text.append(NSAttributedString(
            string: body,
            attributes: [.font: StudioTheme.font(13),
                         .foregroundColor: StudioTheme.secondaryText,
                         .paragraphStyle: paragraph]
        ))
    }

    @objc private func copyAllFormulas() {
        UIPasteboard.general.string = """
        \(wallpaperName.isEmpty ? "iWallee wallpaper" : wallpaperName)
        Expression depth: \(formulas.depth)

        R(x,y) = \(formulas.red)

        G(x,y) = \(formulas.green)

        B(x,y) = \(formulas.blue)

        COORDINATES
        \(Self.coordinateNotes)

        FROM NUMBERS TO COLOR
        \(Self.colorNotes)

        NOTATION
        \(([Self.notationNotes] + formulas.definitions).joined(separator: "\n\n"))
        """

        copyFeedbackReset?.cancel()
        copyButton.setTitle("Copied", for: .normal)
        copyButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        UIAccessibility.post(notification: .announcement, argument: "All three formulas copied.")
        let reset = DispatchWorkItem { [weak self] in
            self?.copyButton.setTitle("Copy all formulas", for: .normal)
            self?.copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        }
        copyFeedbackReset = reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: reset)
    }

    @objc private func closeFormulas() {
        dismiss(animated: true)
    }
}
