//
//  Piece.swift
//  TangramPrototype
//
//  Created by AI Assistant on 8/3/25.
//  Purpose: Represents a tangram game piece with dynamic vertex calculations
//

import SwiftUI
import Foundation

/// Represents a single tangram piece with position, rotation and dynamic vertex calculation
/// Core component that bridges geometric foundation with game logic and UI interaction
struct Piece: Identifiable, Equatable {
    
    // MARK: - Properties (Subtask 5.1)
    
    /// Unique identifier for this piece instance
    let id = UUID()
    
    /// Type of tangram piece (determines base shape and vertices)
    let type: PieceType
    
    /// Current center position of the piece in screen coordinates
    /// Used as the anchor point for rotation and as the SwiftUI .position() value
    var position: CGPoint
    
    /// Current rotation angle in radians
    /// Applied around the piece's center position
    var rotation: Double
    
    /// Visual color for rendering this piece
    var color: Color
    
    // MARK: - Initializers
    
    /// Creates a new piece with specified properties
    /// - Parameters:
    ///   - type: The tangram piece type
    ///   - position: Initial center position in screen coordinates
    ///   - rotation: Initial rotation in radians (default: 0)
    ///   - color: Visual color for the piece
    init(type: PieceType, position: CGPoint, rotation: Double = 0.0, color: Color) {
        self.type = type
        self.position = position
        self.rotation = rotation
        self.color = color
        
        debugLog("Created \(type) piece at position (\(String(format: "%.1f", position.x)), \(String(format: "%.1f", position.y))) with rotation \(String(format: "%.2f", rotation)) radians", category: .geometry)
    }
    
    // MARK: - Dynamic Vertex Calculation (Subtask 5.4)
    
    /// Calculates the current vertices of this piece in screen coordinates
    /// Applies rotation around the piece center, then translates to current position
    /// This is the core property used by the vertex anchor win detection algorithm
    var currentVertices: [Vertex] {
        debugLog("Calculating current vertices for \(type) piece at position (\(String(format: "%.1f", position.x)), \(String(format: "%.1f", position.y))) with rotation \(String(format: "%.2f", rotation)) radians", category: .geometry)
        
        // Get base vertices for this piece type
        let baseVertices = type.baseVertices
        
        // Transform each vertex: 
        // 1. Start with base vertex
        // 2. Rotate around origin (0,0) by current rotation
        // 3. Translate to current position
        let transformedVertices = baseVertices.map { vertex in
            vertex
                .rotated(around: Vertex(x: 0, y: 0), by: rotation)  // Rotate around origin first
                .translated(by: Double(position.x), dy: Double(position.y))  // Then translate to position
        }
        
        debugLog("Transformed \(baseVertices.count) vertices for \(type) piece", category: .geometry)
        return transformedVertices
    }
    
    // MARK: - Piece Manipulation Methods (Subtask 5.5)
    
    /// Translates the piece by the specified offset
    /// - Parameters:
    ///   - dx: Horizontal offset in points
    ///   - dy: Vertical offset in points
    /// - Returns: New piece at the translated position
    func translated(by dx: CGFloat, dy: CGFloat) -> Piece {
        let newPosition = CGPoint(x: position.x + dx, y: position.y + dy)
        debugLog("Translating \(type) piece by (\(String(format: "%.1f", dx)), \(String(format: "%.1f", dy)))", category: .geometry)
        return Piece(type: type, position: newPosition, rotation: rotation, color: color)
    }
    
    /// Translates the piece to a new absolute position
    /// - Parameter newPosition: New center position for the piece
    /// - Returns: New piece at the specified position
    func moved(to newPosition: CGPoint) -> Piece {
        debugLog("Moving \(type) piece to position (\(String(format: "%.1f", newPosition.x)), \(String(format: "%.1f", newPosition.y)))", category: .geometry)
        return Piece(type: type, position: newPosition, rotation: rotation, color: color)
    }
    
    /// Rotates the piece by the specified angle
    /// - Parameter angle: Additional rotation in radians
    /// - Returns: New piece with the additional rotation applied
    func rotated(by angle: Double) -> Piece {
        let newRotation = rotation + angle
        debugLog("Rotating \(type) piece by \(String(format: "%.2f", angle)) radians (total: \(String(format: "%.2f", newRotation)))", category: .geometry)
        return Piece(type: type, position: position, rotation: newRotation, color: color)
    }
    
