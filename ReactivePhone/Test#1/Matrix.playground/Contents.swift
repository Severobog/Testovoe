import Foundation

struct Coordinate: Hashable {
    let row: Int
    let col: Int
}

func updateMatrix(_ mat: [[Int]]) -> [[Int]] {
    let rows = mat.count
    let cols = mat[0].count
    var result = Array(repeating: Array(repeating: Int.max, count: cols), count: rows)
    var queue = [Coordinate]()
    
    for row in 0..<rows {
        for col in 0..<cols {
            if mat[row][col] == 1 {
                result[row][col] = 0
                queue.append(Coordinate(row: row, col: col))
            }
        }
    }
    
    let directions: [(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    
    // BFS
    while !queue.isEmpty {
        let coord = queue.removeFirst()
        
        for direction in directions {
            let newRow = coord.row + direction.0
            let newCol = coord.col + direction.1
            
            if newRow >= 0, newRow < rows, newCol >= 0, newCol < cols {
                if result[newRow][newCol] > result[coord.row][coord.col] + 1 {
                    result[newRow][newCol] = result[coord.row][coord.col] + 1
                    queue.append(Coordinate(row: newRow, col: newCol))
                }
            }
        }
    }
    
    return result
}

let inputMatrix = [
    [1, 0, 1],
    [0, 1, 0],
    [0, 0, 0]
]

let outputMatrix = updateMatrix(inputMatrix)
for row in outputMatrix {
    print(row)
}
