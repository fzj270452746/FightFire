//
//  UmbralForge.swift
//  FightFire
//

import SpriteKit

final class UmbralForge: VesperStage {
    private let sigilBack = "nav_back"
    private let sigilSpin = "forge_spin"

    private var spool: SpoolPylon?
    private var coinSigil: SKLabelNode?
    private var stasis = false

    // Stat card labels
    private var atkValueLabel: SKLabelNode?
    private var hpValueLabel: SKLabelNode?
    private var shieldValueLabel: SKLabelNode?
    private var skillValueLabel: SKLabelNode?

    // Stat card containers for animation
    private var atkCard: SKNode?
    private var hpCard: SKNode?
    private var shieldCard: SKNode?
    private var skillCard: SKNode?

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

        // Title
        let titleSize = tether(34 * gauge, low: 24, high: 60)
        let title = shimmerLabel(text: "RUNE FORGE", size: titleSize, tint: NacrePalette.frost)
        title.position = CGPoint(x: midX, y: topY - 36 * gauge)
        addChild(title)

        // Back button
        let backWidth = tether(width * 0.24, low: 120, high: 220)
        let backHeight = tether(44 * gauge, low: 36, high: 60)
        let back = GloamButton(span: CGSize(width: backWidth, height: backHeight), text: "BACK", tint: NacrePalette.ember)
        back.position = CGPoint(x: frame.minX + backWidth * 0.55, y: baseY + backHeight * 0.8)
        back.name = sigilBack
        addChild(back)

        // Coins display
        let coinSize = tether(16 * gauge, low: 12, high: 24)
        let coin = shimmerLabel(text: "COINS: \(reliquary.hoard)", size: coinSize, tint: NacrePalette.auric)
        coin.horizontalAlignmentMode = .right
        coin.position = CGPoint(x: frame.maxX - 16 * gauge, y: back.position.y)
        addChild(coin)
        coinSigil = coin

        // === STAT CARDS (2x2 grid above slot machine) ===
        let cardW = tether(width * 0.42, low: 140, high: 240)
        let cardH = tether(height * 0.11, low: 60, high: 100)
        let cardGap: CGFloat = 12 * gauge
        let cardsY = topY - 120 * gauge

        let leftX = midX - cardW * 0.5 - cardGap * 0.5
        let rightX = midX + cardW * 0.5 + cardGap * 0.5
        let topRow = cardsY
        let bottomRow = cardsY - cardH - cardGap

        // ATK card (top-left)
        let atkCard = buildStatCard(
            size: CGSize(width: cardW, height: cardH),
            icon: "game-attack",
            label: "ATK",
            value: "\(reliquary.glaive)",
            tint: NacrePalette.ember,
            gauge: gauge
        )
        atkCard.position = CGPoint(x: leftX, y: topRow)
        addChild(atkCard)
        self.atkCard = atkCard
        self.atkValueLabel = atkCard.childNode(withName: "value") as? SKLabelNode

        // HP card (top-right)
        let hpCard = buildStatCard(
            size: CGSize(width: cardW, height: cardH),
            icon: "game-heart",
            label: "HP",
            value: "\(reliquary.vitalis)",
            tint: NacrePalette.verdigris,
            gauge: gauge
        )
        hpCard.position = CGPoint(x: rightX, y: topRow)
        addChild(hpCard)
        self.hpCard = hpCard
        self.hpValueLabel = hpCard.childNode(withName: "value") as? SKLabelNode

        // SHIELD card (bottom-left)
        let shieldCard = buildStatCard(
            size: CGSize(width: cardW, height: cardH),
            icon: "game-defense",
            label: "SHIELD+",
            value: "\(reliquary.pavisGain)",
            tint: NacrePalette.glaucous,
            gauge: gauge
        )
        shieldCard.position = CGPoint(x: leftX, y: bottomRow)
        addChild(shieldCard)
        self.shieldCard = shieldCard
        self.shieldValueLabel = shieldCard.childNode(withName: "value") as? SKLabelNode

        // SKILL card (bottom-right)
        let skillCard = buildStatCard(
            size: CGSize(width: cardW, height: cardH),
            icon: "game-skill",
            label: "SKILL",
            value: "x\(String(format: "%.1f", reliquary.arcanum))",
            tint: NacrePalette.auric,
            gauge: gauge
        )
        skillCard.position = CGPoint(x: rightX, y: bottomRow)
        addChild(skillCard)
        self.skillCard = skillCard
        self.skillValueLabel = skillCard.childNode(withName: "value") as? SKLabelNode

        // === SLOT MACHINE (center) ===
        let slotWidth = tether(width * 0.82, low: 260, high: 500)
        let slotHeight = tether(height * 0.13, low: 70, high: 110)
        let slotSpan = CGSize(width: slotWidth, height: slotHeight)
        let spool = SpoolPylon(timbre: .hud, span: slotSpan)
        spool.position = CGPoint(x: midX, y: baseY + height * 0.50)
        addChild(spool)
        self.spool = spool

        // Spin button
        let spinWidth = tether(width * 0.60, low: 220, high: 420)
        let spinHeight = tether(56 * gauge, low: 44, high: 80)
        let spin = GloamButton(span: CGSize(width: spinWidth, height: spinHeight), text: "SPIN (10 COINS)", tint: NacrePalette.glaucous)
        spin.position = CGPoint(x: midX, y: baseY + height * 0.32)
        spin.name = sigilSpin
        addChild(spin)

