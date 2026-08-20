import SwiftUI

struct SeedJourneyView: View {
    @Bindable var journey: JourneyModel

    var body: some View {
        ZStack {
            NatureBackdrop()

            VStack(spacing: 10) {
                JourneyHeader(step: stepText, seconds: journey.remainingSeconds)
                if journey.screen != .care {
                    titleBlock
                }
                scene
                    .frame(maxHeight: .infinity)
                if journey.screen != .care {
                    instruction
                }
                controls
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 8)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if journey.screen == .opening {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                    journey.startJourney()
                }
            } else if journey.screen == .awaken {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.68)) {
                    journey.awakenSeed()
                }
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: journey.screen)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    @ViewBuilder
    private var titleBlock: some View {
        VStack(spacing: 2) {
            Text(screenTitle)
                .font(
                    journey.screen == .opening
                        ? .system(size: 52, weight: .semibold, design: .serif)
                        : .system(.largeTitle, design: .rounded, weight: .bold)
                )
                .italic(journey.screen == .opening)
                .foregroundStyle(
                    journey.screen == .opening
                        ? Color(red: 0.82, green: 1, blue: 0.55)
                        : .white
                )
                .shadow(color: Color(red: 0.02, green: 0.18, blue: 0.08).opacity(0.65), radius: 3, y: 2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
            Text(screenSubtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.86))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var scene: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(sceneSurface)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.42), .white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            switch journey.screen {
            case .opening:
                FloatingSeed()
                    .transition(.scale.combined(with: .opacity))
            case .plantSeed:
                PlantSeedInteraction { journey.seedWasPlanted() }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
            case .coverSeed:
                CoverSeedInteraction { journey.soilWasCovered() }
                    .transition(.opacity)
            case .awaken:
                CoveredSoilScene()
                    .transition(.scale.combined(with: .opacity))
            case .care:
                CareScene(journey: journey)
                    .transition(.opacity)
            case .growing:
                GrowthScene(assetName: journey.growthAssetName, stage: journey.growthStage)
                    .transition(.blurReplace)
            case .result:
                ResultScene(result: journey.result)
                    .transition(.scale(scale: 0.84).combined(with: .opacity))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color(red: 0.015, green: 0.12, blue: 0.055).opacity(0.32), radius: 18, y: 9)
        .accessibilityElement(children: .contain)
    }

    private var sceneSurface: LinearGradient {
        LinearGradient(
            colors: journey.screen == .care
                ? [.white.opacity(0.13), .white.opacity(0.025), Color.green.opacity(0.05)]
                : [.white.opacity(0.09), Color(red: 0.01, green: 0.13, blue: 0.07).opacity(0.23)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var instruction: some View {
        Text(instructionText)
            .font(.subheadline.bold())
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, 14)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.22), lineWidth: 1))
            .shadow(color: Color(red: 0.02, green: 0.12, blue: 0.05).opacity(0.24), radius: 8, y: 4)
            .accessibilityLabel(instructionText)
    }

    @ViewBuilder
    private var controls: some View {
        switch journey.screen {
        case .opening:
            Text("3 MINUTES  •  1 SEED  •  YOUR CARE")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
                .frame(minHeight: 54)
        case .plantSeed:
            Label("Touch, hold, and drag", systemImage: "hand.draw.fill")
                .font(.subheadline.bold())
                .frame(minHeight: 54)
        case .coverSeed:
            Label("Sweep from side to side", systemImage: "arrow.left.and.right")
                .font(.subheadline.bold())
                .frame(minHeight: 54)
        case .awaken:
            Label("Tap the glowing soil", systemImage: "hand.tap.fill")
                .font(.subheadline.bold())
                .frame(minHeight: 54)
                .accessibilityLabel("Tap the glowing soil to plant the seed")
        case .care:
            EmptyView()
        case .growing:
            ProgressView()
                .tint(.white)
                .frame(minHeight: 54)
                .accessibilityLabel("The plant is growing")
        case .result:
            PrimaryButton(title: "Grow another seed", symbol: "arrow.counterclockwise") {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { journey.reset() }
            }
            .accessibilityLabel("Replay the seed journey")
        }
    }

    private var screenTitle: String {
        switch journey.screen {
        case .opening: "Seed"
        case .plantSeed: "Plant your seed"
        case .coverSeed: "Tuck it in"
        case .awaken: "Plant the seed"
        case .care: "Help it grow"
        case .growing: "Life unfolds"
        case .result: journey.result.title
        }
    }

    private var screenSubtitle: String {
        switch journey.screen {
        case .opening: "A tiny choice can shape an entire life."
        case .plantSeed: "Guide it gently into the earth."
        case .coverSeed: "Sweep the loose earth over your seed."
        case .awaken: "A little intention brings it to life."
        case .care: "Choose thoughtfully - every choice matters."
        case .growing: "Your care is becoming something beautiful."
        case .result: journey.result.message
        }
    }

    private var stepText: String {
        switch journey.screen {
        case .opening: "SEED JOURNEY"
        case .plantSeed: "1 OF 4  •  PLANT"
        case .coverSeed: "2 OF 4  •  COVER"
        case .awaken: "3 OF 4  •  AWAKEN"
        case .care: "4 OF 4  •  CARE"
        case .growing: "GROWING  •  WATCH CLOSELY"
        case .result: "YOUR SEED JOURNEY"
        }
    }

    private var instructionText: String {
        switch journey.screen {
        case .opening: "Tap anywhere to begin"
        case .plantSeed: "Drag the seed into the soil opening"
        case .coverSeed: "Swipe across the soil to cover the seed"
        case .awaken: "Tap the glowing earth"
        case .care: "\(journey.careActionsRemaining) care choices remaining"
        case .growing: growthCaption
        case .result: "Water \(journey.water)   •   Sun \(journey.sunlight)   •   Wind \(journey.wind)"
        }
    }

    private var growthCaption: String {
        ["The seed stirs beneath the soil", "A brave sprout reaches for light", "New leaves gather strength", "A young trunk takes shape", "Your tree stands tall"][min(journey.growthStage, 4)]
    }
}

