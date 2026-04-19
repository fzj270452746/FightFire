//
//  ReflexCrucible.swift
//  FightFire
//
//  符号反应速度战 — 看到符号，快速点击克制它的符号按钮

import SpriteKit

final class ReflexCrucible: VesperStage {

    // MARK: - Sigils
    private let sigilBack    = "reflex_back"
    private let sigilMordant = "reflex_mordant"
    private let sigilArcanum = "reflex_arcanum"
    private let sigilLenitive = "reflex_lenitive"
    private let sigilPavis   = "reflex_pavis"

    // MARK: - Game data
    private var dossier: TyrantDraft
    private var boss:   GloamFighter
    private var player: GloamFighter

    // MARK: - Round state
    private var currentSymbol: OmenGlyph = .mordant
    private var timeLimit:  TimeInterval = 2.0    // decreases as game progresses
    private var timeLeft:   TimeInterval = 2.0
    private var lastUpdate: TimeInterval = 0
    private var roundActive = false
    private var gameOver    = false
    private var correctHits = 0

    // MARK: - UI refs
    private var bossHpBar:    SinewBar?
    private var playerHpBar:  SinewBar?
    private var bossHpLbl:    SKLabelNode?
    private var playerHpLbl:  SKLabelNode?
    private var symbolSprite: SKSpriteNode?
    private var symbolBox:    SKShapeNode?
    private var timerBar:     SinewBar?
    private var hitsLabel:    SKLabelNode?
    private var counterHint:  SKLabelNode?
    private var cameraNode:   SKNode?

    // MARK: - Init
    override init(size: CGSize, reliquary: ReliquaryCodex) {
        let tier     = max(1, min(15, reliquary.summit + 1))
        self.dossier = DreadAtlas.roster().first { $0.tier == tier } ?? DreadAtlas.roster()[0]
        self.boss    = GloamFighter(glaive: dossier.glaive,
                                    vitalisCap: dossier.vitalis, vitalisNow: dossier.vitalis,
                                    pavis: 0, arcanum: dossier.arcanum, pavisGain: dossier.pavisGain)
        self.player  = reliquary.forgeAvatar()
        super.init(size: size, reliquary: reliquary)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        isUserInteractionEnabled = true
    }

