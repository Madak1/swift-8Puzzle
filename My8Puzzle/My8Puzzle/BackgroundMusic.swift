
import AVFoundation

// The music Player for background music

class BackgroundMusic {
    
    static let shared = BackgroundMusic()

    private var player: AVAudioPlayer?

    // Load the song and play at the background forever
    func play() {
        guard let url = Bundle.main.url(forResource: "music", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            print("Error playing background music: \(error.localizedDescription)")
        }
    }

    // Handle the end of the music player
    func stop() {
        player?.stop()
        player = nil
    }
}
