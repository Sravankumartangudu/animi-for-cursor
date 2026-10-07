import Cocoa
import WebKit

/// Transparent layer above the web view that owns all mouse handling:
/// drag to move, click to boop, double-click to cheer, right-click for the menu.
final class OverlayView: NSView {
    weak var app: AppDelegate?
    private var downMouse = NSPoint.zero
    private var downOrigin = NSPoint.zero
    private var moved = false
    private(set) var isHeld = false

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDown(with event: NSEvent) {
        downMouse = NSEvent.mouseLocation
        downOrigin = window?.frame.origin ?? .zero
        moved = false
        isHeld = true
        if event.clickCount == 2 { app?.js("cheer()") }
    }

    override func mouseDragged(with event: NSEvent) {
        let m = NSEvent.mouseLocation
        let dx = m.x - downMouse.x, dy = m.y - downMouse.y
        if !moved {
            guard hypot(dx, dy) >= 3 else { return }
            moved = true
            app?.js("setDrag(true)")
        }
        window?.setFrameOrigin(NSPoint(x: downOrigin.x + dx, y: downOrigin.y + dy))
    }

    override func mouseUp(with event: NSEvent) {
        isHeld = false
        if moved {
            app?.js("setDrag(false)")
            app?.savePosition()
        } else if event.clickCount == 1 {
            app?.js("boop()")
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let menu = app?.menu else { return }
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var window: NSPanel!
    private var web: WKWebView!
    let menu = NSMenu()
    private var statusItem: NSStatusItem!
    private var isMenuOpen = false
    private var overlay: OverlayView!
    private var timer: Timer?
    private var lastSent = ""
    private var velocity = CGVector.zero

    private var follow: Bool {
        get { defaults.object(forKey: "follow") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "follow") }
    }

    private let sizes: [(name: String, width: CGFloat)] = [("Tiny", 80), ("Small", 110), ("Medium", 150), ("Large", 210)]
    private let characters: [(key: String, name: String)] = [
        ("bot", "🤖  Bolt — robot"), ("cat", "🐱  Mochi — cat"), ("ghost", "👻  Boo — ghost"),
        ("slime", "💧  Jelly — slime"), ("penguin", "🐧  Pip — penguin"), ("panda", "🐼  Bao — panda"),
    ]
    private let heroes: [(key: String, name: String)] = [
        ("tether", "🪝  Tether — grapple swinger"), ("cirrus", "☁️  Cirrus — caped flyer"),
        ("volta", "⚡  Volta — storm staff"), ("gust", "💨  Gust — speedster"),
        ("rumble", "⛰️  Rumble — ground smasher"), ("aegis", "🛡️  Aegis — shield thrower"),
    ]
    /// Unofficial fan art, listed after a separator in the Heroes menu.
    private let fanHeroes: [(key: String, name: String)] = [
        ("spidey", "🕷️  Spider-Man — web swing"), ("ironman", "🔥  Iron Man — thruster flight"),
        ("superman", "🦸  Superman — flight"), ("batman", "🦇  Batman — cape glide"),
        ("hulk", "💪  Hulk — smash"), ("cap", "⭐  Captain America — shield throw"),
        ("strange", "🔮  Doctor Strange — spell circles"), ("antman", "🐜  Ant-Man — shrink & sprint"),
    ]
    private let defaults = UserDefaults.standard

    private var width: CGFloat {
        let w = defaults.double(forKey: "width")
        return w > 0 ? CGFloat(w) : 110
    }

    private var character: String {
        get { defaults.string(forKey: "character") ?? "bot" }
        set { defaults.set(newValue, forKey: "character") }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NexusBeacon.start(name: "Animi")
        let size = NSSize(width: width, height: width * 1.2)
        let frame = NSRect(origin: savedOrigin(for: size) ?? defaultOrigin(for: size), size: size)

        window = NSPanel(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel],
                         backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.hidesOnDeactivate = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]

        let content = NSView(frame: NSRect(origin: .zero, size: size))
        let config = WKWebViewConfiguration()
        config.userContentController.addUserScript(WKUserScript(
            source: "window.initialChar = '\(character)';", injectionTime: .atDocumentStart, forMainFrameOnly: true))
        web = WKWebView(frame: content.bounds, configuration: config)
        web.setValue(false, forKey: "drawsBackground")
        web.autoresizingMask = [.width, .height]
        overlay = OverlayView(frame: content.bounds)
        overlay.autoresizingMask = [.width, .height]
        overlay.app = self
        content.addSubview(web)
        content.addSubview(overlay)
        window.contentView = content

        loadCharacter()
        menu.delegate = self
        buildMenu()
        // Menu bar icon that opens the same menu as right-clicking the character.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            let icon = Bundle.main.image(forResource: "AppIcon") ?? NSImage(systemSymbolName: "face.smiling", accessibilityDescription: nil)
            icon?.size = NSSize(width: 18, height: 18)
            button.image = icon
            button.toolTip = "Animi"
        }
        statusItem.menu = menu
        window.orderFrontRegardless()

        let t = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func loadCharacter() {
        let exeDir = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath().deletingLastPathComponent()
        let candidates = [Bundle.main.url(forResource: "animi", withExtension: "html"),
                          exeDir.appendingPathComponent("animi.html")]
        guard let url = candidates.compactMap({ $0 }).first(where: { FileManager.default.fileExists(atPath: $0.path) }),
              let html = try? String(contentsOf: url, encoding: .utf8) else {
            NSLog("Animi: animi.html not found")
            return
        }
        web.loadHTMLString(html, baseURL: nil)
    }

