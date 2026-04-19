//
//  BossBetArena.swift
//  FightFire
//
//  Boss 竞猜押注 — 猜下一个 Boss 的属性是 higher 还是 lower

import SpriteKit

final class BossBetArena: VesperStage {
    private let sigilBack    = "bet_back"
    private let sigilHigher  = "bet_higher"
    private let sigilLower   = "bet_lower"
    private let sigilBet10   = "bet_10"
    private let sigilBet30   = "bet_30"
    private let sigilBet50   = "bet_50"

    // All 15 bosses, shuffled once per session
    private let roster: [TyrantDraft] = DreadAtlas.roster().shuffled()
    private var currentIndex = 0

    private var selectedBet = 10
    private var chain = ZenithChain()

    // Tracked attribute for this round
    private enum CompareAttr { case atk, hp, reward }
    private var currentAttr: CompareAttr = .atk

    // UI references
    private var coinLabel: SKLabelNode?
    private var streakLabel: SKLabelNode?
    private var bossCard: SKNode?
    private var attrLabel: SKLabelNode?
    private var attrValueLabel: SKLabelNode?
    private var nextBossHint: SKLabelNode?
    private var bet10Btn: GloamButton?
    private var bet30Btn: GloamButton?
    private var bet50Btn: GloamButton?
    private var higherBtn: GloamButton?
    private var lowerBtn: GloamButton?
    private var cameraNode: SKNode?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        isUserInteractionEnabled = true
    }

    override func laceLayout() {
        removeAllChildren()

        let camera = SKNode()
        camera.position = .zero
        addChild(camera)
        cameraNode = camera

        camera.addChild(forgeBackdrop())

        let frame  = safeFrame()
        let g      = gauge()
        let midX   = frame.midX
        let topY   = frame.maxY
        let baseY  = frame.minY
        let w      = frame.width
        let h      = frame.height
        let topInset = view?.safeAreaInsets.top ?? 0
        let adjTop   = topY - max(30 * g, topInset + 5)

        // ── Back
        let bw = tether(w * 0.22, low: 90, high: 160)
        let bh = tether(38 * g, low: 32, high: 50)
        let back = GloamButton(span: CGSize(width: bw, height: bh), text: "BACK", tint: NacrePalette.ember)
        back.position = CGPoint(x: frame.minX + bw * 0.6, y: adjTop - 10 * g)
        back.name = sigilBack
        back.zPosition = 100
        camera.addChild(back)

        // ── Title
        let titleLbl = shimmerLabel(text: "BOSS BET", size: tether(26 * g, low: 20, high: 38), tint: NacrePalette.auric)
        titleLbl.position = CGPoint(x: midX, y: adjTop - 10 * g)
        camera.addChild(titleLbl)

        // ── Coin
        let coinSize = tether(14 * g, low: 11, high: 20)
        let cl = shimmerLabel(text: "💰 \(reliquary.hoard)", size: coinSize, tint: NacrePalette.auric)
        cl.position = CGPoint(x: frame.maxX - 16 * g, y: adjTop - 10 * g)
        cl.horizontalAlignmentMode = .right
        camera.addChild(cl)
        coinLabel = cl

        // ── Streak
        let sl = shimmerLabel(text: "", size: tether(13 * g, low: 11, high: 18), tint: NacrePalette.verdigris)
        sl.position = CGPoint(x: midX, y: adjTop - 38 * g)
        camera.addChild(sl)
        streakLabel = sl

        // ── Rule hint
        let ruleSize = tether(11 * g, low: 9, high: 15)
        let rule = shimmerLabel(text: "Is the next boss's stat HIGHER or LOWER?", size: ruleSize, tint: NacrePalette.glaucous)
        rule.position = CGPoint(x: midX, y: adjTop - 58 * g)
        rule.alpha = 0.75
        camera.addChild(rule)

        // ── Boss card zone (center)
        let cardW  = tether(w * 0.78, low: 260, high: 480)
        let cardH  = tether(h * 0.30, low: 160, high: 260)
        let cardY  = baseY + h * 0.62
        buildBossCard(at: CGPoint(x: midX, y: cardY), size: CGSize(width: cardW, height: cardH), g: g, in: camera)

        // ── Bet selector
        let betY = baseY + h * 0.40
        let btnW = tether(w * 0.22, low: 72, high: 130)
        let btnH = tether(44 * g, low: 36, high: 58)

        let b10 = GloamButton(span: CGSize(width: btnW, height: btnH), text: "10", tint: NacrePalette.glaucous)
        b10.position = CGPoint(x: midX - btnW - 14, y: betY)
        b10.name = sigilBet10
        b10.zPosition = 50
        camera.addChild(b10)
        bet10Btn = b10

        let b30 = GloamButton(span: CGSize(width: btnW, height: btnH), text: "30", tint: NacrePalette.glaucous)
        b30.position = CGPoint(x: midX, y: betY)
        b30.name = sigilBet30
        b30.zPosition = 50
        camera.addChild(b30)
        bet30Btn = b30

        let b50 = GloamButton(span: CGSize(width: btnW, height: btnH), text: "50", tint: NacrePalette.glaucous)
        b50.position = CGPoint(x: midX + btnW + 14, y: betY)
        b50.name = sigilBet50
        b50.zPosition = 50
        camera.addChild(b50)
        bet50Btn = b50

        let betTipSize = tether(11 * g, low: 9, high: 14)
        let betTip = shimmerLabel(text: "SELECT BET", size: betTipSize, tint: NacrePalette.frost)
        betTip.position = CGPoint(x: midX, y: betY + btnH * 0.8)
        betTip.alpha = 0.6
        camera.addChild(betTip)

        // ── Higher / Lower buttons
        let guessW = tether(w * 0.40, low: 130, high: 220)
        let guessH = tether(58 * g, low: 46, high: 76)

        let higher = GloamButton(span: CGSize(width: guessW, height: guessH), text: "▲ HIGHER", tint: NacrePalette.verdigris)
        higher.position = CGPoint(x: midX - guessW * 0.55, y: baseY + h * 0.22)
        higher.name = sigilHigher
        higher.zPosition = 50
        camera.addChild(higher)
        higherBtn = higher

        let lower = GloamButton(span: CGSize(width: guessW, height: guessH), text: "▼ LOWER", tint: NacrePalette.ember)
        lower.position = CGPoint(x: midX + guessW * 0.55, y: baseY + h * 0.22)
        lower.name = sigilLower
        lower.zPosition = 50
        camera.addChild(lower)
        lowerBtn = lower

        // ── Next boss hint (hidden until needed)
        let hintLbl = shimmerLabel(text: "", size: tether(12 * g, low: 10, high: 16), tint: NacrePalette.frost)
        hintLbl.position = CGPoint(x: midX, y: baseY + h * 0.10)
        hintLbl.alpha = 0.0
        camera.addChild(hintLbl)
        nextBossHint = hintLbl

        refreshBetHighlight()
        updateStreakLabel()
    }

    // MARK: - Boss card

    private func buildBossCard(at pos: CGPoint, size: CGSize, g: CGFloat, in parent: SKNode) {
        let container = SKNode()
        container.position = pos
        parent.addChild(container)
        bossCard = container

        refreshBossCard(size: size, g: g)
    }

    private func refreshBossCard(size: CGSize, g: CGFloat) {
        guard let container = bossCard else { return }
        container.removeAllChildren()

        let boss = roster[currentIndex % roster.count]
        currentAttr = [CompareAttr.atk, .hp, .reward].randomElement()!

        // Background
        let bg = SKShapeNode(rectOf: size, cornerRadius: 18)
        bg.fillColor = SKColor(red: 0.08, green: 0.09, blue: 0.13, alpha: 0.96)
        bg.strokeColor = NacrePalette.auric
        bg.lineWidth = 2.5
        bg.glowWidth = 10
        container.addChild(bg)

        // Boss portrait
        let portraitSize = tether(size.height * 0.65, low: 80, high: 160)
        let portrait = SKSpriteNode(imageNamed: boss.visage)
        portrait.size = CGSize(width: portraitSize, height: portraitSize)
        portrait.position = CGPoint(x: -size.width * 0.28, y: size.height * 0.04)
        container.addChild(portrait)

        // Boss name & tier
        let nameSize = tether(15 * g, low: 13, high: 22)
        let nameLbl = shimmerLabel(text: boss.sobriquet.uppercased(), size: nameSize, tint: NacrePalette.frost)
        nameLbl.horizontalAlignmentMode = .left
        nameLbl.position = CGPoint(x: size.width * 0.02, y: size.height * 0.26)
        container.addChild(nameLbl)

        let tierLbl = shimmerLabel(text: "TIER \(boss.tier)", size: tether(12 * g, low: 10, high: 16), tint: NacrePalette.auric)
        tierLbl.horizontalAlignmentMode = .left
        tierLbl.position = CGPoint(x: size.width * 0.02, y: size.height * 0.12)
        container.addChild(tierLbl)

        // Attribute label
        let attrName: String
        let attrValue: Int
        let attrIcon: String
        let attrColor: SKColor
        switch currentAttr {
        case .atk:
            attrName = "ATK"; attrValue = boss.glaive
            attrIcon = "game-attack"; attrColor = NacrePalette.ember
        case .hp:
            attrName = "HP"; attrValue = boss.vitalis
            attrIcon = "game-heart"; attrColor = NacrePalette.verdigris
        case .reward:
            attrName = "REWARD"; attrValue = boss.largess
            attrIcon = "game-skill"; attrColor = NacrePalette.auric
        }

        let iconSz = tether(size.height * 0.22, low: 24, high: 42)
        let icon = SKSpriteNode(imageNamed: attrIcon)
        icon.size = CGSize(width: iconSz, height: iconSz)
        icon.position = CGPoint(x: size.width * 0.02, y: -size.height * 0.07)
        container.addChild(icon)

        let attrNameLbl = shimmerLabel(text: attrName, size: tether(12 * g, low: 10, high: 16), tint: attrColor)
        attrNameLbl.horizontalAlignmentMode = .left
        attrNameLbl.position = CGPoint(x: size.width * 0.02 + iconSz * 0.6, y: -size.height * 0.02)
        container.addChild(attrNameLbl)
        attrLabel = attrNameLbl

        let attrValLbl = shimmerLabel(text: "\(attrValue)", size: tether(24 * g, low: 18, high: 36), tint: NacrePalette.frost)
        attrValLbl.horizontalAlignmentMode = .left
        attrValLbl.position = CGPoint(x: size.width * 0.02 + iconSz * 0.6, y: -size.height * 0.22)
        container.addChild(attrValLbl)
        attrValueLabel = attrValLbl

        // "NEXT BOSS?" indicator
        let frame = safeFrame()
        let g2 = gauge()
        let questionSize = tether(11 * g2, low: 9, high: 14)
        let question = shimmerLabel(text: "Next boss →  ?", size: questionSize, tint: NacrePalette.glaucous)
        question.horizontalAlignmentMode = .right
        question.position = CGPoint(x: size.width * 0.46, y: -size.height * 0.35)
        _ = frame // suppress warning
        container.addChild(question)
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pt    = touch.location(in: self)
        let nodes = nodes(at: pt)

        // Popup
        if let popup = childNode(withName: "bet_popup") {
            if nodes.contains(where: { $0.name == "popup_primary" || $0.name == "popup_secondary" }) {
                popup.removeFromParent()
                if nodes.contains(where: { $0.name == "popup_secondary" }) {
                    portcullis?.beckon(.foyer)
                } else {
                    advanceRound()
                }
            }
            return
        }

        if nodes.contains(where: { $0.name == sigilBack }) {
            portcullis?.beckon(.foyer); return
        }

        if nodes.contains(where: { $0.name == sigilBet10 }) { selectBet(10) }
        else if nodes.contains(where: { $0.name == sigilBet30 }) { selectBet(30) }
        else if nodes.contains(where: { $0.name == sigilBet50 }) { selectBet(50) }
        else if nodes.contains(where: { $0.name == sigilHigher }) { guess(higher: true) }
        else if nodes.contains(where: { $0.name == sigilLower }) { guess(higher: false) }
    }

    // MARK: - Game logic

    private func selectBet(_ amount: Int) {
        selectedBet = amount
        refreshBetHighlight()
    }

    private func refreshBetHighlight() {
        let active  = NacrePalette.auric
        let passive = NacrePalette.glaucous
        bet10Btn?.gleam(selectedBet == 10 ? active : passive)
        bet30Btn?.gleam(selectedBet == 30 ? active : passive)
        bet50Btn?.gleam(selectedBet == 50 ? active : passive)
    }

    private func guess(higher: Bool) {
        // Enough coins?
        guard reliquary.hoard >= selectedBet else {
            showPopup(title: "NOT ENOUGH COINS", body: "You need \(selectedBet) coins to bet.", winGain: nil)
            return
        }

        let current = roster[currentIndex % roster.count]
        let next    = roster[(currentIndex + 1) % roster.count]

        let currentVal: Int
        let nextVal: Int
        switch currentAttr {
        case .atk:    currentVal = current.glaive;  nextVal = next.glaive
        case .hp:     currentVal = current.vitalis; nextVal = next.vitalis
        case .reward: currentVal = current.largess; nextVal = next.largess
        }

        let isHigher = nextVal > currentVal
        let tie      = nextVal == currentVal
        let correct  = tie ? true : (higher == isHigher)   // tie is always a win (push)

        // Deduct bet
        _ = reliquary.siphon(selectedBet)

        let attrName: String
        switch currentAttr {
        case .atk:    attrName = "ATK"
        case .hp:     attrName = "HP"
        case .reward: attrName = "REWARD"
        }

        let frame = safeFrame()
        let midPt = CGPoint(x: frame.midX, y: frame.midY)

        if correct {
            let gain: Int
            if tie {
                // Push: return bet only
                gain = selectedBet
                chain.rupture()
                _ = reliquary.mint(gain)
                showPopup(title: "PUSH!", body: "Same value — your bet returned.\nNext \(attrName): \(nextVal)", winGain: nil)
            } else {
                chain.surge()
                let multiplier = chain.multiplier()
                gain = Int(Double(selectedBet) * multiplier)
                _ = reliquary.mint(gain)
                if let cam = cameraNode {
                    EtherealMote.conjure(archetype: .victory, at: midPt, in: cam)
                    PhantomNumeral.manifest(value: gain, cast: .heal, at: midPt, in: cam, scale: gauge())
                }
                let comboText = chain.tally >= 2 ? "\n\(chain.chromaGrade().epithet)  ×\(String(format: "%.1f", multiplier))" : ""
                showPopup(title: "CORRECT!", body: "Next \(attrName): \(nextVal)\n+\(gain) coins\(comboText)", winGain: gain)
            }
        } else {
            chain.rupture()
            if let cam = cameraNode {
                EtherealMote.conjure(archetype: .defeat, at: midPt, in: cam)
                TremorPulse.quake(node: cam, magnitude: .moderate)
            }
            showPopup(title: "WRONG!", body: "Next \(attrName): \(nextVal)\n-\(selectedBet) coins\nStreak reset.", winGain: nil)
        }

        coinLabel?.text = "💰 \(reliquary.hoard)"
        updateStreakLabel()
        currentIndex += 1
    }

    private func advanceRound() {
        // Rebuild card for new boss
        let frame = safeFrame()
        let g     = gauge()
        let cardW = tether(frame.width * 0.78, low: 260, high: 480)
        let cardH = tether(frame.height * 0.30, low: 160, high: 260)
        refreshBossCard(size: CGSize(width: cardW, height: cardH), g: g)

        // Animate card in
        if let card = bossCard {
            card.alpha = 0
            let appear = SKAction.fadeIn(withDuration: 0.3)
            card.run(appear)
        }
    }

    private func showPopup(title: String, body: String, winGain: Int?) {
        let popup = GossamerPopup(span: size, title: title, body: body, primary: "NEXT", secondary: "QUIT")
        popup.name = "bet_popup"
        addChild(popup)
    }

    private func updateStreakLabel() {
        if chain.tally >= 2 {
            let grade = chain.chromaGrade()
            streakLabel?.text = "🔥 \(grade.epithet)  (streak \(chain.tally))"
            let hue = grade.hue
            streakLabel?.fontColor = SKColor(red: hue.r, green: hue.g, blue: hue.b, alpha: 1.0)
        } else if chain.tally == 1 {
            streakLabel?.text = "Streak: 1"
            streakLabel?.fontColor = NacrePalette.frost
        } else {
            streakLabel?.text = ""
        }
    }
}
