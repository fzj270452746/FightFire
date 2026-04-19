//
//  SinewBar.swift
//  FightFire
//

import SpriteKit

final class SinewBar: SKNode {
    private let carapace: SKShapeNode
    private let infusion: SKSpriteNode
    private let girth: CGFloat
    private let stature: CGFloat

    init(span: CGFloat, height: CGFloat, tint: SKColor, back: SKColor) {
        self.girth = span
        self.stature = height
        self.carapace = SKShapeNode(rectOf: CGSize(width: span, height: height), cornerRadius: height * 0.45)
        self.infusion = SKSpriteNode(color: tint, size: CGSize(width: span, height: height))
        super.init()
        carapace.fillColor = back
        carapace.strokeColor = back
        carapace.alpha = 0.65
        infusion.anchorPoint = CGPoint(x: 0, y: 0.5)
        infusion.position = CGPoint(x: -span * 0.5, y: 0)
        infusion.alpha = 0.95
        addChild(carapace)
        addChild(infusion)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drip(_ ratio: CGFloat) {
        let clamped = max(0.0, min(1.0, ratio))
        infusion.xScale = clamped
    }
}
