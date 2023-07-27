
import SwiftUI
import CoreMotion

enum GameState {
    case PLAY, PAUSE, OVER
}

// The soul of the game
// -> How the game work

struct Board: View {
    @FetchRequest(sortDescriptors: []) private var settings: FetchedResults<Setting>
    
    @State private var accX: Double = 0.0
    @State private var accY: Double = 0.0
    private let motionManager = CMMotionManager()
    
    @State private var elapsedTime = 0
    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    @State var originalImage: UIImage
    @State private var tileImages: [UIImage]? = nil
    @State private var blankIndex = 0
    
    // PosX, PosY, TileNum
    @State private var tiles: [(CGFloat, CGFloat, Int)] = [
        (-1,-1,1),(0,-1,2),(1,-1,3),
        (-1,0,4),(0,0,5),(1,0,6),
        (-1,1,7),(0,1,8),(1,1,9)
    ]
    
    @State private var gameLogic: Puzzle = Puzzle()
    @Binding var gameState: GameState
    @Binding var steps: Int
    
    // Designe settings
    var body: some View {
        // Help get the proper size of the board and the tiles
        GeometryReader { geometry in
            ZStack {
                // The board (This is the background)
                Image(uiImage: self.originalImage)
                    .resizable()
                    .cornerRadius(10)
                    .opacity(0.2)
                    .frame(
                        width: getMinSize(size: geometry.size),
                        height: getMinSize(size: geometry.size)
                    )
                    // Label for UI test
                    .accessibility(identifier: "board")
                    // Get the blank tile, set the tiles position and crop the original image
                    .onAppear(perform: {
                        self.blankIndex = self.gameLogic.getBlankNum()-1
                        self.setTilePositions(by: self.gameLogic.getBoard())
                        self.originalImage = self.cropBoard()
                    })
                // When the tiles are ready (crop done) show them
                if let croppedTileImages = self.tileImages {
                    ForEach(tiles.indices, id: \.self) { index in
                        let tSize = getMinSize(size: geometry.size) / 3
                        Tile(
                            image: croppedTileImages[index],
                            size: gameState == GameState.OVER ? tSize :  tSize - 2.5,
                            dx: $tiles[index].0,
                            dy: $tiles[index].1,
                            gameState: $gameState
                        )
                        // Label for UI test
                        .accessibility(identifier: "tile\(index+1)")
                        .onTapGesture {
                            if self.gameState == GameState.PLAY {
                                self.moveTileTap(targetIndex: index)
                            }
                        }.opacity( (blankIndex == index && self.gameState != GameState.OVER ) ? 0 : 1)
                    }
                }
            }
            // Move the board to the center
            .position(
                x: geometry.frame(in: .local).midX,
                y: geometry.frame(in: .local).midY
            )
            // When tilt control is on here can update the board rotation
            .rotation3DEffect(
                .degrees(accX),
                axis: (x: 1, y: 0, z: 0)
            )
            .rotation3DEffect(
                .degrees(accY),
                axis: (x: 0, y: 1, z: 0)
            )
            // Check tilt control is on or not, and if on then start update
            .onAppear(perform: {
                self.tileImages = self.getCroppedTiles()
                if let tiltSetting = self.settings.first(where: { $0.name == "Tilt control" }) {
                    if (tiltSetting.value) {
                        self.startUpdateTilt()
                    }
                }
            })
            // The tilt movement happen every 0.4 sec
            .onReceive(self.timer) { time in
                if self.gameState == GameState.PLAY {
                    self.moveTileTilt()
                }
            }
        }
    }
    
    // Get a matrix with the number of the tiles
    private func getTileNumbers() -> [[Int]] {
        var board: [[Int]] = [[0,0,0],[0,0,0],[0,0,0]]
        for i in self.tiles.indices {
            board[Int(self.tiles[i].1)+1][Int(self.tiles[i].0)+1] = self.tiles[i].2
        }
        return board
    }
    
    // Set all tile to a place based on the game logic's board
    private func setTilePositions(by board: [[Int]]) {
        for i in board.indices {
            for j in board[i].indices {
                for k in self.tiles.indices {
                    if board[i][j] == self.tiles[k].2 {
                        self.tiles[k].0 = CGFloat(i-1)
                        self.tiles[k].1 = CGFloat(j-1)
                    }
                }
            }
        }
    }
    
    // Crop the original image to have a 1:1 board
    private func cropBoard() -> UIImage {
        let cgImage = self.originalImage.cgImage!
        let boardSize = cgImage.width > cgImage.height ? cgImage.height : cgImage.width
        let x = (cgImage.width == boardSize) ? 0 : (cgImage.width - boardSize)/2
        let y = (cgImage.height == boardSize) ? 0 : (cgImage.height - boardSize)/2
        let cropRect = CGRect(x: x, y: y, width: boardSize, height: boardSize)
        let croppedCGImage = cgImage.cropping(to: cropRect)!
        let croppedImage = UIImage(cgImage: croppedCGImage)
        return croppedImage
    }
    
    // Crop all tile from original image
    private func getCroppedTiles() -> [UIImage] {
        var tilesImg: [UIImage] = []
        for i in 0..<9 {
            tilesImg.append(self.cropTile(num: i))
        }
        return tilesImg
    }
    
