//
//  EtherealMote.swift
//  FightFire
//
//  Particle effects system

import SpriteKit

enum MoteArchetype {
    case victory
    case defeat
    case damage
    case heal
    case shield
    case combo
    case sparkle
    case glow

    var chromaTint: SKColor {
        switch self {
        case .victory: return SKColor(red: 0.98, green: 0.82, blue: 0.42, alpha: 1.0)
        case .defeat: return SKColor(red: 0.95, green: 0.45, blue: 0.25, alpha: 1.0)
        case .damage: return SKColor(red: 0.95, green: 0.25, blue: 0.25, alpha: 1.0)
        case .heal: return SKColor(red: 0.20, green: 0.78, blue: 0.68, alpha: 1.0)
        case .shield: return SKColor(red: 0.18, green: 0.55, blue: 0.70, alpha: 1.0)
        case .combo: return SKColor(red: 0.98, green: 0.65, blue: 0.25, alpha: 1.0)
        case .sparkle: return SKColor(red: 0.98, green: 0.93, blue: 0.88, alpha: 1.0)
        case .glow: return SKColor(red: 0.86, green: 0.93, blue: 0.98, alpha: 1.0)
        }
    }
}

final class EtherealMote {
    static func conjure(archetype: MoteArchetype, at position: CGPoint, in parent: SKNode) {
        switch archetype {
        case .victory:
            conjureVictory(at: position, in: parent)
        case .defeat:
            conjureDefeat(at: position, in: parent)
        case .damage:
            conjureDamage(at: position, in: parent)
        case .heal:
            conjureHeal(at: position, in: parent)
        case .shield:
            conjureShield(at: position, in: parent)
        case .combo:
            conjureCombo(at: position, in: parent)
        case .sparkle:
            conjureSparkle(at: position, in: parent)
        case .glow:
            conjureGlow(at: position, in: parent)
        }
    }

