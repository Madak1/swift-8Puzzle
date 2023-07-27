
import SwiftUI

// The Leaderboard
// This view has...
//  - A title
//  - The scores
//  - Back button

// ( To see how it is looks like, then the DataController can add some test user )
//  - Uncomment the addTestUsers() (or win some game)
//  - Start an amulator or use a device

struct LeaderboardView: View {
    
    @Binding var destination: MyDestination
    
    @FetchRequest(sortDescriptors: []) var scores: FetchedResults<Score>
    
    // Designe settings
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("Leaderboard")
                    .font(Font.system(size: getMinSize()/8))
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                Spacer()
                // Use geometry reader to add some effect to scroll view
                // The top and the bottom of the list will be smaller and hide
                GeometryReader { fullView in
                    ScrollView {
                        VStack {
                            // The sorted version of the scores by the scores
                            let sortedScores = self.scores.sorted { $0.score > $1.score }
                            // Iterate all score and display them whit same effect
                            ForEach(sortedScores.indices, id: \.self) { idx in
                                let score = sortedScores[idx]
                                GeometryReader { itemView in
                                    let minY = itemView.frame(in: .global).minY
                                    let maxY = itemView.frame(in: .global).maxY
                                    let sv = scaleValue(
                                        fullFrame: fullView.frame(in: .global).minY,
                                        minY: minY, maxY: maxY
                                    )
                                    ScoreRow(
                                        num: idx+1,
                                        username: score.username ?? "unknown",
                                        score: Int(score.score)
                                    ).padding(.horizontal)
                                    // Opacity and scale settings
                                    .opacity(sv.0)
                                    .scaleEffect(
                                        sv.0,
                                        anchor: sv.1 ? .topLeading : .bottomLeading
                                    )
                                }
                                // Same height size we use for score view
                                .frame(height: getMinSize() / 7.5 + 10)
                            }
                        }
                        .padding(.vertical, 60)
                    }
                }
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
    
    // Get the scale value to have a nice effect at the top and bottom of the leaderoard
    private func scaleValue(fullFrame: CGFloat, minY: CGFloat, maxY: CGFloat) -> (CGFloat, Bool) {
        let screenHeight = UIScreen.main.bounds.height
        let topScale = (minY - 60) / fullFrame
        let bottomScale = ((screenHeight - maxY - getMinSize()/7.5 - 45 ) / fullFrame)
        // The scale is one if it is bigger then 1 otherwise the smoler value
        let scale = min(min(topScale, bottomScale), 1)
        // Return the scale value and a boolen which tell which one was the bigger
        // ( +0.001 -> absolute zero scale make some warning )
        return (scale + 0.001, topScale > bottomScale)
    }
    
    // Get screen height or width (The smaller one)
    private func getMinSize() -> CGFloat {
        let h = UIScreen.main.bounds.height
        let w =  UIScreen.main.bounds.width
        return h > w ? w : h
    }
    
    // === BUTTON ACTIONS ==========================================================
    
    // When the user click on the back button...
    // -> Then the actual destination will be the main menu again
    private func backBtnAction() {
        print("Tap Back")
        destination = MyDestination.MENU_VIEW
    }
}

// =================================================================================

// Preview
struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        @State var dest = MyDestination.LEADERBOARD_VIEW
        LeaderboardView(destination: $dest)
            .background(LinearGradient(gradient: Gradient(stops: [
                Gradient.Stop(color: Color(hex: 0x000000), location: 0.0),
                Gradient.Stop(color: Color(hex: 0x113366), location: 0.6),
            ]), startPoint: .top, endPoint: .bottom))
    }
}
