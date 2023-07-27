
import XCTest

final class PuzzleTests: XCTestCase {

    // sut: SystemUnderTesting
    // -> All test assign to this object
    private var sut: Puzzle!
    
    override func setUpWithError() throws {
        self.sut = Puzzle()
    }
    
    override func tearDownWithError() throws {
        self.sut = nil
    }
    
    // The size of the board is 3
    func test_boardSizeN_returns3() {
        let actual = sut.getBoard().count
        let expected = 3
        XCTAssertEqual(actual, expected)
    }
    
    // The row and column num are equal
    func test_rowSize_returnsColumnNum() {
        let actual = sut.getBoard().count
        let expected = sut.getBoard()[0].count
        XCTAssertEqual(actual, expected)
    }
    
    // All number is different
    func test_setElementNum_returnsBoardElementNum() {
        let flatBoard = sut.getBoard().flatMap { $0 }
        let actual = Set(flatBoard).count
        let expected = flatBoard.count
        XCTAssertEqual(actual, expected)
    }
    
    // The minimum number is 1
    func test_minimumElement_returns1() {
        let flatBoard = sut.getBoard().flatMap { $0 }
        let actual = flatBoard.min()
        let expected = 1
        XCTAssertEqual(actual, expected)
    }
    
    // The maximum number is 9
    func test_maximumElement_returns9() {
        let flatBoard = sut.getBoard().flatMap { $0 }
        let actual = flatBoard.max()
        let expected = 9
        XCTAssertEqual(actual, expected)
    }
    
    // Blank number between 1 and 9
    func test_blank_returnsBtw1and9() {
        let actual = sut.getBlankNum()
        let expected = ( 9 >= actual && 1 <= actual )
        XCTAssertTrue(expected)
    }
    
    // Step number 0 at the start
    func test_stepNum_returns0() {
        let actual = sut.getStepCount()
        let expected = 0
        XCTAssertEqual(actual, expected)
    }
    
    // Never get a board in goal state
    func test_bordIsInGoalState_returnsFalse() {
        var inGoalStateSometime = false
        for _ in 0..<100 {
            sut = nil
            sut = Puzzle()
            if sut.isBoardInGoalState() == true {
                inGoalStateSometime = true
            }
        }
        let expected = inGoalStateSometime
        XCTAssertFalse(expected)
    }
    
    // Never get a impossible game
    func test_bordIsSolvable_returnsTrue() {
        var alwaysSolvable = true
        for _ in 0..<100 {
            sut = nil
            sut = Puzzle()
            if sut.isSolvable() == false {
                alwaysSolvable = false
            }
        }
        let expected = alwaysSolvable
        XCTAssertTrue(expected)
    }
    
    // Wrong dimensions
    func test_wrongDimensionMatrix_throwError() {
        let newBoard = [[1],[2],[3],[4],[5],[6],[7],[8],[9]]
        let prev = sut.getBoard()
        sut.updateBoard(newBoard: newBoard)
        let actual = sut.getBoard()
        let expected = prev
        XCTAssertEqual(actual, expected)
    }
    
    // Not unique numbers
    func test_matrixWithNotUniqueElements_throwError() {
        let newBoard = [[1, 2, 3],[1, 2, 3],[1, 2, 3]]
        let prev = sut.getBoard()
        sut.updateBoard(newBoard: newBoard)
        let actual = sut.getBoard()
        let expected = prev
        XCTAssertEqual(actual, expected)
    }
    
    // Incorrect range
    func test_wrongRangeMatrix_throwError() {
        let newBoard = [[0, 1, 2],[3, 4, 5],[6, 7, 8]]
        let prev = sut.getBoard()
        sut.updateBoard(newBoard: newBoard)
        let actual = sut.getBoard()
        let expected = prev
        XCTAssertEqual(actual, expected)
    }
    
    // Update
    func test_newBoard_updateBoard() {
        let newBoard = [[9, 1, 2],[3, 4, 5],[6, 7, 8]]
        sut.updateBoard(newBoard: newBoard)
        let actual = sut.getBoard()
        let expected = newBoard
        XCTAssertEqual(actual, expected)
    }
    
    // Step increase
    func test_3correctStepAnd2IncorrectStep_returns3() {
        var newBoard = [[9, 1, 2],[3, 4, 5],[6, 7, 8]]
        sut.updateBoard(newBoard: newBoard)
        newBoard = [[9, 1, 2],[6, 7, 8],[3, 4, 5]]
        sut.updateBoard(newBoard: newBoard)
        newBoard = [[9, 1, 2],[3, 0, 5],[6, 7, 8]]
        sut.updateBoard(newBoard: newBoard)
        newBoard = [[9, 1, 2],[3, 4, 5, 6, 7, 8]]
        sut.updateBoard(newBoard: newBoard)
        newBoard = [[9, 1, 2],[3, 4, 5],[6, 7, 8]]
        sut.updateBoard(newBoard: newBoard)
        let actual = sut.getStepCount()
        let expected = 3
        XCTAssertEqual(actual, expected)
    }
    
    // Update with the same board (thats a step too...)
    func test_sameBoard_updateBoard() {
        let newBoard = sut.getBoard()
        sut.updateBoard(newBoard: newBoard)
        let actual = sut.getStepCount()
        let expected = 1
        XCTAssertEqual(actual, expected)
    }
    
    // Goal state
    func test_bordIsInGoalState_returnsTrue() {
        sut.updateBoard(newBoard: [[1, 2, 3],[4, 5, 6],[7, 8, 9]])
        let expected = sut.isBoardInGoalState()
        XCTAssertTrue(expected)
    }

}
