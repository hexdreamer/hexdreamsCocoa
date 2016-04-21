// hexdreamsCocoa
// HXMatrix.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

// Multiplying Matrices
// http://www.mathsisfun.com/algebra/matrix-multiplying.html
// BLAS matrix multiplying
// http://stackoverflow.com/questions/15830913/lapack-matrix-multiplication-with-c
// LAPACK Reference
// http://www.netlib.org/lapack/explore-html/d7/d2b/dgemm_8f.html#aeda3cbd99c8fb834a60a6412878226e1
// Solving systems of equations using matrices
// http://www.mathsisfun.com/algebra/systems-linear-equations-matrices.html
// Accelerate matrix inversion code
// http://stackoverflow.com/questions/3519959/computing-the-inverse-of-a-matrix-using-lapack-in-c

import Accelerate

public class HXMatrix {
    
    public let rows    :UInt
    public let columns :UInt
           var grid    :[Double]
    
    public init(rows: UInt, columns: UInt, values :[Double]) {
        self.rows = rows
        self.columns = columns
        self.grid = values
    }
    
    public convenience init(rows: UInt, columns: UInt) {
        self.init(rows: rows, columns: columns, values: Array(count: Int(rows * columns), repeatedValue: 0.0))
    }
    
    public subscript(row: UInt, column: UInt) -> Double {
        get {
            assert(_indexIsValidForRow(row, column: column), "Index out of range")
            return grid[Int((row * columns) + column)]
        }
        set {
            assert(_indexIsValidForRow(row, column: column), "Index out of range")
            grid[Int((row * columns) + column)] = newValue
        }
    }
    
    public func inverse() -> HXMatrix {
        assert(self.rows == self.columns, "Can only invert a square matrix")
        return HXMatrix(rows: self.rows, columns: self.columns, values: self._invert(self.grid, rows: self.rows))
    }
    
    public func multiply(right :HXMatrix) -> HXMatrix {
        assert(self.columns == right.rows, "Matrix dimensions do not match for multiplication")
        let result = self._multiplyMatrices(self.grid, rowsA: self.rows, colsA: self.columns, matrixB: right.grid, rowsB: right.rows, colsB: right.columns)
        return HXMatrix(rows: self.rows, columns: right.columns, values: result)
    }
    
    //MARK: Private Methods
    
    private func _indexIsValidForRow(row: UInt, column: UInt) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }

    private func _invert(matrix :[Double], rows :UInt) -> [Double] {
        var M    :__CLPK_integer = __CLPK_integer(rows)
        var N    :__CLPK_integer = __CLPK_integer(rows)
        var A    :[__CLPK_doublereal] = matrix
        var LDA  :__CLPK_integer = __CLPK_integer(rows)
        var IPIV :[__CLPK_integer] = [__CLPK_integer](count: Int(rows), repeatedValue: 0)
        var INFO :__CLPK_integer = 0
        var LWORK :__CLPK_integer = N * N
        var WORK :[__CLPK_doublereal] = [__CLPK_doublereal](count: Int(LWORK), repeatedValue: 0.0)
        
        dgetrf_(&M, &N, &A, &LDA, &IPIV, &INFO)
        dgetri_(&N, &A, &LDA, &IPIV, &WORK, &LWORK, &INFO)
        return A
    }
    
    private func _multiplyMatrices(matrixA :[Double], rowsA :UInt, colsA :UInt, matrixB :[Double], rowsB :UInt, colsB :UInt) -> [Double] {
        let Order :CBLAS_ORDER = CblasRowMajor
        let TransA :CBLAS_TRANSPOSE = CblasNoTrans
        let TransB :CBLAS_TRANSPOSE = CblasNoTrans
        let M :Int32 = Int32(rowsA)
        let N :Int32 = Int32(colsB)
        let K :Int32 = Int32(colsA)
        let alpha :Double = 1.0
        var A :[Double] = matrixA
        let lda :Int32 = Int32(colsA)
        var B :[Double] = matrixB
        let ldb :Int32 = Int32(colsB)
        let beta :Double = 1.0
        var C :[Double] = [Double](count: Int(M * N), repeatedValue: 0.0)
        let ldc :Int32 = N
        
        cblas_dgemm(Order, TransA, TransB, M, N, K, alpha, &A, lda, &B, ldb, beta, &C, ldc)
        return C
    }

}

infix operator ⋅ { associativity left precedence 100 }

public func ⋅ (left: HXMatrix, right: HXMatrix) -> HXMatrix {
    return left.multiply(right)
}
