//
//  MahjongRelic.swift
//  FightFire
//
//  Special mahjong tile power system

import Foundation

enum MahjongRelic: String, CaseIterable {
    case dragonRed = "Red Dragon"
    case dragonGreen = "Green Dragon"
    case dragonWhite = "White Dragon"
    case windEast = "East Wind"
    case windSouth = "South Wind"
    case windWest = "West Wind"
    case windNorth = "North Wind"
    case bambooLuck = "Lucky Bamboo"
    case characterFortune = "Fortune Character"
    case dotWealth = "Wealth Dot"

    var epithet: String { rawValue }

    var chronicle: String {
        switch self {
        case .dragonRed:
            return "Double attack damage for 3 turns"
        case .dragonGreen:
            return "Heal 10% HP each turn for 3 turns"
        case .dragonWhite:
            return "Gain 2 shields at turn start for 3 turns"
        case .windEast:
            return "Next skill deals 3x damage"
        case .windSouth:
            return "Reflect 30% damage back to attacker"
        case .windWest:
            return "Immune to next 2 attacks"
        case .windNorth:
            return "Freeze enemy for 1 turn"
        case .bambooLuck:
            return "Next spin guarantees a match"
        case .characterFortune:
            return "Gain 50 bonus coins after battle"
        case .dotWealth:
            return "Double coin rewards this battle"
        }
    }

    var iconName: String {
        switch self {
        case .dragonRed, .dragonGreen, .dragonWhite:
            return "game-skill"
        case .windEast, .windSouth, .windWest, .windNorth:
            return "game-defense"
        case .bambooLuck, .characterFortune, .dotWealth:
            return "game-heart"
        }
    }

    var rarity: RelicRarity {
        switch self {
        case .dragonRed, .dragonGreen, .dragonWhite:
            return .legendary
        case .windEast, .windSouth, .windWest, .windNorth:
            return .epic
        case .bambooLuck, .characterFortune, .dotWealth:
            return .rare
        }
    }
}

enum RelicRarity {
    case rare
    case epic
    case legendary

    var chromaTint: (r: CGFloat, g: CGFloat, b: CGFloat) {
        switch self {
        case .rare: return (0.18, 0.55, 0.70)
        case .epic: return (0.78, 0.42, 0.98)
        case .legendary: return (0.98, 0.82, 0.42)
        }
    }
}

struct RelicVault {
    private(set) var hoard: [MahjongRelic] = []
    private(set) var equipped: MahjongRelic?

    mutating func acquire(_ relic: MahjongRelic) {
        if !hoard.contains(relic) {
            hoard.append(relic)
        }
    }

    mutating func equip(_ relic: MahjongRelic?) {
        equipped = relic
    }

    func hasRelic(_ relic: MahjongRelic) -> Bool {
        return hoard.contains(relic)
    }
}
