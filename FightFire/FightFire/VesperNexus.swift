//
//  VesperNexus.swift
//  FightFire
//

import SpriteKit

enum VesperRoute {
    case foyer
    case roster
    case forge
    case fray(Int)
    case wyrmVigil
    case bossBet
    case reflexCrucible
}

protocol LiminalGate: AnyObject {
    func beckon(_ route: VesperRoute)
}

final class VesperNexus: LiminalGate {
    private weak var vista: SKView?
    private let reliquary: ReliquaryCodex

    init(vista: SKView, reliquary: ReliquaryCodex) {
        self.vista = vista
        self.reliquary = reliquary
    }

    func beckon(_ route: VesperRoute) {
        guard let vista = vista else { return }
        let scene: VesperStage
        switch route {
        case .foyer:
            scene = VellumFoyer(size: vista.bounds.size, reliquary: reliquary)
        case .roster:
            scene = QuarryRoster(size: vista.bounds.size, reliquary: reliquary)
        case .forge:
            scene = UmbralForge(size: vista.bounds.size, reliquary: reliquary)
        case .fray(let tier):
            let dossier = DreadAtlas.roster().first { $0.tier == tier } ?? DreadAtlas.roster().first!
            scene = GambolFray(size: vista.bounds.size, reliquary: reliquary, dossier: dossier)
        case .wyrmVigil:
            scene = WyrmVigilArena(size: vista.bounds.size, reliquary: reliquary)
        case .bossBet:
            scene = BossBetArena(size: vista.bounds.size, reliquary: reliquary)
        case .reflexCrucible:
            scene = ReflexCrucible(size: vista.bounds.size, reliquary: reliquary)
        }
        scene.portcullis = self
        scene.scaleMode = .resizeFill
        let shift = SKTransition.fade(withDuration: 0.35)
        vista.presentScene(scene, transition: shift)
    }
}
