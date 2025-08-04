//
//  PieceType.swift
//  TangramPrototype
//
//  Created by AI Assistant on 8/3/25.
//  Purpose: Defines tangram piece types with geometric properties and validation
//

import Foundation

/// Enumeration of all seven traditional tangram piece types with their geometric definitions
/// 
/// A traditional tangram consists of exactly 7 pieces that can be arranged to form a square:
/// - 2 large right triangles (legs = 2 units)
/// - 1 medium right triangle (legs = √2 units) 
/// - 2 small right triangles (legs = 1 unit)
/// - 1 square (diagonal = √2 units)
/// - 1 parallelogram (long edges = √2 units, short edges = 1 unit)
///
/// All measurements are in terms of Constants.Geometry.baseUnit for consistent scaling.
/// Each piece defines its baseVertices with (0,0) as the logical anchor point for transformations.
enum PieceType: String, CaseIterable, Codable {
    /// Large right triangle #1 - legs of 2 base units, hypotenuse of 2√2 units
    case largeTriangle1 = "large_triangle_1"
    
    /// Large right triangle #2 - identical to largeTriangle1, allows independent positioning
    case largeTriangle2 = "large_triangle_2"
    
    /// Medium right triangle - legs of √2 base units, hypotenuse of 2 units
    case mediumTriangle = "medium_triangle"
    
    /// Small right triangle #1 - legs of 1 base unit, hypotenuse of √2 units
    case smallTriangle1 = "small_triangle_1"
    
    /// Small right triangle #2 - identical to smallTriangle1, allows independent positioning  
    case smallTriangle2 = "small_triangle_2"
    
    /// Square - sides of 1 base unit, displayed as diamond (rotated 45°)
    case square = "square"
    
    /// Parallelogram - long edges of √2 units, short edges of 1 unit, 45° angles
    case parallelogram = "parallelogram"
    
    /// Display name for UI purposes
    var displayName: String {
        switch self {
        case .largeTriangle1: return "Large Triangle 1"
        case .largeTriangle2: return "Large Triangle 2"
        case .mediumTriangle: return "Medium Triangle"
        case .smallTriangle1: return "Small Triangle 1"
        case .smallTriangle2: return "Small Triangle 2"
        case .square: return "Square"
        case .parallelogram: return "Parallelogram"
        }
    }
    
    /// Base vertices defining the geometric shape of each piece type
    /// 
    /// All coordinates are calculated using Constants.Geometry.baseUnit for consistent scaling.
    /// Each piece is positioned with (0,0) at a logical anchor point that facilitates rotation and positioning.
    /// 
    /// Vertex ordering follows counterclockwise convention starting from the anchor point.
    /// This ensures consistent winding for polygon rendering and geometric calculations.
    ///
    /// - Returns: Array of Vertex objects defining the piece's base shape
    var baseVertices: [Vertex] {
        let unit = Double(Constants.Geometry.baseUnit)
        
        switch self {
        case .largeTriangle1, .largeTriangle2:
            // Right triangle with legs of length 2*baseUnit
            // Right angle at origin (0,0) - good anchor candidate
            return [
                Vertex(x: 0.0, y: 0.0),           // Right angle corner (anchor)
                Vertex(x: 2.0 * unit, y: 0.0),   // Bottom right
                Vertex(x: 0.0, y: 2.0 * unit)    // Top left
            ]
            
        case .mediumTriangle:
            // Right triangle with legs of length √2*baseUnit  
            // Right angle at origin (0,0)
            let mediumLeg = unit * sqrt(2.0)
            return [
                Vertex(x: 0.0, y: 0.0),          // Right angle corner (anchor)
                Vertex(x: mediumLeg, y: 0.0),    // Bottom right
                Vertex(x: 0.0, y: mediumLeg)     // Top left
            ]
            
        case .smallTriangle1, .smallTriangle2:
            // Right triangle with legs of length baseUnit
            // Right angle at origin (0,0)
            return [
                Vertex(x: 0.0, y: 0.0),          // Right angle corner (anchor)
                Vertex(x: unit, y: 0.0),         // Bottom right
                Vertex(x: 0.0, y: unit)          // Top left
            ]
            
        case .square:
            // Square with 1×1 unit sides, displayed as diamond (rotated 45°)
            // Diagonal = √2 units, so half-diagonal = √2/2 units
            let halfDiagonal = unit * sqrt(2.0) / 2.0
            return [
                Vertex(x: 0.0, y: -halfDiagonal),      // Bottom
                Vertex(x: halfDiagonal, y: 0.0),       // Right
                Vertex(x: 0.0, y: halfDiagonal),       // Top
                Vertex(x: -halfDiagonal, y: 0.0)       // Left
            ]
            
        case .parallelogram:
            // Parallelogram: longer edges = √2 units (small triangle hypotenuse), shorter edges = 1 unit (square side)
            // Bottom-left corner at origin (0,0)
            let longerEdge = unit * sqrt(2.0)  // Base and top edges: √2 units
            let shorterEdge = unit             // Slant edges: 1 unit (same as square side)
            
            // For slant edges of length 1 with 45° angle: x = y = 1/√2
            let slantX = shorterEdge / sqrt(2.0)  // Horizontal component of slant
            let slantY = shorterEdge / sqrt(2.0)  // Vertical component of slant (height)
            
            return [
                Vertex(x: 0.0, y: 0.0),                           // Bottom left (anchor)
                Vertex(x: longerEdge, y: 0.0),                    // Bottom right
                Vertex(x: longerEdge + slantX, y: slantY),        // Top right
                Vertex(x: slantX, y: slantY)                      // Top left
            ]
        }
    }
    
