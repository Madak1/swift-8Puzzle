
import SwiftUI

// The Settings
// This view has...
//  - A title
//  - Buttons to set the music and tilt control on/off
//  - A button to reset the leaderboard
//  - Back button

// ( Settings will be visible with an emulator or phisical device )

struct SettingsView: View {
    
    @Binding var destination: MyDestination
    
    @State private var musicOn = false
    @State private var tiltOn = false
    
    @State private var tapReset: Bool = false
    
    // Database
    // ( moc -> ManagedObjectContext )
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var settings: FetchedResults<Setting>
    @FetchRequest(sortDescriptors: []) var scores: FetchedResults<Score>
    
    // Music player
    let musicPlayer = BackgroundMusic.shared
    
    // Design settings
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("Settings")
                    .font(Font.system(size: getMinSize()/8))
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                Spacer()
                // List all settings
                //  - Music and Tilt control
                ForEach(settings) { setting in
                    let label = "\(setting.name ?? "unknown"): \(setting.value ? "On" : "Off")"
                    MyButton(label: label,action: { self.settingBtnAction(setting: setting) })
                        .padding(.bottom, 5)
                }
                Spacer()
                MyButton(
                    label: tapReset ? "Tap again to Reset" : "Reset Leaderboard",
                    action: self.resetBtnAction,
                    height: tapReset ? 60 : 25
                )
                Spacer()
                MyButton(
                    label: "Back",
                    action: self.backBtnAction,
                    width: ( getMinSize() - 50 ) / 1.5
                ).padding(.bottom, 25)
            }
            Spacer()
        }
    }
    
    // Get screen height or width (The smaller one)
    private func getMinSize() -> CGFloat {
        let h = UIScreen.main.bounds.height
        let w =  UIScreen.main.bounds.width
        return h > w ? w : h
    }
    
    // === BUTTON ACTIONS ==========================================================
    
    // When the user click on a setting button...
    // -> Then the actual setting's value will toggle
    // -> After the change the new value will be saved in the database
    // -> We save the settings so it will be remain after a new start
    private func settingBtnAction(setting: Setting) {
        print("Tap a Setting")
        setting.value.toggle()
        try? moc.save()
        if (setting.name == "Music") {
            setting.value ? musicPlayer.play() : musicPlayer.stop()
        }
    }
    
    // When the user click on the reset button...
    // -> Then if it is the first tap then the button will change to "Are you sure?" mode
    // -> When the button is in the "Are you sure?" mode, then if we tap again then confirm reset
    // -> In this mode if don't tap again on the buton it will be the original after 2 sec
    private func resetBtnAction() {
        print("Tap Reset")
        if tapReset {
            // "Are you sure?" mode
            // The scores will be deleted
            for score in scores {
                self.moc.delete(score)
            }
            // Save the changes
            try? moc.save()
            // Get back to original mode with animation
            withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.5)) {
                tapReset = false
            }
        } else {
            // Original mode
            // Go to "Are you sure?" mode with animation
            withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.5)) {
                self.tapReset = true
            }
            // After 2 sec get back to original mode with animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.5)) {
                    self.tapReset = false
                }
            }
        }
    }
    
    // When the user click on the back button...
    // -> Then the actual destination will be the main menu again
    private func backBtnAction() {
        print("Tap Back")
        destination = MyDestination.MENU_VIEW
    }
}

// =================================================================================

// Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var dest = MyDestination.SETTINGS_VIEW
        SettingsView(destination: $dest)
            .background(LinearGradient(gradient: Gradient(stops: [
                Gradient.Stop(color: Color(hex: 0x000000), location: 0.0),
                Gradient.Stop(color: Color(hex: 0x113366), location: 0.6)
            ]), startPoint: .top, endPoint: .bottom))
    }
}