private struct JourneyHeader: View {
    let step: String
    let seconds: Int

    var body: some View {
        HStack {
            Text(step)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Spacer(minLength: 8)
            Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                .monospacedDigit()
                .accessibilityLabel("\(seconds / 60) minutes and \(seconds % 60) seconds remaining")
        }
        .font(.caption.bold())
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .frame(height: 40)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.45), .white.opacity(0.12)], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1
                )
        )
        .shadow(color: Color(red: 0.02, green: 0.14, blue: 0.07).opacity(0.25), radius: 8, y: 4)
    }
}

private struct FloatingSeed: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let bob = sin(time * 1.55) * 11
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow.opacity(0.34), .yellow.opacity(0.08), .clear],
                            center: .center,
                            startRadius: 8,
                            endRadius: 90
                        )
                    )
                    .frame(width: 190, height: 190)
                    .scaleEffect(0.9 + sin(time * 1.8) * 0.08)
                AmbientMotes(color: .yellow)
                    .frame(width: 220, height: 190)
                Image("seed_new")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 150, maxHeight: 150)
                    .offset(y: bob)
                    .rotationEffect(.degrees(sin(time * 1.15) * 2.4))
                    .rotation3DEffect(.degrees(sin(time * 0.72) * 7), axis: (x: 0, y: 1, z: 0))
            }
        }
        .accessibilityLabel("A seed gently floating above the soil")
    }
}

private struct SoilHole: View {
    var covered = false

    var body: some View {
        Ellipse()
            .fill(covered ? Color.brown.opacity(0.94) : Color(red: 0.12, green: 0.045, blue: 0.012))
            .stroke(
                LinearGradient(colors: [.brown.opacity(0.95), .orange.opacity(0.35), .brown], startPoint: .top, endPoint: .bottom),
                lineWidth: 5
            )
            .frame(width: 145, height: 52)
        .accessibilityHidden(true)
    }
}

