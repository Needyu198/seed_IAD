# Seed Journey - Technical Audit

## Architecture

- Pure SwiftUI application lifecycle in `SeedJourneyApp.swift`.
- No UIKit view controllers, app delegates, scene delegates, or storyboards.
- Swift 6 language mode with complete strict-concurrency checking.
- `JourneyModel` is the single source of truth and uses the Swift Observation `@Observable` macro.
- Root model ownership uses `@State`; care selection is passed through `@Binding`; interaction views use local `@State` for transient gesture and animation values.

## Offline Guarantee

- No `URLSession`, web view, remote URL, analytics, login, or network entitlement.
- All PNG artwork is stored in `Assets.xcassets`.
- Interface icons are local SF Symbols.
- Ambient audio is synthesized locally with `AVAudioEngine`; nothing is downloaded or streamed.

## Interaction and Polish

- `DragGesture` provides direct seed planting and swipe-to-cover interactions.
- Explicit spring, ease-in, ease-out, repeating, keyframe, and transition animations are implemented with SwiftUI.
- Procedural `TimelineView` and `Canvas` effects animate rain, sunlight rays, wind streams, soil particles, roots, ambient motes, and result foliage without video assets.
- Seed tilt, base-anchored plant sway, normalized stage sizing, moisture-dependent soil, and stage-specific growth motion provide physically coherent feedback without artificial ground shadows.
- `sensoryFeedback` marks navigation, invalid placement, successful covering, and major state transitions.
- The care system supports six actions, live meters, growth stages, priority-based outcomes, and complete replay/reset.

## Accessibility

- Semantic Dynamic Type styles are used throughout the interface.
- Layout supports text sizes through Accessibility 2.
- Interactive controls provide meaningful accessibility labels, values, and hints.
- Decorative background and effect imagery is hidden from assistive technologies.
- Care meters expose a concise spoken level from zero through four.

## Verification

- Target: iPhone and iPad, portrait orientation, iOS 18 or newer.
- Xcode Simulator build verified with Swift 6 strict concurrency.
- Opening screen visually inspected on the iPhone 17 simulator.
- Asset-catalog JSON and local property-list syntax validated.
