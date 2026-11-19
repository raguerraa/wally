//
//  FreeCollectionVC.swift
//  RandomArt
//
//  A curated gallery of mathematical originals.
//

import UIKit
import SideMenuSwift

class FreeCollectionVC: UIViewController {
    @IBOutlet weak var artworkCollection: UICollectionView!
    private var wallpapers: [Wallpaper] = []
    private var catalog: [Wallpaper] = []
    private var isVividTagSelected = false
    private var isDarkTagSelected = false
    private var is50TagSelected = false
    private var is75TagSelected = false
    private var is100TagSelected = false
    private var filterButtons: [UIButton] = []
    private var lastLayoutWidth: CGFloat = 0
    private var lastContentSizeCategory: UIContentSizeCategory = .unspecified
    private let countLabel = StudioTheme.label("", size: 10, weight: .semibold,
                                               color: StudioTheme.lavender)

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func loadView() {
        let root = UIView()
        root.backgroundColor = StudioTheme.background
        view = root
        overrideUserInterfaceStyle = .dark

        let title = StudioTheme.label("Collection", size: 32, weight: .bold)
        title.accessibilityTraits = .header
        title.accessibilityIdentifier = "collectionTitle"
        let subtitle = StudioTheme.label("Curated by chance. Chosen for you.", size: 14,
                                         color: StudioTheme.secondaryText)
        subtitle.numberOfLines = 0
        let menu = StudioTheme.iconButton("line.3.horizontal", accessibilityLabel: "Open menu")
        menu.accessibilityIdentifier = "collectionMenuButton"
        menu.addTarget(self, action: #selector(revealMenu), for: .touchUpInside)

        let filterScroll = UIScrollView()
        filterScroll.showsHorizontalScrollIndicator = false
        filterScroll.clipsToBounds = false
        let filters = UIStackView()
        filters.spacing = 8
        let definitions: [(String, Selector)] = [
            ("All", #selector(clearFilters)),
            ("Vivid", #selector(showVividWallpapers(_:))),
            ("Dark", #selector(showDarkWallpapers(_:))),
            ("50%", #selector(show50PercentComplexity(_:))),
            ("75%", #selector(show75PercentComplexity(_:))),
            ("100%", #selector(show100PercentComplexity(_:))),
        ]
        for (text, action) in definitions {
            let button = UIButton(type: .custom)
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = StudioTheme.font(13, weight: .semibold)
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 17, bottom: 10, right: 17)
            button.layer.cornerRadius = 22
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            button.layer.borderWidth = 1
            button.addTarget(self, action: action, for: .touchUpInside)
            button.accessibilityIdentifier = "galleryFilter\(text)"
            filterButtons.append(button)
            filters.addArrangedSubview(button)
        }
        filters.translatesAutoresizingMaskIntoConstraints = false
        filterScroll.addSubview(filters)

        let reorderHint = StudioTheme.label("Hold to rearrange", size: 10,
                                            color: StudioTheme.mutedText)
        let countRow = UIStackView(arrangedSubviews: [countLabel, UIView(), reorderHint])
        countRow.alignment = .center

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 22
        layout.minimumInteritemSpacing = 12
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.alwaysBounceVertical = true
        collection.showsVerticalScrollIndicator = false
        collection.contentInsetAdjustmentBehavior = .never
        collection.register(StudioWallpaperCell.self, forCellWithReuseIdentifier: "studioWallpaper")
        collection.accessibilityIdentifier = "wallpaperCollection"
        artworkCollection = collection

        for child in [title, subtitle, menu, filterScroll, countRow, collection] {
            child.translatesAutoresizingMaskIntoConstraints = false
            root.addSubview(child)
        }
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            title.topAnchor.constraint(equalTo: root.safeAreaLayoutGuide.topAnchor, constant: 22),
            title.trailingAnchor.constraint(lessThanOrEqualTo: menu.leadingAnchor, constant: -12),
            menu.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            menu.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            menu.widthAnchor.constraint(equalToConstant: 44),
            menu.heightAnchor.constraint(equalToConstant: 44),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            filterScroll.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 24),
            filterScroll.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            filterScroll.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            filters.topAnchor.constraint(equalTo: filterScroll.contentLayoutGuide.topAnchor),
            filters.bottomAnchor.constraint(equalTo: filterScroll.contentLayoutGuide.bottomAnchor),
            filters.leadingAnchor.constraint(equalTo: filterScroll.contentLayoutGuide.leadingAnchor),
            filters.trailingAnchor.constraint(equalTo: filterScroll.contentLayoutGuide.trailingAnchor),
            filters.heightAnchor.constraint(equalTo: filterScroll.frameLayoutGuide.heightAnchor),
            countRow.topAnchor.constraint(equalTo: filterScroll.bottomAnchor, constant: 26),
            countRow.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            countRow.trailingAnchor.constraint(equalTo: subtitle.trailingAnchor),
            collection.topAnchor.constraint(equalTo: countRow.bottomAnchor, constant: 14),
            collection.leadingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: root.safeAreaLayoutGuide.bottomAnchor),
        ])
        updateFilterAppearance()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        artworkCollection.delegate = self
        artworkCollection.dataSource = self
        catalog = (try? loadWallpapers()) ?? []
        wallpapers = catalog
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        artworkCollection.addGestureRecognizer(gesture)
        updateResults()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = artworkCollection.bounds.width
        let category = traitCollection.preferredContentSizeCategory
        guard width != lastLayoutWidth || category != lastContentSizeCategory else { return }
        lastLayoutWidth = width
        lastContentSizeCategory = category
        artworkCollection.collectionViewLayout.invalidateLayout()
    }

    @objc private func revealMenu() { sideMenuController?.revealMenu() }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let index = artworkCollection.indexPathForItem(at: gesture.location(in: artworkCollection))
            else { return }
            artworkCollection.beginInteractiveMovementForItem(at: index)
        case .changed:
            artworkCollection.updateInteractiveMovementTargetPosition(gesture.location(in: artworkCollection))
        case .ended:
            artworkCollection.endInteractiveMovement()
        default:
            artworkCollection.cancelInteractiveMovement()
        }
    }