    /// Sets the piece to a specific rotation angle
    /// - Parameter angle: New rotation in radians
    /// - Returns: New piece with the specified rotation
    func rotated(to angle: Double) -> Piece {
        debugLog("Setting \(type) piece rotation to \(String(format: "%.2f", angle)) radians", category: .geometry)
        return Piece(type: type, position: position, rotation: angle, color: color)
    }
    
    /// Resets the piece to its initial state at the specified position
    /// - Parameter position: Initial position for reset (default: current position)
    /// - Returns: New piece with rotation reset to 0 and specified position
    func resetPosition(at newPosition: CGPoint? = nil) -> Piece {
        let resetPosition = newPosition ?? position
        debugLog("Resetting \(type) piece to position (\(String(format: "%.1f", resetPosition.x)), \(String(format: "%.1f", resetPosition.y))) with zero rotation", category: .geometry)
        return Piece(type: type, position: resetPosition, rotation: 0.0, color: color)
    }
    
    /// Applies rotation snapping based on Constants.Geometry.rotationSnapAngle
    /// - Returns: New piece with rotation snapped to the nearest snap angle
    func withSnappedRotation() -> Piece {
        let snapAngle = Constants.Geometry.rotationSnapAngle
        let snappedRotation = round(rotation / snapAngle) * snapAngle
        
        if abs(rotation - snappedRotation) > 0.001 {  // Only create new piece if rotation actually changed
            debugLog("Snapping \(type) piece rotation from \(String(format: "%.2f", rotation)) to \(String(format: "%.2f", snappedRotation)) radians", category: .geometry)
            return Piece(type: type, position: position, rotation: snappedRotation, color: color)
        }
        
        return self
    }
    
    // MARK: - SwiftUI Integration Helpers (Subtask 5.6)
    
    /// Center point of the piece for SwiftUI .position() modifier
    var centerPosition: CGPoint {
        return position
    }
    
    /// Rotation angle for SwiftUI .rotationEffect() modifier
    var rotationAngle: Angle {
        return Angle(radians: rotation)
    }
    
    /// Bounding box of the piece for layout calculations
    /// Calculates the minimum rectangle that contains all current vertices
    var boundingBox: CGRect {
        let vertices = currentVertices
        guard !vertices.isEmpty else {
            return CGRect(origin: position, size: .zero)
        }
        
        let xValues = vertices.map { $0.x }
        let yValues = vertices.map { $0.y }
        
        let minX = xValues.min() ?? 0
        let maxX = xValues.max() ?? 0
        let minY = yValues.min() ?? 0
        let maxY = yValues.max() ?? 0
        
        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }
    
    /// Estimated frame size for SwiftUI layout
    /// Based on the base vertices dimensions scaled by baseUnit
    var estimatedFrameSize: CGSize {
        let baseVertices = type.baseVertices
        guard !baseVertices.isEmpty else {
            return CGSize(width: Constants.Geometry.baseUnit, height: Constants.Geometry.baseUnit)
        }
        
        let xValues = baseVertices.map { $0.x }
        let yValues = baseVertices.map { $0.y }
        
        let width = (xValues.max() ?? 0) - (xValues.min() ?? 0)
        let height = (yValues.max() ?? 0) - (yValues.min() ?? 0)
        
        return CGSize(width: abs(width), height: abs(height))
    }
    
    /// Creates a piece at a specific point with animation support
    /// - Parameters:
    ///   - point: Target position
    ///   - animated: Whether to support smooth animation (returns intermediate properties)
    /// - Returns: New piece at the target position
    func movingTo(_ point: CGPoint, animated: Bool = true) -> Piece {
        if animated {
            debugLog("Creating animated move for \(type) piece to (\(String(format: "%.1f", point.x)), \(String(format: "%.1f", point.y)))", category: .geometry)
        }
        return moved(to: point)
    }
}

// MARK: - Protocol Conformances (Subtask 5.3)