    // MARK: - Layout
    override func laceLayout() {
        removeAllChildren()

        let camera = SKNode()
        camera.position = .zero
        addChild(camera)
        cameraNode = camera

        camera.addChild(forgeBackdrop())

        let frame    = safeFrame()
        let g        = gauge()
        let midX     = frame.midX
        let topY     = frame.maxY
        let baseY    = frame.minY
        let w        = frame.width
        let h        = frame.height
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
        let titleLbl = shimmerLabel(text: "REFLEX CRUCIBLE", size: tether(17 * g, low: 16, high: 28), tint: NacrePalette.frost)
        titleLbl.position = CGPoint(x: midX, y: adjTop - 10 * g)
        camera.addChild(titleLbl)

        // ── Stat bars shared geometry
        let sideMargin: CGFloat = 14
        let avSz   = tether(h * 0.075, low: 36, high: 64)
        let avPad: CGFloat = 8
        let barW   = w - sideMargin * 2 - avSz - avPad
        let barH   = tether(18 * g, low: 14, high: 24)
        let avCx   = frame.minX + sideMargin + avSz / 2
        let barCx  = frame.minX + sideMargin + avSz + avPad + barW / 2
        let statFontSize = tether(11 * g, low: 9, high: 15)

        // ── Boss HP (top)
        let bossBarY = adjTop - 52 * g

        let bossAv = SKSpriteNode(imageNamed: dossier.visage)
        bossAv.size = CGSize(width: avSz, height: avSz)
        bossAv.position = CGPoint(x: avCx, y: bossBarY)
        camera.addChild(bossAv)

        let bossNameLbl = shimmerLabel(text: "\(dossier.sobriquet.uppercased())  T\(dossier.tier)",
                                       size: tether(12 * g, low: 10, high: 16), tint: NacrePalette.ember)
        bossNameLbl.position = CGPoint(x: barCx, y: bossBarY + barH * 0.9 + 6 * g)
        bossNameLbl.horizontalAlignmentMode = .center
        camera.addChild(bossNameLbl)

        let bossBar = SinewBar(span: barW, height: barH, tint: NacrePalette.ember, back: NacrePalette.onyx)
        bossBar.position = CGPoint(x: barCx, y: bossBarY)
        camera.addChild(bossBar)
        bossHpBar = bossBar

        let bhl = shimmerLabel(text: "\(boss.vitalisNow)/\(boss.vitalisCap)", size: statFontSize, tint: NacrePalette.frost)
        bhl.position = CGPoint(x: barCx, y: bossBarY - barH * 0.9 - 4 * g)
        bhl.horizontalAlignmentMode = .center
        camera.addChild(bhl)
        bossHpLbl = bhl

        // ── Timer bar
        let timerY = bossBarY - barH - 22 * g
        let timerW = tether(w * 0.72, low: 240, high: 440)
        let timerH = tether(12 * g, low: 8, high: 16)
        let tmr = SinewBar(span: timerW, height: timerH, tint: NacrePalette.auric, back: NacrePalette.onyx)
        tmr.position = CGPoint(x: midX, y: timerY)
        camera.addChild(tmr)
        timerBar = tmr

        // ── Central symbol display
        let centerY = baseY + h * 0.55
        let boxSz   = tether(h * 0.17, low: 90, high: 150)

        let box = SKShapeNode(rectOf: CGSize(width: boxSz + 20, height: boxSz + 20), cornerRadius: 22)
        box.fillColor = SKColor(red: 0.08, green: 0.09, blue: 0.13, alpha: 0.95)
        box.strokeColor = NacrePalette.auric
        box.lineWidth = 2.5
        box.glowWidth = 14
        box.position = CGPoint(x: midX, y: centerY)
        box.zPosition = 5
        camera.addChild(box)
        symbolBox = box

        let sym = SKSpriteNode(imageNamed: currentSymbol.sigilName(timbre: .fray))
        sym.size = CGSize(width: boxSz, height: boxSz)
        sym.position = CGPoint(x: midX, y: centerY)
        sym.zPosition = 6
        camera.addChild(sym)
        symbolSprite = sym

        // Hits counter
        let hl = shimmerLabel(text: "HITS: \(correctHits)", size: tether(14 * g, low: 11, high: 20), tint: NacrePalette.auric)
        hl.position = CGPoint(x: midX, y: centerY + (boxSz / 2 + 22) * g * 0.6)
        camera.addChild(hl)
        hitsLabel = hl

        // Counter hint
        let hintLbl = shimmerLabel(text: counterHintText(), size: tether(11 * g, low: 9, high: 15), tint: NacrePalette.glaucous)
        hintLbl.position = CGPoint(x: midX, y: centerY - (boxSz / 2 + 22) * g * 0.5)
        hintLbl.alpha = 0.7
        camera.addChild(hintLbl)
        counterHint = hintLbl

        // ── Player HP bar (above buttons)
        let playerBarY = baseY + h * 0.32

        let playerAv = SKSpriteNode(imageNamed: "game-player")
        playerAv.size = CGSize(width: avSz, height: avSz)
        playerAv.position = CGPoint(x: avCx, y: playerBarY)
        camera.addChild(playerAv)

        let playerBar = SinewBar(span: barW, height: barH, tint: NacrePalette.verdigris, back: NacrePalette.onyx)
        playerBar.position = CGPoint(x: barCx, y: playerBarY)
        camera.addChild(playerBar)
        playerHpBar = playerBar

        let phl = shimmerLabel(text: "\(player.vitalisNow)/\(player.vitalisCap)", size: statFontSize, tint: NacrePalette.frost)
        phl.position = CGPoint(x: barCx, y: playerBarY - barH * 0.9 - 4 * g)
        phl.horizontalAlignmentMode = .center
        camera.addChild(phl)
        playerHpLbl = phl

        // ── 2×2 symbol buttons
        let btnSz    = tether(h * 0.09, low: 56, high: 90)
        let btnGap   = tether(14 * g, low: 10, high: 20)
        let btnRow1Y = playerBarY - avSz * 0.7 - btnGap - btnSz * 0.5
        let btnRow2Y = btnRow1Y - btnSz - btnGap
        let colL     = midX - btnSz * 0.55 - btnGap * 0.5
        let colR     = midX + btnSz * 0.55 + btnGap * 0.5

        makeSymbolButton(.mordant,   name: sigilMordant,  pos: CGPoint(x: colL, y: btnRow1Y), size: btnSz, in: camera)
        makeSymbolButton(.arcanum,   name: sigilArcanum,  pos: CGPoint(x: colR, y: btnRow1Y), size: btnSz, in: camera)
        makeSymbolButton(.lenitive,  name: sigilLenitive, pos: CGPoint(x: colL, y: btnRow2Y), size: btnSz, in: camera)
        makeSymbolButton(.pavis,     name: sigilPavis,    pos: CGPoint(x: colR, y: btnRow2Y), size: btnSz, in: camera)

        refreshBars()

        // Kick off first round
        if !gameOver {
            run(SKAction.wait(forDuration: 0.5)) { [weak self] in
                self?.nextRound()
            }
        }
    }