    private func tick() {
        let m = NSEvent.mouseLocation
        if follow && !overlay.isHeld && !isMenuOpen { fly(toward: m) } else { velocity = .zero }

        // Tell the character where the cursor is (svg viewBox units, y down) and how fast it's moving.
        let f = window.frame
        let s = f.width / 200  // svg viewBox is 200 wide
        let msg = String(format: "look(%.0f,%.0f,%.1f,%.1f,%.3f)",
                         (m.x - f.minX) / s, (f.maxY - m.y) / s, velocity.dx, -velocity.dy, s)
        guard msg != lastSent else { return }
        lastSent = msg
        js(msg)
    }

    /// Glides toward the cursor, stopping a little short so it never sits under the pointer
    /// (that keeps it clickable and out of the way). It never runs away, so you can still grab it.
    private func fly(toward m: NSPoint) {
        var f = window.frame
        let c = NSPoint(x: f.midX, y: f.midY)
        let ax = c.x - m.x, ay = c.y - m.y
        let d = hypot(ax, ay)
        let standoff = max(f.width * 0.9, 90)

        var want = CGVector.zero
        if d > standoff + 4 {
            let target = NSPoint(x: m.x + ax / d * standoff, y: m.y + ay / d * standoff)
            want = CGVector(dx: (target.x - c.x) * 0.07, dy: (target.y - c.y) * 0.07)
            let speed = hypot(want.dx, want.dy), maxSpeed: CGFloat = 16
            if speed > maxSpeed { want = CGVector(dx: want.dx * maxSpeed / speed, dy: want.dy * maxSpeed / speed) }
        }
        // Ease the velocity for a floaty, inertial feel.
        velocity.dx += (want.dx - velocity.dx) * 0.12
        velocity.dy += (want.dy - velocity.dy) * 0.12
        guard hypot(velocity.dx, velocity.dy) > 0.05 else { velocity = .zero; return }

        f.origin.x += velocity.dx
        f.origin.y += velocity.dy
        let screen = NSScreen.screens.first(where: { $0.frame.contains(m) }) ?? NSScreen.main
        if let vf = screen?.visibleFrame {
            f.origin.x = min(max(f.origin.x, vf.minX), vf.maxX - f.width)
            f.origin.y = min(max(f.origin.y, vf.minY), vf.maxY - f.height)
        }
        window.setFrameOrigin(f.origin)
    }

    func js(_ code: String) {
        web.evaluateJavaScript(code, completionHandler: nil)
    }

    // MARK: Menu

    // Hold still while the menu is open (from the character or the menu bar)
    // so the character doesn't chase the cursor as it moves toward an item.
    func menuWillOpen(_ menu: NSMenu) { isMenuOpen = true }
    func menuDidClose(_ menu: NSMenu) { isMenuOpen = false }

    private func buildMenu() {
        menu.removeAllItems()
        for (title, sections) in [("Character", [characters]), ("Heroes", [heroes, fanHeroes])] {
            let groupItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            let groupMenu = NSMenu()
            for (i, list) in sections.enumerated() {
                if i > 0 { groupMenu.addItem(.separator()) }
                for c in list {
                    let item = NSMenuItem(title: c.name, action: #selector(setCharacter(_:)), keyEquivalent: "")
                    item.representedObject = c.key
                    item.target = self
                    item.state = c.key == character ? .on : .off
                    groupMenu.addItem(item)
                }
            }
            groupItem.submenu = groupMenu
            menu.addItem(groupItem)
        }

        let sizeItem = NSMenuItem(title: "Size", action: nil, keyEquivalent: "")
        let sizeMenu = NSMenu()
        for (i, s) in sizes.enumerated() {
            let item = NSMenuItem(title: s.name, action: #selector(setSize(_:)), keyEquivalent: "")
            item.tag = i
            item.target = self
            item.state = abs(s.width - width) < 0.5 ? .on : .off
            sizeMenu.addItem(item)
        }
        sizeItem.submenu = sizeMenu
        menu.addItem(sizeItem)

        let followItem = NSMenuItem(title: "Follow Cursor", action: #selector(toggleFollow), keyEquivalent: "")
        followItem.target = self
        followItem.state = follow ? .on : .off
        menu.addItem(followItem)

        let cheer = NSMenuItem(title: "Say Hi ♥", action: #selector(sayHi), keyEquivalent: "")
        cheer.target = self
        menu.addItem(cheer)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Animi", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    @objc private func sayHi() { js("cheer()") }

    @objc private func setCharacter(_ sender: NSMenuItem) {
        guard let key = sender.representedObject as? String else { return }
        character = key
        js("setCharacter('\(character)'); cheer()")
        buildMenu()
    }

    @objc private func toggleFollow() {
        follow.toggle()
        if !follow { savePosition() }
        buildMenu()
    }

    @objc private func setSize(_ sender: NSMenuItem) {
        let w = sizes[sender.tag].width
        defaults.set(Double(w), forKey: "width")
        let old = window.frame
        let newFrame = NSRect(x: old.midX - w / 2, y: old.minY, width: w, height: w * 1.2)
        window.setFrame(newFrame, display: true, animate: true)
        savePosition()
        buildMenu()
    }

    // MARK: Position persistence

    func savePosition() {
        defaults.set(Double(window.frame.minX), forKey: "x")
        defaults.set(Double(window.frame.minY), forKey: "y")
    }

    private func savedOrigin(for size: NSSize) -> NSPoint? {
        guard defaults.object(forKey: "x") != nil else { return nil }
        let p = NSPoint(x: defaults.double(forKey: "x"), y: defaults.double(forKey: "y"))
        let rect = NSRect(origin: p, size: size)
        return NSScreen.screens.contains(where: { $0.frame.intersects(rect) }) ? p : nil
    }

    private func defaultOrigin(for size: NSSize) -> NSPoint {
        let vf = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        return NSPoint(x: vf.maxX - size.width - 40, y: vf.minY + 40)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