    private func loadWallpapers() throws -> [Wallpaper] {
        guard let url = Bundle.main.url(forResource: "wallpapers", withExtension: "json") else {
            throw FileError.fileNotFound("wallpapers.json")
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(WallpaperFile.self, from: data).wallpapers
    }

    @IBAction func showVividWallpapers(_ sender: Any) {
        isVividTagSelected.toggle()
        applyFilters()
    }

    @IBAction func showDarkWallpapers(_ sender: Any) {
        isDarkTagSelected.toggle()
        applyFilters()
    }

    @IBAction func show50PercentComplexity(_ sender: Any) {
        is50TagSelected.toggle()
        applyFilters()
    }

    @IBAction func show75PercentComplexity(_ sender: Any) {
        is75TagSelected.toggle()
        applyFilters()
    }

    @IBAction func show100PercentComplexity(_ sender: Any) {
        is100TagSelected.toggle()
        applyFilters()
    }

    @objc private func clearFilters() {
        isVividTagSelected = false
        isDarkTagSelected = false
        is50TagSelected = false
        is75TagSelected = false
        is100TagSelected = false
        applyFilters()
    }

    private func applyFilters() {
        var complexities = Set<Int>()
        if is50TagSelected { complexities.insert(50) }
        if is75TagSelected { complexities.insert(75) }
        if is100TagSelected { complexities.insert(100) }
        wallpapers = catalog.filter {
            (!isVividTagSelected || $0.isVivid()) &&
            (!isDarkTagSelected || $0.isDark()) &&
            (complexities.isEmpty || complexities.contains($0.getComplexity()))
        }
        updateFilterAppearance()
        updateResults()
    }

    private func updateFilterAppearance() {
        let flags = [isVividTagSelected, isDarkTagSelected, is50TagSelected,
                     is75TagSelected, is100TagSelected]
        let states = [!flags.contains(true)] + flags
        for (button, selected) in zip(filterButtons, states) {
            button.isSelected = selected
            button.backgroundColor = selected ? StudioTheme.purple : StudioTheme.surface
            button.layer.borderColor = (selected ? StudioTheme.purple : StudioTheme.border).cgColor
            button.setTitleColor(selected ? .white : StudioTheme.secondaryText, for: .normal)
            button.accessibilityTraits = selected ? [.button, .selected] : [.button]
        }
    }

    private func updateResults() {
        countLabel.text = "\(wallpapers.count) WALLPAPERS"
        artworkCollection.reloadData()
        guard wallpapers.isEmpty else {
            artworkCollection.backgroundView = nil
            return
        }
        let empty = UIView()
        let symbol = UIImageView(image: UIImage(systemName: "sparkles"))
        symbol.tintColor = StudioTheme.purple
        symbol.contentMode = .scaleAspectFit
        let title = StudioTheme.label("Try a different combination", size: 19, weight: .semibold)
        title.textAlignment = .center
        title.numberOfLines = 0
        let explanation = StudioTheme.label("No wallpapers match these filters.", size: 14,
                                           color: StudioTheme.secondaryText)
        explanation.textAlignment = .center
        explanation.numberOfLines = 0
        let reset = UIButton(type: .system)
        reset.setTitle("Reset filters", for: .normal)
        reset.titleLabel?.font = StudioTheme.font(15, weight: .semibold)
        reset.tintColor = StudioTheme.lavender
        reset.addTarget(self, action: #selector(clearFilters), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [symbol, title, explanation, reset])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        empty.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: empty.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: empty.trailingAnchor, constant: -28),
            stack.centerYAnchor.constraint(equalTo: empty.centerYAnchor, constant: -30),
            symbol.heightAnchor.constraint(equalToConstant: 40),
            reset.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
        artworkCollection.backgroundView = empty
    }

    @IBAction func showWallpaper(_ sender: Any) {
        guard let control = sender as? UIView else { return }
        let point = control.convert(CGPoint(x: control.bounds.midX, y: control.bounds.midY),
                                    to: artworkCollection)
        guard let index = artworkCollection.indexPathForItem(at: point) else { return }
        presentWallpaper(wallpapers[index.item])
    }

    private func presentWallpaper(_ wallpaper: Wallpaper) {
        guard let controller = freeCollectionStoryboardController() else { return }
        controller.imageName = wallpaper.getImageName()
        controller.wallpaperName = wallpaper.getName()
        controller.complexity = wallpaper.getComplexity()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    private func freeCollectionStoryboardController() -> DownloadVC? {
        UIStoryboard(name: "FreeCollection", bundle: nil)
            .instantiateViewController(withIdentifier: "downloadVC") as? DownloadVC
    }
}

extension FreeCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        wallpapers.count
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        let wallpaper = wallpapers.remove(at: sourceIndexPath.item)
        wallpapers.insert(wallpaper, at: destinationIndexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "studioWallpaper",
                                                       for: indexPath) as! StudioWallpaperCell
        let wallpaper = wallpapers[indexPath.item]
        cell.configure(wallpaper: wallpaper)
        // Capture the item, never a row tag that can become stale after reordering.
        cell.onOpen = { [weak self] in self?.presentWallpaper(wallpaper) }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentWallpaper(wallpapers[indexPath.item])
    }
}

extension FreeCollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 24, bottom: 24, right: 24)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let singleColumn = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        let available = max(1, collectionView.bounds.width - 48)
        let width = singleColumn ? available : (available - 12) / 2
        let captionHeight = UIFontMetrics(forTextStyle: .subheadline).scaledValue(for: 66)
        return CGSize(width: width, height: width * 1.32 + captionHeight)
    }
}

