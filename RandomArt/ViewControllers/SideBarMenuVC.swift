//
//  SideBarMenuVC.swift
//  RandomArt
//
//  Purple-and-black navigation for the iWallee studio.
//

import UIKit
import SideMenuSwift

class SideBarMenuVC: UIViewController {
    let canvasStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let freeCollectionStoryboard = UIStoryboard(name: "FreeCollection", bundle: nil)
    let howToChangeWallpaper = UIStoryboard(name: "HowToChangeWallpaper", bundle: nil)

    @IBOutlet weak var profileView: UIImageView!
    private var navigationButtons: [UIButton] = []
    private var selectedIndex = 0

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func loadView() {
        let root = UIView()
        root.backgroundColor = StudioTheme.background
        view = root
        overrideUserInterfaceStyle = .dark

        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        let content = UIView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(scrollView)
        scrollView.addSubview(content)
        let preferredContentHeight = content.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        preferredContentHeight.priority = .defaultLow

        // SideMenuSwift translates a full-screen menu container. Its visible panel
        // is only menuWidth wide at the far edge of that container.
        let preferences = SideMenuController.preferences.basic
        let reversesDirection = preferences.shouldRespectLanguageDirection &&
            UIView.userInterfaceLayoutDirection(for: root.semanticContentAttribute) == .rightToLeft
        let revealsFromLeft = (preferences.direction == .left) != reversesDirection
        let alignsToRight = preferences.position == .under ? !revealsFromLeft : revealsFromLeft
        let panelEdge = alignsToRight
            ? scrollView.rightAnchor.constraint(equalTo: root.rightAnchor)
            : scrollView.leftAnchor.constraint(equalTo: root.leftAnchor)
        NSLayoutConstraint.activate([
            panelEdge,
            scrollView.widthAnchor.constraint(equalToConstant: preferences.menuWidth),
            scrollView.topAnchor.constraint(equalTo: root.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: root.safeAreaLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
            preferredContentHeight,
        ])

        let logo = StudioTheme.logoView(size: 52)
        profileView = logo
        let title = StudioTheme.label("iWallee", size: 25, weight: .bold)
        title.numberOfLines = 0
        let subtitle = StudioTheme.label("MATH INTO ART", size: 10, weight: .semibold,
                                        color: StudioTheme.lavender)
        subtitle.numberOfLines = 0
        let wordmark = UIStackView(arrangedSubviews: [title, subtitle])
        wordmark.axis = .vertical
        wordmark.spacing = 4
        let brand = UIStackView(arrangedSubviews: [logo, wordmark])
        brand.alignment = .center
        brand.spacing = 12

        let close = StudioTheme.iconButton("chevron.left", accessibilityLabel: "Close menu")
        close.addTarget(self, action: #selector(closeMenu), for: .touchUpInside)

        let section = StudioTheme.label("YOUR CREATIVE SPACE", size: 10, weight: .semibold,
                                       color: StudioTheme.mutedText)
        section.numberOfLines = 0
        let studio = navigationItem(title: "Studio", detail: "Create something original",
                                    symbol: "sparkles", action: #selector(showCanvas(_:)))
        studio.accessibilityIdentifier = "menuStudio"
        let collection = navigationItem(title: "Collection", detail: "Explore the possibilities",
                                        symbol: "square.grid.2x2", action: #selector(showYourWork(_:)))
        collection.accessibilityIdentifier = "menuCollection"
        let guide = navigationItem(title: "How to use", detail: "Make it your wallpaper",
                                   symbol: "questionmark.circle", action: #selector(showHowToChangeWallpaper(_:)))
        guide.accessibilityIdentifier = "menuHowTo"
        navigationButtons = [studio, collection, guide]
        let navigation = UIStackView(arrangedSubviews: navigationButtons)
        navigation.axis = .vertical
        navigation.spacing = 10

        let rule = UIView()
        rule.backgroundColor = StudioTheme.border
        let footerTitle = StudioTheme.label("An infinite canvas.", size: 16, weight: .semibold,
                                           color: StudioTheme.lavender)
        footerTitle.numberOfLines = 0
        let footer = StudioTheme.label("A little mathematics.\nSomething entirely yours.", size: 13,
                                       color: StudioTheme.secondaryText)
        footer.numberOfLines = 0
        let footerStack = UIStackView(arrangedSubviews: [rule, footerTitle, footer])
        footerStack.axis = .vertical
        footerStack.spacing = 12

        for child in [brand, close, section, navigation, footerStack] {
            child.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(child)
        }
        NSLayoutConstraint.activate([
            brand.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
            brand.topAnchor.constraint(equalTo: content.topAnchor, constant: 36),
            brand.trailingAnchor.constraint(lessThanOrEqualTo: content.trailingAnchor, constant: -20),
            logo.widthAnchor.constraint(equalToConstant: 52),
            logo.heightAnchor.constraint(equalToConstant: 52),
            close.leadingAnchor.constraint(equalTo: brand.leadingAnchor),
            close.topAnchor.constraint(equalTo: brand.bottomAnchor, constant: 26),
            close.widthAnchor.constraint(equalToConstant: 44),
            close.heightAnchor.constraint(equalToConstant: 44),
            section.leadingAnchor.constraint(equalTo: brand.leadingAnchor),
            section.topAnchor.constraint(equalTo: close.bottomAnchor, constant: 26),
            navigation.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            navigation.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            navigation.topAnchor.constraint(equalTo: section.bottomAnchor, constant: 14),
            footerStack.leadingAnchor.constraint(equalTo: brand.leadingAnchor),
            footerStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),
            footerStack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -28),
            footerStack.topAnchor.constraint(greaterThanOrEqualTo: navigation.bottomAnchor, constant: 24),
            rule.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureProfileView()
        sideMenuController?.cache(viewControllerGenerator: { [unowned self] in
            self.canvasStoryboard.instantiateViewController(withIdentifier: "canvas")
        }, with: "canvas")
        sideMenuController?.cache(viewControllerGenerator: { [unowned self] in
            self.freeCollectionStoryboard.instantiateViewController(withIdentifier: "freeCollection")
        }, with: "freeCollection")
        sideMenuController?.cache(viewControllerGenerator: { [unowned self] in
            self.howToChangeWallpaper.instantiateViewController(withIdentifier: "howToChangeWallpaper")
        }, with: "howToChangeWallpaper")
        selectItem(0)
        sideMenuController?.setContentViewController(with: "canvas")
        sideMenuController?.hideMenu()
    }

    func configureProfileView() {
        profileView.layer.cornerRadius = 14
        profileView.clipsToBounds = true
    }

    private func navigationItem(title: String, detail: String, symbol: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 18
        button.contentHorizontalAlignment = .left
        button.accessibilityLabel = title
        button.accessibilityHint = detail
        button.addTarget(self, action: action, for: .touchUpInside)

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = StudioTheme.lavender
        icon.contentMode = .scaleAspectFit
        let titleLabel = StudioTheme.label(title, size: 16, weight: .semibold)
        titleLabel.numberOfLines = 0
        let detailLabel = StudioTheme.label(detail, size: 10, color: StudioTheme.secondaryText)
        detailLabel.numberOfLines = 0
        let copy = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        copy.axis = .vertical
        copy.spacing = 4
        let row = UIStackView(arrangedSubviews: [icon, copy])
        row.spacing = 14
        row.alignment = .center
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(row)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 74),
            row.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -12),
            row.topAnchor.constraint(equalTo: button.topAnchor, constant: 14),
            row.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -14),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),
        ])
        return button
    }

    private func selectItem(_ index: Int) {
        selectedIndex = index
        for (position, button) in navigationButtons.enumerated() {
            let selected = position == index
            button.backgroundColor = selected ? StudioTheme.purple.withAlphaComponent(0.18) : .clear
            button.layer.borderWidth = selected ? 1 : 0
            button.layer.borderColor = StudioTheme.purple.withAlphaComponent(0.3).cgColor
            button.accessibilityTraits = selected ? [.button, .selected] : [.button]
        }
    }

    @objc private func closeMenu() { sideMenuController?.hideMenu() }

    @IBAction func showCanvas(_ sender: Any) {
        selectItem(0)
        sideMenuController?.setContentViewController(with: "canvas")
        sideMenuController?.hideMenu()
    }

    @IBAction func showYourWork(_ sender: Any) {
        selectItem(1)
        sideMenuController?.setContentViewController(with: "freeCollection")
        sideMenuController?.hideMenu()
    }

    @IBAction func showHowToChangeWallpaper(_ sender: Any) {
        selectItem(2)
        sideMenuController?.setContentViewController(with: "howToChangeWallpaper")
        sideMenuController?.hideMenu()
    }
}
