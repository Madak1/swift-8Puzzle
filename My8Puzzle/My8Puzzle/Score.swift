
import SwiftUI

// This is how a row looks like in the leaderboard

struct ScoreRow: View {
    
    let num: Int
    let username: String
    let score: Int
    
    // Designe settings
    var body: some View {
        HStack(alignment: .top) {
            Text("\(num<10 ? "0" : "")\(num)")
                .font(Font.custom("Menlo-Bold",size: getMinSize()/7.5))
                .foregroundColor(.white)
                .padding(.trailing)
            VStack(alignment: .leading) {
                Text(username)
                    .foregroundColor(.white)
                    .font(Font.system(size: getMinSize()/15))
                    .bold()
                Text("\(score) pts")
                    .foregroundColor(.orange)
                    .font(Font.system(size: getMinSize()/22.5))
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
}

// =================================================================================

// Preview
struct ScoreRow_Previews: PreviewProvider {
    static var previews: some View {
        ScoreRow(num: 1, username: "username", score: 234)
            .background(LinearGradient(gradient: Gradient(stops: [
            Gradient.Stop(color: Color(hex: 0x000000), location: 0.0),
            Gradient.Stop(color: Color(hex: 0x113366), location: 0.6)
        ]), startPoint: .top, endPoint: .bottom))
    }
}
