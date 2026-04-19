//
//  GloamButton.swift
//  FightFire
//

import SpriteKit

final class GloamButton: SKNode {
    private let placard: SKShapeNode
    private let legend: SKLabelNode
    private let shimmer: SKShapeNode

    init(span: CGSize, text: String, tint: SKColor) {
        self.placard = SKShapeNode(rectOf: span, cornerRadius: span.height * 0.45)
        self.legend = SKLabelNode(fontNamed: "Copperplate-Bold")
        self.shimmer = SKShapeNode(rectOf: span, cornerRadius: span.height * 0.45)
        super.init()

        // Background with gradient effect
        placard.fillColor = tint
        placard.strokeColor = tint.withAlphaComponent(0.9)
        placard.glowWidth = 8
        placard.alpha = 0.95
        addChild(placard)

        // Shimmer overlay
        shimmer.fillColor = .white
        shimmer.strokeColor = .clear
        shimmer.alpha = 0.15
        shimmer.zPosition = 1
        addChild(shimmer)

        // Text
        legend.text = text
        legend.fontSize = span.height * 0.42
        legend.fontColor = NacrePalette.frost
        legend.verticalAlignmentMode = .center
        legend.zPosition = 2

        addChild(legend)

        // Start breathing animation
        startBreathingAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func retitle(_ text: String) {
        legend.text = text
    }

    func gleam(_ tint: SKColor) {
        placard.fillColor = tint
        placard.strokeColor = tint.withAlphaComponent(0.9)
    }

    private func startBreathingAnimation() {
        let breathe = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.95, duration: 1.5),
            SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        ])
        placard.run(SKAction.repeatForever(breathe))

        let shimmerAnim = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.05, duration: 2.0),
            SKAction.fadeAlpha(to: 0.2, duration: 2.0)
        ])
        shimmer.run(SKAction.repeatForever(shimmerAnim))
    }

    func pressEffect() {
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        run(sequence)
    }
}
