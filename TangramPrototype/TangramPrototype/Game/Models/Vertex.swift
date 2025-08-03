//
//  Vertex.swift
//  TangramPrototype
//
//  Created by AI Assistant on 8/3/25.
//  Purpose: Core geometric coordinate system for tangram pieces
//

import Foundation

/// Represents a geometric point in 2D coordinate space
/// Used as the fundamental building block for all tangram piece vertices
struct Vertex {
    
    // MARK: - Properties
    
    /// X coordinate in points (screen coordinate system)
    let x: Double
    
    /// Y coordinate in points (screen coordinate system)  
    let y: Double
    
    // MARK: - Initializers
    
    /// Creates a vertex at the specified coordinates
    /// - Parameters:
    ///   - x: X coordinate in points
    ///   - y: Y coordinate in points
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
        
        debugLog("Created vertex at (\(String(format: "%.2f", x)), \(String(format: "%.2f", y)))", category: .vertex)
    }
    
    /// Creates a vertex at the origin (0, 0)
    init() {
        self.init(x: 0.0, y: 0.0)
    }
    
    /// Creates a vertex from CGPoint for SwiftUI integration
    /// - Parameter point: CGPoint to convert to Vertex
    init(from point: CGPoint) {
        self.init(x: Double(point.x), y: Double(point.y))
    }
    
    // MARK: - Translation Methods (Subtask 4.3)
    
    /// Translates this vertex by the specified offset amounts
    /// - Parameters:
    ///   - dx: Horizontal offset in points
    ///   - dy: Vertical offset in points
    /// - Returns: New vertex at the translated position
    func translated(by dx: Double, dy: Double) -> Vertex {
        let newVertex = Vertex(x: x + dx, y: y + dy)
        debugLog("Translated vertex from (\(String(format: "%.2f", x)), \(String(format: "%.2f", y))) to (\(String(format: "%.2f", newVertex.x)), \(String(format: "%.2f", newVertex.y)))", category: .vertex)
        return newVertex
    }
    
    /// Translates this vertex by another vertex's coordinates (treating it as an offset)
    /// - Parameter offset: Vertex representing the translation offset
    /// - Returns: New vertex at the translated position
    func translated(by offset: Vertex) -> Vertex {
        return translated(by: offset.x, dy: offset.y)
    }
    
    // MARK: - Rotation Methods (Subtask 4.4)
    
    /// Rotates this vertex around a specified pivot point
    /// - Parameters:
    ///   - pivot: The point to rotate around
    ///   - angle: Rotation angle in radians (positive = counterclockwise)
    /// - Returns: New vertex at the rotated position
    func rotated(around pivot: Vertex, by angle: Double) -> Vertex {
        // Translate to origin (relative to pivot)
        let translatedX = x - pivot.x
        let translatedY = y - pivot.y
        
        // Apply rotation matrix transformation
        let cosAngle = cos(angle)
        let sinAngle = sin(angle)
        
        let rotatedX = translatedX * cosAngle - translatedY * sinAngle
        let rotatedY = translatedX * sinAngle + translatedY * cosAngle
        
        // Translate back to world coordinates
        let finalX = rotatedX + pivot.x
        let finalY = rotatedY + pivot.y
        
        let newVertex = Vertex(x: finalX, y: finalY)
        
        debugLog("Rotated vertex around (\(String(format: "%.2f", pivot.x)), \(String(format: "%.2f", pivot.y))) by \(String(format: "%.3f", angle)) radians", category: .vertex)
        debugLog("Result: (\(String(format: "%.2f", x)), \(String(format: "%.2f", y))) → (\(String(format: "%.2f", newVertex.x)), \(String(format: "%.2f", newVertex.y)))", category: .vertex)
        
        return newVertex
    }
    
    /// Rotates this vertex around the origin (0, 0)
    /// - Parameter angle: Rotation angle in radians (positive = counterclockwise)
    /// - Returns: New vertex at the rotated position
    func rotated(by angle: Double) -> Vertex {
        return rotated(around: Vertex(), by: angle)
    }
    
    // MARK: - Utility Methods
    
    /// Converts this vertex to a CGPoint for SwiftUI integration
    /// - Returns: CGPoint representation of this vertex
    func toCGPoint() -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    /// Creates a vertex representing the midpoint between this vertex and another
    /// - Parameter other: The other vertex
    /// - Returns: New vertex at the midpoint
    func midpoint(to other: Vertex) -> Vertex {
        return Vertex(x: (x + other.x) / 2.0, y: (y + other.y) / 2.0)
    }
    
    // MARK: - Distance Methods (Subtask 4.5)
    
    /// Calculates the Euclidean distance to another vertex
    /// - Parameter other: The target vertex
    /// - Returns: Distance in points
    func distance(to other: Vertex) -> Double {
        let deltaX = other.x - x
        let deltaY = other.y - y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        if Constants.Debug.enableGeometryDebug {
            debugLog("Distance from (\(String(format: "%.2f", x)), \(String(format: "%.2f", y))) to (\(String(format: "%.2f", other.x)), \(String(format: "%.2f", other.y))) = \(String(format: "%.3f", distance))", category: .vertex)
        }
        
        return distance
    }
    
    /// Calculates the squared distance to another vertex (faster when comparing distances)
    /// - Parameter other: The target vertex
    /// - Returns: Squared distance in points²
    func squaredDistance(to other: Vertex) -> Double {
        let deltaX = other.x - x
        let deltaY = other.y - y
        return deltaX * deltaX + deltaY * deltaY
    }
    
    /// Static method to calculate distance between two vertices
    /// - Parameters:
    ///   - from: Starting vertex
    ///   - to: Ending vertex
    /// - Returns: Distance in points
    static func distance(from: Vertex, to: Vertex) -> Double {
        return from.distance(to: to)
    }
    
    /// Checks if another vertex is within a specified distance
    /// - Parameters:
    ///   - other: The other vertex
    ///   - threshold: Maximum distance threshold
    /// - Returns: True if within threshold distance
    func isWithinDistance(_ threshold: Double, of other: Vertex) -> Bool {
        return distance(to: other) <= threshold
    }
    
    /// Checks if this vertex is close enough to another to be considered matching
    /// Uses Constants.Geometry.vertexMatchTolerance for the distance check
    /// - Parameter other: The other vertex
    /// - Returns: True if vertices match within tolerance
    func matches(_ other: Vertex) -> Bool {
        return isWithinDistance(Constants.Geometry.vertexMatchTolerance, of: other)
    }
}

