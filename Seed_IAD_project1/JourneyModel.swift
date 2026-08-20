import Foundation
import Observation

enum JourneyScreen: Equatable {
    case opening
    case plantSeed
    case coverSeed
    case awaken
    case care
    case growing
    case result
}

enum CareType: String, CaseIterable, Identifiable {
    case water = "Water"
    case sunlight = "Sunlight"
    case wind = "Wind"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .water: "drop.fill"
        case .sunlight: "sun.max.fill"
        case .wind: "wind"
        }
    }

    var assetName: String {
        switch self {
        case .water: "water_cloud"
        case .sunlight: "sunlight"
        case .wind: "wind"
        }
    }
}

enum TreeResult {
    case flooded
    case burned
    case dry
    case fragile
    case perfect
    case good

    var title: String {
        switch self {
        case .flooded: "Flooded"
        case .burned: "Burned"
        case .dry: "Dry"
        case .fragile: "Fragile"
        case .perfect: "Perfect Care!"
        case .good: "A Healthy Tree"
        }
    }

    var message: String {
        switch self {
        case .flooded: "Too much water. The roots drowned."
        case .burned: "Too much sunlight. The leaves burned."
        case .dry: "Too little water. The plant dried out."
        case .fragile: "The plant needed more wind to grow strong."
        case .perfect: "Perfect care! A beautiful tree flourished."
        case .good: "Great job! Your plant is healthy."
        }
    }

    var assetName: String {
        switch self {
        case .flooded: "flooded_tree"
        case .burned: "burned_tree"
        case .dry: "dry_tree"
        case .fragile, .good: "good_tree"
        case .perfect: "perfect_tree"
        }
    }
}

/// The single source of truth for the three-minute experience.
/// Views observe this model directly through Swift 6 Observation.
@MainActor
@Observable
final class JourneyModel {
    var screen: JourneyScreen = .opening
    var selectedCare: CareType = .water
    var water = 0
    var sunlight = 0
    var wind = 0
    var growthStage = 0
    var remainingSeconds = 180
    var careReaction = 0

    private var clockTask: Task<Void, Never>?
    private var growthTask: Task<Void, Never>?

    var totalCareActions: Int { water + sunlight + wind }
    var careActionsRemaining: Int { max(0, 6 - totalCareActions) }

    var result: TreeResult {
        if water == 4 { return .flooded }
        if sunlight == 4 { return .burned }
        if water <= 1 { return .dry }
        if wind == 0 { return .fragile }
        if water == 2, sunlight == 2, wind == 2 { return .perfect }
        return .good
    }

    var growthAssetName: String {
        ["seed_new", "sprout_new", "small_plant_new", "young_tree_new", "mature_tree"][min(growthStage, 4)]
    }

    func careValue(for type: CareType) -> Int {
        switch type {
        case .water: water
        case .sunlight: sunlight
        case .wind: wind
        }
    }

    func startJourney() {
        guard screen == .opening else { return }
        screen = .plantSeed
        remainingSeconds = 180
        clockTask?.cancel()
        clockTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, self.screen != .opening else { return }
                if self.remainingSeconds > 0 { self.remainingSeconds -= 1 }
            }
        }
    }

    func seedWasPlanted() { screen = .coverSeed }
    func soilWasCovered() { screen = .awaken }
    func awakenSeed() { screen = .care }

    func giveSelectedCare() {
        giveCare(selectedCare)
    }

    func giveCare(_ type: CareType) {
        guard screen == .care, totalCareActions < 6 else { return }
        selectedCare = type
        careReaction += 1
        switch type {
        case .water: water += 1
        case .sunlight: sunlight += 1
        case .wind: wind += 1
        }
        guard totalCareActions == 6 else { return }
        screen = .growing
        growthStage = 0
        beginGrowthSequence()
    }

    func reset() {
        clockTask?.cancel()
        growthTask?.cancel()
        screen = .opening
        selectedCare = .water
        water = 0
        sunlight = 0
        wind = 0
        growthStage = 0
        remainingSeconds = 180
        careReaction = 0
    }

    private func beginGrowthSequence() {
        growthTask?.cancel()
        growthTask = Task { [weak self] in
            guard let self else { return }
            for stage in 1...4 {
                try? await Task.sleep(for: .milliseconds(900))
                guard !Task.isCancelled else { return }
                self.growthStage = stage
            }
            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else { return }
            self.screen = .result
        }
    }
}
