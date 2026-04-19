//
//  GambolFray.swift
//  FightFire
//

import SpriteKit

final class GambolFray: VesperStage {
    private let sigilRetreat = "nav_back"
    private let sigilWhorl = "spin_button"

    private var votary: GloamFighter
    private var tyrant: GloamFighter
    private let dossier: TyrantDraft

    private var votarySinew: SinewBar?
    private var tyrantSinew: SinewBar?
    private var votaryPavis: SKLabelNode?
    private var tyrantPavis: SKLabelNode?
    private var votaryHpLabel: SKLabelNode?
    private var tyrantHpLabel: SKLabelNode?
    private var votarySpool: SpoolPylon?
    private var tyrantSpool: SpoolPylon?
    private var spinButton: GloamButton?
    private var stasis = false
    private var votaryTurn = true

    // Jackpot probabilities: chance to force 3 matching symbols
    // Player: fixed 33%; Boss: scales linearly with tier (tier1≈12% → tier15≈68%)
    private let votaryJackpotChance: Double = 0.33
    private var tyrantJackpotChance: Double {
        return min(0.80, 0.08 + Double(dossier.tier) * 0.04)
    }

    // New features
    private var zenithChain = ZenithChain()
    private var comboLabel: SKLabelNode?
    private var usedShield = false
    private var startingHealth: Int = 0
    private var cameraNode: SKNode?

