//
//  DownloadVC.swift
//  RandomArt
//
//  A focused wallpaper preview with a completion-driven Photos action.
//

import UIKit

class DownloadVC: UIViewController {
    @IBOutlet weak var wallpaperView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var complexityLabel: UILabel!

    var imageName = String()
    var wallpaperName = String()
    var complexity = Int()
    var photoLibrarySaver: PhotoLibrarySaving = PhotoLibrarySaver.shared

    private let saveButton = StudioPrimaryButton(frame: .zero)
    private let closeButton = StudioTheme.iconButton("xmark", accessibilityLabel: "Close wallpaper")
    private let savingIndicator = UIActivityIndicatorView(style: .medium)
    private(set) var isSaving = false

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func loadView() {
        let root = UIView()
        root.backgroundColor = StudioTheme.background
        view = root
        overrideUserInterfaceStyle = .dark

        let eyebrow = StudioTheme.label("FROM THE COLLECTION", size: 10, weight: .semibold,
                                        color: StudioTheme.lavender)
        let name = StudioTheme.label(wallpaperName, size: 28, weight: .bold)
        name.numberOfLines = 0
        name.accessibilityTraits = [.staticText, .header]
        name.accessibilityIdentifier = "downloadTitle"
        name.setContentCompressionResistancePriority(.required, for: .vertical)
        nameLabel = name
        let detail = StudioTheme.label("\(complexity)% complexity", size: 13,
                                        color: StudioTheme.secondaryText)
        detail.numberOfLines = 0
        detail.setContentCompressionResistancePriority(.required, for: .vertical)
        complexityLabel = detail

        closeButton.accessibilityIdentifier = "downloadCloseButton"
        closeButton.addTarget(self, action: #selector(closePreview), for: .touchUpInside)

        let imageStage = UIView()
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        // The source bitmap can be taller than the screen. Let the preview shrink
        // before Auto Layout compresses its title or metadata out of sight.
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.clipsToBounds = true
        imageView.backgroundColor = StudioTheme.surface
        imageView.layer.cornerRadius = 24
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = StudioTheme.border.cgColor
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "\(wallpaperName), mathematical wallpaper preview"
        wallpaperView = imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageStage.addSubview(imageView)

        saveButton.setTitle("Save to Photos", for: .normal)
        saveButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        saveButton.tintColor = .white
        saveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        saveButton.accessibilityIdentifier = "downloadSaveButton"
        saveButton.addTarget(self, action: #selector(downloadWallpaper(_:)), for: .touchUpInside)

        savingIndicator.color = .white
        savingIndicator.hidesWhenStopped = true
        savingIndicator.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addSubview(savingIndicator)

        let footnote = StudioTheme.label("Saved at its original resolution", size: 11,
                                          color: StudioTheme.mutedText)
        footnote.textAlignment = .center
        footnote.numberOfLines = 0
        footnote.setContentCompressionResistancePriority(.required, for: .vertical)
        for child in [eyebrow, name, detail, closeButton, imageStage, saveButton, footnote] {
            child.translatesAutoresizingMaskIntoConstraints = false
            root.addSubview(child)
        }

        let imageSize = imageView.image?.size ?? CGSize(width: 9, height: 19)
        let aspect = imageSize.width / max(imageSize.height, 1)
        let preferredImageHeight = imageView.heightAnchor.constraint(equalTo: imageStage.heightAnchor)
        preferredImageHeight.priority = UILayoutPriority(749)
        let preferredImageWidth = imageView.widthAnchor.constraint(equalTo: imageStage.widthAnchor)
        preferredImageWidth.priority = UILayoutPriority(748)

        NSLayoutConstraint.activate([
            eyebrow.leadingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            eyebrow.topAnchor.constraint(equalTo: root.safeAreaLayoutGuide.topAnchor, constant: 24),
            eyebrow.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -12),
            closeButton.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            closeButton.topAnchor.constraint(equalTo: root.safeAreaLayoutGuide.topAnchor, constant: 14),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            name.leadingAnchor.constraint(equalTo: eyebrow.leadingAnchor),
            name.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            name.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            detail.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            detail.trailingAnchor.constraint(equalTo: name.trailingAnchor),
            detail.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 6),
            imageStage.topAnchor.constraint(equalTo: detail.bottomAnchor, constant: 24),
            imageStage.leadingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            imageStage.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            imageStage.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -24),
            imageView.centerXAnchor.constraint(equalTo: imageStage.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageStage.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: imageStage.widthAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: imageStage.heightAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspect),
            preferredImageHeight,
            preferredImageWidth,
            saveButton.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: name.trailingAnchor),
            saveButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            saveButton.bottomAnchor.constraint(equalTo: footnote.topAnchor, constant: -12),
            footnote.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            footnote.trailingAnchor.constraint(equalTo: name.trailingAnchor),
            footnote.bottomAnchor.constraint(equalTo: root.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            savingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            savingIndicator.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: -20),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        wallpaperView.image = UIImage(named: imageName)
        nameLabel.text = wallpaperName
        complexityLabel.text = "\(complexity)% complexity"
        updateSaveState()
    }

    @IBAction func downloadWallpaper(_ sender: Any) {
        guard !isSaving, let image = wallpaperView.image else { return }
        isSaving = true
        updateSaveState()

        // Re-enable only when Photos reports success or failure, including permissions.
        saveImage(image: image, using: photoLibrarySaver) { [weak self] in
            guard let self = self else { return }
            self.isSaving = false
            self.updateSaveState()
        }
    }

    private func updateSaveState() {
        saveButton.isEnabled = !isSaving && wallpaperView.image != nil
        closeButton.isEnabled = !isSaving
        isModalInPresentation = isSaving
        saveButton.alpha = saveButton.isEnabled ? 1 : 0.65
        saveButton.setTitle(isSaving ? "Saving to Photos…" : "Save to Photos", for: .normal)
        saveButton.setImage(isSaving ? nil : UIImage(systemName: "square.and.arrow.down"), for: .normal)
        saveButton.accessibilityValue = isSaving ? "Saving" : nil
        isSaving ? savingIndicator.startAnimating() : savingIndicator.stopAnimating()
    }

    @objc private func closePreview() {
        guard !isSaving else { return }
        dismiss(animated: true)
    }
}
