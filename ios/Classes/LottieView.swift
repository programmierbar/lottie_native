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
            let value = props["value"] as! String
            let keyPath = props["keyPath"] as! String
            let type = props["type"] as! String
            setValue(type: type, value: value, keyPath: keyPath)
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

    func setValue(type: String, value: String, keyPath: String) {
        switch type {
        case "LOTColorValue":
            let hexColor = UInt32(value.dropFirst(2), radix: 16)
            let value = ColorValueProvider(hexToColor(hex8: hexColor!))
            let keypath = AnimationKeypath(keypath: keyPath + ".Color")
            animationView.setValueProvider(value, keypath: keypath)
        case "LOTOpacityValue":
            let number = NumberFormatter().number(from: value)!
            let value = FloatValueProvider(CGFloat(truncating: number) * 100)
            let keypath = AnimationKeypath(keypath: keyPath + ".Opacity")
            animationView.setValueProvider(value, keypath: keypath)
        default:
            break
        }
    }
}
