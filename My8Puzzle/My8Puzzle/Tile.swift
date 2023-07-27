
import SwiftUI

// How the tiles can move
enum TileDirection {
    case UP, DOWN, LEFT, RIGHT, INVALID
    
    // Get the opposite direction
    var oposite: TileDirection {
        switch self {
        case .UP: return .DOWN
        case .DOWN: return .UP
        case .LEFT: return .RIGHT
        case .RIGHT: return .LEFT
        case .INVALID: return .INVALID
        }
    }
}

// A tile
// -> There will be 9 tile (0ne of them is hiden)

struct Tile: View {
    let image: UIImage
    let size: CGFloat
    @Binding var dx: CGFloat
    @Binding var dy: CGFloat
    @Binding var gameState: GameState
    @State private var tileImage: UIImage = UIImage(named: "tile")!
    
    var body: some View {
        Image(uiImage: self.tileImage)
            .resizable()
            .cornerRadius(gameState == GameState.OVER ? 0 : 5)
            .frame(
                width: gameState == GameState.OVER ? self.size : self.size-5,
                height: gameState == GameState.OVER ? self.size : self.size-5
            )
            .offset(CGSize(
                width: self.dx*self.size,
                height: self.dy*self.size
            ))
            .onAppear(perform: {
                self.tileImage = self.image
            })
    }
}
