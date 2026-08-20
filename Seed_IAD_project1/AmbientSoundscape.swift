import AVFoundation

/// A tiny synthesized soundscape keeps the app completely offline and avoids
/// shipping or streaming copyrighted music.
@MainActor
final class AmbientSoundscape {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var didStart = false

    func start() {
        guard !didStart else { return }
        didStart = true

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2) else { return }
        let frameCount = AVAudioFrameCount(format.sampleRate * 8)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        let frequencies = [174.0, 261.63, 329.63]
        if let channels = buffer.floatChannelData {
            for channel in 0..<2 {
                for frame in 0..<Int(frameCount) {
                    let time = Double(frame) / format.sampleRate
                    let fade = min(1, time / 1.2) * min(1, (8 - time) / 1.2)
                    let chord = frequencies.enumerated().reduce(0.0) { partial, note in
                        partial + sin(2 * .pi * note.element * time + Double(channel) * 0.08) / Double(note.offset + 2)
                    }
                    channels[channel][frame] = Float(chord * fade * 0.018)
                }
            }
        }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        try? engine.start()
        player.play()
    }
}
