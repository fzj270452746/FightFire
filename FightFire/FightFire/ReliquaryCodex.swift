//
//  ReliquaryCodex.swift
//  FightFire
//

import Foundation

final class ReliquaryCodex {
    static let monad = ReliquaryCodex()

    private let archive = UserDefaults.standard
    private let keys = ReliquaryKeys()

    private(set) var hoard: Int
    private(set) var glaive: Int
    private(set) var vitalis: Int
    private(set) var pavisGain: Int
    private(set) var arcanum: Double
    private(set) var summit: Int

    // New systems
    private(set) var totalCoinsEarned: Int
    private(set) var totalBattlesWon: Int
    private(set) var totalBattlesLost: Int
    private(set) var currentWinStreak: Int
    private(set) var maxWinStreak: Int
    private(set) var relicVault: RelicVault
    let laurelCodex: LaurelCodex

    private init() {
        let hoard = archive.integer(forKey: keys.hoard)
        let glaive = archive.integer(forKey: keys.glaive)
        let vitalis = archive.integer(forKey: keys.vitalis)
        let pavisGain = archive.integer(forKey: keys.pavisGain)
        let arcanum = archive.double(forKey: keys.arcanum)
        let summit = archive.integer(forKey: keys.summit)

        let totalCoinsEarned = archive.integer(forKey: keys.totalCoinsEarned)
        let totalBattlesWon = archive.integer(forKey: keys.totalBattlesWon)
        let totalBattlesLost = archive.integer(forKey: keys.totalBattlesLost)
        let currentWinStreak = archive.integer(forKey: keys.currentWinStreak)
        let maxWinStreak = archive.integer(forKey: keys.maxWinStreak)

        self.hoard = hoard == 0 ? 30 : hoard
        self.glaive = glaive == 0 ? 12 : glaive
        self.vitalis = vitalis == 0 ? 120 : vitalis
        self.pavisGain = pavisGain == 0 ? 1 : pavisGain
        self.arcanum = arcanum == 0 ? 1.5 : arcanum
        self.summit = summit

        self.totalCoinsEarned = totalCoinsEarned
        self.totalBattlesWon = totalBattlesWon
        self.totalBattlesLost = totalBattlesLost
        self.currentWinStreak = currentWinStreak
        self.maxWinStreak = maxWinStreak
        self.relicVault = RelicVault()
        self.laurelCodex = LaurelCodex()
    }

    func inscribe() {
        archive.set(hoard, forKey: keys.hoard)
        archive.set(glaive, forKey: keys.glaive)
        archive.set(vitalis, forKey: keys.vitalis)
        archive.set(pavisGain, forKey: keys.pavisGain)
        archive.set(arcanum, forKey: keys.arcanum)
        archive.set(summit, forKey: keys.summit)
        archive.set(totalCoinsEarned, forKey: keys.totalCoinsEarned)
        archive.set(totalBattlesWon, forKey: keys.totalBattlesWon)
        archive.set(totalBattlesLost, forKey: keys.totalBattlesLost)
        archive.set(currentWinStreak, forKey: keys.currentWinStreak)
        archive.set(maxWinStreak, forKey: keys.maxWinStreak)
    }

    func mint(_ amount: Int) {
        hoard += max(0, amount)
        totalCoinsEarned += max(0, amount)
        inscribe()
        checkAchievements()
    }

    func siphon(_ amount: Int) -> Bool {
        guard hoard >= amount else { return false }
        hoard -= amount
        inscribe()
        return true
    }

    func forgeAvatar() -> GloamFighter {
        return GloamFighter(glaive: glaive, vitalisCap: vitalis, vitalisNow: vitalis, pavis: 0, arcanum: arcanum, pavisGain: pavisGain)
    }

    func temperGlaive() {
        glaive += 2
        inscribe()
    }

    func temperVitalis() {
        vitalis += 15
        inscribe()
    }

    func temperPavis() {
        pavisGain = min(3, pavisGain + 1)
        inscribe()
    }

    func temperArcanum() {
        arcanum = min(2.4, arcanum + 0.1)
        inscribe()
    }

    func ascendSummit(_ tier: Int) {
        summit = max(summit, tier)
        inscribe()
    }

    func recordVictory(maxCombo: Int) {
        totalBattlesWon += 1
        currentWinStreak += 1
        maxWinStreak = max(maxWinStreak, currentWinStreak)
        inscribe()
        checkAchievements()
    }

    func recordDefeat() {
        totalBattlesLost += 1
        currentWinStreak = 0
        inscribe()
    }

    func acquireRelic(_ relic: MahjongRelic) {
        relicVault.acquire(relic)
        checkAchievements()
    }

    private func checkAchievements() {
        if totalBattlesWon == 1 {
            _ = laurelCodex.unlock(.firstVictory)
        }
        if currentWinStreak >= 5 {
            _ = laurelCodex.unlock(.winStreak5)
        }
        if currentWinStreak >= 10 {
            _ = laurelCodex.unlock(.winStreak10)
        }
        if summit >= 15 {
            _ = laurelCodex.unlock(.defeat15Bosses)
        }
        if relicVault.hoard.count >= 5 {
            _ = laurelCodex.unlock(.collect5Relics)
        }
        if relicVault.hoard.count >= 10 {
            _ = laurelCodex.unlock(.collect10Relics)
        }
        if totalCoinsEarned >= 1000 {
            _ = laurelCodex.unlock(.earn1000Coins)
        }
        if totalCoinsEarned >= 5000 {
            _ = laurelCodex.unlock(.earn5000Coins)
        }
        if totalBattlesWon >= 50 {
            _ = laurelCodex.unlock(.win50Battles)
        }
        if totalBattlesWon >= 100 {
            _ = laurelCodex.unlock(.win100Battles)
        }
        if glaive >= 50 && vitalis >= 300 && pavisGain >= 3 && arcanum >= 2.4 {
            _ = laurelCodex.unlock(.maxAllStats)
        }
    }
}

private struct ReliquaryKeys {
    let hoard = "reliquary.hoard"
    let glaive = "reliquary.glaive"
    let vitalis = "reliquary.vitalis"
    let pavisGain = "reliquary.pavisGain"
    let arcanum = "reliquary.arcanum"
    let summit = "reliquary.summit"
    let totalCoinsEarned = "reliquary.totalCoinsEarned"
    let totalBattlesWon = "reliquary.totalBattlesWon"
    let totalBattlesLost = "reliquary.totalBattlesLost"
    let currentWinStreak = "reliquary.currentWinStreak"
    let maxWinStreak = "reliquary.maxWinStreak"
}

struct GloamFighter {
    var glaive: Int
    var vitalisCap: Int
    var vitalisNow: Int
    var pavis: Int
    var arcanum: Double
    var pavisGain: Int

    mutating func scar(_ amount: Int) -> Int {
        guard amount > 0 else { return 0 }
        if pavis > 0 {
            pavis -= 1
            return 0
        }
        let loss = min(vitalisNow, amount)
        vitalisNow -= loss
        return loss
    }

    mutating func succor(_ amount: Int) {
        guard amount > 0 else { return }
        vitalisNow = min(vitalisCap, vitalisNow + amount)
    }

    mutating func bastion(_ amount: Int) {
        guard amount > 0 else { return }
        pavis = min(9, pavis + amount)
    }

    func arcanumBlow() -> Int {
        return max(1, Int(Double(glaive) * arcanum))
    }
}
