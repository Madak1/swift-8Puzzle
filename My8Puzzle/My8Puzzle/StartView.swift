
import SwiftUI

// The Game Mode Selector
// This view has...
//  - A title
//  - 3 buttons to select mode (Set the image to the game)
//  - Back button

struct StartView: View {
    
    @Binding var destination: MyDestination
    @Binding var image: UIImage?
    
    @State private var showingPicker: Bool = false
    
    // Design settings
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("Start")
                    .font(Font.system(size: getMinSize()/8))
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                Spacer()
                MyButton(label: "Classic Mode", action: self.classicBtnAction)
                MyButton(label: "Picture Mode", action: self.pictureBtnAction)
                    .padding(.vertical, 5)
                MyButton(label: "Photo Mode", action: self.photoBtnAction)
                Spacer()
                MyButton(
                    label: "Back",
                    action: self.backBtnAction,
                    width: ( getMinSize() - 50 ) / 1.5
                ).padding(.bottom, 25)
            }
            Spacer()
        }
        // If we want to take a picture the camere will appear in full screen
        // When the picture is ready then go to the game
        .fullScreenCover(isPresented: $showingPicker) {
            ImagePicker(img: $image).ignoresSafeArea(.all).onDisappear(perform: {
                if (image != nil) {
                    destination = MyDestination.GAME_VIEW
                }
            })
        }
    }
    
    // Get screen height or width (The smaller one)
    private func getMinSize() -> CGFloat {
        let h = UIScreen.main.bounds.height
        let w =  UIScreen.main.bounds.width
        return h > w ? w : h
    }
    
    // === BUTTON ACTIONS ==========================================================
    
    // When the user click on the classic button...
    // -> Then a classic board with numbers will be selected
    private func classicBtnAction() {
        print("Tap Classic")
        image = UIImage(named: "board")!
        destination = MyDestination.GAME_VIEW
    }
    
    // When the user click on the picture button...
    // -> Then a random picture will be selected
    private func pictureBtnAction() {
        print("Tap Picture")
        let images = [
            UIImage(named: "p1"),
            UIImage(named: "p2"),
            UIImage(named: "p3"),
            UIImage(named: "p4"),
            UIImage(named: "p5")
        ]
        image = images.randomElement()!
        destination = MyDestination.GAME_VIEW
    }
    
    // When the user click on the photo button...
    // -> Then the camera will shows up
    private func photoBtnAction() {
        print("Tap Photo")
        showingPicker = true
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
struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        @State var dest = MyDestination.START_VIEW
        @State var boardImage: UIImage? = UIImage(named: "test")
        StartView(destination: $dest, image: $boardImage)
            .background(LinearGradient(gradient: Gradient(stops: [
                Gradient.Stop(color: Color(hex: 0x000000), location: 0.0),
                Gradient.Stop(color: Color(hex: 0x113366), location: 0.6)
            ]), startPoint: .top, endPoint: .bottom))
    }
}