private struct PlantSeedInteraction: View {
    let onPlanted: () -> Void
    @State private var dragOffset: CGSize = .zero
    @State private var rejected = false
    @State private var isDragging = false
    @State private var planted = false
    @State private var plantedFeedback = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                SoilHole()
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.82)

                if !isDragging && !planted {
                    Canvas { context, _ in
                        var guide = Path()
                        guide.move(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height * 0.42))
                        guide.addCurve(
                            to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height * 0.75),
                            control1: CGPoint(x: proxy.size.width * 0.68, y: proxy.size.height * 0.48),
                            control2: CGPoint(x: proxy.size.width * 0.68, y: proxy.size.height * 0.66)
                        )
                        context.stroke(
                            guide,
                            with: .color(.white.opacity(0.82)),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [7, 8])
                        )
                    }
                    .allowsHitTesting(false)
                }

                ForEach(0..<12, id: \.self) { index in
                    Circle()
                        .fill(index.isMultiple(of: 3) ? Color.orange.opacity(0.65) : Color.brown.opacity(0.9))
                        .frame(width: CGFloat(7 + index % 4 * 3))
                        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.82)
                        .offset(
                            x: planted ? cos(CGFloat(index) / 12 * .pi * 2) * CGFloat(35 + index * 3) : 0,
                            y: planted ? sin(CGFloat(index) / 12 * .pi * 2) * CGFloat(15 + index * 2) - 8 : 0
                        )
                        .opacity(planted ? 0 : 0.75)
                        .scaleEffect(planted ? 0.35 : 1)
                        .animation(.easeOut(duration: 0.65).delay(Double(index) * 0.012), value: planted)
                }

                Image("seed_new")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(145, proxy.size.width * 0.38), height: proxy.size.height * 0.4)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.36)
                    .offset(dragOffset)
                    .scaleEffect(planted ? 0.38 : isDragging ? 1.075 : 1)
                    .rotationEffect(.degrees(planted ? 12 : max(-13, min(13, dragOffset.width / 14))))
                    .rotation3DEffect(.degrees(isDragging ? 8 : 0), axis: (x: 1, y: 0, z: 0))
                    .opacity(planted ? 0.18 : 1)
                    .gesture(
                        DragGesture(minimumDistance: 2)
                            .onChanged {
                                isDragging = true
                                dragOffset = $0.translation
                            }
                            .onEnded { value in
                                let start = CGPoint(x: proxy.size.width / 2, y: proxy.size.height * 0.36)
                                let end = CGPoint(x: start.x + value.translation.width, y: start.y + value.translation.height)
                                let target = CGPoint(x: proxy.size.width / 2, y: proxy.size.height * 0.82)
                                if hypot(end.x - target.x, end.y - target.y) < 105 {
                                    plantedFeedback.toggle()
                                    withAnimation(.timingCurve(0.42, 0, 0.9, 0.55, duration: 0.48)) {
                                        isDragging = false
                                        planted = true
                                        dragOffset = CGSize(width: target.x - start.x, height: target.y - start.y)
                                    }
                                    Task {
                                        try? await Task.sleep(for: .milliseconds(510))
                                        onPlanted()
                                    }
                                } else {
                                    rejected.toggle()
                                    withAnimation(.spring(response: 0.52, dampingFraction: 0.57)) {
                                        isDragging = false
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                    .sensoryFeedback(.warning, trigger: rejected)
                    .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: plantedFeedback)
                    .accessibilityLabel("Seed")
                    .accessibilityHint("Drag the seed into the soil opening")
                    .accessibilityAddTraits(.isButton)
            }
        }
    }
}

private struct CoverSeedInteraction: View {
    let onCovered: () -> Void
    @State private var progress: CGFloat = 0
    @State private var completed = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image("seed_new")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .opacity(1 - progress)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.72)
                SoilHole(covered: progress > 0.65)
                    .scaleEffect(x: 1 + progress * 0.18, y: 1 - progress * 0.3)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.82)
                ForEach(0..<18, id: \.self) { index in
                    let startsLeft = index.isMultiple(of: 2)
                    let startX = startsLeft ? -35.0 - CGFloat(index * 4) : proxy.size.width + 35 + CGFloat(index * 3)
                    let finishX = proxy.size.width / 2 + CGFloat((index * 29) % 105 - 52)
                    let finishY = proxy.size.height * 0.81 + CGFloat((index * 17) % 38 - 19)
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 7, bottomLeading: 3, bottomTrailing: 8, topTrailing: 4))
                        .fill(index.isMultiple(of: 4) ? Color.orange.opacity(0.55) : Color.brown.opacity(0.92))
                        .frame(width: CGFloat(10 + index % 4 * 4), height: CGFloat(7 + index % 3 * 3))
                        .rotationEffect(.degrees(Double(index * 31) * Double(progress)))
                        .position(
                            x: startX + (finishX - startX) * progress,
                            y: finishY - sin(progress * .pi) * CGFloat(30 + index % 5 * 7)
                        )
                }

                Capsule()
                    .fill(Color.brown.opacity(0.68))
                    .frame(width: 150 * progress, height: 28)
                    .blur(radius: 2)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.82)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        progress = min(1, abs(value.translation.width) / max(1, proxy.size.width * 0.48))
                    }
                    .onEnded { _ in
                        if progress > 0.72 {
                            completed.toggle()
                            withAnimation(.easeOut(duration: 0.28)) { progress = 1 }
                            Task {
                                try? await Task.sleep(for: .milliseconds(330))
                                onCovered()
                            }
                        } else {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.7)) { progress = 0 }
                        }
                    }
            )
            .sensoryFeedback(.success, trigger: completed)
            .accessibilityLabel("Loose soil over the planted seed")
            .accessibilityHint("Swipe horizontally to cover the seed")
        }
    }
}

