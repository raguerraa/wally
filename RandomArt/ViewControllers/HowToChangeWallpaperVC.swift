//
//  HowToChangeWallpaperVC.swift
//  RandomArt
//
//  A short, readable guide with the original illustrated PDF kept close by.
//

import UIKit
import PDFKit
import SideMenuSwift

class HowToChangeWallpaperVC: UIViewController {
    let pdfView = PDFView(frame: .zero)

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func loadView() {
        let root = UIView()
        root.backgroundColor = StudioTheme.background
        view = root
        overrideUserInterfaceStyle = .dark

        let eyebrow = StudioTheme.label("A LITTLE GUIDANCE", size: 10, weight: .semibold,
                                        color: StudioTheme.lavender)
        let menu = StudioTheme.iconButton("line.3.horizontal", accessibilityLabel: "Open menu")
        menu.accessibilityIdentifier = "guideMenuButton"
        menu.addTarget(self, action: #selector(revealMenu), for: .touchUpInside)
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 28

        let title = StudioTheme.label("Make it yours.", size: 34, weight: .bold)
        title.numberOfLines = 0
        title.accessibilityTraits = .header
        title.accessibilityIdentifier = "guideTitle"
        let subtitle = StudioTheme.label(
            "From a little mathematics to a wallpaper that feels like you.",
            size: 16, color: StudioTheme.secondaryText
        )
        subtitle.numberOfLines = 0
        let intro = UIStackView(arrangedSubviews: [title, subtitle])
        intro.axis = .vertical
        intro.spacing = 12
        content.addArrangedSubview(intro)
        content.setCustomSpacing(36, after: intro)

        content.addArrangedSubview(instruction(
            number: "01", title: "Find your original",
            body: "In Studio, choose a complexity and tap Generate. Each result is a new mathematical composition. You can also explore the Collection."
        ))
        content.addArrangedSubview(instruction(
            number: "02", title: "Save the one you love",
            body: "Tap Save in Studio, or Save to Photos in the Collection, and allow iWalle to add the image to your library. Wait for the saved confirmation before leaving."
        ))
        content.addArrangedSubview(instruction(
            number: "03", title: "Give it a home",
            body: "Open Wallpaper in your iPhone’s Settings. Choose the image from Photos, adjust the crop, and apply it to your Lock Screen or Home Screen."
        ))

        let divider = UIView()
        divider.backgroundColor = StudioTheme.border
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        content.addArrangedSubview(divider)
        let tip = StudioTheme.label(
            "Try a lower complexity for a quieter background. Turn it up when you want more detail.",
            size: 14, color: StudioTheme.secondaryText
        )
        tip.numberOfLines = 0
        content.addArrangedSubview(tip)

        let guideButton = UIButton(type: .system)
        guideButton.setTitle("View illustrated guide", for: .normal)
        guideButton.setImage(UIImage(systemName: "doc.richtext"), for: .normal)
        guideButton.tintColor = StudioTheme.lavender
        guideButton.backgroundColor = StudioTheme.surface
        guideButton.layer.cornerRadius = 16
        guideButton.layer.borderWidth = 1
        guideButton.layer.borderColor = StudioTheme.border.cgColor
        guideButton.titleLabel?.font = StudioTheme.font(14, weight: .semibold)
        guideButton.titleLabel?.adjustsFontForContentSizeCategory = true
        guideButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        guideButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        guideButton.accessibilityIdentifier = "illustratedGuideButton"
        guideButton.addTarget(self, action: #selector(showIllustratedGuide), for: .touchUpInside)
        content.addArrangedSubview(guideButton)

        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)
        for child in [eyebrow, menu, scrollView] {
            child.translatesAutoresizingMaskIntoConstraints = false
            root.addSubview(child)
        }
        NSLayoutConstraint.activate([
            eyebrow.leadingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            eyebrow.centerYAnchor.constraint(equalTo: menu.centerYAnchor),
            eyebrow.trailingAnchor.constraint(lessThanOrEqualTo: menu.leadingAnchor, constant: -12),
            menu.topAnchor.constraint(equalTo: root.safeAreaLayoutGuide.topAnchor, constant: 18),
            menu.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            menu.widthAnchor.constraint(equalToConstant: 44),
            menu.heightAnchor.constraint(equalToConstant: 44),
            scrollView.topAnchor.constraint(equalTo: menu.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: root.safeAreaLayoutGuide.bottomAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48),
            guideButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePDFView()
        loadHowToChangeWallpaperPDF()
    }

    private func instruction(number: String, title: String, body: String) -> UIView {
        let numberLabel = StudioTheme.label(number, size: 12, weight: .bold,
                                             color: StudioTheme.lavender)
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = StudioTheme.purple.withAlphaComponent(0.13)
        numberLabel.layer.cornerRadius = 20
        numberLabel.clipsToBounds = true
        numberLabel.isAccessibilityElement = false
        let heading = StudioTheme.label(title, size: 18, weight: .semibold)
        heading.numberOfLines = 0
        heading.accessibilityTraits = .header
        let detail = StudioTheme.label(body, size: 15, color: StudioTheme.secondaryText)
        detail.numberOfLines = 0
        let text = UIStackView(arrangedSubviews: [heading, detail])
        text.axis = .vertical
        text.spacing = 9
        let row = UIStackView(arrangedSubviews: [numberLabel, text])
        row.alignment = .top
        row.spacing = 16
        NSLayoutConstraint.activate([
            numberLabel.widthAnchor.constraint(equalToConstant: 40),
            numberLabel.heightAnchor.constraint(equalToConstant: 40),
        ])
        return row
    }

    func configurePDFView() {
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.minScaleFactor = 0.1
        pdfView.maxScaleFactor = 5
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = StudioTheme.surface
        pdfView.layer.cornerRadius = 16
        pdfView.clipsToBounds = true
    }

    func loadHowToChangeWallpaperPDF() {
        guard let path = Bundle.main.url(forResource: "howToChangeWallpapers", withExtension: "pdf")
        else { return }
        pdfView.document = PDFDocument(url: path)
    }

    @objc private func revealMenu() { sideMenuController?.revealMenu() }

    @objc private func showIllustratedGuide() {
        guard pdfView.document != nil else { return }
        let controller = UIViewController()
        controller.title = "Illustrated guide"
        controller.view.backgroundColor = StudioTheme.background
        controller.overrideUserInterfaceStyle = .dark
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closeIllustratedGuide)
        )
        pdfView.removeFromSuperview()
        controller.view.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            pdfView.trailingAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            pdfView.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            pdfView.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        let navigation = UINavigationController(rootViewController: controller)
        navigation.overrideUserInterfaceStyle = .dark
        navigation.navigationBar.tintColor = StudioTheme.lavender
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = StudioTheme.background
        appearance.titleTextAttributes = [.foregroundColor: StudioTheme.text]
        navigation.navigationBar.standardAppearance = appearance
        navigation.navigationBar.scrollEdgeAppearance = appearance
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: true)
    }

    @objc private func closeIllustratedGuide() { dismiss(animated: true) }
}

extension PDFView {
    func disableBouncing() {
        for subview in subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.bounces = false
                return
            }
        }
    }
}
