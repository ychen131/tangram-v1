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
            setupTestPieces()
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
        HStack {
            Button("Reset Pieces") {
                setupTestPieces()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Rotate All") {
                rotateAllPieces()
            }
            .buttonStyle(.borderedProminent)
            
            Toggle("Show Vertices", isOn: $showVertices)
                .toggleStyle(.button)
                .foregroundColor(showVertices ? .blue : .secondary)
        }
        .padding()
    }
    
    private var testDisplayView: some View {
        ZStack {
            backgroundView
            
            // Use ForEach directly in ZStack for better control
            ForEach(testPieces.indices, id: \.self) { index in
                SimplePieceView(
                    piece: testPieces[index],
                    showVertices: showVertices,
                    isSelected: selectedPieceIndex == index
                )
                .offset(
                    x: testPieces[index].position.x - 200,  // Offset from center
                    y: testPieces[index].position.y - 200   // Offset from center
                )
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
                            
                            let newPosition = CGPoint(
                                x: dragStartPosition.x + value.translation.width,
                                y: dragStartPosition.y + value.translation.height
                            )
                            testPieces[index] = testPieces[index].moved(to: newPosition)
                        }
                        .onEnded { _ in
                            debugLog("Finished dragging \(testPieces[index].type.displayName)", category: .ui)
                        }
                )
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
    
    private func setupTestPieces() {
        // Position pieces within the ZStack coordinate space
        // The ZStack with .position() uses coordinates where (0,0) is top-left
        // For a 400px tall canvas, center is at (width/2, 200)
        
        // We'll position pieces in a grid pattern
        // Assume canvas width of about 350 (typical iPhone width minus padding)
        let centerX: CGFloat = 175  // Center of typical canvas width
        let centerY: CGFloat = 200  // Center of 400px height
        let spacing: CGFloat = 80   // Spacing between pieces
        
        // Calculate row positions
        let topRow = centerY - 100     // Top row at y=100
        let middleRow = centerY         // Middle row at y=200
        let bottomRow = centerY + 100   // Bottom row at y=300
        
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
        
        debugLog("Created \(testPieces.count) test pieces with corrected tangram shapes", category: .debug)
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
        // Remove .position() - positioning is now handled by parent view with .offset()
    }
    
    // Convert absolute vertices to relative positions centered on the piece
    private var relativeVertices: [Vertex] {
        return piece.type.baseVertices.map { baseVertex in
            // Apply rotation around origin, but don't translate
            let rotatedX = baseVertex.x * cos(piece.rotation) - baseVertex.y * sin(piece.rotation)
            let rotatedY = baseVertex.x * sin(piece.rotation) + baseVertex.y * cos(piece.rotation)
            return Vertex(x: rotatedX, y: rotatedY)
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
        
        guard !vertices.isEmpty else { return path }
        
        // Move to first vertex
        let firstVertex = vertices[0]
        path.move(to: CGPoint(x: firstVertex.x, y: firstVertex.y))
        
        // Draw lines to all other vertices
        for vertex in vertices.dropFirst() {
            path.addLine(to: CGPoint(x: vertex.x, y: vertex.y))
        }
        
        // Close the path back to first vertex
        path.closeSubpath()
        
        return path
    }
}

struct SimplePieceTestView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePieceTestView()
    }
}