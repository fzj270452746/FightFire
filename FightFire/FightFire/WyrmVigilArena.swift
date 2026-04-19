//
//  WyrmVigilArena.swift
//  FightFire
//
//  Daily boss challenge scene — player-only attack, 10 free spins per day

import SpriteKit

final class WyrmVigilArena: VesperStage {
    private let sigilEgress  = "wyrm_back"
    private let sigilWhorl   = "wyrm_spin"

    private let vigil = WyrmVigilCodex.monad
    private var votary: GloamFighter
    private var cameraNode: SKNode?
    private var stasis = false

    // UI refs
    private var bossHpBar: SinewBar?
    private var bossHpLabel: SKLabelNode?
    private var spinsLabel: SKLabelNode?
    private var spinButton: GloamButton?
    private var playerSpool: SpoolPylon?

    override init(size: CGSize, reliquary: ReliquaryCodex) {
        self.votary = reliquary.forgeAvatar()
        super.init(size: size, reliquary: reliquary)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        isUserInteractionEnabled = true
    }

    override func laceLayout() {
        removeAllChildren()

        let camera = SKNode()
        camera.position = .zero
        addChild(camera)
        self.cameraNode = camera

        let backdrop = forgeBackdrop()
        camera.addChild(backdrop)

        let frame = safeFrame()
        let gauge = gauge()
        let midX = frame.midX
        let topY = frame.maxY
        let baseY = frame.minY
        let width = frame.width
        let height = frame.height
        let topInset = view?.safeAreaInsets.top ?? 0
        let adjustedTopY = topY - max(30 * gauge, topInset + 5)

        // Back button
        let backW = tether(width * 0.22, low: 90, high: 160)
        let backH = tether(38 * gauge, low: 32, high: 50)
        let back = GloamButton(span: CGSize(width: backW, height: backH), text: "BACK", tint: NacrePalette.ember)
        back.position = CGPoint(x: frame.minX + backW * 0.6, y: adjustedTopY - 10 * gauge)
        back.name = sigilEgress
        back.zPosition = 100
        camera.addChild(back)

        // Title
        let titleSize = tether(22 * gauge, low: 18, high: 30)
        let title = shimmerLabel(text: "DAILY WYRM", size: titleSize, tint: NacrePalette.auric)
        title.position = CGPoint(x: midX, y: adjustedTopY - 10 * gauge)
        camera.addChild(title)

        // === BOSS SECTION ===
        let sideMargin: CGFloat = 12
        let avatarSize = tether(height * 0.085, low: 40, high: 68)
        let avatarPad: CGFloat = 8
        let barWidth = frame.width - sideMargin * 2 - avatarSize - avatarPad
        let barHeight = tether(20 * gauge, low: 16, high: 28)
        let statSize = tether(13 * gauge, low: 11, high: 18)
        let iconSize = tether(height * 0.028, low: 18, high: 32)
        let avatarCenterX = frame.minX + sideMargin + avatarSize / 2
        let barCenterX = frame.minX + sideMargin + avatarSize + avatarPad + barWidth / 2

        let bossY = adjustedTopY - 70 * gauge

        // Boss name
        let dossier = DreadAtlas.roster().first { $0.tier == vigil.tier }!
        let bossNameSize = tether(18 * gauge, low: 15, high: 26)
        let bossName = shimmerLabel(text: "\(dossier.sobriquet) — TIER \(vigil.tier)", size: bossNameSize, tint: NacrePalette.ember)
        bossName.position = CGPoint(x: midX, y: bossY)
        camera.addChild(bossName)

        let bossBarY = bossY - 30 * gauge

        // Boss avatar
        let bossAvatar = SKSpriteNode(imageNamed: dossier.visage)
        bossAvatar.size = CGSize(width: avatarSize, height: avatarSize)
        bossAvatar.position = CGPoint(x: avatarCenterX, y: bossBarY)
        camera.addChild(bossAvatar)

        // Boss HP bar
        let bossBar = SinewBar(span: barWidth, height: barHeight, tint: NacrePalette.ember, back: NacrePalette.onyx)
        bossBar.position = CGPoint(x: barCenterX, y: bossBarY)
        camera.addChild(bossBar)
        self.bossHpBar = bossBar

        // Boss HP label
        let bossStatsY = bossBarY - 22 * gauge
        let bossHpIcon = SKSpriteNode(imageNamed: "game-heart")
        bossHpIcon.size = CGSize(width: iconSize, height: iconSize)
        bossHpIcon.position = CGPoint(x: barCenterX - barWidth * 0.3, y: bossStatsY)
        camera.addChild(bossHpIcon)

        let hpLbl = shimmerLabel(text: "\(vigil.bossHpNow)/\(vigil.bossHpCap)", size: statSize, tint: NacrePalette.frost)
        hpLbl.horizontalAlignmentMode = .left
        hpLbl.position = CGPoint(x: bossHpIcon.position.x + iconSize * 0.7, y: bossStatsY)
        camera.addChild(hpLbl)
        self.bossHpLabel = hpLbl

        // Spins remaining label
        let spinsY = bossStatsY - 28 * gauge
        let spinsLbl = shimmerLabel(
            text: vigil.defeated ? "BOSS DEFEATED!" : "FREE SPINS: \(vigil.spinsLeft)/\(WyrmVigilCodex.freeSpinsPerDay)",
            size: tether(15 * gauge, low: 12, high: 20),
            tint: vigil.defeated ? NacrePalette.verdigris : NacrePalette.auric
        )
        spinsLbl.position = CGPoint(x: midX, y: spinsY)
        camera.addChild(spinsLbl)
        self.spinsLabel = spinsLbl

        // === PLAYER SLOT MACHINE ===
        let slotWidth = tether(width * 0.82, low: 260, high: 500)
        let slotHeight = slotWidth / 3.5
        let slotY = baseY + height * 0.32

        let spool = SpoolPylon(timbre: .fray, span: CGSize(width: slotWidth, height: slotHeight))
        spool.position = CGPoint(x: midX, y: slotY)
        camera.addChild(spool)
        self.playerSpool = spool

        // Spin button
        let spinW = tether(width * 0.65, low: 220, high: 420)
        let spinH = tether(60 * gauge, low: 48, high: 80)
        let canSpin = vigil.spinsLeft > 0 && !vigil.defeated
        let spin = GloamButton(
            span: CGSize(width: spinW, height: spinH),
            text: vigil.defeated ? "COMPLETED" : (vigil.spinsLeft > 0 ? "SPIN" : "CLAIM REWARD"),
            tint: canSpin ? NacrePalette.verdigris : NacrePalette.glaucous
        )
        spin.position = CGPoint(x: midX, y: slotY - slotHeight * 0.7 - spinH * 0.7)
        spin.name = sigilWhorl
        spin.zPosition = 50
        spin.alpha = canSpin ? 1.0 : 0.85
        camera.addChild(spin)
        self.spinButton = spin

        // Tip
        let tipSize = tether(12 * gauge, low: 10, high: 16)
        let tip = shimmerLabel(text: "Attack only — deal as much damage as possible!", size: tipSize, tint: NacrePalette.glaucous)
        tip.position = CGPoint(x: midX, y: spin.position.y - spinH * 0.8)
        tip.alpha = 0.7
        camera.addChild(tip)

        refreshBossHp()
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let nodes = nodes(at: point)

        if let popup = childNode(withName: "wyrm_popup") {
            if nodes.contains(where: { $0.name == "popup_primary" }) {
                popup.removeFromParent()
                portcullis?.beckon(.foyer)
            }
            return
        }

        if nodes.contains(where: { $0.name == sigilEgress }) {
            portcullis?.beckon(.foyer)
            return
        }

        if nodes.contains(where: { $0.name == sigilWhorl }) {
            handleSpinTap()
        }
    }

