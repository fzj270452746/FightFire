//
//  ZenithChain.swift
//  FightFire
//
//  Combo system for consecutive matches

import Foundation

final class ZenithChain {
    private(set) var tally: Int = 0
    private(set) var apex: Int = 0

    func surge() {
        tally += 1
        apex = max(apex, tally)
    }

    func rupture() {
        tally = 0
    }

    func multiplier() -> Double {
        switch tally {
        case 0...1: return 1.0
        case 2: return 1.3
        case 3: return 1.6
        case 4: return 2.0
        case 5: return 2.5
        default: return 3.0
        }
    }

    func chromaGrade() -> ChromaGrade {
        switch tally {
        case 0...1: return .dormant
        case 2: return .kindled
        case 3: return .blazing
        case 4: return .inferno
        default: return .cataclysm
        }
    }
}

enum ChromaGrade {
    case dormant
    case kindled
    case blazing
    case inferno
    case cataclysm

    var epithet: String {
        switch self {
        case .dormant: return ""
        case .kindled: return "COMBO x2"
        case .blazing: return "COMBO x3"
        case .inferno: return "COMBO x4"
        case .cataclysm: return "MEGA COMBO x5+"
        }
    }

    var hue: (r: CGFloat, g: CGFloat, b: CGFloat) {
        switch self {
        case .dormant: return (0.5, 0.5, 0.5)
        case .kindled: return (0.98, 0.82, 0.42)
        case .blazing: return (0.95, 0.65, 0.25)
        case .inferno: return (0.95, 0.45, 0.25)
        case .cataclysm: return (0.98, 0.25, 0.45)
        }
    }
}
