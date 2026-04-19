//
//  LaurelCodex.swift
//  FightFire
//
//  Achievement system

import Foundation

enum LaurelMark: String, CaseIterable {
    case firstVictory = "First Blood"
    case winStreak5 = "Unstoppable"
    case winStreak10 = "Legendary"
    case defeat15Bosses = "Boss Slayer"
    case maxCombo = "Combo Master"
    case collect5Relics = "Relic Hunter"
    case collect10Relics = "Treasure Seeker"
    case earn1000Coins = "Wealthy"
    case earn5000Coins = "Tycoon"
    case maxAllStats = "Perfect Warrior"
    case win50Battles = "Veteran"
    case win100Battles = "Champion"
    case noShieldWin = "Glass Cannon"
    case perfectHealth = "Flawless Victory"
    case useAllRelics = "Collector"

    var epithet: String { rawValue }

    var chronicle: String {
        switch self {
        case .firstVictory:
            return "Win your first battle"
        case .winStreak5:
            return "Win 5 battles in a row"
        case .winStreak10:
            return "Win 10 battles in a row"
        case .defeat15Bosses:
            return "Defeat all 15 bosses"
        case .maxCombo:
            return "Reach a 5+ combo"
        case .collect5Relics:
            return "Collect 5 different relics"
        case .collect10Relics:
            return "Collect all 10 relics"
        case .earn1000Coins:
            return "Earn 1000 total coins"
        case .earn5000Coins:
            return "Earn 5000 total coins"
        case .maxAllStats:
            return "Max out all stats"
        case .win50Battles:
            return "Win 50 battles"
        case .win100Battles:
            return "Win 100 battles"
        case .noShieldWin:
            return "Win without using shields"
        case .perfectHealth:
            return "Win at full health"
        case .useAllRelics:
            return "Use each relic at least once"
        }
    }

    var bounty: Int {
        switch self {
        case .firstVictory: return 50
        case .winStreak5: return 100
        case .winStreak10: return 200
        case .defeat15Bosses: return 500
        case .maxCombo: return 150
        case .collect5Relics: return 100
        case .collect10Relics: return 300
        case .earn1000Coins: return 100
        case .earn5000Coins: return 500
        case .maxAllStats: return 400
        case .win50Battles: return 300
        case .win100Battles: return 600
        case .noShieldWin: return 150
        case .perfectHealth: return 200
        case .useAllRelics: return 400
        }
    }
}

final class LaurelCodex {
    private let archive = UserDefaults.standard
    private let keyPrefix = "laurel."
    private(set) var unlocked: Set<LaurelMark> = []

    init() {
        loadProgress()
    }

    private func loadProgress() {
        for mark in LaurelMark.allCases {
            let key = keyPrefix + mark.rawValue
            if archive.bool(forKey: key) {
                unlocked.insert(mark)
            }
        }
    }

    func unlock(_ mark: LaurelMark) -> Bool {
        guard !unlocked.contains(mark) else { return false }
        unlocked.insert(mark)
        let key = keyPrefix + mark.rawValue
        archive.set(true, forKey: key)
        return true
    }

    func isUnlocked(_ mark: LaurelMark) -> Bool {
        return unlocked.contains(mark)
    }

    func progress() -> (unlocked: Int, total: Int) {
        return (unlocked.count, LaurelMark.allCases.count)
    }
}
