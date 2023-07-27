
import SwiftUI

// The Game
// This view has...
//  - A timer
//  - The Board
//  - Pause button
//  - Exit button

struct GameView: View {
    
    @Binding var destination: MyDestination
    @Binding var boardImage: UIImage?
    @Binding var gameScore: Int
    
    @State private var gameState: GameState = GameState.PAUSE
    @State private var stepCount: Int = 0
    
    @State private var timeDisplay = "00:00:00"
    @State private var elapsedTime: Int = 0
    
    @State private var tapOnExit: Bool = false
    
    // Timer to measure the ellapsed time
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Designe settings
    var body: some View {
        HStack {
            Spacer()
            VStack {
                // Tmer with a font style which hase the same size for every number
                Text(timeDisplay)
                    .font(Font.custom("Menlo-Bold",size: getMinSize()/7))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .offset(CGSize(
                        width: 0,
                        height: self.gameState == GameState.PAUSE ? 200 : 0
                    ))
                Spacer()
                // Show the board if the board has an image
                if let img = boardImage {
                    Board(originalImage: img, gameState: $gameState, steps: $stepCount)
                        .padding()
                        // Hide the board if the game has paused
                        .opacity(self.gameState == GameState.PAUSE ? 0 : 1)
                        .scaleEffect(self.gameState == GameState.PAUSE ? 0.001 : 1)
                        // Reset the time, step num
                        .onAppear(perform: {
                            self.elapsedTime = 0
                            self.stepCount = 0
                            self.updateTimeDisplay()
                            // The game will be play state after 0.2 sec
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation {
                                    self.gameState = GameState.PLAY
                                }
                            }
                        })
                        // Handle the time (If play state -> Timer++ and update display)
                        .onReceive(self.timer) { time in
                            if self.gameState == GameState.PLAY {
                                self.elapsedTime += 1
                                self.updateTimeDisplay()
                            }
                        }
                }
                Spacer()
                // This button is the pause, reasume and upload button
                MyButton(label: self.getPauseBtnLabel(), action: self.pauseBtnAction)
                    .padding(.bottom, 5)
                // Exit (with safe mode -> "Are you sure?")
                MyButton(
                    label: tapOnExit ? "Tap again to Exit" : "Exit",
                    action: self.exitBtnAction,
                    height: tapOnExit ? 60 : 25
                ).padding(.bottom, 25)
            }
            Spacer()
        }
    }
    
    // Update the time display with a proper string format
    private func updateTimeDisplay() {
        let t = elapsedTime
        let h = t % 86400 / 3600
        let m = t % 86400 % 3600 / 60
        let s = t % 86400 % 3600 % 60
        self.timeDisplay = String(format: "%02d:%02d:%02d", h, m, s)
    }
    
    // Get screen height or width (The smaller one)
    private func getMinSize() -> CGFloat {
        let h = UIScreen.main.bounds.height
        let w =  UIScreen.main.bounds.width
        return h > w ? w : h
    }
    
    // Get the actual label for the pause button
    private func getPauseBtnLabel() -> String {
        if self.gameState == GameState.PAUSE {
            return "Resume"
        } else if self.gameState == GameState.PLAY {
            return "Pause"
        } else {
            return "Upload"
        }
    }
    
    // === BUTTON ACTIONS ==========================================================
    
    // When the user click on the pause button...
    // -> If play mode: Pause the game
    // -> If pause mode: Resume the game
    // -> If upload mode: Navigate to upload view (set destination)
    private func pauseBtnAction() {
        print("Tap Pause")
        if self.gameState == GameState.PAUSE {
            self.gameState = GameState.PLAY
        } else if self.gameState == GameState.PLAY {
            self.gameState = GameState.PAUSE
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.gameState = GameState.PAUSE
                self.boardImage = nil
            }
            // Max point: 1000 (Impossible to get)
            // -> Subtract 3x the time plus 2x the steps from the max
            // -> (Just the tap count step so if we want large score need to practice tilt control)
            let pts = 1000 - ( 3 * self.elapsedTime + 2 * self.stepCount )
            self.gameScore = pts > 0 ? pts : 0
            self.destination = MyDestination.UPLOAD_VIEW
        }
    }
    
    // When the user click on the exit button...
    // -> Then if it is the first tap then the button will change to "Are you sure?" mode
    // -> When the button is in the "Are you sure?" mode, then if we tap again then confirm exit
    // -> In this mode if don't tap again on the buton it will be the original after 2 sec
    private func exitBtnAction() {
        print("Tap Exit")
        if tapOnExit {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.gameState = GameState.PAUSE
                self.boardImage = nil
                self.tapOnExit = false
            }
            self.destination = MyDestination.MENU_VIEW
        } else {
            withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.5)) { 
                self.tapOnExit = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.5)) {
                    self.tapOnExit = false
                }
            }
        }
    }
}

// =================================================================================

// Preview
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        @State var dest = MyDestination.GAME_VIEW
        @State var img: UIImage? = UIImage(named: "board")
        @State var score: Int = 10
        GameView(destination: $dest, boardImage: $img, gameScore: $score)
            .background(LinearGradient(gradient: Gradient(stops: [
                Gradient.Stop(color: Color(hex: 0x000000), location: 0.0),
                Gradient.Stop(color: Color(hex: 0x113366), location: 0.6)
            ]), startPoint: .top, endPoint: .bottom)) 
    }
}
