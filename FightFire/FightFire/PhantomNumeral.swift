//
//  PhantomNumeral.swift
//  FightFire
//
//  Floating damage/heal numbers

import SpriteKit

enum NumeralCast {
    case damage
    case heal
    case shield
    case combo

    var chromaTint: SKColor {
        switch self {
        case .damage: return SKColor(red: 0.95, green: 0.25, blue: 0.25, alpha: 1.0)
        case .heal: return SKColor(red: 0.20, green: 0.78, blue: 0.68, alpha: 1.0)
        case .shield: return SKColor(red: 0.18, green: 0.55, blue: 0.70, alpha: 1.0)
        case .combo: return SKColor(red: 0.98, green: 0.65, blue: 0.25, alpha: 1.0)
        }
    }

    var prefix: String {
        switch self {
        case .damage: return "-"
        case .heal: return "+"
        case .shield: return "+"
        case .combo: return "x"
        }
    }
}

final class PhantomNumeral {
    static func manifest(value: Int, cast: NumeralCast, at position: CGPoint, in parent: SKNode, scale: CGFloat = 1.0) {
        let label = SKLabelNode(fontNamed: "Copperplate-Bold")
        label.text = "\(cast.prefix)\(value)"
        label.fontSize = 32 * scale
        label.fontColor = cast.chromaTint
        label.position = position
        label.zPosition = 150
        label.verticalAlignmentMode = .center

        // Add outline effect
        let outline = SKLabelNode(fontNamed: "Copperplate-Bold")
        outline.text = label.text
        outline.fontSize = label.fontSize
        outline.fontColor = .black
        outline.position = CGPoint(x: 0, y: 0)
        outline.zPosition = -1
        outline.verticalAlignmentMode = .center
        outline.setScale(1.05)
        label.addChild(outline)

        parent.addChild(label)

        let moveUp = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: 80, duration: 1.0)
        let scaleUp = SKAction.scale(to: 1.3 * scale, duration: 0.2)
        let scaleDown = SKAction.scale(to: 0.8 * scale, duration: 0.8)
        let fade = SKAction.fadeOut(withDuration: 1.0)
        let scaleSeq = SKAction.sequence([scaleUp, scaleDown])
        let group = SKAction.group([moveUp, scaleSeq, fade])
        let remove = SKAction.removeFromParent()

        label.run(SKAction.sequence([group, remove]))
    }

    static func manifestText(text: String, tint: SKColor, at position: CGPoint, in parent: SKNode, scale: CGFloat = 1.0) {
        let label = SKLabelNode(fontNamed: "Copperplate-Bold")
        label.text = text
        label.fontSize = 28 * scale
        label.fontColor = tint
        label.position = position
        label.zPosition = 150
        label.verticalAlignmentMode = .center

        let outline = SKLabelNode(fontNamed: "Copperplate-Bold")
        outline.text = label.text
        outline.fontSize = label.fontSize
        outline.fontColor = .black
        outline.position = CGPoint(x: 0, y: 0)
        outline.zPosition = -1
        outline.verticalAlignmentMode = .center
        outline.setScale(1.05)
        label.addChild(outline)

        parent.addChild(label)

        let moveUp = SKAction.moveBy(x: 0, y: 60, duration: 1.2)
        let scaleUp = SKAction.scale(to: 1.4 * scale, duration: 0.3)
        let scaleDown = SKAction.scale(to: 0.9 * scale, duration: 0.9)
        let fade = SKAction.fadeOut(withDuration: 1.2)
        let scaleSeq = SKAction.sequence([scaleUp, scaleDown])
        let group = SKAction.group([moveUp, scaleSeq, fade])
        let remove = SKAction.removeFromParent()

        label.run(SKAction.sequence([group, remove]))
    }
}
