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
        /// Total number of tangram pieces in the game
        /// Standard tangram set has exactly 7 pieces
        static let totalPieceCount: Int = 7
        
        /// Individual piece count by type for validation
        static let smallTriangleCount: Int = 2
        static let largeTriangleCount: Int = 2  
        static let mediumTriangleCount: Int = 1
        static let squareCount: Int = 1
        static let parallelogramCount: Int = 1
        
        /// Maximum number of puzzles/levels in the game
        /// Can be expanded as more puzzle templates are added
        static let maxPuzzleCount: Int = 50
        
        /// Scoring system configuration
        struct Scoring {
            /// Base points awarded for completing any puzzle
            static let basePuzzlePoints: Int = 100
            
            /// Bonus points for speed completion (per second under target)
            static let speedBonusPerSecond: Int = 5
            
            /// Perfect placement bonus (no repositioning needed)
            static let perfectPlacementBonus: Int = 50
            
            /// Hint usage penalty (deducted per hint used)
            static let hintPenalty: Int = 10
            
            /// Maximum possible score for a single puzzle
            static let maxPuzzleScore: Int = 300
        }
        
        /// Difficulty level configuration
        struct Difficulty {
            /// Easy: Simple shapes with clear outlines
            static let easyTargetTime: TimeInterval = 180.0  // 3 minutes
            static let easyHintLimit: Int = 5
            
            /// Medium: Moderate complexity shapes
            static let mediumTargetTime: TimeInterval = 120.0  // 2 minutes  
            static let mediumHintLimit: Int = 3
            
            /// Hard: Complex shapes, minimal hints
            static let hardTargetTime: TimeInterval = 90.0   // 1.5 minutes
            static let hardHintLimit: Int = 1
            
            /// Expert: No hints, tight time limits
            static let expertTargetTime: TimeInterval = 60.0  // 1 minute
            static let expertHintLimit: Int = 0
        }
        
        /// Game session configuration
        struct Session {
            /// Maximum time allowed per puzzle (in seconds)
            static let maxPuzzleTime: TimeInterval = 300.0  // 5 minutes
            
            /// Auto-save interval for game progress
            static let autoSaveInterval: TimeInterval = 30.0  // 30 seconds
            
            /// Time between puzzle completion and next puzzle presentation
            static let puzzleTransitionDelay: TimeInterval = 2.0
        }
        
        // Debug log game constants initialization
        static func logGameConstants() {
            debugLog("Game constants initialized - Total pieces: \(totalPieceCount)", category: .game)
            debugLog("Max puzzle score: \(Scoring.maxPuzzleScore) points", category: .game)
            debugLog("Difficulty levels: Easy(\(Difficulty.easyTargetTime)s), Expert(\(Difficulty.expertTargetTime)s)", category: .game)
        }
    }
    
    // MARK: - Debug & Development Constants
    /// Development and debugging configuration flags
    struct Debug {
        /// Enable/disable all debug logging (master switch)
        /// Set to false for production builds to improve performance
        static let enableDebugLogging: Bool = true
        
        /// Enable detailed geometry calculations logging
        /// Useful for debugging piece positioning and win detection
        static let enableGeometryDebug: Bool = true
        
        /// Enable UI interaction logging (touches, drags, animations)
        /// Helpful for debugging user input and animation issues
        static let enableUIDebug: Bool = true
        
        /// Enable game logic debugging (scoring, state changes)
        /// Shows game flow and scoring calculations
        static let enableGameDebug: Bool = true
        
        /// Enable performance monitoring logs
        /// Tracks frame rates and memory usage
        static let enablePerformanceDebug: Bool = false
        
        /// Show piece bounding boxes and collision areas
        /// Visual debugging aid for development
        static let showDebugOverlays: Bool = false
        
        /// Enable automatic screenshot capture for failed tests
        /// Useful for debugging UI test failures
        static let captureFailureScreenshots: Bool = true
        
        /// Force all puzzles to auto-complete after this duration (debug only)
        /// Set to 0 to disable. Useful for testing completion flows
        static let autoCompleteDelay: TimeInterval = 0.0  // Disabled by default
        
        /// Skip victory animations for faster testing
        /// Speeds up automated testing and development iteration
        static let skipVictoryAnimations: Bool = false
        
        /// Log memory usage every N seconds (0 = disabled)
        /// Helps identify memory leaks during development
        static let memoryLoggingInterval: TimeInterval = 0.0  // Disabled
        
        // Debug log debug constants initialization
        static func logDebugConstants() {
            debugLog("Debug constants initialized - Logging enabled: \(enableDebugLogging)", category: .debug)
            debugLog("Debug overlays: \(showDebugOverlays), Auto-complete: \(autoCompleteDelay)s", category: .debug)
            debugLog("Categories enabled - Geometry: \(enableGeometryDebug), UI: \(enableUIDebug), Game: \(enableGameDebug)", category: .debug)
        }
    }
    
    // MARK: - Colors
    struct Colors {
        /// Colors for tangram pieces to provide clear visual differentiation
        struct Pieces {
            static let largeTriangle1: Color = .red
            static let largeTriangle2: Color = Color(red: 0.0, green: 0.0, blue: 0.5) // Navy
            static let smallTriangle1: Color = .blue
            static let smallTriangle2: Color = .purple
            static let mediumTriangle: Color = .green
            static let square: Color = .yellow
            static let parallelogram: Color = .orange
        }
        
        /// UI accent colors
        struct UI {
            static let background: Color = Color.gray.opacity(0.05)
            static let vertexDot: Color = .red
            static let strokeColor: Color = .black
        }
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
    case debug = "DEBUG"
    case vertex = "VERTEX"
    case anchor = "ANCHOR"
}