//
//  Constants.swift
//  TangramPrototype
//
//  Created by AI Assistant on 8/2/25.
//  Purpose: Central configuration constants for the Tangram game
//

import SwiftUI
import Foundation

/// Central configuration constants for the Tangram prototype
/// Organized by functional area for maintainability
struct Constants {
    
    // MARK: - Geometric Constants
    /// Base unit for all geometric calculations and piece sizing
    /// All tangram pieces are scaled relative to this fundamental unit
    struct Geometry {
        /// Base scaling unit for all tangram pieces (50 points = 1 unit)
        /// All piece dimensions are multiplied by this value for UI display
        static let baseUnit: CGFloat = 50.0
        
        /// Tolerance for vertex matching in win detection algorithm
        /// Allows slight imprecision in touch-based gameplay
        static let vertexMatchTolerance: Double = 8.0
        
        /// Minimum distance between vertices to be considered distinct
        /// Prevents overlapping vertices in piece validation
        static let minimumVertexSeparation: Double = 3.0
        
        /// Rotation snap angle in radians (15 degrees)
        /// Provides gentle snapping for user-friendly rotation
        static let rotationSnapAngle: Double = .pi / 12.0
        
        /// Maximum rotation velocity to trigger snap behavior
        /// Higher velocities bypass snapping for fluid interaction
        static let maxSnapVelocity: Double = 2.0
        
        // MARK: - Tangram Unit Measurements (scaled by baseUnit)
        /// Standard tangram piece measurements in base units
        /// Reference: Small triangle legs = 1×1, Large triangle legs = 2×2
        
        /// Small triangle leg length (1 unit * baseUnit)
        static let smallTriangleLeg: CGFloat = 1.0 * baseUnit
        
        /// Large triangle leg length (2 units * baseUnit) 
        static let largeTriangleLeg: CGFloat = 2.0 * baseUnit
        
        /// Medium triangle leg length (√2 units * baseUnit)
        static let mediumTriangleLeg: CGFloat = sqrt(2.0) * baseUnit
        
        /// Square side length (1 unit * baseUnit)
        static let squareSide: CGFloat = 1.0 * baseUnit
        
        /// Parallelogram base length (2 units * baseUnit)
        static let parallelogramBase: CGFloat = 2.0 * baseUnit
        
        /// Parallelogram height (1 unit * baseUnit)
        static let parallelogramHeight: CGFloat = 1.0 * baseUnit
        
        // Debug log geometric constants initialization
        static func logGeometryConstants() {
            debugLog("Geometry constants initialized - baseUnit: \(baseUnit)pt", category: .geometry)
            debugLog("Vertex match tolerance: \(vertexMatchTolerance)pt", category: .geometry)
            debugLog("Rotation snap angle: \(rotationSnapAngle * 180 / .pi)°", category: .geometry)
        }
    }
    
    // MARK: - UI & Animation Constants  
    /// User interface and animation timing constants
    struct UI {
        /// Standard animation duration for piece movements (in seconds)
        /// Used for smooth piece dragging and positioning feedback
        static let standardAnimationDuration: TimeInterval = 0.3
        
        /// Quick animation duration for snapping and micro-interactions
        /// Used for piece snapping to correct positions
        static let quickAnimationDuration: TimeInterval = 0.15
        
        /// Victory animation duration for celebration effects
        /// Used when puzzle is completed successfully
        static let victoryAnimationDuration: TimeInterval = 0.8
        
        /// Drag sensitivity threshold (minimum distance to start drag)
        /// Prevents accidental drags from small finger movements
        static let dragStartThreshold: CGFloat = 8.0
        
        /// Maximum drag velocity for smooth interaction (points/second)
        /// Above this velocity, disable rotation snapping for fluid movement
        static let maxSmoothDragVelocity: CGFloat = 500.0
        
        /// Minimum touch area for piece interaction (44pt is iOS standard)
        /// Ensures pieces are easily tappable on all device sizes
        static let minimumTouchArea: CGFloat = 44.0
        
        /// Haptic feedback intensity for piece interactions
        /// Light feedback when pieces are selected or snapped
        static let hapticFeedbackIntensity: Float = 0.7
        
        // MARK: - Layout & Spacing Constants
        
        /// Standard padding between UI elements
        static let standardPadding: CGFloat = 16.0
        
        /// Large padding for major UI sections
        static let largePadding: CGFloat = 24.0
        
        /// Small padding for tight layouts
        static let smallPadding: CGFloat = 8.0
        
        /// Corner radius for UI cards and overlays
        static let standardCornerRadius: CGFloat = 12.0
        
        /// Game area margin from screen edges
        /// Ensures pieces don't get dragged off-screen
        static let gameAreaMargin: CGFloat = 20.0
        
        /// Z-index for dragged pieces (ensures they appear on top)
        static let draggedPieceZIndex: Double = 100.0
        
        // MARK: - Visual Feedback Constants
        
        /// Scale factor for piece selection animation (slightly larger)
        static let selectionScaleFactor: CGFloat = 1.05
        
        /// Opacity for piece shadows and depth effects
        static let shadowOpacity: Double = 0.15
        
        /// Shadow radius for piece depth effects
        static let shadowRadius: CGFloat = 4.0
        
        /// Shadow offset for realistic depth appearance
        static let shadowOffset: CGSize = CGSize(width: 0, height: 2)
        
        // Debug log UI constants initialization
        static func logUIConstants() {
            debugLog("UI constants initialized - standardAnimation: \(standardAnimationDuration)s", category: .ui)
            debugLog("Drag threshold: \(dragStartThreshold)pt, Touch area: \(minimumTouchArea)pt", category: .ui)
            debugLog("Padding: small=\(smallPadding), standard=\(standardPadding), large=\(largePadding)", category: .ui)
        }
    }
    
    // MARK: - Game Logic Constants
    /// Core game mechanics and state management constants
    struct Game {
        // TODO: Add piece counts in subtask 3.4
        // TODO: Add game state values in subtask 3.4
        // TODO: Add scoring constants in subtask 3.4
    }
    
    // MARK: - Debug & Development Constants
    /// Development and debugging configuration flags
    struct Debug {
        // TODO: Add debug flags in subtask 3.5
        // TODO: Add logging levels in subtask 3.5
    }
}

// MARK: - Debug Logging
/// Helper function for consistent debug logging throughout the app
/// Usage: debugLog("Message", category: .geometry)
func debugLog(_ message: String, category: LogCategory = .general) {
    #if DEBUG
    print("🔸 [\(category.rawValue)] \(message)")
    #endif
}

/// Categories for organized debug logging
enum LogCategory: String {
    case general = "GENERAL"
    case geometry = "GEOMETRY"
    case ui = "UI"
    case game = "GAME"
    case vertex = "VERTEX"
    case anchor = "ANCHOR"
}