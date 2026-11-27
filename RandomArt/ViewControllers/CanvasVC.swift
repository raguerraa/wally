import UIKit
import CoreGraphics
import SideMenuSwift
import NVActivityIndicatorView

struct Color {
    let name: String
    let decimal: Int
}

class CanvasVC: UIViewController {
    var sideMenu: SideBarMenuVC?

    // Kept as outlets so existing callers and storyboard controller identifiers remain compatible.
    @IBOutlet weak var complexityPercentage: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var canvas: CanvasV!
    @IBOutlet weak var colorAdjective: UILabel!
    @IBOutlet weak var artNoun: UILabel!
    @IBOutlet weak var pressMeView: NVActivityIndicatorView!
    @IBOutlet weak var progressView: NVActivityIndicatorView!
    @IBOutlet weak var topBar: UIStackView!
    @IBOutlet weak var saveButton: UIButton!

    private let goButton = StudioPrimaryButton(frame: .zero)
    private let formulaButton = UIButton(type: .system)
    private var introductionSpace: UILayoutGuide!
    private var introductoryContent: UIStackView!
    private var wallpaperEyebrow: UILabel!
    private var studioStatus: UILabel!
    private var hasWallpaper = false
    private var isBusy = false
    var photoLibrarySaver: PhotoLibrarySaving = PhotoLibrarySaver.shared
    private var colors: [Color] = []
    private var artNames: [String] = []

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func loadView() {
        let root = UIView()
        root.backgroundColor = StudioTheme.background
        view = root

        // The rendering surface still covers the entire display. UI chrome is a separate
        // overlay, so the exported wallpaper keeps its full portrait aspect ratio.
        let canvasView = CanvasV()
        canvasView.backgroundColor = StudioTheme.background
        canvasView.layer.contentsGravity = .resize
        canvasView.clipsToBounds = true
        canvasView.accessibilityIdentifier = "wallpaperCanvas"
        canvasView.isAccessibilityElement = true
        canvasView.accessibilityLabel = "Wallpaper preview"
        canvasView.accessibilityValue = "No wallpaper generated"
        root.addSubview(canvasView)
        canvas = canvasView
        pin(canvasView, to: root)

        let shade = StudioCanvasShade()
        root.addSubview(shade)
        pin(shade, to: root)

        let brand = UIStackView(arrangedSubviews: [
            StudioTheme.label("iWalle", size: 22, weight: .bold),
            eyebrow("WALLPAPER STUDIO", color: StudioTheme.secondaryText)
        ])
        brand.axis = .vertical
        brand.spacing = 2
        let menu = StudioTheme.iconButton("line.3.horizontal", accessibilityLabel: "Open menu")
        menu.accessibilityIdentifier = "studioMenuButton"
        menu.addTarget(self, action: #selector(menuItemTap(_:)), for: .touchUpInside)
        let header = UIStackView(arrangedSubviews: [
            StudioTheme.logoView(size: 44), brand, UIView(), menu
        ])
        header.spacing = 10
        header.alignment = .center
        root.addSubview(header)
        topBar = header
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: root.safeAreaLayoutGuide.topAnchor, constant: 10),
            header.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),
            header.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24)
        ])

        let heading = eyebrow("CREATE YOUR NEXT ORIGINAL", color: StudioTheme.secondaryText)
        wallpaperEyebrow = heading
        let colorLabel = StudioTheme.label("A little math.", size: 31, weight: .medium,
                                          color: StudioTheme.lavender)
        let nameLabel = StudioTheme.label("A lot of art.", size: 39, weight: .bold)
        for label in [colorLabel, nameLabel] {
            label.numberOfLines = 2
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.65
        }
        formulaButton.setTitle("View formula", for: .normal)
        formulaButton.setImage(UIImage(systemName: "function"), for: .normal)
        formulaButton.tintColor = StudioTheme.lavender
        formulaButton.setTitleColor(StudioTheme.lavender, for: .normal)
        formulaButton.titleLabel?.font = StudioTheme.font(13, weight: .semibold)
        formulaButton.titleLabel?.adjustsFontForContentSizeCategory = true
        formulaButton.backgroundColor = StudioTheme.surface.withAlphaComponent(0.85)
        formulaButton.layer.cornerRadius = 16
        formulaButton.layer.cornerCurve = .continuous
        formulaButton.layer.borderWidth = 1
        formulaButton.layer.borderColor = StudioTheme.purple.withAlphaComponent(0.35).cgColor
        formulaButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        formulaButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        formulaButton.accessibilityIdentifier = "showFormulaButton"
        formulaButton.accessibilityLabel = "Show wallpaper formulas"
        formulaButton.addTarget(self, action: #selector(showWallpaperFormula), for: .touchUpInside)
        formulaButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        formulaButton.setContentHuggingPriority(.required, for: .horizontal)
        let formulaRow = UIStackView(arrangedSubviews: [formulaButton, UIView()])

        let names = UIStackView(arrangedSubviews: [heading, colorLabel, nameLabel, formulaRow])
        names.axis = .vertical
        names.spacing = 2
        names.setCustomSpacing(14, after: heading)
        names.setCustomSpacing(12, after: nameLabel)
        root.addSubview(names)
        colorAdjective = colorLabel
        artNoun = nameLabel
        names.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            names.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 28),
            names.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -28),
            names.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 30)
        ])

        let dock = makeControlPanel()
        root.addSubview(dock)
        dock.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dock.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 18),
            dock.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -18),
            dock.bottomAnchor.constraint(equalTo: root.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            names.bottomAnchor.constraint(lessThanOrEqualTo: dock.topAnchor, constant: -16)
        ])

        let introduction = StudioTheme.label(
            "Explore endless combinations\nof color, shape and rhythm.",
            size: 14, color: StudioTheme.secondaryText
        )
        introduction.textAlignment = .center
        introduction.numberOfLines = 2
        let intro = UIStackView(arrangedSubviews: [
            StudioTheme.logoView(size: 160), introduction
        ])
        intro.axis = .vertical
        intro.spacing = 14
        intro.alignment = .center
        root.addSubview(intro)
        introductoryContent = intro
        let openSpace = UILayoutGuide()
        introductionSpace = openSpace
        root.addLayoutGuide(openSpace)
        intro.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            openSpace.topAnchor.constraint(equalTo: names.bottomAnchor),
            openSpace.bottomAnchor.constraint(equalTo: dock.topAnchor),
            openSpace.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            openSpace.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            intro.centerXAnchor.constraint(equalTo: openSpace.centerXAnchor),
            intro.centerYAnchor.constraint(equalTo: openSpace.centerYAnchor),
            intro.leadingAnchor.constraint(greaterThanOrEqualTo: root.leadingAnchor, constant: 24),
            intro.trailingAnchor.constraint(lessThanOrEqualTo: root.trailingAnchor, constant: -24)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        setBusy(false)
        do { colors = try readColorWordsFile() }
        catch { colors = [Color(name: "Absolute", decimal: 0)] }
        do { artNames = try readArtWordsFile() }
        catch { artNames = ["Wallpaper"] }
        canvas.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keep decorative branding out of the controls at smaller sizes or larger text.
        let fitsIntroduction = introductionSpace.layoutFrame.height >= introductoryContent.bounds.height + 24
        introductoryContent.isHidden = hasWallpaper || !fitsIntroduction
    }

    private func makeControlPanel() -> UIView {
        let panel = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        panel.backgroundColor = StudioTheme.surface.withAlphaComponent(0.9)
        panel.layer.cornerRadius = 28
        panel.layer.cornerCurve = .continuous
        panel.layer.borderWidth = 1
        panel.layer.borderColor = StudioTheme.border.withAlphaComponent(0.85).cgColor
        panel.clipsToBounds = true

        let percent = StudioTheme.label("50%", size: 13, weight: .semibold,
                                        color: StudioTheme.lavender)
        percent.textAlignment = .center
        percent.backgroundColor = StudioTheme.elevated
        percent.layer.cornerRadius = 10
        percent.clipsToBounds = true
        let complexityRow = UIStackView(arrangedSubviews: [
            StudioTheme.label("Complexity", size: 14, weight: .semibold), UIView(), percent
        ])
        complexityRow.alignment = .center
        percent.widthAnchor.constraint(equalToConstant: 62).isActive = true
        percent.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let complexitySlider = UISlider()
        complexitySlider.minimumValue = 1
        complexitySlider.maximumValue = 11
        complexitySlider.value = 6
        complexitySlider.minimumTrackTintColor = StudioTheme.purple
        complexitySlider.maximumTrackTintColor = StudioTheme.border
        complexitySlider.thumbTintColor = StudioTheme.lavender
        complexitySlider.accessibilityLabel = "Wallpaper complexity"
        complexitySlider.accessibilityValue = "50 percent"
        complexitySlider.accessibilityIdentifier = "complexitySlider"
        complexitySlider.addTarget(self, action: #selector(changeComplexity(_:)), for: .valueChanged)

        let range = UIStackView(arrangedSubviews: [
            StudioTheme.label("Minimal", size: 11, color: StudioTheme.mutedText),
            UIView(),
            StudioTheme.label("Intricate", size: 11, color: StudioTheme.mutedText)
        ])

        goButton.setTitle("Generate", for: .normal)
        goButton.setImage(UIImage(systemName: "sparkles"), for: .normal)
        goButton.accessibilityLabel = "Generate wallpaper"
        goButton.accessibilityIdentifier = "generateWallpaperButton"
        goButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)

        let save = UIButton(type: .system)
        save.backgroundColor = StudioTheme.elevated
        save.layer.cornerRadius = 18
        save.layer.cornerCurve = .continuous
        save.layer.borderWidth = 1
        save.layer.borderColor = StudioTheme.border.cgColor
        save.tintColor = StudioTheme.lavender
        save.setTitleColor(StudioTheme.lavender, for: .normal)
        save.setTitle("Save", for: .normal)
        save.setImage(UIImage(systemName: "square.and.arrow.down",
                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)),
                      for: .normal)
        save.titleLabel?.font = StudioTheme.font(14, weight: .semibold)
        save.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        save.accessibilityLabel = "Save wallpaper"
        save.accessibilityIdentifier = "saveWallpaperButton"
        save.addTarget(self, action: #selector(saveWallpaper(_:)), for: .touchUpInside)
        let actions = UIStackView(arrangedSubviews: [goButton, save])
        actions.spacing = 12
        save.widthAnchor.constraint(equalToConstant: 92).isActive = true
        actions.heightAnchor.constraint(equalToConstant: 54).isActive = true

        let spinner = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin,
                                               color: .white, padding: 0)
        spinner.isUserInteractionEnabled = false
        spinner.isAccessibilityElement = false
        goButton.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.leadingAnchor.constraint(equalTo: goButton.leadingAnchor, constant: 16),
            spinner.centerYAnchor.constraint(equalTo: goButton.centerYAnchor),
            spinner.widthAnchor.constraint(equalToConstant: 16),
            spinner.heightAnchor.constraint(equalToConstant: 16)
        ])

        let ready = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 9, height: 9), type: .ballScaleMultiple,
                                             color: StudioTheme.purple, padding: 0)
        ready.isAccessibilityElement = false
        let status = StudioTheme.label("Adjust, generate, make it yours.", size: 11,
                                       color: StudioTheme.secondaryText)
        status.adjustsFontSizeToFitWidth = true
        status.minimumScaleFactor = 0.8
        let footer = UIStackView(arrangedSubviews: [ready, status])
        footer.alignment = .center
        footer.spacing = 7
        NSLayoutConstraint.activate([
            ready.widthAnchor.constraint(equalToConstant: 9),
            ready.heightAnchor.constraint(equalToConstant: 9)
        ])

        let controls = UIStackView(arrangedSubviews: [complexityRow, complexitySlider, range, actions, footer])
        controls.axis = .vertical
        controls.spacing = 10
        controls.setCustomSpacing(0, after: complexitySlider)
        controls.setCustomSpacing(18, after: range)
        panel.contentView.addSubview(controls)
        pin(controls, to: panel.contentView, inset: 20)

        complexityPercentage = percent
        slider = complexitySlider
        saveButton = save
        progressView = spinner
        pressMeView = ready
        studioStatus = status
        return panel
    }

    private func pin(_ child: UIView, to parent: UIView, inset: CGFloat = 0) {
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: inset),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -inset),
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: inset),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -inset)
        ])
    }

    private func eyebrow(_ text: String, color: UIColor) -> UILabel {
        let label = StudioTheme.label(text, size: 9, weight: .semibold, color: color)
        label.attributedText = NSAttributedString(string: text, attributes: [.kern: 1.5])
        return label
    }

    // This method reads the files that contains the names of colors and positive words
    // so that we can use them to form the names of the wallpapers.It throws a FileError if 
    // there was an error while reading the file.
    private func readColorWordsFile() throws -> [Color] {
        var colors: [Color] = []
        
        // Find the file path for "colorsDb.txt" in the app's bundle
        guard let filepath = Bundle.main.path(forResource: "colorsDb", ofType: "txt") else {
            throw FileError.fileNotFound("colorsDb.txt")
        }
        
        do {
            // Read the contents of the file
            let contents = try String(contentsOfFile: filepath)
            
            // Split the contents by new lines
            let lines = contents.split(separator: "\r\n")
            
            for line in lines {
                // Split each line by the first space
                let components = line.split(separator: " ", maxSplits: 1).map(String.init)
                
                // Extract the decimal value
                let decimal = Int(components[0]) ?? 0
                
                // Extract the name and capitalize it
                let name = String(components[1].dropFirst(2)).capitalized
                
                // Create a Color object and add it to the colors array
                let color = Color(name: name, decimal: decimal)
                colors.append(color)
            }
            
            return colors
        } catch {
            throw FileError.fileReadError(filepath)
        }
    }
    
    // This method loads the file that contains art words and returns a list of them. If
    // there is an error while reading the file, it throws an error.
    private func readArtWordsFile() throws -> [String] {
        guard let filepath = Bundle.main.path(forResource: "artWords", ofType: "txt") else {
            throw FileError.fileNotFound("artWords.txt")
        }
        
        do {
            let contents = try String(contentsOfFile: filepath)
            // Parse the string by new line
            let lines = contents.split(separator: "\r\n").map(String.init)
            
            return lines
        } catch {
            throw FileError.fileReadError(filepath)
        }
    }
    
    // This method binary search in the color file, colorsDB.txt, for a similar color to the
    // given decimal color.
    private func binarySearchSimilarColor(colors:[Color], colorDecimal:Int) -> Color{
        return binarySearchHelper(colors: colors, low: 0, high: colors.count-1, colorDecimal: colorDecimal)
    }
    
    // This is a helper method that performs the actual binary search algorithm to
    // look for a similar color in the file colorsDB.txt
    private func binarySearchHelper(colors: [Color], low: Int, high: Int, colorDecimal: Int) -> Color {
        // Base case: low index is equal to or exceeds high index
        if low >= high {
            return colors[low]
        }
        
        let med = (low + high) / 2 // Calculate the midpoint
        
        // Check if the color at the midpoint matches the target color
        if colors[med].decimal == colorDecimal {
            return colors[med]
        } else if colors[med].decimal > colorDecimal {
            // If the color is greater than the target color, search the left half
            return binarySearchHelper(colors: colors, low: low, high: med - 1, colorDecimal: colorDecimal)
        } else {
            // If the color is less than the target color, search the right half
            return binarySearchHelper(colors: colors, low: med + 1, high: high, colorDecimal: colorDecimal)
        }
    }
    


    @IBAction func menuItemTap(_ sender: Any) {
        sideMenuController?.revealMenu()
    }

    // Claim the shared busy state synchronously, before asynchronous drawing or saving starts.
    private func beginWork(title: String, status: String) -> Bool {
        guard !isBusy else { return false }
        setBusy(true)
        goButton.setTitle(title, for: .normal)
        studioStatus.text = status
        return true
    }

    private func setBusy(_ busy: Bool) {
        isBusy = busy
        goButton.isEnabled = !busy
        saveButton.isEnabled = !busy
        slider.isEnabled = !busy
        formulaButton.isEnabled = !busy && canvas.currentFormulas != nil
        formulaButton.alpha = formulaButton.isEnabled ? 1 : 0.4
        formulaButton.accessibilityHint = canvas.currentFormulas == nil
            ? "Generate a wallpaper first." : "Shows the red, green, and blue functions for this wallpaper."
        goButton.alpha = busy ? 0.55 : 1
        saveButton.alpha = busy ? 0.4 : 1
        slider.alpha = busy ? 0.45 : 1
        if busy {
            goButton.setImage(nil, for: .normal)
            goButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 38, bottom: 14, right: 10)
            pressMeView.stopAnimating()
            progressView.startAnimating()
        } else {
            goButton.setTitle("Generate", for: .normal)
            goButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
            goButton.setImage(UIImage(systemName: "sparkles"), for: .normal)
            progressView.stopAnimating()
            pressMeView.startAnimating()
            studioStatus.text = hasWallpaper ? "Made with math. Yours to keep." : "Adjust, generate, make it yours."
        }
    }

    @objc func goButtonPressed() {
        guard beginWork(title: "Creating…", status: "Finding your next original…") else { return }
        canvas.generateWallpaper { [weak self] successful in
            guard let self = self else { return }
            if successful {
                self.hasWallpaper = true
                self.introductoryContent.isHidden = true
                self.wallpaperEyebrow.text = "YOUR ORIGINAL WALLPAPER"
                self.canvas.accessibilityValue = "Generated wallpaper"
            }
            self.setBusy(false)
            if !successful { self.showRenderingError() }
        }
    }

    @objc private func showWallpaperFormula() {
        guard !isBusy, presentedViewController == nil,
              let formulas = canvas.currentFormulas else { return }
        let name = [colorAdjective.text, artNoun.text].compactMap { $0 }.joined(separator: " ")
        let controller = WallpaperFormulaVC(formulas: formulas, wallpaperName: name)
        controller.modalPresentationStyle = .pageSheet
        present(controller, animated: true)
    }

    private func showRenderingError() {
        let alert = UIAlertController(title: "Wallpaper unavailable",
                                      message: "We couldn't render this wallpaper. Please try again.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func changeComplexity(_ sender: Any) {
        guard !isBusy else { return }
        let percent = (slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue) * 100
        complexityPercentage.text = String(format: "%.0f%%", percent)
        slider.accessibilityValue = String(format: "%.0f percent", percent)
        canvas.changeDepth(with: Int(slider.value))
    }

    @IBAction func saveWallpaper(_ sender: Any) {
        guard beginWork(title: "Exporting…", status: "Rendering your full-resolution wallpaper…") else { return }
        canvas.exportWallpaper { [weak self] image in
            guard let self = self else { return }
            guard let image = image else {
                self.setBusy(false)
                self.showRenderingError()
                return
            }
            self.goButton.setTitle("Saving…", for: .normal)
            self.studioStatus.text = "Adding your wallpaper to Photos…"
            self.saveImage(image: image, using: self.photoLibrarySaver) { [weak self] in
                self?.setBusy(false)
            }
        }
    }
}

extension CanvasVC: CanvasVDelegate {
    func updateName(averageColor: Int) {
        let color = binarySearchSimilarColor(colors: colors, colorDecimal: averageColor)
        colorAdjective.text = color.name
        artNoun.text = artNames.randomElement() ?? "Wallpaper"
    }
}

/// Dark edges let the controls remain legible even when the generated art is bright.
private final class StudioCanvasShade: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        let gradient = layer as! CAGradientLayer
        gradient.colors = [
            StudioTheme.background.withAlphaComponent(0.78).cgColor,
            StudioTheme.background.withAlphaComponent(0.10).cgColor,
            UIColor.clear.cgColor,
            StudioTheme.background.withAlphaComponent(0.10).cgColor,
            StudioTheme.background.withAlphaComponent(0.78).cgColor
        ]
        gradient.locations = [0, 0.19, 0.43, 0.63, 1]
    }
    required init?(coder: NSCoder) { fatalError("Use init(frame:)") }
}
