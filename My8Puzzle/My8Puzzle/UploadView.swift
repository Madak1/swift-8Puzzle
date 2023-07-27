
import SwiftUI

// The Upload field
// This view has...
//  - A title
//  - The Score
//  - A Text field (with description what to give and the limitations)
//  - Upload button
//  - Cancel button

struct UploadView: View {
    
    @Binding var destination: MyDestination
    
    @State private var username: String = ""
    @State private var shakeOff: CGFloat = 0
    
    let score: Int
    
    // Managed Object Context (To add score to database)
    @Environment(\.managedObjectContext) var moc
    
    // Designe settings
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("Upload Score")
                    .font(Font.system(size: getMinSize()/8))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                Text("\(self.score) pts")
                    .font(Font.system(size: getMinSize()/13))
                    .foregroundColor(.orange)
                    .bold()
                Spacer()
                Group {
                    Text("Add username")
                        .font(Font.system(size: getMinSize()/13))
                        .foregroundColor(.white)
                        .bold()
                    // Condition (it is shake if something wrong with the given name)
                    Text("Length: 3 - 15")
                        .font(Font.system(size: getMinSize()/20))
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                        .offset(CGSize(width: self.shakeOff, height: 0))
                }
                // Here can add a user a username
                TextField("", text: $username)
                    .font(Font.system(size: getMinSize()/20))
                    .foregroundColor(.white)
                    .bold()                    .padding()
                    .frame(width: getMinSize()-50, height: 60)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.bottom, 20)
                MyButton(label: "Upload", action: self.uploadBtnAction)
                Spacer()
                Spacer()
                MyButton(
                    label: "Cancel",
                    action: self.cancelBtnAction,
                    width: (getMinSize()-50)/1.5
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
    
    // When the user click on the upload button...
    // -> Then the new score will be add to the database then go to leaderboard
    // -> If the user give incorrect username then the condition text will shake
    private func uploadBtnAction() {
        print("Tap Upload")
        // Hide the keyboard
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        // Check the given username
        // -> Incorrect: Shake condition text
        // -> Correct: Upload score and go to leaderboard
        if self.username.count < 3 || self.username.count > 15 {
            withAnimation(Animation.spring(response: 0.1, dampingFraction: 0.1)) {
                self.shakeOff += 5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.shakeOff -= 5
            }
        } else {
            let score = Score(context: moc)
            score.id = UUID()
            score.username = self.username
            score.score = Int16(self.score)
            try? moc.save()
            destination = MyDestination.LEADERBOARD_VIEW
        }
    }
    
    // When the user click on the cancel button...
    // -> Then the actual destination will be the main menu again
    private func cancelBtnAction() {
        print("Tap Cancel")
        destination = MyDestination.MENU_VIEW
    }
}

// =================================================================================

// Preview
struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        @State var dest = MyDestination.LEADERBOARD_VIEW
        UploadView(destination: $dest, score: 555)
            .background(LinearGradient(gradient: Gradient(stops: [
                Gradient.Stop(color: Color(hex: 0x000000), location: 0.0),
                Gradient.Stop(color: Color(hex: 0x113366), location: 0.6)
            ]), startPoint: .top, endPoint: .bottom))
    }
}
