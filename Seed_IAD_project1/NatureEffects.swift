import SwiftUI

/// Lightweight procedural effects keep movement organic without video files or networking.
struct CareWeatherEffect: View {
    let type: CareType
    let trigger: Int
    var interactionOffset: CGSize = .zero
    var intensity: CGFloat = 1

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    switch type {
                    case .water:
                        rain(time: time, size: proxy.size)
                    case .sunlight:
                        sunlight(time: time, size: proxy.size)
                    case .wind:
                        wind(time: time, size: proxy.size)
                    }
                }
                .opacity(0.32 + intensity * 0.68)
            }
        }
        .id(type)
        .transition(.scale(scale: 0.84).combined(with: .opacity))
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func rain(time: TimeInterval, size: CGSize) -> some View {
        LinearGradient(
            colors: [.blue.opacity(0.05), .blue.opacity(0.18), .clear],
            startPoint: .top,
            endPoint: .bottom
        )
        Canvas { context, canvasSize in
            for index in 0..<24 {
                let lane = CGFloat((index * 47) % 101) / 100
                let speed = 150 + CGFloat((index * 19) % 85)
                let phase = CGFloat((index * 73) % 170)
                let y = (CGFloat(time) * speed + phase).truncatingRemainder(dividingBy: canvasSize.height + 80) - 45
                let x = lane * canvasSize.width
                var drop = Path()
                drop.move(to: CGPoint(x: x, y: y))
                drop.addLine(to: CGPoint(x: x - 5, y: y + 17))
                context.stroke(drop, with: .linearGradient(
                    Gradient(colors: [.white.opacity(0.2), .cyan.opacity(0.85)]),
                    startPoint: CGPoint(x: x, y: y),
                    endPoint: CGPoint(x: x - 5, y: y + 17)
                ), lineWidth: index.isMultiple(of: 3) ? 2.2 : 1.2)
            }
        }
        Image("water_cloud")
            .resizable()
            .scaledToFit()
            .frame(width: min(230, size.width * 0.62))
            .offset(
                x: size.width * 0.17 + interactionOffset.width,
                y: -size.height * 0.27 + sin(time * 1.4) * 4 + interactionOffset.height
            )
            .shadow(color: .blue.opacity(0.32), radius: 18, y: 10)
    }

    @ViewBuilder
    private func sunlight(time: TimeInterval, size: CGSize) -> some View {
        RadialGradient(
            colors: [.yellow.opacity(0.3), .orange.opacity(0.12), .clear],
            center: .topTrailing,
            startRadius: 10,
            endRadius: size.width * 0.85
        )
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width * 0.84, y: canvasSize.height * 0.08)
            for index in 0..<16 {
                let angle = CGFloat(index) / 16 * .pi * 2 + CGFloat(time * 0.06)
                let inner: CGFloat = 66
                let outer: CGFloat = 102 + sin(CGFloat(time * 1.2) + CGFloat(index)) * 7
                var ray = Path()
                ray.move(to: CGPoint(x: center.x + cos(angle) * inner, y: center.y + sin(angle) * inner))
                ray.addLine(to: CGPoint(x: center.x + cos(angle) * outer, y: center.y + sin(angle) * outer))
                context.stroke(ray, with: .color(.yellow.opacity(0.42)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            }
        }
        Image("sunlight")
            .resizable()
            .scaledToFit()
            .frame(width: min(215, size.width * 0.57))
            .offset(
                x: size.width * 0.21 + interactionOffset.width,
                y: -size.height * 0.29 + interactionOffset.height
            )
            .scaleEffect(1 + sin(time * 1.5) * 0.025)
            .shadow(color: .yellow.opacity(0.55), radius: 24)
    }

    @ViewBuilder
    private func wind(time: TimeInterval, size: CGSize) -> some View {
        Canvas { context, canvasSize in
            for index in 0..<7 {
                let vertical = canvasSize.height * (0.18 + CGFloat(index) * 0.105)
                let travel = (CGFloat(time) * (72 + CGFloat(index * 9)) * max(0.25, intensity)).truncatingRemainder(dividingBy: canvasSize.width + 180) - 130 + interactionOffset.width * 0.35
                var stream = Path()
                stream.move(to: CGPoint(x: travel, y: vertical))
                stream.addCurve(
                    to: CGPoint(x: travel + 145, y: vertical + sin(CGFloat(time) + CGFloat(index)) * 14),
                    control1: CGPoint(x: travel + 42, y: vertical - 18),
                    control2: CGPoint(x: travel + 100, y: vertical + 22)
                )
                context.stroke(stream, with: .linearGradient(
                    Gradient(colors: [.clear, .white.opacity(0.58), .cyan.opacity(0.2), .clear]),
                    startPoint: CGPoint(x: travel, y: vertical),
                    endPoint: CGPoint(x: travel + 145, y: vertical)
                ), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))

                let leafX = travel + 92
                let leafY = vertical + sin(CGFloat(time * 2) + CGFloat(index)) * 17
                let leaf = Path(ellipseIn: CGRect(x: leafX, y: leafY, width: 12, height: 6))
                context.fill(leaf, with: .color(.green.opacity(0.78)))
            }
        }
        Image("wind")
            .resizable()
            .scaledToFit()
            .frame(width: min(245, size.width * 0.66))
            .offset(x: size.width * 0.16 + sin(time) * 5, y: -size.height * 0.24)
            .opacity(0.82)
    }
}