    init(size: CGSize, reliquary: ReliquaryCodex, dossier: TyrantDraft) {
        self.dossier = dossier
        self.votary = reliquary.forgeAvatar()
        self.tyrant = GloamFighter(glaive: dossier.glaive, vitalisCap: dossier.vitalis, vitalisNow: dossier.vitalis, pavis: 0, arcanum: dossier.arcanum, pavisGain: dossier.pavisGain)
        self.startingHealth = self.votary.vitalisNow
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

        // Create camera node for shake effects
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

        // Adjust for status bar
        let topInset = view?.safeAreaInsets.top ?? 0
        let adjustedTopY = topY - max(30 * gauge, topInset + 5)

        // QUIT button - top left
        let quitWidth = tether(width * 0.22, low: 90, high: 160)
        let quitHeight = tether(38 * gauge, low: 32, high: 50)
        let quit = GloamButton(span: CGSize(width: quitWidth, height: quitHeight), text: "QUIT", tint: NacrePalette.ember)
        quit.position = CGPoint(x: frame.minX + quitWidth * 0.6, y: adjustedTopY - 10 * gauge)
        quit.name = sigilRetreat
        quit.zPosition = 100
        camera.addChild(quit)

        // Shared layout constants — bar width derived from available space after avatar
        let sideMargin: CGFloat = 12
        let avatarSize = tether(height * 0.085, low: 40, high: 68)
        let avatarPad: CGFloat = 8
        let barWidth = frame.width - sideMargin * 2 - avatarSize - avatarPad
        let barHeight = tether(20 * gauge, low: 16, high: 28)
        let statSize = tether(13 * gauge, low: 11, high: 18)
        let iconSize = tether(height * 0.028, low: 18, high: 32)
        // Avatar left-anchored; bar fills the rest of the row
        let avatarCenterX = frame.minX + sideMargin + avatarSize / 2
        let barCenterX = frame.minX + sideMargin + avatarSize + avatarPad + barWidth / 2

        // === BOSS SECTION (TOP) ===
        let bossY = adjustedTopY - 60 * gauge

        // Boss name and tier
        let bossNameSize = tether(18 * gauge, low: 15, high: 26)
        let bossName = shimmerLabel(text: "\(dossier.sobriquet) - TIER \(dossier.tier)", size: bossNameSize, tint: NacrePalette.ember)
        bossName.position = CGPoint(x: midX, y: bossY)
        camera.addChild(bossName)

        let bossBarY = bossY - 30 * gauge

        // Boss avatar - left of HP bar
        let bossAvatar = SKSpriteNode(imageNamed: dossier.visage)
        bossAvatar.size = CGSize(width: avatarSize, height: avatarSize)
        bossAvatar.position = CGPoint(x: avatarCenterX, y: bossBarY)
        camera.addChild(bossAvatar)

        // Boss HP bar
        let bossBar = SinewBar(span: barWidth, height: barHeight, tint: NacrePalette.ember, back: NacrePalette.onyx)
        bossBar.position = CGPoint(x: barCenterX, y: bossBarY)
        camera.addChild(bossBar)
        self.tyrantSinew = bossBar

        // Boss stats - single row: HP / ATK / SKILL / SHIELD
        let bossStatsY = bossBarY - 22 * gauge

        let bossHpIcon = SKSpriteNode(imageNamed: "game-heart")
        bossHpIcon.size = CGSize(width: iconSize, height: iconSize)
        bossHpIcon.position = CGPoint(x: barCenterX - barWidth * 0.375, y: bossStatsY)
        camera.addChild(bossHpIcon)
        let bossHpLabel = shimmerLabel(text: "\(tyrant.vitalisNow)/\(tyrant.vitalisCap)", size: statSize, tint: NacrePalette.frost)
        bossHpLabel.position = CGPoint(x: bossHpIcon.position.x + iconSize * 0.7, y: bossStatsY)
        bossHpLabel.horizontalAlignmentMode = .left
        camera.addChild(bossHpLabel)
        self.tyrantHpLabel = bossHpLabel

        let bossAtkIcon = SKSpriteNode(imageNamed: "game-attack")
        bossAtkIcon.size = CGSize(width: iconSize, height: iconSize)
        bossAtkIcon.position = CGPoint(x: barCenterX - barWidth * 0.125, y: bossStatsY)
        camera.addChild(bossAtkIcon)
        let bossAtkLabel = shimmerLabel(text: "\(tyrant.glaive)", size: statSize, tint: NacrePalette.frost)
        bossAtkLabel.position = CGPoint(x: bossAtkIcon.position.x + iconSize * 0.7, y: bossStatsY)
        bossAtkLabel.horizontalAlignmentMode = .left
        camera.addChild(bossAtkLabel)

        let bossSkillIcon = SKSpriteNode(imageNamed: "game-skill")
        bossSkillIcon.size = CGSize(width: iconSize, height: iconSize)
        bossSkillIcon.position = CGPoint(x: barCenterX + barWidth * 0.125, y: bossStatsY)
        camera.addChild(bossSkillIcon)
        let bossSkillLabel = shimmerLabel(text: "\(Int(tyrant.arcanum * 100))%", size: statSize, tint: NacrePalette.frost)
        bossSkillLabel.position = CGPoint(x: bossSkillIcon.position.x + iconSize * 0.7, y: bossStatsY)
        bossSkillLabel.horizontalAlignmentMode = .left
        camera.addChild(bossSkillLabel)

        let bossShieldIcon = SKSpriteNode(imageNamed: "game-defense")
        bossShieldIcon.size = CGSize(width: iconSize, height: iconSize)
        bossShieldIcon.position = CGPoint(x: barCenterX + barWidth * 0.375, y: bossStatsY)
        camera.addChild(bossShieldIcon)
        let bossShield = shimmerLabel(text: "\(tyrant.pavis)", size: statSize, tint: NacrePalette.glaucous)
        bossShield.position = CGPoint(x: bossShieldIcon.position.x + iconSize * 0.7, y: bossStatsY)
        bossShield.horizontalAlignmentMode = .left
        camera.addChild(bossShield)
        self.tyrantPavis = bossShield

        // Boss slot machine
        let slotWidth = tether(width * 0.82, low: 260, high: 500)
        let slotHeight = slotWidth / 3.5
        let bossSlotY = bossStatsY - iconSize * 1.2 - slotHeight * 0.5

        let bossSpool = SpoolPylon(timbre: .fray, span: CGSize(width: slotWidth, height: slotHeight))
        bossSpool.position = CGPoint(x: midX, y: bossSlotY)
        camera.addChild(bossSpool)
        self.tyrantSpool = bossSpool

        // === CENTER SPIN BUTTON ===
        let centerY = (bossSlotY + baseY + height * 0.25) / 2
        let spinWidth = tether(width * 0.65, low: 220, high: 420)
        let spinHeight = tether(60 * gauge, low: 48, high: 80)
        let spin = GloamButton(span: CGSize(width: spinWidth, height: spinHeight), text: "PLAYER SPIN", tint: NacrePalette.verdigris)
        spin.position = CGPoint(x: midX, y: centerY)
        spin.name = sigilWhorl
        spin.zPosition = 50
        camera.addChild(spin)
        self.spinButton = spin

        // Combo display
        let comboSize = tether(16 * gauge, low: 13, high: 24)
        let combo = shimmerLabel(text: "", size: comboSize, tint: NacrePalette.auric)
        combo.position = CGPoint(x: midX, y: centerY + spinHeight * 0.8)
        combo.alpha = 0
        camera.addChild(combo)
        self.comboLabel = combo

        // === PLAYER SECTION (BOTTOM) ===
        let playerSlotY = baseY + height * 0.25

        let playerSpool = SpoolPylon(timbre: .fray, span: CGSize(width: slotWidth, height: slotHeight))
        playerSpool.position = CGPoint(x: midX, y: playerSlotY)
        camera.addChild(playerSpool)
        self.votarySpool = playerSpool

        let playerBarY = playerSlotY + slotHeight * 0.7 + 25 * gauge

        // Player avatar - left of HP bar
        let playerAvatar = SKSpriteNode(imageNamed: "game-player")
        playerAvatar.size = CGSize(width: avatarSize, height: avatarSize)
        playerAvatar.position = CGPoint(x: avatarCenterX, y: playerBarY)
        camera.addChild(playerAvatar)

        // Player HP bar
        let playerBar = SinewBar(span: barWidth, height: barHeight, tint: NacrePalette.verdigris, back: NacrePalette.onyx)
        playerBar.position = CGPoint(x: barCenterX, y: playerBarY)
        camera.addChild(playerBar)
        self.votarySinew = playerBar

        // Player stats - single row: HP / ATK / SKILL / SHIELD
        let playerStatsY = playerBarY - 22 * gauge

        let playerHpIcon = SKSpriteNode(imageNamed: "game-heart")
        playerHpIcon.size = CGSize(width: iconSize, height: iconSize)
        playerHpIcon.position = CGPoint(x: barCenterX - barWidth * 0.375, y: playerStatsY)
        camera.addChild(playerHpIcon)
        let playerHpLabel = shimmerLabel(text: "\(votary.vitalisNow)/\(votary.vitalisCap)", size: statSize, tint: NacrePalette.frost)
        playerHpLabel.position = CGPoint(x: playerHpIcon.position.x + iconSize * 0.7, y: playerStatsY)
        playerHpLabel.horizontalAlignmentMode = .left
        camera.addChild(playerHpLabel)
        self.votaryHpLabel = playerHpLabel

        let playerAtkIcon = SKSpriteNode(imageNamed: "game-attack")
        playerAtkIcon.size = CGSize(width: iconSize, height: iconSize)
        playerAtkIcon.position = CGPoint(x: barCenterX - barWidth * 0.125, y: playerStatsY)
        camera.addChild(playerAtkIcon)
        let playerAtkLabel = shimmerLabel(text: "\(votary.glaive)", size: statSize, tint: NacrePalette.frost)
        playerAtkLabel.position = CGPoint(x: playerAtkIcon.position.x + iconSize * 0.7, y: playerStatsY)
        playerAtkLabel.horizontalAlignmentMode = .left
        camera.addChild(playerAtkLabel)

        let playerSkillIcon = SKSpriteNode(imageNamed: "game-skill")
        playerSkillIcon.size = CGSize(width: iconSize, height: iconSize)
        playerSkillIcon.position = CGPoint(x: barCenterX + barWidth * 0.125, y: playerStatsY)
        camera.addChild(playerSkillIcon)
        let playerSkillLabel = shimmerLabel(text: "\(Int(votary.arcanum * 100))%", size: statSize, tint: NacrePalette.frost)
        playerSkillLabel.position = CGPoint(x: playerSkillIcon.position.x + iconSize * 0.7, y: playerStatsY)
        playerSkillLabel.horizontalAlignmentMode = .left
        camera.addChild(playerSkillLabel)

        let playerShieldIcon = SKSpriteNode(imageNamed: "game-defense")
        playerShieldIcon.size = CGSize(width: iconSize, height: iconSize)
        playerShieldIcon.position = CGPoint(x: barCenterX + barWidth * 0.375, y: playerStatsY)
        camera.addChild(playerShieldIcon)
        let playerShield = shimmerLabel(text: "\(votary.pavis)", size: statSize, tint: NacrePalette.glaucous)
        playerShield.position = CGPoint(x: playerShieldIcon.position.x + iconSize * 0.7, y: playerStatsY)
        playerShield.horizontalAlignmentMode = .left
        camera.addChild(playerShield)
        self.votaryPavis = playerShield

        refreshSinew()
    }

