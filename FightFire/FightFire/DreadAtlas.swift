//
//  DreadAtlas.swift
//  FightFire
//

import Foundation

struct TyrantDraft {
    let tier: Int
    let sobriquet: String
    let visage: String
    let glaive: Int
    let vitalis: Int
    let arcanum: Double
    let pavisGain: Int
    let largess: Int
}

enum DreadAtlas {
    static func roster() -> [TyrantDraft] {
        let names = [
            "Cinder Vagrant",
            "Jade Reaver",
            "Obsidian Wisp",
            "Ember Stalker",
            "Lacquer Titan",
            "Umbral Regent",
            "Gilded Ravager",
            "Sable Weaver",
            "Crimson Herald",
            "Viridian Marauder",
            "Ashen Oracle",
            "Ivory Colossus",
            "Verdant Tyrant",
            "Onyx Revenant",
            "Aether Sovereign"
        ]
        return (1...15).map { tier in
            let glaive = 8 + tier * 3
            let vitalis = 90 + tier * 35
            let arcanum = 1.20 + Double(tier) * 0.03
            let pavisGain = 1 + tier / 6
            let largess = 30 + tier * 20
            return TyrantDraft(
                tier: tier,
                sobriquet: names[tier - 1],
                visage: "game-boss-\(tier)",
                glaive: glaive,
                vitalis: vitalis,
                arcanum: arcanum,
                pavisGain: pavisGain,
                largess: largess
            )
        }
    }
}
