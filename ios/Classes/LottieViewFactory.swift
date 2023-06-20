#if os(iOS)
    import Flutter
#else
    import FlutterMacOS
#endif
import Lottie

public class LottieViewFactory: NSObject, FlutterPlatformViewFactory {
    var registrar: FlutterPluginRegistrar

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return LottieView(frame, viewId: viewId, args: args, registrar: registrar)
    }
}
