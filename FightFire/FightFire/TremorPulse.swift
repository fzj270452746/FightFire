//
//  TremorPulse.swift
//  FightFire
//
//  Screen shake effect system

import SpriteKit

enum TremorMagnitude {
    case subtle
    case moderate
    case intense
    case cataclysmic

    var amplitude: CGFloat {
        switch self {
        case .subtle: return 3
        case .moderate: return 6
        case .intense: return 10
        case .cataclysmic: return 16
        }
    }

    var duration: TimeInterval {
        switch self {
        case .subtle: return 0.2
        case .moderate: return 0.3
        case .intense: return 0.4
        case .cataclysmic: return 0.6
        }
    }
}

final class TremorPulse {
    static func quake(node: SKNode, magnitude: TremorMagnitude) {
        let amplitude = magnitude.amplitude
        let duration = magnitude.duration
        let iterations = 8

        var actions: [SKAction] = []
        for _ in 0..<iterations {
            let randomX = CGFloat.random(in: -amplitude...amplitude)
            let randomY = CGFloat.random(in: -amplitude...amplitude)
            let move = SKAction.moveBy(x: randomX, y: randomY, duration: duration / Double(iterations))
            actions.append(move)
        }

        let reset = SKAction.move(to: .zero, duration: duration / Double(iterations))
        actions.append(reset)

        let sequence = SKAction.sequence(actions)
        node.run(sequence)
    }

    static func pulse(node: SKNode, scale: CGFloat = 1.15, duration: TimeInterval = 0.15) {
        let scaleUp = SKAction.scale(to: scale, duration: duration)
        let scaleDown = SKAction.scale(to: 1.0, duration: duration)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        node.run(sequence)
    }

    static func flash(node: SKNode, tint: SKColor, duration: TimeInterval = 0.2) {
        guard let sprite = node as? SKSpriteNode else { return }
        let originalColor = sprite.color
        let originalBlend = sprite.colorBlendFactor

        sprite.color = tint
        sprite.colorBlendFactor = 0.6

        let wait = SKAction.wait(forDuration: duration)
        let reset = SKAction.run {
            sprite.color = originalColor
            sprite.colorBlendFactor = originalBlend
        }
        sprite.run(SKAction.sequence([wait, reset]))
    }
}