    private static func conjureVictory(at position: CGPoint, in parent: SKNode) {
        for _ in 0..<30 {
            let mote = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8))
            mote.fillColor = SKColor(red: 0.98, green: 0.82, blue: 0.42, alpha: 1.0)
            mote.strokeColor = .clear
            mote.position = position
            mote.zPosition = 100

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 80...200)
            let endX = position.x + cos(angle) * distance
            let endY = position.y + sin(angle) * distance

            let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 1.2)
            let fade = SKAction.fadeOut(withDuration: 1.2)
            let scale = SKAction.scale(to: 0.3, duration: 1.2)
            let group = SKAction.group([move, fade, scale])
            let remove = SKAction.removeFromParent()

            parent.addChild(mote)
            mote.run(SKAction.sequence([group, remove]))
        }
    }

    private static func conjureDefeat(at position: CGPoint, in parent: SKNode) {
        for _ in 0..<20 {
            let mote = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...10))
            mote.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 0.8)
            mote.strokeColor = .clear
            mote.position = position
            mote.zPosition = 100

            let endY = position.y - CGFloat.random(in: 100...200)
            let endX = position.x + CGFloat.random(in: -50...50)

            let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 1.5)
            let fade = SKAction.fadeOut(withDuration: 1.5)
            let group = SKAction.group([move, fade])
            let remove = SKAction.removeFromParent()

            parent.addChild(mote)
            mote.run(SKAction.sequence([group, remove]))
        }
    }

    private static func conjureDamage(at position: CGPoint, in parent: SKNode) {
        for _ in 0..<15 {
            let mote = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...6))
            mote.fillColor = SKColor(red: 0.95, green: 0.25, blue: 0.25, alpha: 1.0)
            mote.strokeColor = .clear
            mote.position = position
            mote.zPosition = 100

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 30...80)
            let endX = position.x + cos(angle) * distance
            let endY = position.y + sin(angle) * distance

            let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 0.6)
            let fade = SKAction.fadeOut(withDuration: 0.6)
            let group = SKAction.group([move, fade])
            let remove = SKAction.removeFromParent()

            parent.addChild(mote)
            mote.run(SKAction.sequence([group, remove]))
        }
    }

    private static func conjureHeal(at position: CGPoint, in parent: SKNode) {
        for _ in 0..<12 {
            let mote = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...7))
            mote.fillColor = SKColor(red: 0.20, green: 0.78, blue: 0.68, alpha: 1.0)
            mote.strokeColor = .clear
            mote.position = CGPoint(x: position.x + CGFloat.random(in: -30...30),
                                   y: position.y - 50)
            mote.zPosition = 100

            let move = SKAction.moveBy(x: CGFloat.random(in: -20...20),
                                      y: CGFloat.random(in: 80...120),
                                      duration: 1.0)
            let fade = SKAction.fadeOut(withDuration: 1.0)
            let group = SKAction.group([move, fade])
            let remove = SKAction.removeFromParent()

            parent.addChild(mote)
            mote.run(SKAction.sequence([group, remove]))
        }
    }

    private static func conjureShield(at position: CGPoint, in parent: SKNode) {
        let ring = SKShapeNode(circleOfRadius: 60)
        ring.strokeColor = SKColor(red: 0.18, green: 0.55, blue: 0.70, alpha: 1.0)
        ring.lineWidth = 4
        ring.fillColor = .clear
        ring.position = position
        ring.zPosition = 100
        ring.setScale(0.3)

        let scale = SKAction.scale(to: 1.5, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        let group = SKAction.group([scale, fade])
        let remove = SKAction.removeFromParent()

        parent.addChild(ring)
        ring.run(SKAction.sequence([group, remove]))
    }

    private static func conjureCombo(at position: CGPoint, in parent: SKNode) {
        for _ in 0..<20 {
            let mote = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...9))
            mote.fillColor = SKColor(red: 0.98, green: 0.65, blue: 0.25, alpha: 1.0)
            mote.strokeColor = .clear
            mote.position = position
            mote.zPosition = 100

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 50...120)
            let endX = position.x + cos(angle) * distance
            let endY = position.y + sin(angle) * distance

            let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 0.8)
            let fade = SKAction.fadeOut(withDuration: 0.8)
            let scale = SKAction.scale(to: 0.2, duration: 0.8)
            let group = SKAction.group([move, fade, scale])
            let remove = SKAction.removeFromParent()

            parent.addChild(mote)
            mote.run(SKAction.sequence([group, remove]))
        }
    }

    private static func conjureSparkle(at position: CGPoint, in parent: SKNode) {
        for _ in 0..<8 {
            let mote = SKShapeNode(circleOfRadius: 3)
            mote.fillColor = SKColor(red: 0.98, green: 0.93, blue: 0.88, alpha: 1.0)
            mote.strokeColor = .clear
            mote.position = CGPoint(x: position.x + CGFloat.random(in: -40...40),
                                   y: position.y + CGFloat.random(in: -40...40))
            mote.zPosition = 100

            let scale1 = SKAction.scale(to: 1.5, duration: 0.3)
            let scale2 = SKAction.scale(to: 0.1, duration: 0.3)
            let fade = SKAction.fadeOut(withDuration: 0.6)
            let sequence = SKAction.sequence([scale1, scale2])
            let group = SKAction.group([sequence, fade])
            let remove = SKAction.removeFromParent()

            parent.addChild(mote)
            mote.run(SKAction.sequence([group, remove]))
        }
    }

    private static func conjureGlow(at position: CGPoint, in parent: SKNode) {
        let glow = SKShapeNode(circleOfRadius: 80)
        glow.fillColor = SKColor(red: 0.86, green: 0.93, blue: 0.98, alpha: 0.3)
        glow.strokeColor = .clear
        glow.position = position
        glow.zPosition = 99
        glow.setScale(0.5)

        let scale = SKAction.scale(to: 1.2, duration: 0.4)
        let fade = SKAction.fadeOut(withDuration: 0.4)
        let group = SKAction.group([scale, fade])
        let remove = SKAction.removeFromParent()

        parent.addChild(glow)
        glow.run(SKAction.sequence([group, remove]))
    }
}