private struct CoveredSoilScene: View {
    @State private var glows = false

    var body: some View {
        ZStack {
            AmbientMotes(color: Color.lime)
            SoilHole(covered: true)
                .scaleEffect(x: 1.2, y: 0.72)
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(Color.lime.opacity(0.52 - Double(index) * 0.12), lineWidth: 2)
                    .frame(width: glows ? CGFloat(130 + index * 35) : 55, height: glows ? CGFloat(130 + index * 35) : 55)
                    .opacity(glows ? 0 : 0.9)
                    .animation(.easeOut(duration: 1.5).delay(Double(index) * 0.22).repeatForever(autoreverses: false), value: glows)
            }
            Image(systemName: "sparkles")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(Color.lime)
                .symbolEffect(.breathe.pulse.byLayer, options: .repeating)
        }
        .onAppear { glows = true }
        .accessibilityLabel("A glowing point in the covered soil")
    }
}

private struct CareScene: View {
    @Bindable var journey: JourneyModel
    @State private var gestureOffset: CGSize = .zero
    @State private var gestureProgress: CGFloat = 0
    @State private var isApplyingCare = false
    @State private var gestureFeedback = 0
    @State private var showingChooser = true

    private var plantAsset: String {
        switch journey.totalCareActions {
        case 0...1: "sprout_new"
        case 2...3: "small_plant_new"
        default: "young_tree_new"
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                if !showingChooser {
                    CareWeatherEffect(
                        type: journey.selectedCare,
                        trigger: journey.careReaction,
                        interactionOffset: gestureOffset,
                        intensity: isApplyingCare ? 1 : max(0.18, gestureProgress)
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
                }

                OrganicPlantImage(
                    assetName: plantAsset,
                    care: showingChooser ? .sunlight : journey.selectedCare,
                    reactionTrigger: journey.careReaction
                )
                .padding(.leading, proxy.size.width * 0.18)
                .padding(.trailing, 24)
                .padding(.top, 70)
                .padding(.bottom, 52)
                .frame(
                    width: proxy.size.width * 0.58,
                    height: proxy.size.height * 0.58,
                    alignment: .bottom
                )
                .scaleEffect(carePlantScale, anchor: .bottom)
                .id(plantAsset)
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.72, anchor: .bottom).combined(with: .opacity),
                        removal: .scale(scale: 1.08, anchor: .bottom).combined(with: .opacity)
                    )
                )
                .accessibilityLabel("Growing plant responding to \(journey.selectedCare.rawValue.lowercased())")

                SoilMound()
                    .frame(
                        width: min(210, proxy.size.width * 0.46),
                        height: 58
                    )
                    .offset(x: proxy.size.width * 0.08)
                    .padding(.bottom, 43)

                VStack(spacing: 0) {
                    Text(careModeTitle)
                        .font(.title.bold())
                        .foregroundStyle(.black.opacity(0.82))
                        .shadow(color: .white.opacity(0.7), radius: 1, y: 1)
                        .padding(.top, 18)

                    Spacer()

                    Text(careInstruction)
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .padding(.horizontal, 14)
                        .background(.black.opacity(0.56))
                }