    private func makeSymbolButton(_ glyph: OmenGlyph, name: String, pos: CGPoint, size: CGFloat, in parent: SKNode) {
        let bg = SKShapeNode(rectOf: CGSize(width: size + 12, height: size + 12), cornerRadius: 14)
        bg.fillColor = SKColor(red: 0.10, green: 0.11, blue: 0.16, alpha: 0.95)
        bg.strokeColor = glyph.chroma
        bg.lineWidth = 2.5
        bg.glowWidth = 8
        bg.position = pos
        bg.name = name
        bg.zPosition = 50
        parent.addChild(bg)

        let ic = SKSpriteNode(imageNamed: glyph.sigilName(timbre: .fray))
        ic.size = CGSize(width: size * 0.68, height: size * 0.68)
        ic.position = pos
        ic.name = name
        ic.zPosition = 51
        parent.addChild(ic)
    }

    // MARK: - Counter logic

    /// Attack → Shield, Shield → Skill, Skill → Heal, Heal → Attack
    private func counter(for symbol: OmenGlyph) -> OmenGlyph {
        switch symbol {
        case .mordant:  return .pavis
        case .pavis:    return .arcanum
        case .arcanum:  return .lenitive
        case .lenitive: return .mordant
        }
    }

    private func counterHintText() -> String {
        switch currentSymbol {
        case .mordant:  return "Attack → Block with SHIELD"
        case .pavis:    return "Shield → Pierce with SKILL"
        case .arcanum:  return "Skill → Absorb with HEAL"
        case .lenitive: return "Heal → Interrupt with ATTACK"
        }
    }

    // MARK: - Round management

