//
//  VellumFoyer.swift
//  FightFire
//

import SpriteKit

final class VellumFoyer: VesperStage {

    // ── Navigation sigils
    private let sigilStart   = "nav_roster"
    private let sigilForge   = "nav_forge"
    private let sigilWyrm    = "nav_wyrm"
    private let sigilBet     = "nav_bet"
    private let sigilReflex  = "nav_reflex"
    private let sigilAchieve = "nav_achieve"
    private let sigilGuide   = "nav_guide"

    // ── Achievement scroll
    private var achievementScrollNode:   SKNode?
    private var achievementScrollStart:  CGFloat = 0
    private var achievementScrollOffset: CGFloat = 0
    private var achievementScrollMin:    CGFloat = 0
    private var achievementScrollMax:    CGFloat = 0

    override func didMove(to view: SKView) {
        super.didMove(to: view)          // calls laceLayout → addFloatingMahjongTiles
        isUserInteractionEnabled = true
    }

    // MARK: - Layout

    override func laceLayout() {
        removeAllChildren()
        addChild(forgeBackdrop())

        let frame  = safeFrame()
        let g      = gauge()
        let midX   = frame.midX
        let topY   = frame.maxY
        let baseY  = frame.minY
        let w      = frame.width
        let h      = frame.height

        // ── Halos
        let halo1 = TinctureForge.halo(radius: w * 0.5, tint: NacrePalette.glaucous, alpha: 0.08)
        halo1.position = CGPoint(x: midX, y: baseY + h * 0.72)
        addChild(halo1)
        let halo2 = TinctureForge.halo(radius: w * 0.35, tint: NacrePalette.ember, alpha: 0.06)
        halo2.position = CGPoint(x: midX, y: baseY + h * 0.72)
        addChild(halo2)

        // ── Title  (safeAreaInsets 首次渲染可能为 0，强制最小值覆盖灵动岛)
        let safeTop    = max(view?.safeAreaInsets.top ?? 0, 54.0)
        let titleBandY = size.height - safeTop - 22 * g 

        let titleSize = tether(30 * g, low: 22, high: 48)
        let title = shimmerLabel(text: "FIGHT SLOT FIRE", size: titleSize, tint: NacrePalette.frost)
        title.position = CGPoint(x: midX, y: titleBandY)
        addChild(title)
        title.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.04, duration: 1.8),
            SKAction.scale(to: 1.0,  duration: 1.8)
        ])))

        let subtitleSize = tether(13 * g, low: 10, high: 18)
        let subtitle = shimmerLabel(text: "BOSS DUEL", size: subtitleSize, tint: NacrePalette.glaucous)
        subtitle.position = CGPoint(x: midX, y: titleBandY - 24 * g)
        addChild(subtitle)

        // ── Stats row (coins left | pill center | streak right)
        let statsY   = titleBandY - 50 * g
        let statSize = tether(12 * g, low: 10, high: 17)

        let coinText = shimmerLabel(text: "💰 \(reliquary.hoard)", size: statSize, tint: NacrePalette.auric)
        coinText.horizontalAlignmentMode = .left
        coinText.position = CGPoint(x: frame.minX + 14, y: statsY)
        addChild(coinText)

        let streakText = shimmerLabel(text: "🔥 \(reliquary.currentWinStreak)", size: statSize, tint: NacrePalette.verdigris)
        streakText.horizontalAlignmentMode = .right
        streakText.position = CGPoint(x: frame.maxX - 14, y: statsY)
        addChild(streakText)

        let progress  = reliquary.laurelCodex.progress()
        let pillW     = tether(w * 0.42, low: 130, high: 220)
        let pillH     = tether(22 * g, low: 18, high: 30)
        let pill      = SKShapeNode(rectOf: CGSize(width: pillW, height: pillH), cornerRadius: pillH * 0.5)
        pill.fillColor   = NacrePalette.onyx.withAlphaComponent(0.6)
        pill.strokeColor = NacrePalette.glaucous.withAlphaComponent(0.45)
        pill.lineWidth   = 1.5
        pill.position    = CGPoint(x: midX, y: statsY)
        addChild(pill)

        let pillLbl = shimmerLabel(
            text: "🏆 \(progress.unlocked)/\(progress.total)",
            size: tether(10 * g, low: 9, high: 13),
            tint: NacrePalette.frost)
        pillLbl.position = CGPoint(x: midX, y: statsY)
        pillLbl.name     = sigilAchieve
        pillLbl.alpha    = 0.85
        addChild(pillLbl)

        // ═══════════════════════════════════════════
        //  GAME GRID  — 2 columns × 3 rows
        // ═══════════════════════════════════════════
        let bottomStripH = tether(h * 0.10, low: 56, high: 80)
        let gridBottom   = baseY + bottomStripH
        let gridTop      = statsY - 28 * g
        let gridH        = max(1, gridTop - gridBottom)

        let colGap  = tether(10 * g, low: 8, high: 14)
        let rowGap  = tether(8  * g, low: 6, high: 12)
        let cardW   = min((w - colGap * 3) / 2, 170)
        let cardH   = min((gridH - rowGap * 4) / 3, 108)

        // 以 midX 为轴居中两列，colGap 为列间距
        let colL  = midX - colGap * 0.5 - cardW * 0.5
        let colR  = midX + colGap * 0.5 + cardW * 0.5
        // 三行卡片在 gridBottom~gridTop 区间内垂直居中
        let gridCenterY = (gridTop + gridBottom) * 0.5
        let row2Y = gridCenterY
        let row1Y = row2Y + cardH + rowGap
        let row3Y = row2Y - cardH - rowGap

        // (x, y, title, subtitle, icon, tint, sigil)
        // 只使用 ui/ 文件夹内的小图标，避免大图溢出卡片
        let cards: [(CGFloat, CGFloat, String, String, String, SKColor, String)] = [
            (colL, row1Y, "BOSS GATE",   "Battle bosses",     "game-attack",  NacrePalette.ember,                                   sigilStart),
            (colR, row1Y, "RUNE FORGE",  "Upgrade stats",     "game-defense", NacrePalette.auric,                                   sigilForge),
            (colL, row2Y, "DAILY WYRM",  "Free daily spins",  "game-recover", NacrePalette.verdigris,                               sigilWyrm),
            (colR, row2Y, "BOSS BET",    "Guess & earn",      "game-heart",   NacrePalette.glaucous,                                sigilBet),
            (colL, row3Y, "REFLEX WAR",  "React to survive",  "game-skill",   SKColor(red: 0.68, green: 0.28, blue: 0.95, alpha: 1),sigilReflex),
            (colR, row3Y, "HOW TO PLAY", "Game guide",        "game-attack",  NacrePalette.frost,                                   sigilGuide),
        ]

        for (cx, cy, t, sub, icon, tint, sigil) in cards {
            let card = buildGameCard(
                size:     CGSize(width: cardW, height: cardH),
                title:    t,
                subtitle: sub,
                iconName: icon,
                tint:     tint,
                sigil:    sigil,
                g:        g
            )
            card.position = CGPoint(x: cx, y: cy)
            addChild(card)
        }

        // ── Bottom strip: ACHIEVEMENTS button
        let utilY  = baseY + bottomStripH * 0.48 + 50
        let utilW  = tether(w * 0.72, low: 210, high: 400)
        let utilH  = tether(36 * g, low: 30, high: 44)
        let achieve = GloamButton(span: CGSize(width: utilW, height: utilH),
                                   text: "ACHIEVEMENTS", tint: NacrePalette.glaucous)
        achieve.position  = CGPoint(x: midX, y: utilY)
        achieve.name      = sigilAchieve
        achieve.zPosition = 10
        addChild(achieve)

        // ── Footer tip
        let tipSize = tether(9 * g, low: 8, high: 12)
        let tip = shimmerLabel(text: "Master the symbols  •  Defeat all 15 bosses",
                               size: tipSize, tint: NacrePalette.frost)
        tip.position = CGPoint(x: midX, y: baseY + 9 * g + 50)
        tip.alpha    = 0.40
        addChild(tip)

        addFloatingMahjongTiles()
    }

    // MARK: - Game card builder
    //
    //  Layout (icon centered at top, title + subtitle centered below):
    //
    //  ┌──────── stripe ─────────┐
    //  │                         │
    //  │       [ ICON ]          │
    //  │                         │
    //  │       TITLE TEXT        │
    //  │     subtitle text       │
    //  └─────────────────────────┘

    private func buildGameCard(size: CGSize, title: String, subtitle: String,
                                iconName: String, tint: SKColor, sigil: String, g: CGFloat) -> SKNode {
        let node = SKNode()
        node.name = sigil

        // Shadow
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: size.height + 4), cornerRadius: 17)
        shadow.fillColor   = SKColor.black.withAlphaComponent(0.38)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: 2, y: -3)
        shadow.zPosition   = 0
        node.addChild(shadow)

        // Card background
        let bg = SKShapeNode(rectOf: size, cornerRadius: 15)
        bg.fillColor   = SKColor(red: 0.08, green: 0.09, blue: 0.13, alpha: 0.97)
        bg.strokeColor = tint.withAlphaComponent(0.70)
        bg.lineWidth   = 2.0
        bg.glowWidth   = 8
        bg.zPosition   = 1
        bg.name        = sigil
        node.addChild(bg)

        // Top color stripe
        let stripeH = max(6, size.height * 0.07)
        let stripe  = SKShapeNode(rectOf: CGSize(width: size.width - 6, height: stripeH), cornerRadius: 4)
        stripe.fillColor   = tint.withAlphaComponent(0.28)
        stripe.strokeColor = .clear
        stripe.position    = CGPoint(x: 0, y: size.height * 0.5 - stripeH * 0.5 - 1)
        stripe.zPosition   = 2
        node.addChild(stripe)

        // Icon — explicitly capped at 44pt to prevent overflow
        let iconSide: CGFloat = tether(size.height * 0.28, low: 28, high: 44)
        let iconNode = SKSpriteNode(imageNamed: iconName)
        iconNode.size      = CGSize(width: iconSide, height: iconSide)
        iconNode.position  = CGPoint(x: 0, y: size.height * 0.10)
        iconNode.zPosition = 4
        node.addChild(iconNode)

        // Glow circle behind icon
        let glow = SKShapeNode(circleOfRadius: iconSide * 0.55)
        glow.fillColor   = tint.withAlphaComponent(0.13)
        glow.strokeColor = .clear
        glow.position    = iconNode.position
        glow.zPosition   = 3
        node.addChild(glow)

        // Title
        let titleSize = tether(11.5 * g, low: 10, high: 16)
        let titleLbl  = shimmerLabel(text: title, size: titleSize, tint: NacrePalette.frost)
        titleLbl.position  = CGPoint(x: 0, y: -size.height * 0.19)
        titleLbl.zPosition = 4
        titleLbl.name      = sigil
        node.addChild(titleLbl)

        // Subtitle
        let subSize = tether(9 * g, low: 8, high: 12)
        let subLbl  = shimmerLabel(text: subtitle, size: subSize, tint: tint)
        subLbl.position  = CGPoint(x: 0, y: -size.height * 0.36)
        subLbl.zPosition = 4
        subLbl.alpha     = 0.78
        subLbl.name      = sigil
        node.addChild(subLbl)

        // Breathing glow
        let breathe = SKAction.sequence([
            SKAction.customAction(withDuration: 2.0) { n, _ in (n as? SKShapeNode)?.glowWidth = 14 },
            SKAction.wait(forDuration: 0.8),
            SKAction.customAction(withDuration: 2.0) { n, _ in (n as? SKShapeNode)?.glowWidth = 8  }
        ])
        bg.run(SKAction.repeatForever(breathe))

        return node
    }

    // MARK: - Floating background tiles

    private func addFloatingMahjongTiles() {
        let frame     = safeFrame()
        let tileNames = ["game-attack", "game-defense", "game-heart", "game-skill"]
        for i in 0..<8 {
            spawnFloatingTile(name: tileNames[i % tileNames.count], in: frame)
        }
    }

    private func spawnFloatingTile(name: String, in frame: CGRect) {
        let tile     = SKSpriteNode(imageNamed: name)
        let side     = CGFloat.random(in: 14...28)
        tile.size    = CGSize(width: side, height: side)
        tile.alpha   = CGFloat.random(in: 0.06...0.18)
        tile.zPosition = -5
        tile.position  = CGPoint(x: CGFloat.random(in: frame.minX...frame.maxX),
                                  y: frame.minY - 40)
        addChild(tile)

        let endY     = frame.maxY + 40
        let duration = TimeInterval.random(in: 18...28)
        let delay    = TimeInterval.random(in: 0...5)
        let move     = SKAction.moveBy(x: CGFloat.random(in: -25...25),
                                        y: endY - tile.position.y, duration: duration)
        let rotate   = SKAction.rotate(byAngle: CGFloat.random(in: -1.5...1.5), duration: duration)
        let group    = SKAction.group([move, rotate])
        tile.run(SKAction.sequence([SKAction.wait(forDuration: delay), group,
                                    SKAction.removeFromParent()])) { [weak self] in
            guard let self else { return }
            self.spawnFloatingTile(name: name, in: frame)
        }
    }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let nodes = nodes(at: point)

        // Guide popup
        if childNode(withName: "popup_guide") != nil {
            if nodes.contains(where: { $0.name == "popup_close" }) {
                childNode(withName: "popup_guide")?.removeFromParent()
            }
            return
        }

        // Achievement popup
        if childNode(withName: "popup_achieve") != nil {
            if nodes.contains(where: { $0.name == "popup_close" }) {
                childNode(withName: "popup_achieve")?.removeFromParent()
                achievementScrollNode = nil
            } else {
                achievementScrollStart = point.y
            }
            return
        }

        // Press animation on GloamButton
        if let btn = nodes.first(where: { $0 is GloamButton }) as? GloamButton {
            btn.pressEffect()
        }
        // Press animation on custom card nodes
        for n in nodes {
            if let sigil = n.name,
               [sigilStart, sigilForge, sigilWyrm, sigilBet, sigilReflex, sigilGuide].contains(sigil) {
                let scaleD = SKAction.scale(to: 0.95, duration: 0.07)
                let scaleU = SKAction.scale(to: 1.0,  duration: 0.07)
                n.parent?.run(SKAction.sequence([scaleD, scaleU]))
                break
            }
        }

        let delay = SKAction.wait(forDuration: 0.09)

        if nodes.contains(where: { $0.name == sigilStart }) {
            run(delay) { [weak self] in self?.portcullis?.beckon(.roster) }
        } else if nodes.contains(where: { $0.name == sigilForge }) {
            run(delay) { [weak self] in self?.portcullis?.beckon(.forge) }
        } else if nodes.contains(where: { $0.name == sigilWyrm }) {
            run(delay) { [weak self] in self?.portcullis?.beckon(.wyrmVigil) }
        } else if nodes.contains(where: { $0.name == sigilBet }) {
            run(delay) { [weak self] in self?.portcullis?.beckon(.bossBet) }
        } else if nodes.contains(where: { $0.name == sigilReflex }) {
            run(delay) { [weak self] in self?.portcullis?.beckon(.reflexCrucible) }
        } else if nodes.contains(where: { $0.name == sigilAchieve }) {
            run(delay) { [weak self] in self?.showAchievements() }
        } else if nodes.contains(where: { $0.name == sigilGuide }) {
            showGuide()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let scrollNode = achievementScrollNode else { return }
        let point = touch.location(in: self)
        let delta = point.y - achievementScrollStart
        achievementScrollStart = point.y
        let newY = scrollNode.position.y + delta
        scrollNode.position.y = min(achievementScrollMax, max(achievementScrollMin, newY))
        achievementScrollOffset = scrollNode.position.y
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        achievementScrollStart = 0
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        achievementScrollStart = 0
    }

    // MARK: - Achievements popup

    private func showAchievements() {
        let popup = createAchievementPopup()
        popup.name = "popup_achieve"
        addChild(popup)
    }

    private func createAchievementPopup() -> SKNode {
        let container = SKNode()
        let veil = SKShapeNode(rectOf: size)
        veil.fillColor   = NacrePalette.umbra.withAlphaComponent(0.85)
        veil.strokeColor = .clear
        veil.zPosition   = 200
        veil.position    = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        container.addChild(veil)

        let frame      = safeFrame()
        let g          = gauge()
        let panelWidth = tether(frame.width * 0.88, low: 300, high: 500)
        let panelH     = tether(frame.height * 0.72, low: 480, high: 700)
        let panel      = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelH), cornerRadius: 20)
        panel.fillColor   = NacrePalette.onyx
        panel.strokeColor = NacrePalette.glaucous
        panel.glowWidth   = 8
        panel.zPosition   = 210
        panel.position    = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        container.addChild(panel)

        let titleLabel = shimmerLabel(text: "ACHIEVEMENTS",
                                      size: tether(24 * g, low: 20, high: 30), tint: NacrePalette.frost)
        titleLabel.position = CGPoint(x: 0, y: panelH * 0.42)
        panel.addChild(titleLabel)

        let progress = reliquary.laurelCodex.progress()
        let progressLabel = shimmerLabel(text: "\(progress.unlocked)/\(progress.total) Unlocked",
                                          size: tether(13 * g, low: 11, high: 17), tint: NacrePalette.auric)
        progressLabel.position = CGPoint(x: 0, y: panelH * 0.36)
        panel.addChild(progressLabel)

        let listHeight = panelH * 0.62
        let listY      = panelH * 0.30 - listHeight * 0.5

        let cropMask = SKShapeNode(rectOf: CGSize(width: panelWidth - 20, height: listHeight))
        cropMask.fillColor   = .white
        cropMask.strokeColor = .clear

        let cropNode = SKCropNode()
        cropNode.maskNode = cropMask
        cropNode.position = CGPoint(x: 0, y: listY)
        panel.addChild(cropNode)

        let listContainer = SKNode()
        cropNode.addChild(listContainer)

        let itemH:   CGFloat = tether(62 * g, low: 54, high: 70)
        let itemGap: CGFloat = tether(6  * g, low: 5,  high: 8)
        let achievements = LaurelMark.allCases

        for (idx, mark) in achievements.enumerated() {
            let yPos       = listHeight * 0.5 - itemH * 0.5 - 4 - CGFloat(idx) * (itemH + itemGap)
            let isUnlocked = reliquary.laurelCodex.isUnlocked(mark)
            let cardW      = panelWidth * 0.90

            let card = SKShapeNode(rectOf: CGSize(width: cardW, height: itemH), cornerRadius: 8)
            card.fillColor   = isUnlocked
                ? SKColor(red: 0.12, green: 0.18, blue: 0.12, alpha: 0.9)
                : SKColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 0.7)
            card.strokeColor = isUnlocked
                ? NacrePalette.verdigris.withAlphaComponent(0.6)
                : NacrePalette.glaucous.withAlphaComponent(0.25)
            card.lineWidth   = 1.5
            card.position    = CGPoint(x: 0, y: yPos)
            listContainer.addChild(card)

            let icon = SKLabelNode(text: isUnlocked ? "✓" : "🔒")
            icon.fontSize              = tether(20 * g, low: 18, high: 24)
            icon.fontColor             = isUnlocked ? NacrePalette.verdigris : SKColor.gray
            icon.verticalAlignmentMode = .center
            icon.position              = CGPoint(x: -cardW * 0.42, y: yPos)
            listContainer.addChild(icon)

            let titleLbl = shimmerLabel(text: mark.epithet,
                                        size: tether(13 * g, low: 11, high: 16),
                                        tint: isUnlocked ? NacrePalette.frost : SKColor.gray)
            titleLbl.horizontalAlignmentMode = .left
            titleLbl.position                = CGPoint(x: -cardW * 0.34, y: yPos + itemH * 0.18)
            listContainer.addChild(titleLbl)

            let descLbl = shimmerLabel(text: mark.chronicle,
                                       size: tether(10 * g, low: 9, high: 13),
                                       tint: isUnlocked ? NacrePalette.glaucous : SKColor.darkGray)
            descLbl.horizontalAlignmentMode = .left
            descLbl.position                = CGPoint(x: -cardW * 0.34, y: yPos - itemH * 0.15)
            listContainer.addChild(descLbl)

            let reward = shimmerLabel(text: "+\(mark.bounty)",
                                       size: tether(12 * g, low: 10, high: 15),
                                       tint: NacrePalette.auric)
            reward.horizontalAlignmentMode = .right
            reward.position                = CGPoint(x: cardW * 0.40, y: yPos)
            reward.alpha                   = isUnlocked ? 1.0 : 0.5
            listContainer.addChild(reward)
        }

        let totalContent = CGFloat(achievements.count) * (itemH + itemGap)
        let overflow     = max(0, totalContent - listHeight)
        achievementScrollNode    = listContainer
        listContainer.position.y = 0
        achievementScrollOffset  = 0
        achievementScrollMin     = 0
        achievementScrollMax     = overflow
        listContainer.name       = "achievement_scroll"

        let closeW      = tether(100 * g, low: 90, high: 130)
        let closeH      = tether(38  * g, low: 34, high: 48)
        let closeButton = GloamButton(span: CGSize(width: closeW, height: closeH),
                                       text: "CLOSE", tint: NacrePalette.ember)
        closeButton.position = CGPoint(x: 0, y: -panelH * 0.42)
        closeButton.name     = "popup_close"
        panel.addChild(closeButton)

        return container
    }

    // MARK: - Guide popup

    private func showGuide() {
        let container = SKNode()
        container.name = "popup_guide"

        let veil = SKShapeNode(rectOf: size)
        veil.fillColor   = NacrePalette.umbra.withAlphaComponent(0.88)
        veil.strokeColor = .clear
        veil.zPosition   = 200
        veil.position    = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        container.addChild(veil)

        let frame  = safeFrame()
        let g      = gauge()
        let panelW = tether(frame.width * 0.88, low: 300, high: 500)
        let panelH = tether(frame.height * 0.82, low: 520, high: 740)
        let panel  = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 20)
        panel.fillColor   = NacrePalette.onyx
        panel.strokeColor = NacrePalette.auric
        panel.glowWidth   = 8
        panel.zPosition   = 210
        panel.position    = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        container.addChild(panel)

        let titleLbl = shimmerLabel(text: "HOW TO PLAY",
                                    size: tether(24 * g, low: 20, high: 30), tint: NacrePalette.auric)
        titleLbl.position = CGPoint(x: 0, y: panelH * 0.43)
        panel.addChild(titleLbl)

        let sections: [(icon: String, title: String, body: String)] = [
            ("game-attack",  "BOSS GATE",   "Choose a boss and battle using your slot machine. Match 3 symbols to trigger effects. Take turns until one side falls."),
            ("game-defense", "RUNE FORGE",  "Spend 10 coins per spin. Match 3 runes to permanently upgrade ATK, HP, SHIELD or SKILL stats."),
            ("game-recover", "DAILY WYRM",  "A random boss appears each day with massive HP. 10 free spins — deal as much damage as possible!"),
            ("game-heart",   "BOSS BET",    "See a boss's stat, guess if the next boss is HIGHER or LOWER. Correct guesses pay back ×combo!"),
            ("game-skill",   "REFLEX WAR",  "A symbol flashes — quickly tap its counter. Attack→Shield, Shield→Skill, Skill→Heal, Heal→Attack."),
        ]

        let secGap: CGFloat = tether(8  * g, low: 6,  high: 12)
        let secH:   CGFloat = tether(72 * g, low: 62, high: 86)
        var curY = panelH * 0.30

        for sec in sections {
            let cardW  = panelW * 0.88
            let card   = SKShapeNode(rectOf: CGSize(width: cardW, height: secH), cornerRadius: 10)
            card.fillColor   = SKColor(red: 0.10, green: 0.12, blue: 0.16, alpha: 0.9)
            card.strokeColor = NacrePalette.glaucous.withAlphaComponent(0.35)
            card.lineWidth   = 1.5
            card.position    = CGPoint(x: 0, y: curY)
            panel.addChild(card)

            let iconSz = tether(24 * g, low: 20, high: 32)
            let icon   = SKSpriteNode(imageNamed: sec.icon)
            icon.size     = CGSize(width: iconSz, height: iconSz)
            icon.position = CGPoint(x: -cardW * 0.40, y: curY)
            panel.addChild(icon)

            let stLbl = shimmerLabel(text: sec.title,
                                      size: tether(11 * g, low: 9, high: 14), tint: NacrePalette.auric)
            stLbl.horizontalAlignmentMode = .left
            stLbl.position                = CGPoint(x: -cardW * 0.28, y: curY + secH * 0.22)
            panel.addChild(stLbl)

            let bodyLbl = shimmerLabel(text: sec.body,
                                        size: tether(9 * g, low: 8, high: 12), tint: NacrePalette.frost)
            bodyLbl.horizontalAlignmentMode = .left
            bodyLbl.numberOfLines           = 3
            bodyLbl.preferredMaxLayoutWidth = cardW * 0.68
            bodyLbl.position                = CGPoint(x: -cardW * 0.28, y: curY - secH * 0.10)
            panel.addChild(bodyLbl)

            curY -= (secH + secGap)
        }

        let closeW   = tether(100 * g, low: 90, high: 130)
        let closeH   = tether(38  * g, low: 34, high: 48)
        let closeBtn = GloamButton(span: CGSize(width: closeW, height: closeH),
                                    text: "CLOSE", tint: NacrePalette.ember)
        closeBtn.position = CGPoint(x: 0, y: -panelH * 0.44)
        closeBtn.name     = "popup_close"
        panel.addChild(closeBtn)

        addChild(container)
    }
}