    private func refreshSinew() {
        let votaryRatio = CGFloat(votary.vitalisNow) / CGFloat(votary.vitalisCap)
        let tyrantRatio = CGFloat(tyrant.vitalisNow) / CGFloat(tyrant.vitalisCap)
        votarySinew?.drip(votaryRatio)
        tyrantSinew?.drip(tyrantRatio)
        votaryHpLabel?.text = "\(votary.vitalisNow)/\(votary.vitalisCap)"
        tyrantHpLabel?.text = "\(tyrant.vitalisNow)/\(tyrant.vitalisCap)"
        votaryPavis?.text = "\(votary.pavis)"
        tyrantPavis?.text = "\(tyrant.pavis)"
    }

    private func updateSpinButton() {
        // isUserInteractionEnabled stays false — touches handled in scene's touchesBegan
        if votaryTurn {
            spinButton?.retitle("PLAYER SPIN")
            spinButton?.gleam(NacrePalette.verdigris)
            spinButton?.alpha = 1.0
        } else {
            spinButton?.retitle("BOSS SPIN")
            spinButton?.gleam(NacrePalette.ember)
            spinButton?.alpha = 0.7
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let nodes = nodes(at: point)

        if nodes.contains(where: { $0.name == sigilRetreat }) {
            portcullis?.beckon(.foyer)
            return
        }

        if nodes.contains(where: { $0.name == sigilWhorl }) {
            if votaryTurn && !stasis {
                provokeVotarySpin()
            }
        }
    }

    private func provokeVotarySpin() {
        guard votaryTurn, !stasis else { return }
        stasis = true
        votarySpool?.gyrate(jackpotChance: votaryJackpotChance) { [weak self] tally in
            guard let self = self else { return }
            self.imbueOutcome(tally: tally, agent: .votary)
        }
    }

    private func provokeTyrantSpin() {
        guard !votaryTurn else { return }
        tyrantSpool?.gyrate(jackpotChance: tyrantJackpotChance) { [weak self] tally in
            guard let self = self else { return }
            self.imbueOutcome(tally: tally, agent: .tyrant)
        }
    }

    private enum DuelCast {
        case votary
        case tyrant
    }

    private func sealTurn(note: String, agent: DuelCast) {
        let delay = SKAction.wait(forDuration: 1.5)
        let next = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.votary.vitalisNow <= 0 || self.tyrant.vitalisNow <= 0 {
                self.finalizeDuel()
            } else {
                self.votaryTurn.toggle()
                self.updateSpinButton()
                self.stasis = false
                if !self.votaryTurn {
                    let bossDelay = SKAction.wait(forDuration: 0.8)
                    let bossSpin = SKAction.run { [weak self] in
                        self?.provokeTyrantSpin()
                    }
                    self.run(SKAction.sequence([bossDelay, bossSpin]))
                }
            }
        }
        run(SKAction.sequence([delay, next]))
    }