    // MARK: - Spin logic

    private func handleSpinTap() {
        guard !stasis else { return }

        // No spins left or already defeated — claim reward
        if vigil.spinsLeft == 0 || vigil.defeated {
            claimReward()
            return
        }

        stasis = true
        vigil.consumeSpin()
        updateSpinsLabel()

        let jackpot: Double = 0.33
        playerSpool?.gyrate(jackpotChance: jackpot) { [weak self] tally in
            guard let self = self else { return }
            self.resolveOutcome(tally: tally)
        }
    }

    private func resolveOutcome(tally: OmenTally) {
        let frame = safeFrame()
        let targetPos = CGPoint(x: frame.midX, y: frame.midY + frame.height * 0.1)

        if tally.triune, let crest = tally.crest {
            switch crest {
            case .mordant:
                let dmg = votary.glaive
                vigil.applyDamage(dmg)
                showFloating(value: dmg, cast: .damage, at: targetPos)
                if let cam = cameraNode { TremorPulse.quake(node: cam, magnitude: .moderate) }

            case .arcanum:
                let dmg = votary.arcanumBlow()
                vigil.applyDamage(dmg)
                showFloating(value: dmg, cast: .damage, at: targetPos)
                if let cam = cameraNode {
                    EtherealMote.conjure(archetype: .sparkle, at: targetPos, in: cam)
                    TremorPulse.quake(node: cam, magnitude: .intense)
                }

            case .lenitive:
                // Heal has no effect on boss-only mode — show miss
                if let cam = cameraNode {
                    PhantomNumeral.manifestText(text: "MISS", tint: NacrePalette.glaucous, at: targetPos, in: cam, scale: gauge())
                }

            case .pavis:
                // Shield has no effect — show miss
                if let cam = cameraNode {
                    PhantomNumeral.manifestText(text: "MISS", tint: NacrePalette.glaucous, at: targetPos, in: cam, scale: gauge())
                }
            }
        } else {
            // No match
            if let cam = cameraNode {
                PhantomNumeral.manifestText(text: "NO MATCH", tint: SKColor.gray, at: targetPos, in: cam, scale: gauge())
            }
        }

        refreshBossHp()

        let delay = SKAction.wait(forDuration: 1.2)
        run(delay) { [weak self] in
            guard let self = self else { return }
            self.stasis = false

            if self.vigil.defeated {
                self.claimReward()
                return
            }

            if self.vigil.spinsLeft == 0 {
                self.claimReward()
                return
            }
        }
    }

