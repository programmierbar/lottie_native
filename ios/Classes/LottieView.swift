#if os(iOS)
    import Flutter
#else
    import FlutterMacOS
#endif
import Lottie

public class LottieView: NSObject, FlutterPlatformView, FlutterStreamHandler {
    let frame: CGRect
    let viewId: Int64
    let registrar: FlutterPluginRegistrar
    let animationView: LottieAnimationView
    var eventSink: FlutterEventSink?

    init(_ frame: CGRect, viewId: Int64, args: Any?, registrar: FlutterPluginRegistrar) {
        self.frame = frame
        self.viewId = viewId
        self.registrar = registrar
        self.animationView = LottieAnimationView(frame: frame)
        super.init()
        create(args: args)
    }

    func create(args: Any?) {
        let channel = FlutterMethodChannel(
            name: "de.lotum/lottie_native_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        channel.setMethodCallHandler(methodCall)

        let eventChannel = FlutterEventChannel(
            name: "de.lotum/lottie_native_state_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(self)

        if let argsDict = args as? [String: Any] {
            let url = argsDict["url"] as? String ?? nil
            let filePath = argsDict["filePath"] as? String ?? nil
            let json = argsDict["json"] as? String ?? nil
            let loop = argsDict["loop"] as? Bool ?? false
            let reverse = argsDict["reverse"] as? Bool ?? false
            let autoPlay = argsDict["autoPlay"] as? Bool ?? false

            animationView.contentMode = .scaleAspectFit

            if loop {
                animationView.loopMode = LottieLoopMode.loop
            }
            if reverse {
                animationView.loopMode = LottieLoopMode.autoReverse
            }

            if url != nil {
                LottieAnimation.loadedFrom(
                    url: URL(string: url!)!,
                    closure: { animation in
                        self.animationView.animation = animation
                        if autoPlay && animation != nil {
                            self.playAnimation()
                        }
                    },
                    animationCache: nil
                )
            } else if filePath != nil {
                let key = registrar.lookupKey(forAsset: filePath!)
                let path = Bundle.main.path(forResource: key, ofType: nil)
                animationView.animation = LottieAnimation.filepath(path!)
            } else if json != nil {
                animationView.animation = try? LottieAnimation.from(data: Data(json!.utf8))
            }

            if autoPlay {
                playAnimation()
            }
        }
        
        animationView.animationLoaded = { animationView, animation in
            self.updateState(state: "loaded")
        }
    }

    public func view() -> UIView {
        return animationView
    }
    
    private func playAnimation() {
        animationView.play(completion: animationFinished)
        updateState(state: "started")
    }

    private func animationFinished(finished: Bool) {
        updateState(state: finished ? "finished" : "cancelled")
    }
    
    private func updateState(state: String) {
        if let eventSink = eventSink {
            eventSink(state)
        }
    }

    func methodCall(call: FlutterMethodCall, result: FlutterResult) {
        let props = call.arguments as? [String: Any] ?? [String: Any]()

        switch call.method {
        case "play":
            animationView.currentProgress = 0
            playAnimation()
            result(nil)
            break
        case "resume":
            playAnimation()
            result(nil)
            break
        case "playWithProgress":
            let toProgress = props["toProgress"] as! CGFloat
            if let fromProgress = props["fromProgress"] as? CGFloat {
                animationView.play(fromProgress: fromProgress, toProgress: toProgress,
                                    completion: animationFinished)
            } else {
                animationView.play(toProgress: toProgress,
                                    completion: animationFinished)
            }
            result(nil)
            updateState(state: "started")
            break
        case "playWithFrames":
            let toFrame = props["toFrame"] as! NSNumber
            if let fromFrame = props["fromFrame"] as? NSNumber {
                animationView.play(
                    fromFrame: fromFrame as? AnimationFrameTime,
                    toFrame: AnimationFrameTime(truncating: toFrame),
                    completion: animationFinished
                )
            } else {
                animationView.play(
                    toFrame: AnimationFrameTime(truncating: toFrame),
                    completion: animationFinished
                )
            }
            result(nil)
            updateState(state: "started")
            break
        case "stop":
            animationView.stop()
            result(nil)
            break
        case "pause":
            animationView.pause()
            result(nil)
            break
        case "setAnimationSpeed":
            animationView.animationSpeed = props["speed"] as! CGFloat
            result(nil)
            break
        case "setLoopAnimation":
            animationView.loopMode = props["loop"] as! LottieLoopMode
            result(nil)
            break
        case "setAutoReverseAnimation":
            animationView.loopMode = props["reverse"] as! LottieLoopMode
            result(nil)
            break
        case "setAnimationProgress":
            animationView.currentProgress = props["progress"] as! CGFloat
            result(nil)
            break
        case "setProgressWithFrame":
            let frame = props["frame"] as! NSNumber
            animationView.currentProgress = AnimationProgressTime(truncating: frame)
            result(nil)
            break
        case "isAnimationPlaying":
            result(animationView.isAnimationPlaying)
        case "getAnimationDuration":
            result(animationView.animation!.duration)
            break
        case "getAnimationProgress":
            result(animationView.currentProgress)
            break
        case "getAnimationSpeed":
            result(animationView.animationSpeed)
            break
        case "getLoopAnimation":
            result(animationView.loopMode)
            break
        case "getAutoReverseAnimation":
            result(animationView.loopMode)
            break
        case "setValue":
            guard
                let value = props["value"] as? String,
                let keyPath = props["keyPath"] as? String,
                let type = props["type"] as? String
            else {
                result(
                    FlutterError(
                        code: "invalid_arguments",
                        message: "setValue expects string arguments for value, type, and keyPath.",
                        details: props
                    )
                )
                return
            }

            if let error = setValue(type: type, value: value, keyPath: keyPath) {
                result(error)
            } else {
                result(nil)
            }
            break
        case "setAnimationFromUrl":
            animationView.stop()
            animationView.currentProgress = 0
            let url = props["url"] as! String
            LottieAnimation.loadedFrom(url: URL(string: url)!, closure: { animation in
                self.animationView.animation = animation
                self.updateState(state: "loaded")
            }, animationCache: nil)
            result(nil)
            break
        case "setAnimationFromAsset":
            animationView.stop()
            animationView.currentProgress = 0
            let filePath = props["filePath"] as! String
            let key = registrar.lookupKey(forAsset: filePath)
            let path = Bundle.main.path(forResource: key, ofType: nil)
            animationView.animation = LottieAnimation.filepath(path!)
            updateState(state: "loaded")
            result(nil)
            break
        case "setAnimationFromJson":
            animationView.stop()
            animationView.currentProgress = 0
            let json = props["json"] as! String
            animationView.animation = try? LottieAnimation.from(data: Data(json.utf8))
            updateState(state: "loaded")
            result(nil)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }

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

    func setValue(type: String, value: String, keyPath: String) -> FlutterError? {
        switch type {
        case "LOTColorValue":
            guard let hexColor = parseColorValue(value) else {
                return FlutterError(
                    code: "invalid_color_value",
                    message: "Expected a color value formatted like 0xff0000ff or #ff0000ff.",
                    details: value
                )
            }

            let valueProvider = ColorValueProvider(hexToColor(hex8: hexColor))
            let keypath = AnimationKeypath(keypath: keyPath + ".Color")
            animationView.setValueProvider(valueProvider, keypath: keypath)
        case "LOTOpacityValue":
            guard let opacity = Double(value) else {
                return FlutterError(
                    code: "invalid_opacity_value",
                    message: "Expected opacity as a decimal string, for example 0.1.",
                    details: value
                )
            }

            let valueProvider = FloatValueProvider(CGFloat(opacity) * 100)
            let keypath = AnimationKeypath(keypath: keyPath + ".Opacity")
            animationView.setValueProvider(valueProvider, keypath: keypath)
        default:
            return FlutterError(
                code: "unsupported_value_type",
                message: "Unsupported value type: \(type)",
                details: type
            )
        }

        return nil
    }

    private func parseColorValue(_ value: String) -> UInt32? {
        if value.hasPrefix("0x") || value.hasPrefix("0X") {
            return UInt32(value.dropFirst(2), radix: 16)
        }

        if value.hasPrefix("#") {
            return UInt32(value.dropFirst(), radix: 16)
        }

        return UInt32(value, radix: 16)
    }
}
