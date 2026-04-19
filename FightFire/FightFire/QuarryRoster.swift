//
//  QuarryRoster.swift
//  FightFire
//

import SpriteKit

final class QuarryRoster: VesperStage {
    private let sigilBack = "nav_back"
    private var scrollContainer: SKNode?
    private var scrollOffset: CGFloat = 0
    private var maxScrollOffset: CGFloat = 0
    private var minScrollOffset: CGFloat = 0
    private var lastTouchY: CGFloat = 0
    private var isDragging = false

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        isUserInteractionEnabled = true
    }

    override func laceLayout() {
        removeAllChildren()
        addChild(forgeBackdrop())

        let frame = safeFrame()
        let gauge = gauge()
        let midX = frame.midX
        let topY = frame.maxY
        let baseY = frame.minY
        let width = frame.width
        let height = frame.height

        // Adjust for status bar
        let topInset = view?.safeAreaInsets.top ?? 0
        let adjustedTopY = topY - max(40 * gauge, topInset + 5)

        // Fixed title
        let titleSize = tether(28 * gauge, low: 22, high: 50)
        let title = shimmerLabel(text: "BOSS GATE", size: titleSize, tint: NacrePalette.frost)
        title.position = CGPoint(x: midX, y: adjustedTopY)
        title.zPosition = 100
        addChild(title)

        // Fixed back button
        let backWidth = tether(width * 0.24, low: 100, high: 180)
        let backHeight = tether(40 * gauge, low: 32, high: 52)
        let back = GloamButton(span: CGSize(width: backWidth, height: backHeight), text: "BACK", tint: NacrePalette.ember)
        back.position = CGPoint(x: frame.minX + backWidth * 0.6, y: baseY + backHeight * 0.7)
        back.name = sigilBack
        back.zPosition = 100
        addChild(back)

        // Scrollable boss list container
        let container = SKNode()
        container.position = CGPoint(x: 0, y: 0)
        container.zPosition = 1
        addChild(container)
        self.scrollContainer = container

        let roster = DreadAtlas.roster()
        let cardHeight = tether(height * 0.12, low: 80, high: 140)
        let cardSpacing = tether(12 * gauge, low: 8, high: 16)
        let startY = adjustedTopY - 70 * gauge
        let cardWidth = width * 0.92

        let totalHeight = CGFloat(roster.count) * (cardHeight + cardSpacing)
        let visibleHeight = startY - (baseY + backHeight * 1.5)
        maxScrollOffset = max(0, totalHeight - visibleHeight)
        minScrollOffset = 0

        for (index, dossier) in roster.enumerated() {
            let yPos = startY - CGFloat(index) * (cardHeight + cardSpacing)
            let card = createBossCard(dossier: dossier, size: CGSize(width: cardWidth, height: cardHeight), gauge: gauge)
            card.position = CGPoint(x: midX, y: yPos)
            card.name = "boss_\(dossier.tier)"
            container.addChild(card)
        }
    }

    private func createBossCard(dossier: TyrantDraft, size: CGSize, gauge: CGFloat) -> SKNode {
        let container = SKNode()
        let locked = dossier.tier > (reliquary.summit + 1)
        let cleared = dossier.tier <= reliquary.summit

        // Card background
        let card = SKShapeNode(rectOf: size, cornerRadius: size.height * 0.15)
        card.fillColor = locked ? NacrePalette.onyx.withAlphaComponent(0.5) : NacrePalette.onyx
        card.strokeColor = locked ? NacrePalette.ember.withAlphaComponent(0.3) :
                          cleared ? NacrePalette.verdigris : NacrePalette.glaucous
        card.glowWidth = locked ? 2 : 4
        card.alpha = locked ? 0.6 : 0.95
        container.addChild(card)

        // Boss portrait
        let portraitSize = size.height * 0.7
        let portrait = SKSpriteNode(imageNamed: dossier.visage)
        portrait.size = CGSize(width: portraitSize, height: portraitSize)
        portrait.position = CGPoint(x: -size.width * 0.35, y: 0)
        if locked {
            portrait.color = .gray
            portrait.colorBlendFactor = 0.8
            portrait.alpha = 0.4
        }
        container.addChild(portrait)

        // Info section
        let infoX = -size.width * 0.05
        let textSize = size.height * 0.16

        let nameLabel = SKLabelNode(fontNamed: "Copperplate-Bold")
        nameLabel.text = dossier.sobriquet.uppercased()
        nameLabel.fontSize = textSize
        nameLabel.fontColor = locked ? NacrePalette.frost.withAlphaComponent(0.4) : NacrePalette.frost
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: infoX, y: size.height * 0.28)
        container.addChild(nameLabel)

        let tierLabel = SKLabelNode(fontNamed: "Copperplate-Bold")
        tierLabel.text = "TIER \(dossier.tier)"
        tierLabel.fontSize = textSize * 0.7
        tierLabel.fontColor = locked ? NacrePalette.auric.withAlphaComponent(0.5) : NacrePalette.auric
        tierLabel.horizontalAlignmentMode = .left
        tierLabel.verticalAlignmentMode = .center
        tierLabel.position = CGPoint(x: infoX, y: size.height * 0.15)
        container.addChild(tierLabel)

        // Stats with icons
        let statSize = textSize * 0.75
        let iconSize = size.height * 0.12
        let row1Y = size.height * 0.02
        let row2Y = -size.height * 0.11
        let col1X = infoX
        let col2X = infoX + size.width * 0.22

        // HP Icon
        let hpIcon = SKSpriteNode(imageNamed: "game-heart")
        hpIcon.size = CGSize(width: iconSize, height: iconSize)
        hpIcon.position = CGPoint(x: col1X, y: row1Y)
        hpIcon.alpha = locked ? 0.4 : 1.0
        container.addChild(hpIcon)

        let hpLabel = SKLabelNode(fontNamed: "Copperplate-Bold")
        hpLabel.text = "\(dossier.vitalis)"
        hpLabel.fontSize = statSize
        hpLabel.fontColor = locked ? NacrePalette.frost.withAlphaComponent(0.4) : NacrePalette.frost
        hpLabel.horizontalAlignmentMode = .left
        hpLabel.verticalAlignmentMode = .center
        hpLabel.position = CGPoint(x: col1X + iconSize * 0.7, y: row1Y)
        container.addChild(hpLabel)

        // ATK Icon
        let atkIcon = SKSpriteNode(imageNamed: "game-attack")
        atkIcon.size = CGSize(width: iconSize, height: iconSize)
        atkIcon.position = CGPoint(x: col2X, y: row1Y)
        atkIcon.alpha = locked ? 0.4 : 1.0
        container.addChild(atkIcon)

        let atkLabel = SKLabelNode(fontNamed: "Copperplate-Bold")
        atkLabel.text = "\(dossier.glaive)"
        atkLabel.fontSize = statSize
        atkLabel.fontColor = locked ? NacrePalette.frost.withAlphaComponent(0.4) : NacrePalette.frost
        atkLabel.horizontalAlignmentMode = .left
        atkLabel.verticalAlignmentMode = .center
        atkLabel.position = CGPoint(x: col2X + iconSize * 0.7, y: row1Y)
        container.addChild(atkLabel)

        // SKILL Icon
        let skillIcon = SKSpriteNode(imageNamed: "game-skill")
        skillIcon.size = CGSize(width: iconSize, height: iconSize)
        skillIcon.position = CGPoint(x: col1X, y: row2Y)
        skillIcon.alpha = locked ? 0.4 : 1.0
        container.addChild(skillIcon)

        let skillLabel = SKLabelNode(fontNamed: "Copperplate-Bold")
        skillLabel.text = "\(Int(dossier.arcanum * 100))%"
        skillLabel.fontSize = statSize
        skillLabel.fontColor = locked ? NacrePalette.frost.withAlphaComponent(0.4) : NacrePalette.frost
        skillLabel.horizontalAlignmentMode = .left
        skillLabel.verticalAlignmentMode = .center
        skillLabel.position = CGPoint(x: col1X + iconSize * 0.7, y: row2Y)
        container.addChild(skillLabel)

        // REWARD
        let coinLabel = SKLabelNode(fontNamed: "Copperplate-Bold")
        coinLabel.text = "💰\(dossier.largess)"
        coinLabel.fontSize = statSize
        coinLabel.fontColor = locked ? NacrePalette.auric.withAlphaComponent(0.4) : NacrePalette.auric
        coinLabel.horizontalAlignmentMode = .left
        coinLabel.verticalAlignmentMode = .center
        coinLabel.position = CGPoint(x: col2X, y: row2Y)
        container.addChild(coinLabel)

        // Status indicators
        if locked {
            let lockIcon = SKLabelNode(text: "🔒")
            lockIcon.fontSize = size.height * 0.35
            lockIcon.position = CGPoint(x: size.width * 0.38, y: 0)
            lockIcon.zPosition = 10
            container.addChild(lockIcon)
        } else if cleared {
            let checkIcon = SKLabelNode(text: "✓")
            checkIcon.fontSize = size.height * 0.3
            checkIcon.fontColor = NacrePalette.verdigris
            checkIcon.position = CGPoint(x: size.width * 0.38, y: 0)
            checkIcon.zPosition = 10
            container.addChild(checkIcon)
        } else {
            let arrow = SKLabelNode(text: "▶")
            arrow.fontSize = size.height * 0.25
            arrow.fontColor = NacrePalette.glaucous
            arrow.position = CGPoint(x: size.width * 0.38, y: 0)
            arrow.zPosition = 10
            container.addChild(arrow)

            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.8),
                SKAction.fadeAlpha(to: 1.0, duration: 0.8)
            ])
            arrow.run(SKAction.repeatForever(pulse))
        }

        return container
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchY = touch.location(in: self).y
        isDragging = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentY = touch.location(in: self).y
        let deltaY = currentY - lastTouchY

        if abs(deltaY) > 5 {
            isDragging = true
            scrollOffset = max(minScrollOffset, min(maxScrollOffset, scrollOffset + deltaY))
            scrollContainer?.position.y = scrollOffset
        }

        lastTouchY = currentY
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isDragging else {
            isDragging = false
            return
        }

        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let hits = nodes(at: point)

        if childNode(withName: "popup_lock") != nil {
            if hits.contains(where: { $0.name == "popup_primary" }) {
                childNode(withName: "popup_lock")?.removeFromParent()
            }
            return
        }

        if hits.contains(where: { $0.name == sigilBack }) {
            portcullis?.beckon(.foyer)
            return
        }

        if let bossNode = hits.first(where: { $0.name?.hasPrefix("boss_") == true }),
           let token = bossNode.name?.replacingOccurrences(of: "boss_", with: ""),
           let tier = Int(token) {
            if tier <= reliquary.summit + 1 {
                portcullis?.beckon(.fray(tier))
            } else {
                showLockPopup()
            }
        }
    }

    private func showLockPopup() {
        let popup = GossamerPopup(span: size, title: "LOCKED", body: "Defeat the previous boss to unlock this gate.", primary: "OK", secondary: nil)
        popup.position = CGPoint(x: 0, y: 0)
        popup.name = "popup_lock"
        addChild(popup)
    }
}
