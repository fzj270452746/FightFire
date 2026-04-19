//
//  WyrmVigilCodex.swift
//  FightFire
//
//  Daily boss challenge data persistence

import Foundation

final class WyrmVigilCodex {
    static let monad = WyrmVigilCodex()

    private let archive = UserDefaults.standard
    private let keyTier       = "wyrm.tier"
    private let keyDate       = "wyrm.date"
    private let keySpinsLeft  = "wyrm.spinsLeft"
    private let keyBossHp     = "wyrm.bossHp"
    private let keyBossHpCap  = "wyrm.bossHpCap"
    private let keyDefeated   = "wyrm.defeated"

    private(set) var tier: Int
    private(set) var spinsLeft: Int
    private(set) var bossHpNow: Int
    private(set) var bossHpCap: Int
    private(set) var defeated: Bool

    static let freeSpinsPerDay = 10
    static let baseHp = 5000

    private init() {
        let savedDate = archive.string(forKey: keyDate) ?? ""
        let today = WyrmVigilCodex.todayString()

        if savedDate == today {
            // Same day — restore state
            self.tier       = archive.integer(forKey: keyTier)
            self.spinsLeft  = archive.integer(forKey: keySpinsLeft)
            self.bossHpNow  = archive.integer(forKey: keyBossHp)
            self.bossHpCap  = archive.integer(forKey: keyBossHpCap)
            self.defeated   = archive.bool(forKey: keyDefeated)
        } else {
            // New day — roll a fresh boss
            let newTier = Int.random(in: 1...15)
            let hp = WyrmVigilCodex.calcHp(tier: newTier)
            self.tier      = newTier
            self.spinsLeft = WyrmVigilCodex.freeSpinsPerDay
            self.bossHpNow = hp
            self.bossHpCap = hp
            self.defeated  = false
            archive.set(today,   forKey: keyDate)
            archive.set(newTier, forKey: keyTier)
            archive.set(WyrmVigilCodex.freeSpinsPerDay, forKey: keySpinsLeft)
            archive.set(hp,      forKey: keyBossHp)
            archive.set(hp,      forKey: keyBossHpCap)
            archive.set(false,   forKey: keyDefeated)
        }
    }

    // MARK: - Helpers

    static func calcHp(tier: Int) -> Int {
        // Tier 1 = 5000, each tier adds 2000
        return baseHp + (tier - 1) * 2000
    }

    static func todayString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }

    // MARK: - Mutations

    func consumeSpin() {
        guard spinsLeft > 0 else { return }
        spinsLeft -= 1
        archive.set(spinsLeft, forKey: keySpinsLeft)
    }

    func applyDamage(_ amount: Int) {
        guard !defeated else { return }
        bossHpNow = max(0, bossHpNow - amount)
        archive.set(bossHpNow, forKey: keyBossHp)
        if bossHpNow == 0 {
            defeated = true
            archive.set(true, forKey: keyDefeated)
        }
    }

    // MARK: - Reward calculation

    func calcReward() -> Int {
        if defeated {
            // Full defeat: base 200 + tier bonus
            return 200 + tier * 50
        } else {
            // Partial: proportional to damage dealt
            let dmgDealt = bossHpCap - bossHpNow
            let ratio = Double(dmgDealt) / Double(bossHpCap)
            return max(10, Int(ratio * Double(100 + tier * 20)))
        }
    }
}
