//
//  TinctureForge.swift
//  FightFire
//

import SpriteKit

final class TinctureForge {
    static func glaze(size: CGSize, colors: [SKColor]) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgColors = colors.map { $0.cgColor } as CFArray
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgColors, locations: nil) else { return }
            let start = CGPoint(x: size.width * 0.5, y: 0)
            let end = CGPoint(x: size.width * 0.5, y: size.height)
            context.cgContext.drawLinearGradient(gradient, start: start, end: end, options: [])
        }
        return SKTexture(image: image)
    }

    static func halo(radius: CGFloat, tint: SKColor, alpha: CGFloat) -> SKShapeNode {
        let halo = SKShapeNode(circleOfRadius: radius)
        halo.fillColor = tint.withAlphaComponent(alpha)
        halo.strokeColor = .clear
        halo.blendMode = .add
        halo.zPosition = -5
        return halo
    }
}
