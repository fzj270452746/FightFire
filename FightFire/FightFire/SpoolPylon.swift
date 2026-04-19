//
//  SpoolPylon.swift
//  FightFire
//

import SpriteKit

final class SpoolPylon: SKNode {
    private let timbre: SigilTimbre
    private let reelSprites: [SKSpriteNode]
    private let glyphs: [OmenGlyph]
    private var torpor = false

    init(timbre: SigilTimbre, span: CGSize) {
        self.timbre = timbre
        self.glyphs = OmenGlyph.allCases

        let cellWidth = span.width / 3.0
        let symbolSize = CGSize(width: cellWidth * 0.62, height: span.height * 0.62)
        var sprites: [SKSpriteNode] = []
        for idx in 0..<3 {
            let glyph = glyphs.randomElement() ?? .mordant
            let sprite = SKSpriteNode(imageNamed: glyph.sigilName(timbre: timbre))
            sprite.size = symbolSize
            sprite.position = CGPoint(
                x: (-span.width * 0.5) + cellWidth * (CGFloat(idx) + 0.5),
                y: 0
            )
            sprite.zPosition = 0
            sprites.append(sprite)
        }
        self.reelSprites = sprites
        super.init()
        buildCabinet(span: span, cellWidth: cellWidth)
        sprites.forEach { addChild($0) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Cabinet

    private func buildCabinet(span: CGSize, cellWidth: CGFloat) {
        // Outer bevel ring (gold halo)
        let bevel = SKShapeNode(rectOf: CGSize(width: span.width + 8, height: span.height + 8),
                                cornerRadius: 16)
        bevel.fillColor = NacrePalette.auric.withAlphaComponent(0.35)
        bevel.strokeColor = .clear
        bevel.zPosition = -12
        addChild(bevel)

        // Main cabinet body
        let body = SKShapeNode(rectOf: span, cornerRadius: 13)
        body.fillColor = SKColor(red: 0.10, green: 0.11, blue: 0.16, alpha: 1.0)
        body.strokeColor = NacrePalette.auric
        body.lineWidth = 2.5
        body.glowWidth = 12
        body.zPosition = -11
        addChild(body)

        // Top edge highlight (gives a lit-from-above look)
        let highlight = SKShapeNode(rectOf: CGSize(width: span.width - 10, height: 2))
        highlight.position = CGPoint(x: 0, y: span.height * 0.5 - 4)
        highlight.fillColor = SKColor.white.withAlphaComponent(0.18)
        highlight.strokeColor = .clear
        highlight.zPosition = -10
        addChild(highlight)

        // Individual reel cells
        let pad: CGFloat = 6
        let reelW = cellWidth - pad * 2
        let reelH = span.height - pad * 2
        for idx in 0..<3 {
            let cx = (-span.width * 0.5) + cellWidth * (CGFloat(idx) + 0.5)

            // Cell drop-shadow
            let shadow = SKShapeNode(
                rectOf: CGSize(width: reelW + 2, height: reelH + 2),
                cornerRadius: 10)
            shadow.position = CGPoint(x: cx + 1, y: -2)
            shadow.fillColor = SKColor.black.withAlphaComponent(0.55)
            shadow.strokeColor = .clear
            shadow.zPosition = -9
            addChild(shadow)

            // Cell background
            let cell = SKShapeNode(rectOf: CGSize(width: reelW, height: reelH), cornerRadius: 9)
            cell.position = CGPoint(x: cx, y: 0)
            cell.fillColor = SKColor(red: 0.05, green: 0.05, blue: 0.09, alpha: 1.0)
            cell.strokeColor = NacrePalette.glaucous.withAlphaComponent(0.45)
            cell.lineWidth = 1.5
            cell.zPosition = -8
            addChild(cell)

            // Inner cell top-gloss (subtle white arc at top)
            let gloss = SKShapeNode(rectOf: CGSize(width: reelW - 6, height: 3), cornerRadius: 2)
            gloss.position = CGPoint(x: cx, y: reelH * 0.5 - 5)
            gloss.fillColor = SKColor.white.withAlphaComponent(0.10)
            gloss.strokeColor = .clear
            gloss.zPosition = -7
            addChild(gloss)
        }

        // Vertical dividers between cells
        for idx in 1..<3 {
            let dx = (-span.width * 0.5) + cellWidth * CGFloat(idx)
            let divider = SKShapeNode(rectOf: CGSize(width: 3, height: span.height - 8))
            divider.position = CGPoint(x: dx, y: 0)
            divider.fillColor = NacrePalette.auric.withAlphaComponent(0.55)
            divider.strokeColor = .clear
            divider.zPosition = -6
            addChild(divider)
        }

        // Payline — golden horizontal center line
        let payline = SKShapeNode(rectOf: CGSize(width: span.width - 6, height: 2.5))
        payline.fillColor = NacrePalette.auric
        payline.strokeColor = .clear
        payline.glowWidth = 9
        payline.alpha = 0.80
        payline.zPosition = 25
        addChild(payline)

        // Payline left/right arrow markers
        for side: CGFloat in [-1, 1] {
            let arrow = SKLabelNode(text: side < 0 ? "▶" : "◀")
            arrow.fontSize = span.height * 0.22
            arrow.fontColor = NacrePalette.auric
            arrow.verticalAlignmentMode = .center
            arrow.position = CGPoint(x: side * (span.width * 0.5 + span.height * 0.18), y: 0)
            arrow.zPosition = 25
            addChild(arrow)
        }

        // Corner studs
        let studR: CGFloat = 4.5
        let margin: CGFloat = studR + 5
        let corners: [CGPoint] = [
            CGPoint(x: -span.width * 0.5 + margin, y:  span.height * 0.5 - margin),
            CGPoint(x:  span.width * 0.5 - margin, y:  span.height * 0.5 - margin),
            CGPoint(x: -span.width * 0.5 + margin, y: -span.height * 0.5 + margin),
            CGPoint(x:  span.width * 0.5 - margin, y: -span.height * 0.5 + margin),
        ]
        for pt in corners {
            let stud = SKShapeNode(circleOfRadius: studR)
            stud.position = pt
            stud.fillColor = NacrePalette.auric
            stud.strokeColor = SKColor(red: 0.55, green: 0.38, blue: 0.08, alpha: 1.0)
            stud.lineWidth = 1
            stud.glowWidth = 4
            stud.zPosition = 20
            addChild(stud)
        }
    }

    // MARK: - Spin

    func gyrate(jackpotChance: Double = 0, _ completion: @escaping (OmenTally) -> Void) {
        guard !torpor else { return }
        torpor = true

        // Pre-determine results before animation starts
        let results: [OmenGlyph]
        if Double.random(in: 0..<1) < jackpotChance {
            let symbol = glyphs.randomElement() ?? .mordant
            results = [symbol, symbol, symbol]
        } else {
            results = (0..<3).map { _ in glyphs.randomElement() ?? .mordant }
        }

        let baseCadence: TimeInterval = 0.11
        let spins = [10, 12, 14]

        for (idx, reel) in reelSprites.enumerated() {
            let count = spins[idx]
            var sequence: [SKAction] = []

            // Spinning ticks — Y-squeeze simulates reel drum rotation
            for i in 0..<count {
                let glyph = glyphs.randomElement() ?? .mordant

                // Last 3 ticks decelerate
                let distFromEnd = count - 1 - i
                let slowFactor: TimeInterval = distFromEnd < 3
                    ? 1.0 + Double(2 - distFromEnd) * 0.4
                    : 1.0
                let tickDur = baseCadence * slowFactor

                let squish   = SKAction.scaleY(to: 0.04, duration: tickDur * 0.38)
                let change   = SKAction.run { [weak reel] in
                    reel?.texture = SKTexture(imageNamed: glyph.sigilName(timbre: self.timbre))
                }
                let expand   = SKAction.scaleY(to: 1.0,  duration: tickDur * 0.38)
                let hold     = SKAction.wait(forDuration: tickDur * 0.24)
                sequence.append(contentsOf: [squish, change, expand, hold])
            }

            // Final symbol — squish in, set, bounce settle
            let finalGlyph = results[idx]
            let squishFinal = SKAction.scaleY(to: 0.04, duration: baseCadence * 0.55)
            let setFinal    = SKAction.run { [weak reel] in
                reel?.texture = SKTexture(imageNamed: finalGlyph.sigilName(timbre: self.timbre))
            }
            let overshoot   = SKAction.scaleY(to: 1.14, duration: baseCadence * 0.22)
            let settle      = SKAction.scaleY(to: 1.0,  duration: baseCadence * 0.14)
            sequence.append(contentsOf: [squishFinal, setFinal, overshoot, settle])

            let action = SKAction.sequence(sequence)
            reel.run(action) {
                if idx == self.reelSprites.count - 1 {
                    self.torpor = false
                    completion(OmenTally(glyphs: results))
                }
            }
        }
    }

    func seed(_ glyphs: [OmenGlyph]) {
        for (idx, glyph) in glyphs.enumerated() {
            guard idx < reelSprites.count else { continue }
            reelSprites[idx].texture = SKTexture(imageNamed: glyph.sigilName(timbre: timbre))
        }
    }
}