    // MARK: - Reward

    private func claimReward() {
        let reward = vigil.calcReward()
        reliquary.mint(reward)

        let title = vigil.defeated ? "WYRM SLAIN!" : "SPINS EXHAUSTED"
        let dmgDealt = vigil.bossHpCap - vigil.bossHpNow
        let body = vigil.defeated
            ? "Tier \(vigil.tier) boss defeated!\nReward: +\(reward) coins"
            : "Damage dealt: \(dmgDealt)/\(vigil.bossHpCap)\nReward: +\(reward) coins"

        let popup = GossamerPopup(span: size, title: title, body: body, primary: "OK", secondary: nil)
        popup.name = "wyrm_popup"
        addChild(popup)

        spinButton?.alpha = 0.5
    }

    // MARK: - UI refresh

    private func refreshBossHp() {
        let ratio = CGFloat(vigil.bossHpNow) / CGFloat(vigil.bossHpCap)
        bossHpBar?.drip(ratio)
        bossHpLabel?.text = "\(vigil.bossHpNow)/\(vigil.bossHpCap)"
    }

    private func updateSpinsLabel() {
        spinsLabel?.text = vigil.defeated
            ? "BOSS DEFEATED!"
            : "FREE SPINS: \(vigil.spinsLeft)/\(WyrmVigilCodex.freeSpinsPerDay)"
        spinsLabel?.fontColor = vigil.defeated ? NacrePalette.verdigris : NacrePalette.auric
    }

    private func showFloating(value: Int, cast: NumeralCast, at pos: CGPoint) {
        guard let cam = cameraNode else { return }
        EtherealMote.conjure(archetype: .damage, at: pos, in: cam)
        PhantomNumeral.manifest(value: value, cast: cast, at: pos, in: cam, scale: gauge())
    }
}