        // Tip text
        let tipSize = tether(12 * gauge, low: 10, high: 18)
        let tip = shimmerLabel(text: "Match 3 symbols to upgrade the corresponding stat", size: tipSize, tint: NacrePalette.frost)
        tip.position = CGPoint(x: midX, y: baseY + height * 0.20)
        tip.alpha = 0.65
        addChild(tip)
    }

    // MARK: - Build Stat Card

    private func buildStatCard(size: CGSize, icon: String, label: String, value: String, tint: SKColor, gauge: CGFloat) -> SKNode {
        let container = SKNode()

        // Card background with bevel
        let bevel = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: size.height + 4), cornerRadius: 12)
        bevel.fillColor = tint.withAlphaComponent(0.25)
        bevel.strokeColor = .clear
        bevel.zPosition = 0
        container.addChild(bevel)

        let bg = SKShapeNode(rectOf: size, cornerRadius: 10)
        bg.fillColor = SKColor(red: 0.08, green: 0.09, blue: 0.12, alpha: 0.95)
        bg.strokeColor = tint
        bg.lineWidth = 2.5
        bg.glowWidth = 8
        bg.zPosition = 1
        container.addChild(bg)

        // Icon (left side)
        let iconSize: CGFloat = size.height * 0.50
        let iconSprite = SKSpriteNode(imageNamed: icon)
        iconSprite.size = CGSize(width: iconSize, height: iconSize)
        iconSprite.position = CGPoint(x: -size.width * 0.32, y: 0)
        iconSprite.zPosition = 2
        container.addChild(iconSprite)

        // Label (top-center-right)
        let labelSize = tether(13 * gauge, low: 11, high: 18)
        let labelNode = shimmerLabel(text: label, size: labelSize, tint: tint)
        labelNode.position = CGPoint(x: size.width * 0.12, y: size.height * 0.18)
        labelNode.horizontalAlignmentMode = .center
        labelNode.zPosition = 2
        container.addChild(labelNode)

        // Value (bottom-center-right, larger)
        let valueSize = tether(22 * gauge, low: 18, high: 32)
        let valueNode = shimmerLabel(text: value, size: valueSize, tint: NacrePalette.frost)
        valueNode.position = CGPoint(x: size.width * 0.12, y: -size.height * 0.16)
        valueNode.horizontalAlignmentMode = .center
        valueNode.name = "value"
        valueNode.zPosition = 2
        container.addChild(valueNode)

        return container
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let hits = nodes(at: point)
        if childNode(withName: "popup_forge") != nil {
            if hits.contains(where: { $0.name == "popup_primary" }) {
                childNode(withName: "popup_forge")?.removeFromParent()
            }
            return
        }
        if hits.contains(where: { $0.name == sigilBack }) {
            portcullis?.beckon(.foyer)
            return
        }
        if hits.contains(where: { $0.name == sigilSpin }) {
            attemptWhorl()
            return
        }
    }

    // MARK: - Spin Logic

    private func attemptWhorl() {
        guard !stasis else { return }
        guard reliquary.siphon(10) else {
            let popup = GossamerPopup(span: size, title: "NEED COINS", body: "Earn more coins by defeating bosses.", primary: "OK", secondary: nil)
            popup.name = "popup_forge"
            addChild(popup)
            return
        }
        stasis = true
        coinSigil?.text = "COINS: \(reliquary.hoard)"

        spool?.gyrate { [weak self] tally in
            guard let self = self else { return }

            if tally.triune, let crest = tally.crest {
                switch crest {
                case .mordant:
                    self.reliquary.temperGlaive()
                    self.animateUpgrade(card: self.atkCard, label: self.atkValueLabel, newValue: "\(self.reliquary.glaive)")
                case .lenitive:
                    self.reliquary.temperVitalis()
                    self.animateUpgrade(card: self.hpCard, label: self.hpValueLabel, newValue: "\(self.reliquary.vitalis)")
                case .pavis:
                    self.reliquary.temperPavis()
                    self.animateUpgrade(card: self.shieldCard, label: self.shieldValueLabel, newValue: "\(self.reliquary.pavisGain)")
                case .arcanum:
                    self.reliquary.temperArcanum()
                    self.animateUpgrade(card: self.skillCard, label: self.skillValueLabel, newValue: "x\(String(format: "%.1f", self.reliquary.arcanum))")
                }
            }

            self.stasis = false
        }
    }

    // MARK: - Upgrade Animation

    private func animateUpgrade(card: SKNode?, label: SKLabelNode?, newValue: String) {
        guard let card = card, let label = label else { return }

        // Flash card border
        let flash1 = SKAction.run {
            if let bg = card.children.first(where: { $0 is SKShapeNode && $0.zPosition == 1 }) as? SKShapeNode {
                bg.glowWidth = 20
            }
        }
        let wait1 = SKAction.wait(forDuration: 0.15)
        let flash2 = SKAction.run {
            if let bg = card.children.first(where: { $0 is SKShapeNode && $0.zPosition == 1 }) as? SKShapeNode {
                bg.glowWidth = 8
            }
        }
        let wait2 = SKAction.wait(forDuration: 0.15)
        let flashSeq = SKAction.sequence([flash1, wait1, flash2, wait2])
        card.run(SKAction.repeat(flashSeq, count: 3))

        // Scale pulse on card
        let scaleUp = SKAction.scale(to: 1.12, duration: 0.2)
        scaleUp.timingMode = .easeOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        scaleDown.timingMode = .easeInEaseOut
        card.run(SKAction.sequence([scaleUp, scaleDown]))

        // Update label with scale animation
        let labelScale = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.2),
            SKAction.run { label.text = newValue },
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        label.run(labelScale)

        // Particle burst
        if let camera = card.parent {
            EtherealMote.conjure(archetype: .sparkle, at: card.position, in: camera)
        }
    }
}
