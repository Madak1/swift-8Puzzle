
import Foundation

// The logic of the game
//  - Store the board
//  - Select blank tile
//  - Count the steps
//  - Randomize the board
//  - Check when the user win

enum PuzzleError: Error {
    case differentDimensions
    case notUniqueNumbers
    case incorrectRange
}

class Puzzle {
    
    private var board = [[1,2,3],[4,5,6],[7,8,9]]
    
    private let boardSizeN: Int
    private let blankNum: Int
    private var stepCount: Int
    
    // Set the board's size
    // Select a blank tile
    // Set the step counter to zero
    // Randomize the board
    init() {
        self.boardSizeN = self.board.count
        self.blankNum = self.board[Int.random(in: 0..<self.boardSizeN)][Int.random(in: 0..<self.boardSizeN)]
        self.stepCount = 0
        self.shuffleBoard()
    }
    
    // Board getter
    func getBoard() -> [[Int]] {
        return self.board
    }
    
    // Blank tile getter (get the NUMBER of the blank tile)
    func getBlankNum() -> Int{
        return self.blankNum
    }
    
    // Step number getter
    func getStepCount() -> Int{
        return self.stepCount
    }
    
    // Change the board state
    // -> In our case when make a move the first switch will not update just the second
    // (target -> blank && blank -> target) -> StepNum and update will correct
    // -> The step counter only increase when use tap (tilt control doesn't increase the step num)
    func updateBoard(newBoard: [[Int]], isTilt: Bool = false){
        do {
            try matrixCorrect(array: newBoard)
            self.board = newBoard
            self.stepCount +=  isTilt ? 0 : 1
            print("Board updated - Steps \( isTilt ? "remain at" : "increase to" ) \(self.stepCount)")
        } catch {
            print("Board not updated")
        }
    }
    
    // Check matrix dimension compare to prev
    private func haveSameDimensions(array: [[Int]]) -> Bool {
        let rows1 = array.count
        let columns1 = array.first?.count ?? 0
        let rows2 = self.board.count
        let columns2 = self.board.first?.count ?? 0
        return rows1 == rows2 && columns1 == columns2
    }
    
    // Check the matrix is correct
    private func matrixCorrect(array: [[Int]]) throws {
        let flatArray = array.flatMap { $0 }
        if !self.haveSameDimensions(array: array) {
            throw PuzzleError.differentDimensions
        }
        if Set(flatArray).count != 9 {
            throw PuzzleError.notUniqueNumbers
        }
        if flatArray.min() != 1 || flatArray.max() != 9 {
            throw PuzzleError.incorrectRange
        }
    }
    
    // Check the bord is in goal state or not
    func isBoardInGoalState() -> Bool {
        for i in 0 ..< self.boardSizeN {
            for j in 0 ..< self.boardSizeN {
                if i*self.boardSizeN+j != self.board[i][j]-1 {
                    return false
                }
            }
        }
        return true
    }
    
    // Randomize the board until is it solvable (but not complete)
    private func shuffleBoard() {
        repeat {
            for _ in 0 ... 99 {
                let r1 = Int.random(in: 0 ... 2)
                let r2 = Int.random(in: 0 ... 2)
                let c1 = Int.random(in: 0 ... 2)
                let c2 = Int.random(in: 0 ... 2)
                let tmp = self.board[r1][c1]
                self.board[r1][c1] = self.board[r2][c2]
                self.board[r2][c2] = tmp
            }
        } while (!self.isSolvable() || self.isBoardInGoalState())
    }
    
    // Check the board is solvable
    func isSolvable() -> Bool {
        var sumInversion = 0
        var tmpList: [Int] = []
        for row in 0 ..< self.boardSizeN {
            for col in 0 ..< self.boardSizeN {
                let x = self.board[col][row]
                if (x != self.blankNum) {
                    for y in tmpList {
                        if y > x {
                            sumInversion += 1
                        }
                    }
                    tmpList.append(x)
                }
            }
        }
        return sumInversion % 2 == 0
    }
    
}
