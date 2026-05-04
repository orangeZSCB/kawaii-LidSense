//
//  ContentView.swift
//  LidSense
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var reader = LidAngleReader.shared

    var body: some View {
        VStack(spacing: 18) {
            Text("Lid Angle")
                .font(.title2)
                .fontWeight(.semibold)

            if let angle = reader.angle {
                Text(reader.kaomoji)
                    .font(.system(size: 48, weight: .regular, design: .rounded))

                Text("\(angle)°")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "laptopcomputer.trianglebadge.exclamationmark")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)

                    Text("Unavailable")
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    Text(reader.status)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }

            Text(reader.status)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minWidth: 360, minHeight: 260)
        .padding(32)
    }
}
