
import SwiftUI

// The Main Menu
// This view has...
//  - The logo
//  - 3 buttons to navigate other views

struct MenuView: View {
    
    @Binding var destination: MyDestination
    
    // Design settings
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: getMinSize())
            Spacer()
            MyButton(label: "Start", action: self.startBtnAction)
                .padding(.bottom, 5)
            MyButton(label: "Settings", action: self.settingsBtnAction)
                .padding(.bottom, 5)
            MyButton(label: "Leaderboard", action: self.leaderboardBtnAction)
                .padding(.bottom, 25)
        }
    }
    
    // Which is the smaller? Screen height or width
    // -> Need for the ipad to change orientation
    private func getMinSize() -> CGFloat {
        let h = UIScreen.main.bounds.height
        let w =  UIScreen.main.bounds.width
        return h > w ? w : h
    }
    
    // === BUTTON ACTIONS ==========================================================
    
    // When the user click on the start button...
    // -> The actual destination will be the start view
    private func startBtnAction() {
        print("Tap Start")
        destination = MyDestination.START_VIEW
    }
    
    // When the user click on the settings button...
    // -> The actual destination will be the settings view
    private func settingsBtnAction() {
        print("Tap Settings")
        destination = MyDestination.SETTINGS_VIEW
    }
    
    // When the user click on the leaderboard button...
    // -> The actual destination will be the leaderboard view
    private func leaderboardBtnAction() {
        print("Tap Leaderboard")
        destination = MyDestination.LEADERBOARD_VIEW
    }
    
}

// =================================================================================

// Preview
// Set the background to the color which we use
// -> To see how this view will looks like
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        @State var dest = MyDestination.MENU_VIEW
        MenuView(destination: $dest)
            .background(LinearGradient(gradient: Gradient(stops: [
                Gradient.Stop(color: Color(hex: 0x000000), location: 0.0),
                Gradient.Stop(color: Color(hex: 0x113366), location: 0.6)
            ]), startPoint: .top, endPoint: .bottom))
    }
}
