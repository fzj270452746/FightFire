//
//  OmenGlyph.swift
//  FightFire
//

import SpriteKit

enum SigilTimbre {
    case fray
    case forge
    case hud
}

enum OmenGlyph: CaseIterable {
    case mordant   // attack
    case lenitive  // heal
    case pavis     // shield
    case arcanum   // skill

    func sigilName(timbre: SigilTimbre) -> String {
        switch self {
        case .mordant:
            return "game-attack"
        case .lenitive:
            return timbre == .fray ? "game-recover" : "game-heart"
        case .pavis:
            return "game-defense"
        case .arcanum:
            return "game-skill"
        }
    }

    var chroma: SKColor {
        switch self {
        case .mordant:
            return NacrePalette.ember
        case .lenitive:
            return NacrePalette.verdigris
        case .pavis:
            return NacrePalette.glaucous
        case .arcanum:
            return NacrePalette.auric
        }
    }
}

struct OmenTally {
    let glyphs: [OmenGlyph]

    var triune: Bool {
        guard let head = glyphs.first else { return false }
        return glyphs.allSatisfy { $0 == head }
    }

    var crest: OmenGlyph? {
        return glyphs.first
    }
}
