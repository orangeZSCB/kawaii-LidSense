//
//  LidAngleReader.swift
//  LidSense
//

import Combine
import Foundation
import IOKit.hid

final class LidAngleReader: ObservableObject {
    static let shared = LidAngleReader()

    @Published var angle: Int?
    @Published var status = "Looking for lid angle sensor..."

    var kaomoji: String {
        guard let angle else { return "＝＿＝" }
        switch angle {
        case ...60:  return "(๑>ㅁ<ฅ)"
        case ..<120: return "＝O_O＝"
        default:     return "＝￣ω￣＝"
        }
    }

    private enum HID {
        static let vendorID = 0x05AC
        static let productID = 0x8104
        static let primaryUsagePage = 0x0020
        static let primaryUsage = 0x008A
        static let featureReportID = CFIndex(1)
        static let reportLength = 3
    }

    private var manager: IOHIDManager?
    private var device: IOHIDDevice?
    private var timer: Timer?

    init() {
        connect()
    }

    deinit {
        timer?.invalidate()

        if let device {
            IOHIDDeviceClose(device, IOOptionBits(kIOHIDOptionsTypeNone))
        }

        if let manager {
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        }
    }

    private func connect() {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        self.manager = manager

        // This sensor/report pairing is undocumented macOS HID behavior. It is
        // useful for personal experiments, but may disappear or behave
        // differently across MacBook models and macOS releases.
        let matching = [
            kIOHIDVendorIDKey as String: NSNumber(value: HID.vendorID),
            kIOHIDProductIDKey as String: NSNumber(value: HID.productID),
            kIOHIDPrimaryUsagePageKey as String: NSNumber(value: HID.primaryUsagePage),
            kIOHIDPrimaryUsageKey as String: NSNumber(value: HID.primaryUsage),
        ] as NSDictionary

        IOHIDManagerSetDeviceMatching(manager, matching)

        let managerResult = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        guard managerResult == kIOReturnSuccess else {
            setUnavailable("Could not open HID manager: \(hex(managerResult)).")
            return
        }

        guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice>,
              let device = devices.first else {
            setUnavailable("Lid angle sensor was not found on this Mac.")
            return
        }

        let openResult = IOHIDDeviceOpen(device, IOOptionBits(kIOHIDOptionsTypeNone))
        guard openResult == kIOReturnSuccess else {
            setUnavailable("Could not open lid angle sensor: \(hex(openResult)).")
            return
        }

        self.device = device
        status = "Reading lid angle..."
        readAngle()
        startPolling()
    }

    private func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.readAngle()
        }
    }

    private func readAngle() {
        guard let device else {
            setUnavailable("Lid angle sensor is unavailable.")
            return
        }

        var report = [UInt8](repeating: 0, count: HID.reportLength)
        var reportLength = CFIndex(report.count)

        let result = report.withUnsafeMutableBufferPointer { buffer -> IOReturn in
            guard let baseAddress = buffer.baseAddress else {
                return kIOReturnError
            }

            return IOHIDDeviceGetReport(
                device,
                kIOHIDReportTypeFeature,
                HID.featureReportID,
                baseAddress,
                &reportLength
            )
        }

        guard result == kIOReturnSuccess else {
            setUnavailable("Could not read lid angle: \(hex(result)).")
            return
        }

        guard reportLength >= HID.reportLength else {
            setUnavailable("Lid angle sensor returned an invalid report.")
            return
        }

        angle = Int(report[1]) | (Int(report[2]) << 8)
        status = "Reading lid angle..."
    }

    private func setUnavailable(_ message: String) {
        angle = nil
        status = message
    }

    private func hex(_ value: IOReturn) -> String {
        "0x" + String(UInt32(bitPattern: value), radix: 16, uppercase: true)
    }
}