private final class StudioWallpaperCell: UICollectionViewCell {
    private let artwork = UIImageView()
    private let title = StudioTheme.label("", size: 13, weight: .semibold)
    private let detail = StudioTheme.label("", size: 11, color: StudioTheme.mutedText)
    private let openButton = UIButton(type: .custom)
    var onOpen: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        artwork.contentMode = .scaleAspectFill
        artwork.clipsToBounds = true
        artwork.backgroundColor = StudioTheme.surface
        artwork.layer.cornerRadius = 20
        artwork.layer.borderWidth = 1
        artwork.layer.borderColor = StudioTheme.border.cgColor
        title.numberOfLines = 2
        detail.numberOfLines = 1
        openButton.backgroundColor = StudioTheme.background.withAlphaComponent(0.72)
        openButton.layer.cornerRadius = 22
        openButton.setImage(UIImage(systemName: "arrow.up.right"), for: .normal)
        openButton.tintColor = .white
        openButton.addTarget(self, action: #selector(openPreview), for: .touchUpInside)
        for child in [artwork, title, detail, openButton] {
            child.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(child)
        }
        NSLayoutConstraint.activate([
            artwork.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            artwork.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            artwork.topAnchor.constraint(equalTo: contentView.topAnchor),
            artwork.heightAnchor.constraint(equalTo: artwork.widthAnchor, multiplier: 1.32),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            title.topAnchor.constraint(equalTo: artwork.bottomAnchor, constant: 10),
            detail.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            detail.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            detail.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            detail.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            openButton.widthAnchor.constraint(equalToConstant: 44),
            openButton.heightAnchor.constraint(equalToConstant: 44),
            openButton.trailingAnchor.constraint(equalTo: artwork.trailingAnchor, constant: -10),
            openButton.bottomAnchor.constraint(equalTo: artwork.bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { fatalError("Use init(frame:)") }

    func configure(wallpaper: Wallpaper) {
        artwork.image = UIImage(named: wallpaper.getImageName())
        title.text = wallpaper.getName()
        detail.text = "\(wallpaper.getComplexity())% complexity"
        openButton.accessibilityLabel = "Preview \(wallpaper.getName())"
        accessibilityIdentifier = "wallpaper-\(wallpaper.getImageName())"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onOpen = nil
        artwork.image = nil
    }

    @objc private func openPreview() { onOpen?() }
}
