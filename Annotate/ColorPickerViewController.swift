import Cocoa
import SwiftUI

class ColorSwatchButton: NSButton {
    var swatchColor: NSColor = .clear {
        didSet { needsDisplay = true }
    }

    var colorIndex: Int = 0
    var isHovered: Bool = false {
        didSet { needsDisplay = true }
    }

    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingArea { removeTrackingArea(existing) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) { isHovered = true }
    override func mouseExited(with event: NSEvent) { isHovered = false }

    override func draw(_ dirtyRect: NSRect) {
        let radius: CGFloat = 10
        let inset: CGFloat = isHovered ? 1 : 3
        let rect = bounds.insetBy(dx: inset, dy: inset)
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        swatchColor.setFill()
        path.fill()

        if isHovered {
            NSColor.white.withAlphaComponent(0.85).setStroke()
            path.lineWidth = 1.5
            path.stroke()
        }
    }
}

class ColorPickerViewController: NSViewController {
    private var keyMonitor: Any?
    private var buttons: [ColorSwatchButton] = []
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.userDefaults = .standard
        super.init(coder: coder)
    }

    override func loadView() {
        let containerSize = NSSize(width: 180, height: 130)
        let containerView = NSView(frame: NSRect(origin: .zero, size: containerSize))

        let visualEffect = NSVisualEffectView(frame: containerView.bounds)
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 14
        visualEffect.layer?.masksToBounds = true
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(visualEffect)

        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .centerX
        stackView.distribution = .fillEqually
        stackView.spacing = 6

        let columnsPerRow = 3
        var buttonIndex = 0

        for chunk in colorPalette.chunked(into: columnsPerRow) {
            let rowStack = NSStackView()
            rowStack.orientation = .horizontal
            rowStack.alignment = .centerY
            rowStack.distribution = .fillEqually
            rowStack.spacing = 6

            for color in chunk {
                let button = ColorSwatchButton(frame: NSRect(x: 0, y: 0, width: 44, height: 44))
                button.swatchColor = color
                button.isBordered = false
                button.bezelStyle = .smallSquare
                button.wantsLayer = true
                button.target = self
                button.action = #selector(colorSwatchClicked(_:))

                buttonIndex += 1
                button.colorIndex = buttonIndex

                buttons.append(button)

                rowStack.addArrangedSubview(button)
            }
            stackView.addArrangedSubview(rowStack)
        }

        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            visualEffect.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            visualEffect.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            visualEffect.topAnchor.constraint(equalTo: containerView.topAnchor),
            visualEffect.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
        ])

        self.view = containerView
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        setupKeyboardMonitoring()
        updateButtonLabels()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        removeKeyboardMonitoring()
    }

    private func setupKeyboardMonitoring() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if let strongSelf = self, strongSelf.handleKeyEvent(event) {
                return nil
            }
            return event
        }
    }

    private func removeKeyboardMonitoring() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }

    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        guard let characters = event.characters, characters.count == 1 else {
            return false
        }

        if let digit = Int(characters), digit >= 1 && digit <= min(9, colorPalette.count) {
            if digit <= buttons.count {
                let button = buttons[digit - 1]
                colorSwatchClicked(button)
                return true
            }
        }

        return false
    }

    private func updateButtonLabels() {
        for button in buttons {
            button.subviews.forEach { if $0 is NSTextField { $0.removeFromSuperview() } }

            let label = NSTextField()
            label.stringValue = "\(button.colorIndex)"
            label.isBezeled = false
            label.drawsBackground = false
            label.isEditable = false
            label.isSelectable = false
            label.textColor = button.swatchColor.contrastingColor()

            label.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
            label.alignment = .center
            label.alphaValue = 0.7

            button.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            ])
        }
    }

    @objc func colorSwatchClicked(_ sender: ColorSwatchButton) {
        guard let appDelegate = AppDelegate.shared else { return }
        let selectedColor = sender.swatchColor

        if let colorData = try? NSKeyedArchiver.archivedData(
            withRootObject: selectedColor, requiringSecureCoding: false)
        {
            userDefaults.set(colorData, forKey: "SelectedColor")
        }

        appDelegate.currentColor = selectedColor
        appDelegate.overlayWindows.values.forEach { $0.currentColor = selectedColor }
        appDelegate.updateStatusBarIcon(with: selectedColor)
        CursorHighlightManager.shared.annotationColor = selectedColor

        if let popover = AppDelegate.shared?.colorPopover {
            popover.performClose(nil)
        } else if let parentWindow = self.view.window {
            parentWindow.close()
        }
    }
}
