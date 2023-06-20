#if os(iOS)
    import Flutter
#else
    import FlutterMacOS
#endif
import Lottie

public class LottieNativePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let viewFactory = LottieViewFactory(registrar: registrar)
        registrar.register(viewFactory, withId: "de.lotum/lottie_native")
    }
}
