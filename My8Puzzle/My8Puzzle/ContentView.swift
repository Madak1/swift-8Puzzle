
import SwiftUI

// The destinations to control what we want to see
enum MyDestination: Int {
    case MENU_VIEW
    case START_VIEW
    case SETTINGS_VIEW
    case LEADERBOARD_VIEW
    case GAME_VIEW
    case UPLOAD_VIEW
}

// The Content View
// This control which wiew is "active" and show that to the user

struct ContentView: View {
    
    @FetchRequest(sortDescriptors: []) private var settings: FetchedResults<Setting>
    
    let musicPlayer = BackgroundMusic.shared
    
    @State private var actDest = MyDestination.MENU_VIEW
    @State private var boardImage: UIImage? = nil
    @State private var scroe: Int = 0
    
    var body: some View {
        ZStack {
            // Show the current view to the user based on the actual destination
            // The others are hiden under the screen
            MenuView(destination: $actDest)
                .offset(CGSize(
                    width: 0,
                    height: self.getHeightWhenDest(is: .MENU_VIEW)
                )).opacity(self.getOpacityWhenDest(is: .MENU_VIEW))
            StartView(destination: $actDest, image: $boardImage)
                .offset(CGSize(
                    width: 0,
                    height: self.getHeightWhenDest(is: .START_VIEW)
                )).opacity(self.getOpacityWhenDest(is: .START_VIEW))
            SettingsView(destination: $actDest)
                .offset(CGSize(
                    width: 0,
                    height: self.getHeightWhenDest(is: .SETTINGS_VIEW)
                )).opacity(self.getOpacityWhenDest(is: .SETTINGS_VIEW))
            LeaderboardView(destination: $actDest)
                .offset(CGSize(
                    width: 0,
                    height: self.getHeightWhenDest(is: .LEADERBOARD_VIEW)
                )).opacity(self.getOpacityWhenDest(is: .LEADERBOARD_VIEW))
            GameView(destination: $actDest, boardImage: $boardImage, gameScore: $scroe)
                .offset(CGSize(
                    width: 0,
                    height: self.getHeightWhenDest(is: .GAME_VIEW)
                )).opacity(self.getOpacityWhenDest(is: .GAME_VIEW))
            UploadView(destination: $actDest, score: scroe)
                .offset(CGSize(
                    width: 0,
                    height: self.getHeightWhenDest(is: .UPLOAD_VIEW)
                )).opacity(self.getOpacityWhenDest(is: .UPLOAD_VIEW))
        }
        // Set the backgrond to black to blue -> The notch will hiden
        .background(
            LinearGradient(gradient: Gradient(stops: [
                Gradient.Stop(color: Color(hex: 0x000000), location: 0.0),
                Gradient.Stop(color: Color(hex: 0x113366), location: 0.6)
            ]), startPoint: .top, endPoint: .bottom)
        )
        // Before the view appears start music (if it is on)
        .onAppear(perform: {
            self.setupBgMusic()
        })
        // After the view disappear stop the music player
        .onDisappear(perform: {
            self.musicPlayer.stop()
        })
    }
    
    // Get the height based on the actual destination
    private func getHeightWhenDest(is dest: MyDestination) -> CGFloat {
        return self.actDest == dest ? 0 : UIScreen.main.bounds.height
    }
    
    // Get the opacity based on the actual destination
    private func getOpacityWhenDest(is dest: MyDestination) -> CGFloat {
        return self.actDest == dest ? 1 : 0
    }
    
    // Check the setting and start the music if it is on
    private func setupBgMusic() {
        if let musicSetting = settings.first(where: { $0.name == "Music" }) {
            if (musicSetting.value) {
                musicPlayer.play()
            }
        }
    }
}

// =================================================================================

// Preview
// (Warning: The views which based on the database will missing on the previews)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