    private func nextRound() {
        guard !gameOver else { return }
        currentSymbol = OmenGlyph.allCases.randomElement() ?? .mordant
        symbolSprite?.texture = SKTexture(imageNamed: currentSymbol.sigilName(timbre: .fray))
        counterHint?.text = counterHintText()

        // Animate symbol pop-in
        symbolSprite?.setScale(0.6)
        symbolSprite?.run(SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.12),
            SKAction.scale(to: 1.0,  duration: 0.08)
        ]))

        timeLeft    = timeLimit
        lastUpdate  = 0
        roundActive = true
    }

    private func resolveHit(correct: Bool) {
        guard roundActive else { return }
        roundActive = false
        timerBar?.drip(1.0) // reset bar visually

        let frame = safeFrame()

        if correct {
            correctHits += 1
            hitsLabel?.text = "HITS: \(correctHits)"
            let dmg = player.glaive
            _ = boss.scar(dmg)

            if let cam = cameraNode {
                let pt = CGPoint(x: frame.midX, y: frame.midY + frame.height * 0.12)
                EtherealMote.conjure(archetype: .damage, at: pt, in: cam)
                PhantomNumeral.manifest(value: dmg, cast: .damage, at: pt, in: cam, scale: gauge())
                TremorPulse.pulse(node: symbolSprite ?? SKNode(), scale: 1.2, duration: 0.12)
            }

            // Flash box green
            symbolBox?.strokeColor = NacrePalette.verdigris
            run(SKAction.wait(forDuration: 0.25)) { [weak self] in
                self?.symbolBox?.strokeColor = NacrePalette.auric
            }

            // Speed up slightly every 5 correct hits
            if correctHits % 5 == 0 {
                timeLimit = max(0.75, timeLimit - 0.15)
            }

            if boss.vitalisNow <= 0 {
                refreshBars()
                finalize(win: true)
                return
            }
        } else {
            let dmg = boss.glaive
            _ = player.scar(dmg)

            if let cam = cameraNode {
                let pt = CGPoint(x: frame.midX, y: frame.midY - frame.height * 0.12)
                EtherealMote.conjure(archetype: .damage, at: pt, in: cam)
                PhantomNumeral.manifest(value: dmg, cast: .damage, at: pt, in: cam, scale: gauge())
                TremorPulse.quake(node: cam, magnitude: .moderate)
            }

            // Flash box red
            symbolBox?.strokeColor = NacrePalette.ember
            run(SKAction.wait(forDuration: 0.25)) { [weak self] in
                self?.symbolBox?.strokeColor = NacrePalette.auric
            }

            if player.vitalisNow <= 0 {
                refreshBars()
                finalize(win: false)
                return
            }
        }

        refreshBars()

        run(SKAction.wait(forDuration: 0.45)) { [weak self] in
            self?.nextRound()
        }
    }

    private func finalize(win: Bool) {
        gameOver = true
        roundActive = false
        timerBar?.drip(0)

        let reward = win ? (50 + dossier.tier * 15) : max(10, correctHits * 4)
        reliquary.mint(reward)

        let title = win ? "BOSS SLAIN!" : "DEFEATED"
        let body  = win
            ? "Reflex victory!\nHits: \(correctHits)  |  +\(reward) 💰"
            : "You fell in battle.\nHits: \(correctHits)  |  +\(reward) 💰"

        let popup = GossamerPopup(span: size, title: title, body: body, primary: "OK", secondary: nil)
        popup.name = "reflex_popup"
        addChild(popup)

        if let cam = cameraNode {
            let c = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            EtherealMote.conjure(archetype: win ? .victory : .defeat, at: c, in: cam)
        }
    }

    // MARK: - UI refresh

    private func refreshBars() {
        bossHpBar?.drip(CGFloat(boss.vitalisNow) / CGFloat(boss.vitalisCap))
        playerHpBar?.drip(CGFloat(player.vitalisNow) / CGFloat(player.vitalisCap))
        bossHpLbl?.text = "\(boss.vitalisNow)/\(boss.vitalisCap)"
        playerHpLbl?.text = "\(player.vitalisNow)/\(player.vitalisCap)"
    }

    // MARK: - Update loop (timer countdown)

    override func update(_ currentTime: TimeInterval) {
        guard roundActive, !gameOver else { return }

        if lastUpdate == 0 {
            lastUpdate = currentTime
            return
        }
        let dt = currentTime - lastUpdate
        lastUpdate = currentTime
        timeLeft  -= dt

        let ratio = CGFloat(max(0, timeLeft) / timeLimit)
        timerBar?.drip(ratio)

        // Change timer color as it runs out
        if ratio < 0.25 {
            timerBar?.drip(ratio) // already called above, just visual cue
            TremorPulse.pulse(node: timerBar ?? SKNode(), scale: 1.02, duration: 0.08)
        }

        if timeLeft <= 0 {
            // Timeout — treat as wrong answer
            if let cam = cameraNode {
                let pt = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                PhantomNumeral.manifestText(text: "TOO SLOW!", tint: NacrePalette.ember,
                                            at: pt, in: cam, scale: gauge())
            }
            resolveHit(correct: false)
        }
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pt    = touch.location(in: self)
        let nodes = nodes(at: pt)

        if let popup = childNode(withName: "reflex_popup") {
            if nodes.contains(where: { $0.name == "popup_primary" }) {
                popup.removeFromParent()
                portcullis?.beckon(.foyer)
            }
            return
        }

        if nodes.contains(where: { $0.name == sigilBack })     { portcullis?.beckon(.foyer); return }
        if nodes.contains(where: { $0.name == sigilMordant })  { resolveHit(correct: .mordant  == counter(for: currentSymbol)); return }
        if nodes.contains(where: { $0.name == sigilArcanum })  { resolveHit(correct: .arcanum  == counter(for: currentSymbol)); return }
        if nodes.contains(where: { $0.name == sigilLenitive }) { resolveHit(correct: .lenitive == counter(for: currentSymbol)); return }
        if nodes.contains(where: { $0.name == sigilPavis })    { resolveHit(correct: .pavis    == counter(for: currentSymbol)); return }
    }
}