    // MARK: - Geometric Properties & Validation (Subtask 6.4)
    
    /// Number of vertices for this piece type (triangles = 3, square = 4, parallelogram = 4)
    var vertexCount: Int {
        return baseVertices.count
    }
    
    /// Calculated area of the piece in square base units
    /// Uses the shoelace formula for polygon area calculation
    var area: Double {
        let vertices = baseVertices
        guard vertices.count >= 3 else { return 0.0 }
        
        var area: Double = 0.0
        let n = vertices.count
        
        for i in 0..<n {
            let j = (i + 1) % n
            area += vertices[i].x * vertices[j].y
            area -= vertices[j].x * vertices[i].y
        }
        
        return abs(area) / 2.0
    }
    
    /// Whether this piece type is a triangle (3 vertices)
    var isTriangle: Bool {
        return vertexCount == 3
    }
    
    /// Whether this piece type is a quadrilateral (4 vertices)
    var isQuadrilateral: Bool {
        return vertexCount == 4
    }
    
    /// Validates that the piece geometry is correctly defined
    /// Checks for minimum vertex count, non-zero area, and reasonable dimensions
    /// - Returns: True if geometry is valid, false otherwise
    func validateGeometry() -> Bool {
        let vertices = baseVertices
        
        // Must have at least 3 vertices
        guard vertices.count >= 3 else {
            debugLog("Invalid geometry for \(rawValue): insufficient vertices (\(vertices.count))", category: .geometry)
            return false
        }
        
        // Must have non-zero area
        let calculatedArea = area
        guard calculatedArea > 0.001 else {
            debugLog("Invalid geometry for \(rawValue): zero or negative area (\(calculatedArea))", category: .geometry)
            return false
        }
        
        // Area should be reasonable (between 0.1 and 10 square base units)
        let unit = Double(Constants.Geometry.baseUnit)
        let maxReasonableArea = 10.0 * unit * unit
        let minReasonableArea = 0.1 * unit * unit
        
        guard calculatedArea >= minReasonableArea && calculatedArea <= maxReasonableArea else {
            debugLog("Invalid geometry for \(rawValue): unreasonable area (\(calculatedArea))", category: .geometry)
            return false
        }
        
        debugLog("Validated geometry for \(rawValue): \(vertices.count) vertices, area \(String(format: "%.2f", calculatedArea))", category: .geometry)
        return true
    }
    
    /// Compares the area of this piece to another piece type
    /// - Parameter other: The piece type to compare against
    /// - Returns: Comparison result (less, equal, greater)
    func compareArea(to other: PieceType) -> ComparisonResult {
        let thisArea = self.area
        let otherArea = other.area
        let tolerance = 0.001
        
        if abs(thisArea - otherArea) < tolerance {
            return .orderedSame
        } else if thisArea < otherArea {
            return .orderedAscending
        } else {
            return .orderedDescending
        }
    }
    
    /// Returns all piece types grouped by their geometric properties
    /// - Returns: Dictionary with geometry type as key and piece types as values
    static func groupedByGeometry() -> [String: [PieceType]] {
        var groups: [String: [PieceType]] = [:]
        
        for pieceType in PieceType.allCases {
            let key: String
            if pieceType.isTriangle {
                key = "Triangles"
            } else if pieceType.isQuadrilateral {
                key = "Quadrilaterals"
            } else {
                key = "Other"
            }
            
            if groups[key] == nil {
                groups[key] = []
            }
            groups[key]?.append(pieceType)
        }
        
        return groups
    }
    
    /// Validates that all tangram pieces have correct total area
    /// A complete tangram set should have pieces that sum to 4 square base units
    /// - Returns: True if total area is correct for a tangram set
    static func validateTangramSet() -> Bool {
        let totalArea = PieceType.allCases.reduce(0.0) { $0 + $1.area }
        let unit = Double(Constants.Geometry.baseUnit)
        let expectedArea = 4.0 * unit * unit  // Standard tangram total area
        let tolerance = 0.01 * unit * unit
        
        let isValid = abs(totalArea - expectedArea) < tolerance
        
        debugLog("Tangram set validation: total area \(String(format: "%.2f", totalArea)), expected \(String(format: "%.2f", expectedArea)), valid: \(isValid)", category: .geometry)
        
        return isValid
    }
}