struct OrganicPlantImage: View {
    let assetName: String
    let care: CareType
    let reactionTrigger: Int

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let amplitude = care == .wind ? 3.2 : care == .water ? 0.8 : 0.35
            Image(assetName)
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(sin(time * 1.65) * amplitude), anchor: .bottom)
                .offset(x: care == .wind ? sin(time * 1.2) * 3 : 0)
        }
        .keyframeAnimator(initialValue: PlantReaction(), trigger: reactionTrigger) { content, value in
            content
                .scaleEffect(x: value.width, y: value.height, anchor: .bottom)
                .offset(y: value.verticalOffset)
        } keyframes: { _ in
            KeyframeTrack(\.width) {
                LinearKeyframe(1, duration: 0.05)
                SpringKeyframe(1.045, duration: 0.22, spring: .snappy)
                SpringKeyframe(1, duration: 0.36, spring: .bouncy)
            }
            KeyframeTrack(\.height) {
                LinearKeyframe(1, duration: 0.05)
                SpringKeyframe(0.96, duration: 0.16, spring: .snappy)
                SpringKeyframe(1.025, duration: 0.2, spring: .bouncy)
                SpringKeyframe(1, duration: 0.24, spring: .smooth)
            }
            KeyframeTrack(\.verticalOffset) {
                LinearKeyframe(0, duration: 0.05)
                SpringKeyframe(5, duration: 0.16, spring: .snappy)
                SpringKeyframe(-3, duration: 0.2, spring: .bouncy)
                SpringKeyframe(0, duration: 0.24, spring: .smooth)
            }
        }
    }
}

private struct PlantReaction {
    var width: CGFloat = 1
    var height: CGFloat = 1
    var verticalOffset: CGFloat = 0
}

struct AmbientMotes: View {
    var color: Color = .white

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for index in 0..<18 {
                    let x = CGFloat((index * 61) % 101) / 100 * size.width
                    let phase = CGFloat((index * 37) % 100) / 100 * size.height
                    let y = size.height - (CGFloat(time * (7 + Double(index % 5))) + phase).truncatingRemainder(dividingBy: size.height + 20)
                    let radius = CGFloat(1.2 + Double(index % 3))
                    let opacity = 0.18 + 0.16 * sin(CGFloat(time) + CGFloat(index))
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)), with: .color(color.opacity(opacity)))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct ResultParticleField: View {
    let result: TreeResult

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for index in 0..<22 {
                    let lane = CGFloat((index * 43) % 97) / 96
                    let phase = CGFloat((index * 71) % 200)
                    let speed: CGFloat = result == .dry ? 32 : 18
                    let y = (CGFloat(time) * speed + phase).truncatingRemainder(dividingBy: size.height + 30) - 15
                    let drift = sin(CGFloat(time * 0.8) + CGFloat(index)) * 16
                    let x = lane * size.width + drift
                    let particle = Path(ellipseIn: CGRect(x: x, y: y, width: 8, height: 4))
                    context.fill(particle, with: .color(particleColor.opacity(0.7)))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var particleColor: Color {
        switch result {
        case .perfect: .pink
        case .good, .fragile: .green
        case .dry: .orange
        case .burned: .red
        case .flooded: .cyan
        }
    }
}
