//
//  PieceType.swift
//  TangramPrototype
//
//  Created by AI Assistant on 8/3/25.
//  Purpose: Defines tangram piece types with geometric properties
//

import Foundation

/// Enumeration of all tangram piece types with their geometric definitions
/// Each piece type defines its base vertices for use in the Piece model
enum PieceType: String, CaseIterable, Codable {
    case largeTriangle1 = "large_triangle_1"
    case largeTriangle2 = "large_triangle_2"
    case mediumTriangle = "medium_triangle"
    case smallTriangle1 = "small_triangle_1"
    case smallTriangle2 = "small_triangle_2"
    case square = "square"
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
    
    /// Base vertices for each piece type before any transformations
    /// Coordinates are in base units (will be scaled by Constants.Geometry.baseUnit)
    /// Each piece is defined with (0,0) at a logical anchor point
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
}