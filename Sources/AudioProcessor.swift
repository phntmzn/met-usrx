import Foundation

class AudioProcessor {
    let renderer = MetalRenderer()
    let soundfontPath = "/Users/macbookair/Downloads/OPLLandOPLL2DrumFix2Remake.sf2"
    let fluidsynthPath = "/opt/homebrew/bin/fluidsynth"
    let sampleRate = 44100
    let outputDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop/wav_only_200")

    func renderMIDI(midiURL: URL, wavURL: URL) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: fluidsynthPath)
        process.arguments = ["-ni", soundfontPath, midiURL.path, "-F", wavURL.path, "-r", "\(sampleRate)"]
        try? process.run()
        process.waitUntilExit()
    }

    func processAudio(at path: URL) {
        guard let audioData = try? Data(contentsOf: path) else { return }
        // Decode WAV to float32 array (use AudioKit or SwiftWav for real implementation)
        // Then pass to `renderer.applyEffect(...)`, convert back to PCM16, and write WAV
    }
}