    // Crop a tile
    private func cropTile(num: Int) -> UIImage {
        let cgImage = self.cropBoard().cgImage!
        let tileSize = CGSize(width: cgImage.width / 3, height: cgImage.height / 3)
        let x = tileSize.width * CGFloat(num%3)
        let y = tileSize.height * CGFloat(num/3%3)
        let cropRect = CGRect(x: x, y: y, width: tileSize.width, height: tileSize.height)
        let croppedCGImage = cgImage.cropping(to: cropRect)!
        let croppedImage = UIImage(cgImage: croppedCGImage)
        return croppedImage
    }
    
    // Return the smaler size for crop
    private func getMinSize(size: CGSize) -> CGFloat {
        return size.height > size.width ? size.width : size.height
    }
    
    // Setup sensor for tilt
    private func startUpdateTilt() {
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.accelerometerUpdateInterval = 0.01
            self.motionManager.startAccelerometerUpdates(to: .main) { (data, err) in
                guard let acc = data?.acceleration else {return}
                self.updateAcc(acc)
            }
        }
    }
    
    // Update for tilt control and board movement
    private func updateAcc(_ acc: CMAcceleration) {
        self.accX = -acc.y*15
        self.accY = -acc.x*15
    }
    
    // === TILE MOVMENT ============================================================
    
    // Move tile when tap them (Find the blank place to make move)
    private func moveTileTap(targetIndex: Int) {
        let targetTile = self.tiles[targetIndex]
        let blankTile = self.tiles[self.blankIndex]
        var dir: TileDirection
        switch targetTile.0 {
        case blankTile.0 where targetTile.1 == blankTile.1 + 1:
            dir = TileDirection.UP
        case blankTile.0 where targetTile.1 == blankTile.1 - 1:
            dir = TileDirection.DOWN
        case blankTile.0 + 1 where targetTile.1 == blankTile.1:
            dir = TileDirection.LEFT
        case blankTile.0 - 1 where targetTile.1 == blankTile.1:
            dir = TileDirection.RIGHT
        default:
            dir = TileDirection.INVALID
        }
        if dir == TileDirection.INVALID {
            self.shakeTile(at: targetIndex)
        } else {
            // Only the second move will update the board
            self.moveTile(at: targetIndex, direction: dir)
            self.moveTile(at: self.blankIndex, direction: dir.oposite)
        }
    }
    
    // Check device orientation and make a move
    private func moveTileTilt() {
        var dir: TileDirection
        switch (self.accX, self.accY) {
        case (let x, _) where x < -5:
            dir = TileDirection.UP
        case (let x, _) where x > 5:
            dir = TileDirection.DOWN
        case (_, let y) where y > 5:
            dir = TileDirection.LEFT
        case (_, let y) where y < -5:
            dir = TileDirection.RIGHT
        default:
            dir = TileDirection.INVALID
        }
        if let targetIndex = self.getTileIndexTilt(dir: dir) {
            self.moveTile(at: targetIndex, direction: dir, isTilt: true)
            self.moveTile(at: self.blankIndex, direction: dir.oposite, isTilt: true)
        }
    }
    
    // Get the tile which can move based on the given direction (in case of tilt)
    private func getTileIndexTilt(dir: TileDirection) -> Int? {
        for tileIndex in tiles.indices {
            let actTile = self.tiles[tileIndex]
            let blankTile = self.tiles[self.blankIndex]
            switch dir {
            case TileDirection.UP:
                if actTile.0 == blankTile.0 && actTile.1 == blankTile.1 + 1 {
                    return tileIndex
                }
            case TileDirection.DOWN:
                if actTile.0 == blankTile.0 && actTile.1 == blankTile.1 - 1 {
                    return tileIndex
                }
            case TileDirection.LEFT:
                if actTile.0 == blankTile.0 + 1 && actTile.1 == blankTile.1 {
                    return tileIndex
                }
            case TileDirection.RIGHT:
                if actTile.0 == blankTile.0 - 1 && actTile.1 == blankTile.1 {
                    return tileIndex
                }
            case TileDirection.INVALID:
                return nil
            }
        }
        return nil
    }
    
    // Move a given tile to a given direction
    // -> Update board and increase step
    // -> Check is it goal state or not
    private func moveTile(at index: Int, direction: TileDirection, isTilt: Bool = false) {
        withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.7)) {
            switch direction {
            case TileDirection.UP:
                tiles[index].1 -= 1
            case TileDirection.DOWN:
                tiles[index].1 += 1
            case TileDirection.LEFT:
                tiles[index].0 -= 1
            case TileDirection.RIGHT:
                tiles[index].0 += 1
            case TileDirection.INVALID:
                return
            }
        }
        self.gameLogic.updateBoard(newBoard: self.getTileNumbers(), isTilt: isTilt)
        if self.gameLogic.isBoardInGoalState() {
            withAnimation(Animation.easeInOut(duration: 1)) {
                self.gameState = GameState.OVER
            }
            self.steps = self.gameLogic.getStepCount()
        }
    }
    
    // Shake tile if it can't move
    private func shakeTile(at index: Int) {
        let tmp = self.tiles[index].0
        withAnimation(Animation.spring(response: 0.1, dampingFraction: 0.1)) {
            self.tiles[index].0 += 0.1
        }
        self.tiles[index].0 = tmp
    }
    
}

// =================================================================================

// Preview
struct Board_Previews: PreviewProvider {
    static var previews: some View {
        @State var state: GameState = GameState.PLAY
        @State var steps: Int = 0
        Board(originalImage: UIImage(named: "board")!, gameState: $state, steps: $steps)
    }
}
