//
//  SimplePieceTestView.swift
//  TangramPrototype
//
//  Created by AI Assistant on 8/3/25.
//  Purpose: Simple test interface for Piece model validation
//

import SwiftUI

/// Simple test view for validating Piece model functionality
struct SimplePieceTestView: View {
    
    @State private var testPieces: [Piece] = []
    @State private var selectedPieceIndex: Int? = nil
    @State private var showVertices = true
    @State private var dragStartPosition: CGPoint = .zero
    @State private var containerSize: CGSize = CGSize(width: 350, height: 400)
    @State private var showTestDot = true
    @State private var useSimpleShapes = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                controlsView
                testDisplayView
                debugInfoView
            }
            .padding()
        }
        .onAppear {
            // Initial setup with default size - will be updated by GeometryReader
            setupTestPieces(in: containerSize)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("🧩 Piece Model Test")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Testing geometric calculations and transformations")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var controlsView: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Reset Pieces") {
                    setupTestPieces(in: containerSize)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Rotate All") {
                    rotateAllPieces()
                }
                .buttonStyle(.borderedProminent)
            }
            
            HStack {
                Toggle("Show Vertices", isOn: $showVertices)
                    .toggleStyle(.button)
                    .foregroundColor(showVertices ? .blue : .secondary)
                
                Toggle("Debug Dot", isOn: $showTestDot)
                    .toggleStyle(.button)
                    .foregroundColor(showTestDot ? .red : .secondary)
                
                Toggle("Simple Test", isOn: $useSimpleShapes)
                    .toggleStyle(.button)
                    .foregroundColor(useSimpleShapes ? .green : .secondary)
            }
        }
        .padding()
    }
    
    private var testDisplayView: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView
                
                // Use actual container bounds for positioning
                ForEach(testPieces.indices, id: \.self) { index in
                    Group {
                        if useSimpleShapes {
                            // Simple colored rectangle for testing positioning
                            Rectangle()
                                .fill(testPieces[index].color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("\(index + 1)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                )
                                .position(
                                    x: testPieces[index].position.x,
                                    y: testPieces[index].position.y
                                )
                                .onAppear {
                                    debugLog("🟩 Simple shape \(index + 1) positioned at (\(String(format: "%.1f", testPieces[index].position.x)), \(String(format: "%.1f", testPieces[index].position.y)))", category: .debug)
                                }
                        } else {
                            SimplePieceView(
                                piece: testPieces[index],
                                showVertices: showVertices,
                                isSelected: selectedPieceIndex == index
                            )
                            .position(
                                x: testPieces[index].position.x,
                                y: testPieces[index].position.y
                            )
                            .background(
                                // Debug: Add a small indicator at the exact calculated position
                                Circle()
                                    .fill(Color.blue.opacity(0.5))
                                    .frame(width: 8, height: 8)
                                    .onAppear {
                                        debugLog("🔵 Piece \(index + 1) (\(testPieces[index].type.displayName)) - Expected at (\(String(format: "%.1f", testPieces[index].position.x)), \(String(format: "%.1f", testPieces[index].position.y)))", category: .debug)
                                        debugLog("🔵 Piece \(index + 1) vertices: \(testPieces[index].currentVertices)", category: .debug)
                                        debugLog("🔵 Piece \(index + 1) baseVertices: \(testPieces[index].type.baseVertices)", category: .debug)
                                    }
                            )
                        }
                    }
                    .onTapGesture {
                        selectedPieceIndex = index
                        debugLog("Selected \(testPieces[index].type.displayName) piece", category: .ui)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if selectedPieceIndex != index {
                                    selectedPieceIndex = index
                                    dragStartPosition = testPieces[index].position
                                }
                                
                                // Constrain to container bounds
                                let newX = max(0, min(geometry.size.width, dragStartPosition.x + value.translation.width))
                                let newY = max(0, min(geometry.size.height, dragStartPosition.y + value.translation.height))
                                
                                let newPosition = CGPoint(x: newX, y: newY)
                                testPieces[index] = testPieces[index].moved(to: newPosition)
                                debugLog("Dragging \(testPieces[index].type.displayName) to (\(String(format: "%.1f", newPosition.x)), \(String(format: "%.1f", newPosition.y))) in bounds \(geometry.size)", category: .ui)
                            }
                            .onEnded { _ in
                                debugLog("Finished dragging \(testPieces[index].type.displayName)", category: .ui)
                            }
                    )
                }
                
                // Debug test dot - should appear in top right corner
                if showTestDot {
                    let topRightX = geometry.size.width - 20
                    let topRightY: CGFloat = 20
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                        .position(x: topRightX, y: topRightY)
                        .overlay(
                            Text("🎯")
                                .font(.title2)
                                .position(x: topRightX, y: topRightY)
                        )
                        .onAppear {
                            debugLog("🎯 TEST DOT: Container size = \(geometry.size)", category: .debug)
                            debugLog("🎯 TEST DOT: Positioned at (\(topRightX), \(topRightY)) - should be top right corner", category: .debug)
                        }
                }
            }
            .onAppear {
                // Update piece positions when container size is known
                containerSize = geometry.size
                setupTestPieces(in: geometry.size)
                debugLog("Container appeared with size: \(geometry.size)", category: .ui)
            }
            .onChange(of: geometry.size) { _, newSize in
                // Reposition pieces when container size changes (e.g., rotation)
                containerSize = newSize
                setupTestPieces(in: newSize)
                debugLog("Container size changed to: \(newSize)", category: .ui)
            }
        }
        .frame(height: 400)
        .padding()
    }
    
    private var backgroundView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))  // More visible gray
            .frame(height: 400)
            .cornerRadius(12)
            .onTapGesture {
                selectedPieceIndex = nil
                debugLog("Deselected all pieces", category: .ui)
            }
    }
    
    private var debugInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🐛 Debug Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(testPieces.indices, id: \.self) { index in
                let piece = testPieces[index]
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(piece.type.displayName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(piece.color)
                    
                    HStack {
                        Text("Position: (\(String(format: "%.1f", piece.position.x)), \(String(format: "%.1f", piece.position.y)))")
                        Spacer()
                        Text("Rotation: \(String(format: "%.2f", piece.rotation))°")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text("Vertices: \(piece.currentVertices.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(piece.color.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func setupTestPieces(in containerSize: CGSize) {
        // Position pieces relative to actual container bounds
        // GeometryReader provides the real available space
        debugLog("📏 SETUP: Container size = \(containerSize)", category: .debug)
        
        let centerX = containerSize.width / 2
        let centerY = containerSize.height / 2
        let spacing = min(containerSize.width, containerSize.height) * 0.2  // 20% of smaller dimension
        
        // Calculate row positions as fractions of container height
        let topRow = centerY - spacing     // Top row above center
        let middleRow = centerY            // Middle row at center
        let bottomRow = centerY + spacing  // Bottom row below center
        
        debugLog("📏 CALCULATED POSITIONS:", category: .debug)
        debugLog("   centerX: \(centerX), centerY: \(centerY)", category: .debug)
        debugLog("   spacing: \(spacing)", category: .debug)
        debugLog("   topRow: \(topRow), middleRow: \(middleRow), bottomRow: \(bottomRow)", category: .debug)
        debugLog("   Container bounds: (0,0) to (\(containerSize.width), \(containerSize.height))", category: .debug)
        
        testPieces = [
            // Row 1 - Top of canvas
            // Large Triangle 1 (red) - top left
            Piece(
                type: .largeTriangle1,
                position: CGPoint(x: centerX - spacing, y: topRow),
                rotation: 0,
                color: Constants.Colors.Pieces.largeTriangle1
            ),
            // Medium Triangle (green) - top center  
            Piece(
                type: .mediumTriangle,
                position: CGPoint(x: centerX, y: topRow),
                rotation: Double.pi / 2,
                color: Constants.Colors.Pieces.mediumTriangle
            ),
            // Large Triangle 2 (navy) - top right
            Piece(
                type: .largeTriangle2,
                position: CGPoint(x: centerX + spacing, y: topRow),
                rotation: Double.pi,
                color: Constants.Colors.Pieces.largeTriangle2
            ),
            
            // Row 2 - Middle of canvas
            // Small Triangle 1 (blue) - middle left
            Piece(
                type: .smallTriangle1,
                position: CGPoint(x: centerX - spacing, y: middleRow),
                rotation: Double.pi / 4,
                color: Constants.Colors.Pieces.smallTriangle1
            ),
            // Square (yellow) - center
            Piece(
                type: .square,
                position: CGPoint(x: centerX, y: middleRow),
                rotation: 0,
                color: Constants.Colors.Pieces.square
            ),
            // Small Triangle 2 (purple) - middle right
            Piece(
                type: .smallTriangle2,
                position: CGPoint(x: centerX + spacing, y: middleRow),
                rotation: Double.pi * 3/4,
                color: Constants.Colors.Pieces.smallTriangle2
            ),
            
            // Row 3 - Bottom of canvas
            // Parallelogram (orange) - bottom center
            Piece(
                type: .parallelogram,
                position: CGPoint(x: centerX, y: bottomRow),
                rotation: Double.pi / 6,
                color: Constants.Colors.Pieces.parallelogram
            )
        ]
        
        debugLog("🎲 CREATED \(testPieces.count) pieces:", category: .debug)
        for (index, piece) in testPieces.enumerated() {
            debugLog("   \(index + 1). \(piece.type.displayName) at (\(String(format: "%.1f", piece.position.x)), \(String(format: "%.1f", piece.position.y)))", category: .debug)
        }
    }
    
    private func rotateAllPieces() {
        for index in testPieces.indices {
            let newRotation = testPieces[index].rotation + Double.pi / 8
            testPieces[index] = testPieces[index].rotated(to: newRotation)
        }
        debugLog("Rotated all pieces by 22.5 degrees", category: .debug)
    }
}

// Accurate tangram piece rendering using actual vertex coordinates
struct SimplePieceView: View {
    let piece: Piece
    let showVertices: Bool
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Draw actual tangram shape using relative vertices
            relativeShape
                .fill(piece.color.opacity(0.6))
                .stroke(
                    isSelected ? Color.yellow : Constants.Colors.UI.strokeColor,
                    lineWidth: isSelected ? 4 : 2
                )
                .onAppear {
                    debugLog("🎨 SimplePieceView rendered: \(piece.type.displayName) with \(relativeVertices.count) vertices", category: .debug)
                    for (i, vertex) in relativeVertices.enumerated() {
                        debugLog("🎨   Vertex \(i): (\(String(format: "%.1f", vertex.x)), \(String(format: "%.1f", vertex.y)))", category: .debug)
                    }
                }
            
            // Text labels removed for cleaner visualization
            
            // Vertex visualization using relative positions
            if showVertices {
                ForEach(relativeVertices.indices, id: \.self) { index in
                    let vertex = relativeVertices[index]
                    Circle()
                        .fill(Constants.Colors.UI.vertexDot)
                        .frame(width: 10, height: 10)
                        .position(x: vertex.x, y: vertex.y)
                        .overlay(
                            Text("\(index)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .position(x: vertex.x, y: vertex.y)
                        )
                }
            }
        }
        .frame(width: 150, height: 150)  // Provide consistent frame size for shape centering
        // Remove .position() - positioning is now handled by parent view with .offset()
    }
    
    // Convert absolute vertices to relative positions centered in the view
    private var relativeVertices: [Vertex] {
        // Apply rotation to base vertices
        let rotatedVertices = piece.type.baseVertices.map { baseVertex in
            let rotatedX = baseVertex.x * cos(piece.rotation) - baseVertex.y * sin(piece.rotation)
            let rotatedY = baseVertex.x * sin(piece.rotation) + baseVertex.y * cos(piece.rotation)
            return Vertex(x: rotatedX, y: rotatedY)
        }
        
        // Find the bounds of the rotated shape
        guard !rotatedVertices.isEmpty else { return [] }
        let minX = rotatedVertices.map { $0.x }.min() ?? 0
        let maxX = rotatedVertices.map { $0.x }.max() ?? 0
        let minY = rotatedVertices.map { $0.y }.min() ?? 0
        let maxY = rotatedVertices.map { $0.y }.max() ?? 0
        
        // Calculate shape center point
        let shapeCenterX = (minX + maxX) / 2
        let shapeCenterY = (minY + maxY) / 2
        
        // Assume view frame of 150x150 (will be clipped appropriately)
        let viewSize: CGFloat = 150
        let viewCenterX = viewSize / 2
        let viewCenterY = viewSize / 2
        
        // Center the shape in the view by offsetting vertices
        return rotatedVertices.map { vertex in
            Vertex(
                x: vertex.x - shapeCenterX + viewCenterX,
                y: vertex.y - shapeCenterY + viewCenterY
            )
        }
    }
    
    private var relativeShape: some Shape {
        TangramShape(vertices: relativeVertices)
    }
}

// Custom Shape that draws a polygon from vertex coordinates
struct TangramShape: Shape {
    let vertices: [Vertex]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !vertices.isEmpty else { 
            debugLog("⚠️ TangramShape: No vertices provided", category: .debug)
            return path 
        }
        
        debugLog("🎯 TangramShape: Creating path with \(vertices.count) vertices in rect \(rect)", category: .debug)
        
        // Move to first vertex
        let firstVertex = vertices[0]
        path.move(to: CGPoint(x: firstVertex.x, y: firstVertex.y))
        debugLog("🎯   Start: (\(String(format: "%.1f", firstVertex.x)), \(String(format: "%.1f", firstVertex.y)))", category: .debug)
        
        // Draw lines to all other vertices
        for (i, vertex) in vertices.dropFirst().enumerated() {
            path.addLine(to: CGPoint(x: vertex.x, y: vertex.y))
            debugLog("🎯   Line \(i + 1): (\(String(format: "%.1f", vertex.x)), \(String(format: "%.1f", vertex.y)))", category: .debug)
        }
        
        // Close the path back to first vertex
        path.closeSubpath()
        debugLog("🎯   Path closed", category: .debug)
        
        return path
    }
}

struct SimplePieceTestView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePieceTestView()
    }
}