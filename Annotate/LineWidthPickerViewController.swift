import Cocoa

class LineWidthPickerViewController: NSViewController {
    private var slider: NSSlider!
    private var valueLabel: NSTextField!
    private var previewView: LineWidthPreviewView!
    private let userDefaults: UserDefaults

    let minLineWidth: CGFloat = 0.5
    let maxLineWidth: CGFloat = 20.0
    let ratio: CGFloat = 0.25

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.userDefaults = .standard
        super.init(coder: coder)
    }
    
    override func loadView() {
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 140))

        let visualEffect = NSVisualEffectView(frame: containerView.bounds)
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 14
        visualEffect.layer?.masksToBounds = true
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(visualEffect)

        let titleLabel = NSTextField(labelWithString: "Line Width")
        titleLabel.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        titleLabel.alignment = .center
        titleLabel.textColor = .labelColor
        titleLabel.alphaValue = 0.65

        valueLabel = NSTextField(labelWithString: "")
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        valueLabel.alignment = .center
        valueLabel.textColor = .secondaryLabelColor

        previewView = LineWidthPreviewView(frame: NSRect(x: 0, y: 0, width: 270, height: 44))
        previewView.lineWidth = getCurrentLineWidth()
        previewView.wantsLayer = true
        previewView.layer?.cornerRadius = 8
        previewView.layer?.masksToBounds = true

        slider = NSSlider(frame: NSRect(x: 0, y: 0, width: 270, height: 20))
        slider.minValue = Double(minLineWidth)
        slider.maxValue = Double(maxLineWidth)
        slider.numberOfTickMarks = 0
        slider.allowsTickMarkValuesOnly = false
        slider.target = self
        slider.action = #selector(sliderValueChanged(_:))

        let currentLineWidth = getCurrentLineWidth()
        slider.doubleValue = Double(currentLineWidth)
        updateValueLabel(currentLineWidth)

        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        containerView.addSubview(previewView)
        containerView.addSubview(slider)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        previewView.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            visualEffect.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            visualEffect.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            visualEffect.topAnchor.constraint(equalTo: containerView.topAnchor),
            visualEffect.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            previewView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            previewView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            previewView.widthAnchor.constraint(equalToConstant: 270),
            previewView.heightAnchor.constraint(equalToConstant: 44),

            slider.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 10),
            slider.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            slider.widthAnchor.constraint(equalToConstant: 270),

            valueLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 6),
            valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
        ])

        self.view = containerView
    }
    
    private func getCurrentLineWidth() -> CGFloat {
        let savedWidth = userDefaults.object(forKey: UserDefaults.lineWidthKey) as? Double ?? 3.0
        return CGFloat(savedWidth)
    }
    
    @objc func sliderValueChanged(_ sender: NSSlider) {
        let rawValue = CGFloat(sender.doubleValue)
        let adjustedValue = round(rawValue / ratio) * ratio

        let lineWidth = max(minLineWidth, min(maxLineWidth, adjustedValue))

        updateValueLabel(lineWidth)
        previewView.lineWidth = lineWidth

        userDefaults.set(Double(lineWidth), forKey: UserDefaults.lineWidthKey)

        AppDelegate.shared?.overlayWindows.values.forEach { window in
            window.overlayView.currentLineWidth = lineWidth
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        previewView.needsDisplay = true
    }
    
    private func updateValueLabel(_ lineWidth: CGFloat) {
        valueLabel.stringValue = String(format: "%.2f px", lineWidth)
    }
}

class LineWidthPreviewView: NSView {
    var lineWidth: CGFloat = 3.0 {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let color = AppDelegate.shared?.currentColor ?? NSColor.systemRed
        let radius: CGFloat = 8

        let bgPath = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius)
        let backgroundColor = color.contrastingColor().withAlphaComponent(0.55)
        backgroundColor.setFill()
        bgPath.fill()

        let path = NSBezierPath()
        let startPoint = NSPoint(x: 24, y: bounds.midY)
        let endPoint = NSPoint(x: bounds.width - 24, y: bounds.midY)

        path.move(to: startPoint)
        path.line(to: endPoint)

        color.setStroke()
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.stroke()

        let stroke = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), xRadius: radius, yRadius: radius)
        NSColor.separatorColor.withAlphaComponent(0.5).setStroke()
        stroke.lineWidth = 1
        stroke.stroke()
    }
}
