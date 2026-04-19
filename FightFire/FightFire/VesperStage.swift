//
//  VesperStage.swift
//  FightFire
//

import SpriteKit

class VesperStage: SKScene {
    weak var portcullis: LiminalGate?
    let reliquary: ReliquaryCodex

    init(size: CGSize, reliquary: ReliquaryCodex) {
        self.reliquary = reliquary
        super.init(size: size)
        backgroundColor = NacrePalette.umbra
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        laceLayout()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        laceLayout()
    }

    func safeFrame() -> CGRect {
        let insets = view?.safeAreaInsets ?? .zero
        let width = size.width - insets.left - insets.right
        let height = size.height - insets.top - insets.bottom

        // For iPad compatibility, ensure proper aspect ratio handling
        let maxWidth: CGFloat = 600
        let actualWidth = min(width, maxWidth)
        let offsetX = (width - actualWidth) / 2.0

        return CGRect(
            x: insets.left + offsetX,
            y: insets.bottom,
            width: actualWidth,
            height: height
        )
    }

    func gauge() -> CGFloat {
        let frame = safeFrame()
        let minDim = min(frame.width, frame.height)
        let raw = minDim / 390.0
        return max(0.75, min(1.5, raw))
    }

    func tether(_ value: CGFloat, low: CGFloat, high: CGFloat) -> CGFloat {
        return max(low, min(high, value))
    }

    func laceLayout() {
        // override in subclass
    }

    func forgeBackdrop() -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: "boss-game-back")
        node.size = size
        node.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        node.zPosition = -10

        // Dark overlay to reduce brightness and improve readability
        let overlay = SKSpriteNode(color: SKColor(red: 0, green: 0, blue: 0, alpha: 0.62), size: size)
        overlay.position = .zero
        overlay.zPosition = 1
        node.addChild(overlay)

        return node
    }

    func shimmerLabel(text: String, size: CGFloat, tint: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Copperplate-Bold")
        label.text = text
        label.fontSize = size
        label.fontColor = tint
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
}