                HStack(spacing: 0) {
                    Group {
                        if showingChooser {
                            CareSelectionRail { type in
                                withAnimation(.spring(response: 0.48, dampingFraction: 0.78)) {
                                    journey.selectedCare = type
                                    showingChooser = false
                                }
                            }
                        } else {
                            CareLevelRail(
                                type: journey.selectedCare,
                                value: journey.careValue(for: journey.selectedCare)
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                    showingChooser = true
                                }
                            }
                        }
                    }
                    .frame(width: min(178, proxy.size.width * 0.42))

                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(showingChooser ? nil : careGesture(in: proxy.size))
                }
                .padding(.top, 58)
                .padding(.bottom, 48)
                .padding(.horizontal, 10)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: journey.selectedCare)
        .animation(.spring(response: 0.72, dampingFraction: 0.76), value: journey.totalCareActions)
        .sensoryFeedback(.success, trigger: gestureFeedback)
        .onChange(of: journey.selectedCare) {
            gestureOffset = .zero
            gestureProgress = 0
            isApplyingCare = false
        }
    }

    private var careModeTitle: String {
        if showingChooser { return "4. CARE MODE" }
        switch journey.selectedCare {
        case .water: return "5. WATER"
        case .sunlight: return "6. SUNLIGHT"
        case .wind: return "7. WIND"
        }
    }

    private var careInstruction: String {
        if showingChooser { return "Choose how you want to care for your plant" }
        switch journey.selectedCare {
        case .water: return "Drag the cloud to water the plant"
        case .sunlight: return "Drag the sun to give the right light"
        case .wind: return "Swipe across the screen to create wind"
        }
    }

    private func careGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard !isApplyingCare else { return }
                gestureOffset = value.translation
                switch journey.selectedCare {
                case .water, .sunlight:
                    gestureProgress = min(1, hypot(value.translation.width, value.translation.height) / max(90, size.width * 0.28))
                case .wind:
                    gestureProgress = min(1, abs(value.translation.width) / max(120, size.width * 0.42))
                }
            }
            .onEnded { value in
                guard !isApplyingCare else { return }
                let completed: Bool
                switch journey.selectedCare {
                case .water, .sunlight:
                    completed = hypot(value.translation.width, value.translation.height) >= max(80, size.width * 0.22)
                case .wind:
                    completed = abs(value.translation.width) >= max(105, size.width * 0.34)
                }

                guard completed else {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                        gestureOffset = .zero
                        gestureProgress = 0
                    }
                    return
                }

                let care = journey.selectedCare
                gestureFeedback += 1
                withAnimation(.easeOut(duration: 0.22)) {
                    isApplyingCare = true
                    gestureProgress = 1
                }
                Task {
                    try? await Task.sleep(for: .milliseconds(650))
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.74)) {
                        journey.giveCare(care)
                        gestureOffset = .zero
                        gestureProgress = 0
                        isApplyingCare = false
                        showingChooser = true
                    }
                }
            }
    }

    private var carePlantScale: CGFloat {
        switch journey.totalCareActions {
        case 0...1: 0.72
        case 2...3: 0.84
        default: 0.96
        }
    }
}

private struct SoilMound: View {
    var body: some View {
        Canvas { context, size in
            var mound = Path()
            mound.move(to: CGPoint(x: 0, y: size.height * 0.9))
            mound.addCurve(
                to: CGPoint(x: size.width, y: size.height * 0.9),
                control1: CGPoint(x: size.width * 0.2, y: size.height * 0.24),
                control2: CGPoint(x: size.width * 0.8, y: size.height * 0.24)
            )
            mound.closeSubpath()
            context.fill(
                mound,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.34, green: 0.17, blue: 0.07),
                        Color(red: 0.23, green: 0.105, blue: 0.045),
                        Color(red: 0.16, green: 0.07, blue: 0.03)
                    ]),
                    startPoint: CGPoint(x: size.width / 2, y: 0),
                    endPoint: CGPoint(x: size.width / 2, y: size.height)
                )
            )

            for index in 0..<18 {
                let x = CGFloat((index * 47) % 97) / 96 * size.width
                let arch = 1 - abs(x / size.width - 0.5) * 1.7
                let y = size.height * (0.44 + CGFloat((index * 19) % 28) / 100) - max(0, arch) * 13
                let diameter = CGFloat(4 + (index * 7) % 7)
                let clod = Path(ellipseIn: CGRect(x: x, y: y, width: diameter, height: diameter * 0.62))
                context.fill(
                    clod,
                    with: .color(index.isMultiple(of: 3) ? Color.brown.opacity(0.88) : Color.orange.opacity(0.28))
                )
            }
        }
        .accessibilityHidden(true)
    }
}