    private func imbueOutcome(tally: OmenTally, agent: DuelCast) {
        let triune = tally.triune
        let crest = tally.crest
        let frame = safeFrame()
        let targetPos = agent == .votary ? CGPoint(x: frame.midX, y: frame.maxY * 0.7) : CGPoint(x: frame.midX, y: frame.minY + frame.height * 0.3)

        if triune, let crest {
            if agent == .votary {
                zenithChain.surge()
                updateComboDisplay()
                if zenithChain.tally >= 5 {
                    _ = reliquary.laurelCodex.unlock(.maxCombo)
                }
            }

            let multiplier = agent == .votary ? zenithChain.multiplier() : 1.0

            switch crest {
            case .mordant:
                let baseStrike = agent == .votary ? votary.glaive : tyrant.glaive
                let strike = Int(Double(baseStrike) * multiplier)
                let wound = agent == .votary ? tyrant.scar(strike) : votary.scar(strike)

                if let camera = cameraNode {
                    if wound > 0 {
                        EtherealMote.conjure(archetype: .damage, at: targetPos, in: camera)
                        PhantomNumeral.manifest(value: wound, cast: .damage, at: targetPos, in: camera, scale: gauge())
                        TremorPulse.quake(node: camera, magnitude: .moderate)
                    } else {
                        EtherealMote.conjure(archetype: .shield, at: targetPos, in: camera)
                        PhantomNumeral.manifestText(text: "BLOCKED!", tint: NacrePalette.glaucous, at: targetPos, in: camera, scale: gauge())
                    }
                }

            case .lenitive:
                let maxVitalis = agent == .votary ? votary.vitalisCap : tyrant.vitalisCap
                let heal = max(1, Int(Double(maxVitalis) * 0.05))
                if agent == .votary {
                    votary.succor(heal)
                } else {
                    tyrant.succor(heal)
                }

                if let camera = cameraNode {
                    EtherealMote.conjure(archetype: .heal, at: targetPos, in: camera)
                    PhantomNumeral.manifest(value: heal, cast: .heal, at: targetPos, in: camera, scale: gauge())
                }

            case .pavis:
                let gain = agent == .votary ? votary.pavisGain : tyrant.pavisGain
                if agent == .votary {
                    votary.bastion(gain)
                    if votary.pavis > 0 {
                        usedShield = true
                    }
                } else {
                    tyrant.bastion(gain)
                }

                if let camera = cameraNode {
                    EtherealMote.conjure(archetype: .shield, at: targetPos, in: camera)
                    PhantomNumeral.manifest(value: gain, cast: .shield, at: targetPos, in: camera, scale: gauge())
                }

            case .arcanum:
                let baseStrike = agent == .votary ? votary.arcanumBlow() : tyrant.arcanumBlow()
                let strike = Int(Double(baseStrike) * multiplier)
                let wound = agent == .votary ? tyrant.scar(strike) : votary.scar(strike)

                if let camera = cameraNode {
                    if wound > 0 {
                        EtherealMote.conjure(archetype: .damage, at: targetPos, in: camera)
                        EtherealMote.conjure(archetype: .sparkle, at: targetPos, in: camera)
                        PhantomNumeral.manifest(value: wound, cast: .damage, at: targetPos, in: camera, scale: gauge())
                        TremorPulse.quake(node: camera, magnitude: .intense)
                    } else {
                        EtherealMote.conjure(archetype: .shield, at: targetPos, in: camera)
                        PhantomNumeral.manifestText(text: "BLOCKED!", tint: NacrePalette.glaucous, at: targetPos, in: camera, scale: gauge())
                    }
                }
            }
        } else {
            if agent == .votary {
                zenithChain.rupture()
                updateComboDisplay()
            }
        }

        refreshSinew()
        sealTurn(note: "", agent: agent)
    }

