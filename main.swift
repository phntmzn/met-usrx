import Foundation

let processor = AudioProcessor()
let composer = MIDIComposer()

let group = DispatchGroup()

let total = 200
let queue = DispatchQueue(label: "wav.queue", attributes: .concurrent)

for i in 0..<total {
    queue.async(group: group) {
        let midi = composer.generate()
        let wav = processor.outputDir.appendingPathComponent(String(format: "%05d.wav", i))
        processor.renderMIDI(midiURL: midi, wavURL: wav)
        processor.processAudio(at: wav)
        print("✅ Finished \(wav.lastPathComponent)")
    }
}

group.wait()
