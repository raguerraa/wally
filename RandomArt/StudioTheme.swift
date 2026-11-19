import UIKit

/// One palette and a small set of controls keep every screen feeling like iWallee.
enum StudioTheme {
    static let background = UIColor(hex: 0x08060D)
    static let surface = UIColor(hex: 0x15101F)
    static let elevated = UIColor(hex: 0x21182F)
    static let purple = UIColor(hex: 0x9866FF)
    static let lavender = UIColor(hex: 0xD7C5FF)
    static let text = UIColor(hex: 0xF7F3FF)
    static let secondaryText = UIColor(hex: 0xB2A7C5)
    static let mutedText = UIColor(hex: 0x7D708F)
    static let border = UIColor(hex: 0x362746)

    static func font(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFontMetrics.default.scaledFont(for: base, maximumPointSize: size * 1.35)
    }

    static func label(_ text: String, size: CGFloat,
                      weight: UIFont.Weight = .regular,
                      color: UIColor = StudioTheme.text) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font(size, weight: weight)
        label.textColor = color
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    static func logoView(size: CGFloat) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "iWalleeMark"))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = size * 0.22
        imageView.clipsToBounds = true
        imageView.isAccessibilityElement = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size),
            imageView.heightAnchor.constraint(equalToConstant: size)
        ])
        return imageView
    }

    static func iconButton(_ systemName: String, accessibilityLabel: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName,
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)),
                        for: .normal)
        button.tintColor = text
        button.backgroundColor = elevated
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.layer.borderWidth = 1
        button.layer.borderColor = border.cgColor
        button.accessibilityLabel = accessibilityLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        return button
    }
}

/// Shared purple CTA. The gradient resizes with the button's layer.
final class StudioPrimaryButton: UIButton {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAppearance()
    }

    private func configureAppearance() {
        let gradient = layer as! CAGradientLayer
        gradient.colors = [UIColor(hex: 0xA87AFF).cgColor, UIColor(hex: 0x7439E6).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        clipsToBounds = true
        tintColor = .white
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .disabled)
        titleLabel?.font = StudioTheme.font(16, weight: .semibold)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.8
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
    }

    override var isHighlighted: Bool {
        didSet { transform = isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity }
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }
}
