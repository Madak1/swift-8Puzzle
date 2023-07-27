
import SwiftUI

// The button
// The buttons have...
//  - A label -> Describe the porpuse of the button
//  - An action -> What will the buttons do
//  - Width and height

struct MyButton: View {
    
    var label: String
    let action: () -> Void
    // The button has a little less with then the smaller side of the screen
    var width: CGFloat = UIScreen.main.bounds.height > UIScreen.main.bounds.width ? UIScreen.main.bounds.width-50 : UIScreen.main.bounds.height-50
    // This is the padding size
    var height: CGFloat = 25
    
    var body: some View {
        Button {
            // The action will be perform with animation (spring animation)
            withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.8)) {
                self.action()
            }
        } label: {
            Text(self.label)
                .font(Font.system(size: getMinSize()/12))
                .bold()
                .shadow(color: Color.black, radius: 1, x: 2, y: 2)
                .padding(.vertical, height)
                .frame(width: self.width)
                .foregroundColor(Color.white)
                .background(Color(hex: 0x5588BB))
                .cornerRadius(20)
                .shadow(radius: 5)
                .navigationBarBackButtonHidden(true)
        }
    }
    
    // Get screen height or width (The smaller one)
    private func getMinSize() -> CGFloat {
        let h = UIScreen.main.bounds.height
        let w =  UIScreen.main.bounds.width
        return h > w ? w : h
    }
}
