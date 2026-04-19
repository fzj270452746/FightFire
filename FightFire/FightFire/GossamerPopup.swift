//
//  GossamerPopup.swift
//  FightFire
//

import SpriteKit

final class GossamerPopup: SKNode {
    let sigilPrimary = "popup_primary"
    let sigilSecondary = "popup_secondary"

    init(span: CGSize, title: String, body: String, primary: String, secondary: String?) {
        super.init()
        let veil = SKShapeNode(rectOf: span)
        veil.fillColor = NacrePalette.umbra.withAlphaComponent(0.75)
        veil.strokeColor = .clear
        veil.zPosition = 200
        veil.position = CGPoint(x: span.width * 0.5, y: span.height * 0.5)
        addChild(veil)

        let panelSize = CGSize(width: span.width * 0.82, height: span.height * 0.38)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 22)
        panel.fillColor = NacrePalette.onyx
        panel.strokeColor = NacrePalette.glaucous
        panel.glowWidth = 6
        panel.zPosition = 210
        panel.position = CGPoint(x: span.width * 0.5, y: span.height * 0.5)
        addChild(panel)

        let titleLabel = SKLabelNode(fontNamed: "Copperplate-Bold")
        titleLabel.text = title
        titleLabel.fontSize = min(panelSize.height * 0.15, 28)
        titleLabel.fontColor = NacrePalette.frost
        titleLabel.position = CGPoint(x: 0, y: panelSize.height * 0.25)
        titleLabel.verticalAlignmentMode = .center
        titleLabel.preferredMaxLayoutWidth = panelSize.width * 0.85
        titleLabel.numberOfLines = 0
        panel.addChild(titleLabel)

        // Handle multi-line body text
        let bodyLines = body.components(separatedBy: "\n")
        let bodyFontSize = min(panelSize.height * 0.10, 16)
        let lineSpacing: CGFloat = bodyFontSize * 1.3
        let startY = CGFloat(bodyLines.count - 1) * lineSpacing * 0.5

        for (index, line) in bodyLines.enumerated() {
            let bodyLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            bodyLabel.text = line
            bodyLabel.fontSize = bodyFontSize
            bodyLabel.fontColor = NacrePalette.glaucous
            bodyLabel.position = CGPoint(x: 0, y: startY - CGFloat(index) * lineSpacing)
            bodyLabel.verticalAlignmentMode = .center
            bodyLabel.preferredMaxLayoutWidth = panelSize.width * 0.85
            bodyLabel.numberOfLines = 0
            panel.addChild(bodyLabel)
        }

        let buttonSpan = CGSize(width: panelSize.width * 0.35, height: panelSize.height * 0.18)
        let primaryButton = GloamButton(span: buttonSpan, text: primary, tint: NacrePalette.verdigris)
        primaryButton.position = CGPoint(x: 0, y: -panelSize.height * 0.28)
        primaryButton.name = sigilPrimary
        panel.addChild(primaryButton)

        if let secondary = secondary {
            let secondaryButton = GloamButton(span: buttonSpan, text: secondary, tint: NacrePalette.ember)
            secondaryButton.position = CGPoint(x: -buttonSpan.width * 0.7, y: -panelSize.height * 0.28)
            secondaryButton.name = sigilSecondary
            panel.addChild(secondaryButton)
            primaryButton.position = CGPoint(x: buttonSpan.width * 0.7, y: -panelSize.height * 0.28)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
