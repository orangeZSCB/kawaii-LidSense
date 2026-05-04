//
//  LidSenseApp.swift
//  LidSense
//

import SwiftUI

@main
struct LidSenseApp: App {
    @ObservedObject private var reader = LidAngleReader.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        MenuBarExtra {
            VStack(alignment: .leading, spacing: 6) {
                if let angle = reader.angle {
                    Text("Lid Angle: \(angle)°")
                    Text(reader.status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(reader.status)
                }

                Divider()

                Button("Quit LidSense") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        } label: {
            Text(reader.kaomoji)
        }
    }
}
