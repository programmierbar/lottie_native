#if os(iOS)
    import Flutter
#else
    import FlutterMacOS
#endif
import Lottie


public class TestStreamHandler: FlutterStreamHandler {
    var eventSink: FlutterEventSink?

    public func onListen(
        withArguments _: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments _: Any?) -> FlutterError? {
        return nil
    }
}

func hexToColor(hex8: UInt32) -> LottieColor {
    let divisor = CGFloat(255)
    let alpha = CGFloat((hex8 & 0xFF00_0000) >> 24) / divisor
    let red = CGFloat((hex8 & 0x00FF_0000) >> 16) / divisor
    let green = CGFloat((hex8 & 0x0000_FF00) >> 8) / divisor
    let blue = CGFloat(hex8 & 0x0000_00FF) / divisor
    return LottieColor(r: red, g: green, b: blue, a: alpha)
}

func intFromHexString(hexStr: String) -> UInt32 {
    var hexInt: UInt32 = 0
    // Create scanner
    let scanner = Scanner(string: hexStr)
    // Tell scanner to skip the # character
    scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
    // Scan hex value
    scanner.scanHexInt32(&hexInt)
    return hexInt
}