private struct CareSelectionRail: View {
    let select: (CareType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(CareType.allCases) { type in
                Button {
                    select(type)
                } label: {
                    HStack(spacing: 9) {
                        CareIcon(type: type, isActive: true)
                            .frame(width: 52, height: 52)
                        Text(type.rawValue)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.75), radius: 1, y: 1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Choose \(type.rawValue)")
            }
        }
    }
}

private struct CareLevelRail: View {
    let type: CareType
    let value: Int

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                CareIcon(type: type, isActive: index == 0)
                    .frame(width: 54, height: 54)
                    .opacity(index == 0 ? 1 : 0.48)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(.black.opacity(0.46), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.16), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(type.rawValue) mode, level \(value) out of 4. Tap to choose another care mode")
    }
}

private struct CareIcon: View {
    let type: CareType
    let isActive: Bool

    private var color: Color {
        switch type {
        case .water: .cyan
        case .sunlight: .yellow
        case .wind: .mint
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(isActive ? 0.5 : 0.36))
                .overlay(Circle().stroke(.white.opacity(0.42), lineWidth: 2))
            Image(systemName: type.symbol)
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(isActive ? color : .white.opacity(0.65))
                .symbolEffect(.breathe.pulse, options: isActive ? .repeating : .nonRepeating)
        }
    }
}

private struct GrowthScene: View {
    let assetName: String
    let stage: Int
    @State private var emerged = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                RadialGradient(
                    colors: [Color.lime.opacity(0.23), .clear],
                    center: .bottom,
                    startRadius: 8,
                    endRadius: proxy.size.width * 0.55
                )
                AmbientMotes(color: stage == 0 ? .brown : Color.lime)
                Canvas { context, size in
                    guard stage > 0 else { return }
                    for index in 0..<7 {
                        let center = CGPoint(x: size.width / 2, y: size.height - 27)
                        let direction: CGFloat = index.isMultiple(of: 2) ? -1 : 1
                        let length = CGFloat(28 + index * 13) * min(1, CGFloat(stage) / 2)
                        var root = Path()
                        root.move(to: center)
                        root.addCurve(
                            to: CGPoint(x: center.x + direction * length, y: center.y + 22 + CGFloat(index % 3) * 8),
                            control1: CGPoint(x: center.x + direction * length * 0.35, y: center.y + 5),
                            control2: CGPoint(x: center.x + direction * length * 0.7, y: center.y + 24)
                        )
                        context.stroke(root, with: .color(.brown.opacity(0.5)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    }
                }

                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 4)
                    .scaleEffect(stageScale, anchor: .bottom)
                    .id(assetName)
                    .transition(
                        .asymmetric(
                            insertion: .offset(y: 95).combined(with: .scale(scale: 0.74, anchor: .bottom)).combined(with: .opacity),
                            removal: .scale(scale: 1.06, anchor: .bottom).combined(with: .opacity)
                        )
                    )
                    .scaleEffect(x: emerged ? 1 : 0.92, y: emerged ? 1 : 0.68, anchor: .bottom)
                    .accessibilityLabel("Growth stage \(stage + 1) of 5")
            }
        }
        .onAppear { withAnimation(.spring(response: 0.85, dampingFraction: 0.68)) { emerged = true } }
        .animation(.spring(response: 0.82, dampingFraction: 0.74), value: stage)
    }

    private var stageScale: CGFloat {
        switch stage {
        case 0: 0.42
        case 1: 0.52
        case 2: 0.7
        case 3: 0.86
        default: 1
        }
    }
}

