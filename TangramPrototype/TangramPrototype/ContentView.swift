//
//  ContentView.swift
//  TangramPrototype
//
//  Created by yiran-gauntlet on 8/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("🧩 Tangram Prototype")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Testing Implementation So Far...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Test Constants Display
            VStack(alignment: .leading, spacing: 8) {
                Text("📐 Geometric Constants:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Group {
                    Text("Base Unit: \(Constants.Geometry.baseUnit)pt")
                    Text("Vertex Tolerance: \(Constants.Geometry.vertexMatchTolerance)pt")
                    Text("Rotation Snap: \(String(format: "%.1f", Constants.Geometry.rotationSnapAngle * 180 / .pi))°")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Text("🔧 Piece Dimensions:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                Group {
                    Text("Small Triangle: \(Constants.Geometry.smallTriangleLeg)pt")
                    Text("Large Triangle: \(Constants.Geometry.largeTriangleLeg)pt") 
                    Text("Medium Triangle: \(String(format: "%.1f", Constants.Geometry.mediumTriangleLeg))pt")
                    Text("Square Side: \(Constants.Geometry.squareSide)pt")
                    Text("Parallelogram: \(Constants.Geometry.parallelogramBase)×\(Constants.Geometry.parallelogramHeight)pt")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Visual Scale Test
            VStack {
                Text("📏 Visual Scale Test (baseUnit = 50pt):")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: Constants.Geometry.baseUnit, height: Constants.Geometry.baseUnit)
                        .overlay(Text("1×1\nunit").font(.caption).foregroundColor(.white))
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: Constants.Geometry.largeTriangleLeg, height: Constants.Geometry.baseUnit)
                        .overlay(Text("2×1\nunits").font(.caption).foregroundColor(.white))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            // UI Constants Test Section
            VStack(alignment: .leading, spacing: 8) {
                Text("🎨 UI & Animation Constants:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Group {
                    Text("Standard Animation: \(Constants.UI.standardAnimationDuration)s")
                    Text("Quick Animation: \(Constants.UI.quickAnimationDuration)s")
                    Text("Drag Threshold: \(Constants.UI.dragStartThreshold)pt")
                    Text("Touch Area: \(Constants.UI.minimumTouchArea)pt")
                    Text("Standard Padding: \(Constants.UI.standardPadding)pt")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(Constants.UI.standardCornerRadius) // Using our constant!
            
            // Game Constants Test Section
            VStack(alignment: .leading, spacing: 8) {
                Text("🎮 Game Logic Constants:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Group {
                    Text("Total Pieces: \(Constants.Game.totalPieceCount)")
                    Text("Base Score: \(Constants.Game.Scoring.basePuzzlePoints) pts")
                    Text("Max Score: \(Constants.Game.Scoring.maxPuzzleScore) pts")
                    Text("Easy Target: \(Int(Constants.Game.Difficulty.easyTargetTime))s")
                    Text("Expert Target: \(Int(Constants.Game.Difficulty.expertTargetTime))s")
                    Text("Max Puzzle Time: \(Int(Constants.Game.Session.maxPuzzleTime))s")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(12)
            
            // Debug Constants Test Section
            VStack(alignment: .leading, spacing: 8) {
                Text("🔧 Debug & Development Constants:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Group {
                    Text("Debug Logging: \(Constants.Debug.enableDebugLogging ? "ON" : "OFF")")
                    Text("Geometry Debug: \(Constants.Debug.enableGeometryDebug ? "ON" : "OFF")")
                    Text("UI Debug: \(Constants.Debug.enableUIDebug ? "ON" : "OFF")")
                    Text("Game Debug: \(Constants.Debug.enableGameDebug ? "ON" : "OFF")")
                    Text("Debug Overlays: \(Constants.Debug.showDebugOverlays ? "ON" : "OFF")")
                    Text("Auto-complete: \(Constants.Debug.autoCompleteDelay > 0 ? "\(Int(Constants.Debug.autoCompleteDelay))s" : "OFF")")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.05))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding(Constants.UI.standardPadding) // Using our constant!
        .onAppear {
            // Test debug logging for all constant groups
            Constants.Geometry.logGeometryConstants()
            Constants.UI.logUIConstants()
            Constants.Game.logGameConstants()
            Constants.Debug.logDebugConstants()
            debugLog("ContentView appeared - All constants test successful!", category: .ui)
        }
    }
}

#Preview {
    ContentView()
}