    private func finalizeDuel() {
        let win = tyrant.vitalisNow <= 0 && votary.vitalisNow > 0

        if win {
            reliquary.mint(dossier.largess)
            reliquary.ascendSummit(dossier.tier)
            reliquary.recordVictory(maxCombo: zenithChain.apex)

            if !usedShield {
                _ = reliquary.laurelCodex.unlock(.noShieldWin)
            }
            if votary.vitalisNow == startingHealth {
                _ = reliquary.laurelCodex.unlock(.perfectHealth)
            }

            if let camera = cameraNode {
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                EtherealMote.conjure(archetype: .victory, at: center, in: camera)
            }
        } else {
            reliquary.recordDefeat()

            if let camera = cameraNode {
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                EtherealMote.conjure(archetype: .defeat, at: center, in: camera)
            }
        }

        let title = win ? "VICTORY!" : "DEFEAT"
        var body = win ? "Reward: +\(dossier.largess) coins" : "Try again to claim the reward"
        if win && zenithChain.apex >= 3 {
            body += "\nMax Combo: \(zenithChain.apex)x"
        }

        let popup = GossamerPopup(span: size, title: title, body: body, primary: "OK", secondary: nil)
        popup.name = "popup_result"
        addChild(popup)
    }

    private func updateComboDisplay() {
        guard let comboLabel = comboLabel else { return }

        let grade = zenithChain.chromaGrade()
        if zenithChain.tally >= 2 {
            comboLabel.text = grade.epithet
            let hue = grade.hue
            comboLabel.fontColor = SKColor(red: hue.r, green: hue.g, blue: hue.b, alpha: 1.0)
            comboLabel.alpha = 1.0

            TremorPulse.pulse(node: comboLabel, scale: 1.3, duration: 0.2)

            if let camera = cameraNode {
                EtherealMote.conjure(archetype: .combo, at: comboLabel.position, in: camera)
            }
        } else {
            let fade = SKAction.fadeOut(withDuration: 0.3)
            comboLabel.run(fade)
        }
    }
}