private struct ResultScene: View {
    let result: TreeResult
    @State private var appears = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ResultParticleField(result: result)
                .opacity(appears ? 1 : 0)
            if result == .perfect {
                ForEach(0..<14, id: \.self) { index in
                    Image(systemName: index.isMultiple(of: 2) ? "sparkle" : "leaf.fill")
                        .foregroundStyle(index.isMultiple(of: 3) ? .white : Color.lime)
                        .offset(
                            x: CGFloat(cos(Double(index) / 14 * .pi * 2)) * (appears ? 145 : 20),
                            y: CGFloat(sin(Double(index) / 14 * .pi * 2)) * (appears ? 145 : 20)
                        )
                        .opacity(appears ? 0 : 1)
                        .animation(.easeOut(duration: 1.3).delay(Double(index) * 0.025), value: appears)
                }
            }
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                Image(result.assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .saturation(result == .fragile ? 0.45 : 1)
                    .opacity(result == .fragile ? 0.72 : 1)
                    .scaleEffect(
                        x: appears ? 1 + sin(time * 0.85) * 0.004 : 0.84,
                        y: appears ? 1 + sin(time * 0.85) * 0.008 : 0.84,
                        anchor: .bottom
                    )
                    .rotationEffect(.degrees(sin(time * 0.55) * resultSway), anchor: .bottom)
                    .shadow(color: resultGlow, radius: appears ? 16 : 0)
                    .animation(.spring(response: 0.82, dampingFraction: 0.7), value: appears)
                    .accessibilityLabel("\(result.title) tree")
            }
        }
        .onAppear { appears = true }
    }

    private var resultSway: Double {
        switch result {
        case .fragile: 1.8
        case .perfect, .good: 0.35
        default: 0.12
        }
    }

    private var resultGlow: Color {
        switch result {
        case .perfect: .pink.opacity(0.55)
        case .good: Color.lime.opacity(0.28)
        case .flooded: .cyan.opacity(0.25)
        case .burned: .orange.opacity(0.25)
        case .dry, .fragile: .clear
        }
    }
}

private struct CareControls: View {
    @Binding var selectedCare: CareType
    let journey: JourneyModel

    var body: some View {
        VStack(spacing: 7) {
            HStack(spacing: 7) {
                ForEach(CareType.allCases) { type in
                    CareMeter(title: type.rawValue, value: journey.careValue(for: type))
                }
            }
            HStack(spacing: 8) {
                ForEach(CareType.allCases) { type in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) { selectedCare = type }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: type.symbol)
                            Text(type.rawValue)
                                .font(.caption.bold())
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(CareChoiceStyle(isSelected: selectedCare == type, type: type))
                    .accessibilityLabel("Select \(type.rawValue)")
                    .accessibilityValue(selectedCare == type ? "Selected" : "Not selected")
                }
            }
            Text(actionHint)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.82))
                .frame(maxWidth: .infinity, minHeight: 28)
                .accessibilityLabel(actionHint)
        }
    }

    private var actionHint: String {
        switch selectedCare {
        case .water: "Drag the cloud to water the plant"
        case .sunlight: "Drag the sun to give the right light"
        case .wind: "Swipe across the scene to create wind"
        }
    }
}

private struct CareMeter: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(title.uppercased())
                .font(.caption2.bold())
            HStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < value ? Color.lime : .white.opacity(0.28))
                        .frame(width: 7, height: 7)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) level \(value) out of 4")
    }
}

private struct CareChoiceStyle: ButtonStyle {
    let isSelected: Bool
    let type: CareType

    private var selectedColor: Color {
        switch type {
        case .water: .blue
        case .sunlight: .yellow
        case .wind: .mint
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isSelected ? Color(red: 0.03, green: 0.15, blue: 0.07) : .white)
            .background(isSelected ? selectedColor : .white.opacity(0.14), in: RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

private struct PrimaryButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.headline)
                .foregroundStyle(Color(red: 0.03, green: 0.16, blue: 0.07))
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.9, green: 1, blue: 0.5), Color.lime],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    in: Capsule()
                )
                .overlay(Capsule().stroke(.white.opacity(0.62), lineWidth: 1))
                .shadow(color: Color.lime.opacity(0.28), radius: 12, y: 5)
        }
        .buttonStyle(.plain)
    }
}

private struct NatureBackdrop: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image("nature_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .saturation(1.08)
                    .contrast(1.03)

                RadialGradient(
                    colors: [.white.opacity(0.26), .yellow.opacity(0.09), .clear],
                    center: UnitPoint(x: 0.12, y: 0.04),
                    startRadius: 12,
                    endRadius: min(proxy.size.width, proxy.size.height) * 0.62
                )

                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.03),
                        .clear,
                        Color(red: 0.015, green: 0.12, blue: 0.05).opacity(0.48)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .accessibilityHidden(true)
        }
        .ignoresSafeArea()
    }
}

private extension Color {
    static let lime = Color(red: 0.77, green: 0.96, blue: 0.32)
}