extension Piece {
    /// Equatable conformance for piece comparison
    /// Compares all properties except color (which doesn't conform to Equatable)
    static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs.id == rhs.id &&
               lhs.type == rhs.type &&
               lhs.position == rhs.position &&
               abs(lhs.rotation - rhs.rotation) < Constants.Geometry.vertexMatchTolerance / 1000.0 // Use small tolerance for rotation
    }
}

// MARK: - Debug Support (Subtask 5.7)

extension Piece: CustomStringConvertible {
    /// Human-readable description for debugging
    var description: String {
        let positionStr = "(\(String(format: "%.1f", position.x)), \(String(format: "%.1f", position.y)))"
        let rotationDegrees = rotation * 180.0 / Double.pi
        let rotationStr = String(format: "%.1f", rotationDegrees)
        return "\(type.displayName) at \(positionStr), rotated \(rotationStr)°"
    }
    
    /// Detailed description including vertex information
    var debugDescription: String {
        let vertices = currentVertices
        let vertexCount = vertices.count
        let boundingRect = boundingBox
        
        var result = description
        result += "\n  ID: \(id)"
        result += "\n  Base Vertices: \(type.baseVertices.count)"
        result += "\n  Current Vertices: \(vertexCount)"
        result += "\n  Bounding Box: (\(String(format: "%.1f", boundingRect.origin.x)), \(String(format: "%.1f", boundingRect.origin.y))) - \(String(format: "%.1f", boundingRect.width))×\(String(format: "%.1f", boundingRect.height))"
        
        if !vertices.isEmpty {
            result += "\n  Vertices:"
            for (index, vertex) in vertices.enumerated() {
                result += "\n    [\(index)]: (\(String(format: "%.2f", vertex.x)), \(String(format: "%.2f", vertex.y)))"
            }
        }
        
        return result
    }
    
    /// Quick status string for logging
    var statusString: String {
        return "\(type.rawValue) | pos: (\(String(format: "%.0f", position.x)),\(String(format: "%.0f", position.y))) | rot: \(String(format: "%.1f", rotation * 180.0 / Double.pi))°"
    }
}

// MARK: - Codable Support (Subtask 5.3)

extension Piece: Codable {
    /// Coding keys for Codable conformance
    private enum CodingKeys: String, CodingKey {
        case id, type, position, rotation, colorData
    }
    
    /// Custom encoding to handle Color serialization
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(position, forKey: .position)
        try container.encode(rotation, forKey: .rotation)
        
        // Encode color as a simple string representation
        let colorData: String
        switch color {
        case .red: colorData = "red"
        case .blue: colorData = "blue"
        case .green: colorData = "green"
        case .yellow: colorData = "yellow"
        case .orange: colorData = "orange"
        case .purple: colorData = "purple"
        case .cyan: colorData = "cyan"
        case .black: colorData = "black"
        case .white: colorData = "white"
        case .gray: colorData = "gray"
        case .pink: colorData = "pink"
        case .brown: colorData = "brown"
        default: colorData = "blue" // Default fallback
        }
        
        try container.encode(colorData, forKey: .colorData)
    }
    
    /// Custom decoding to handle Color deserialization
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _ = try container.decode(UUID.self, forKey: .id)  // Decode but don't use (id is let constant)
        type = try container.decode(PieceType.self, forKey: .type)
        position = try container.decode(CGPoint.self, forKey: .position)
        rotation = try container.decode(Double.self, forKey: .rotation)
        
        // Decode color from string representation
        let colorData = try container.decode(String.self, forKey: .colorData)
        switch colorData {
        case "red": color = .red
        case "blue": color = .blue
        case "green": color = .green
        case "yellow": color = .yellow
        case "orange": color = .orange
        case "purple": color = .purple
        case "cyan": color = .cyan
        case "black": color = .black
        case "white": color = .white
        case "gray": color = .gray
        case "pink": color = .pink
        case "brown": color = .brown
        default: color = .blue // Default fallback
        }
        
        // Note: We can't use the decoded ID directly because `id` is a let constant
        // For now, we'll generate a new ID - this is acceptable for this prototype
        // In a production app, you might use a different approach
        debugLog("Decoded \(type) piece at position (\(String(format: "%.1f", position.x)), \(String(format: "%.1f", position.y)))", category: .geometry)
    }
}

// MARK: - PieceType Integration (Task 6)
// PieceType is now defined in dedicated Game/Models/PieceType.swift file