// MARK: - Equatable Conformance (Subtask 4.2)

extension Vertex: Equatable {
    /// Compares two vertices for equality using tolerance-based matching
    /// Uses Constants.Geometry.vertexMatchTolerance for precision handling
    static func == (lhs: Vertex, rhs: Vertex) -> Bool {
        let tolerance = Constants.Geometry.vertexMatchTolerance
        let deltaX = abs(lhs.x - rhs.x)
        let deltaY = abs(lhs.y - rhs.y)
        
        let isEqual = deltaX <= tolerance && deltaY <= tolerance
        
        if Constants.Debug.enableGeometryDebug {
            debugLog("Vertex equality check: (\(String(format: "%.2f", lhs.x)), \(String(format: "%.2f", lhs.y))) == (\(String(format: "%.2f", rhs.x)), \(String(format: "%.2f", rhs.y))) → \(isEqual)", category: .vertex)
            debugLog("Deltas: dx=\(String(format: "%.3f", deltaX)), dy=\(String(format: "%.3f", deltaY)), tolerance=\(tolerance)", category: .vertex)
        }
        
        return isEqual
    }
}

// MARK: - Hashable Conformance (Subtask 4.2)

extension Vertex: Hashable {
    /// Generates hash value for use in collections (Sets, Dictionaries)
    /// Rounds coordinates to tolerance precision to ensure consistent hashing for equivalent vertices
    func hash(into hasher: inout Hasher) {
        let tolerance = Constants.Geometry.vertexMatchTolerance
        
        // Round to tolerance precision to ensure vertices that compare equal also hash equally
        let roundedX = (x / tolerance).rounded() * tolerance
        let roundedY = (y / tolerance).rounded() * tolerance
        
        hasher.combine(roundedX)
        hasher.combine(roundedY)
    }
}

// MARK: - CustomStringConvertible Conformance

extension Vertex: CustomStringConvertible {
    /// Human-readable description of the vertex
    var description: String {
        return "Vertex(x: \(String(format: "%.2f", x)), y: \(String(format: "%.2f", y)))"
    }
}

// MARK: - Static Factory Methods

extension Vertex {
    /// Creates a vertex representing a unit vector in the specified direction
    /// - Parameter angle: Direction angle in radians (0 = right, π/2 = up)
    /// - Returns: Unit vertex in the specified direction
    static func unitVector(angle: Double) -> Vertex {
        return Vertex(x: cos(angle), y: sin(angle))
    }
    
    /// Creates vertices for a regular polygon centered at the origin
    /// - Parameters:
    ///   - sides: Number of sides (minimum 3)
    ///   - radius: Distance from center to vertices
    ///   - startAngle: Starting angle in radians (default: 0)
    /// - Returns: Array of vertices forming the polygon
    static func regularPolygon(sides: Int, radius: Double, startAngle: Double = 0) -> [Vertex] {
        guard sides >= 3 else {
            debugLog("Invalid polygon: sides must be >= 3, got \(sides)", category: .vertex)
            return []
        }
        
        let angleIncrement = 2 * Double.pi / Double(sides)
        var vertices: [Vertex] = []
        
        for i in 0..<sides {
            let angle = startAngle + Double(i) * angleIncrement
            let vertex = Vertex(x: radius * cos(angle), y: radius * sin(angle))
            vertices.append(vertex)
        }
        
        debugLog("Created \(sides)-sided regular polygon with radius \(radius)", category: .vertex)
        return vertices
    }
}