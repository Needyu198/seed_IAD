# seed_IAD
# Seed Journey

Seed Journey is a three-minute, interactive SwiftUI experience about growth, balance, and the consequences of care. The user plants a seed, covers it with soil, awakens it, and then makes six choices involving water, sunlight, and wind. Those choices determine how the final tree develops.

The application is designed as a short, immersive story suitable for iPhone and iPad. It works entirely offline and uses only locally packaged artwork, SF Symbols, procedural effects, and synthesized ambient audio.

## Experience

1. Tap the opening screen to begin the journey.
2. Drag the seed into the soil opening.
3. Swipe horizontally to cover the seed.
4. Tap the glowing soil to awaken it.
5. Choose Water, Sunlight, or Wind and complete the corresponding gesture.
6. Perform six total care actions.
7. Watch the automatic growth sequence from seed to mature tree.
8. Discover the final result and replay with a different balance.

The care interactions are direct and tactile:

- **Water:** drag the rain cloud toward the plant.
- **Sunlight:** drag the sun toward the plant.
- **Wind:** swipe horizontally across the scene.

Invalid planting and covering gestures return naturally to their starting state. Successful actions use animation and haptic feedback to make the interaction feel responsive.

## Possible Results

The final tree is calculated after six care actions. Conditions are evaluated in priority order:

| Priority | Condition | Result |
| ---: | --- | --- |
| 1 | Water equals 4 | Flooded |
| 2 | Sunlight equals 4 | Burned |
| 3 | Water is 0 or 1 | Dry |
| 4 | Wind equals 0 | Fragile |
| 5 | Water, sunlight, and wind equal 2 each | Perfect Care |
| 6 | Any other acceptable balance | Healthy Tree |

## Technical Highlights

- Native **SwiftUI** interface with no UIKit views or storyboards.
- **Swift 6** with strict-concurrency-compatible state and tasks.
- Modern Observation using `@Observable`, model ownership using `@State`, care selection using `@Binding`, and transient interaction state using `@State`.
- Custom transitions, spring animations, keyframe animation, `TimelineView`, and `Canvas` effects.
- Complex `DragGesture` interactions for planting, covering, care, and wind.
- Local haptic feedback through SwiftUI `sensoryFeedback`.
- Procedural rain, sunlight, wind, particles, soil, and plant movement.
- Locally synthesized ambient sound using `AVAudioEngine`.
- Responsive layouts for both iPhone and iPad.

## Offline Design

Seed Journey has no networking dependency:

- No `URLSession` calls.
- No web views, remote URLs, analytics, accounts, or login flow.
- All PNG artwork is bundled inside `Assets.xcassets`.
- Icons use locally available SF Symbols.
- Ambient audio is generated on the device and is never streamed.

The application remains fully functional without Wi-Fi or cellular data.

## Accessibility

- Dynamic Type support through accessibility text sizes.
- Meaningful labels, values, and hints for interactive controls.
- Spoken care-meter values.
- Decorative backgrounds and procedural effects are hidden from assistive technologies.
- Strong contrast and scalable layouts for iPhone and iPad.

## Architecture

The project uses a lightweight, model-driven SwiftUI structure:

```text
SeedJourneyApp
└── SeedJourneyView
    ├── planting and covering interactions
    ├── care-mode views and gestures
    ├── automatic growth sequence
    └── result and replay views
         ↕
    JourneyModel (@Observable)
```

`JourneyModel` is the single source of truth for navigation, the countdown, care values, growth stages, outcome calculation, and replay. Individual views keep short-lived animation and gesture values locally.

## Project Structure

| File | Purpose |
| --- | --- |
| `SeedJourneyApp.swift` | SwiftUI application entry point and root model ownership |
| `SeedJourneyView.swift` | Screens, layout, gestures, controls, and transitions |
| `JourneyModel.swift` | Journey state, care logic, growth sequence, and result calculation |
| `NatureEffects.swift` | Procedural rain, sunlight, wind, particles, and plant reactions |
