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
    var animationView: LottieAnimationView?
    var eventSink: FlutterEventSink?
    
    init(_ frame: CGRect, viewId: Int64, args: Any?, registrar: FlutterPluginRegistrar) {
        self.frame = frame
        self.viewId = viewId
        self.registrar = registrar

        super.init()

        create(args: args)
    }

    func create(args: Any?) {
        let channel = FlutterMethodChannel(
            name: "de.lotum/lottie_native_" + String(viewId),
            binaryMessenger: registrar.messenger()
        )
        let handler: FlutterMethodCallHandler = methodCall
        channel.setMethodCallHandler(handler)

        let testChannel = FlutterEventChannel(
            name: "de.lotum/lottie_native_stream_play_finished_" + String(viewId),
            binaryMessenger: registrar.messenger()
        )
        testChannel.setStreamHandler(self)

        if let argsDict = args as? [String: Any] {
            let url = argsDict["url"] as? String ?? nil
            let filePath = argsDict["filePath"] as? String ?? nil
            let json = argsDict["json"] as? String ?? nil
            let loop = argsDict["loop"] as? Bool ?? false
            let reverse = argsDict["reverse"] as? Bool ?? false
            let autoPlay = argsDict["autoPlay"] as? Bool ?? false
            
            if url != nil {
                animationView = LottieAnimationView(
                    url: URL(string: url!)!,
                    imageProvider: nil,
                    closure: { error in
                        if autoPlay && error == nil {
                            self.animationView!.play(completion: self.completionBlock)
                        }
                    },
                    animationCache: nil
                )
            } else if filePath != nil {
                print("THIS IS THE ID " + String(viewId) + " " + filePath!)
                let key = registrar.lookupKey(forAsset: filePath!)
                let path = Bundle.main.path(forResource: key, ofType: nil)
                animationView = LottieAnimationView(filePath: path!)
            } else if json != nil {
                let data = Data(json!.utf8)
                let animation = try? JSONDecoder().decode(LottieAnimation.self, from: data)
                animationView = LottieAnimationView(animation: animation)
            }

            animationView!.contentMode = .scaleAspectFit

            if loop {
                animationView!.loopMode = LottieLoopMode.loop
            }
            if reverse {
                animationView!.loopMode = LottieLoopMode.autoReverse
            }
            if autoPlay {
                animationView!.play(completion: completionBlock)
            }
        }
    }

    public func view() -> UIView {
        return animationView!
    }

    public func completionBlock(animationFinished: Bool) {
        if let eventSink = eventSink {
            eventSink(animationFinished)
        }
    }

    func methodCall(call: FlutterMethodCall, result: FlutterResult) {
        var props = [String: Any]()

        if let args = call.arguments as? [String: Any] {
            props = args
        }

        if call.method == "play" {
            animationView?.currentProgress = 0
            animationView?.play(completion: completionBlock)
        }

        if call.method == "resume" {
            animationView?.play(completion: completionBlock)
        }

        if call.method == "playWithProgress" {
            let toProgress = props["toProgress"] as! CGFloat
            if let fromProgress = props["fromProgress"] as? CGFloat {
                animationView?.play(fromProgress: fromProgress, toProgress: toProgress,
                                    completion: completionBlock)
            } else {
                animationView?.play(toProgress: toProgress,
                                    completion: completionBlock)
            }
        }

        if call.method == "playWithFrames" {
            let toFrame = props["toFrame"] as! NSNumber
            if let fromFrame = props["fromFrame"] as? NSNumber {
                animationView?.play(
                    fromFrame: fromFrame as? AnimationFrameTime,
                    toFrame: AnimationFrameTime(truncating: toFrame),
                    completion: completionBlock
                )
            } else {
                animationView?.play(
                    toFrame: AnimationFrameTime(truncating: toFrame),
                    completion: completionBlock
                )
            }
        }

        if call.method == "stop" {
            animationView?.stop()
        }

        if call.method == "pause" {
            animationView?.pause()
        }

        if call.method == "setAnimationSpeed" {
            animationView?.animationSpeed = props["speed"] as! CGFloat
        }

        if call.method == "setLoopAnimation" {
            animationView?.loopMode = props["loop"] as! LottieLoopMode
        }

        if call.method == "setAutoReverseAnimation" {
            animationView?.loopMode = props["reverse"] as! LottieLoopMode
        }

        if call.method == "setAnimationProgress" {
            animationView?.currentProgress = props["progress"] as! CGFloat
        }

        if call.method == "setProgressWithFrame" {
            let frame = props["frame"] as! NSNumber
            animationView?.currentProgress = AnimationProgressTime(truncating: frame)
//         self.animationView?.setProgressWithFrame(frame)
        }

        if call.method == "isAnimationPlaying" {
            let isAnimationPlaying = animationView?.isAnimationPlaying
            result(isAnimationPlaying)
        }

        if call.method == "getAnimationDuration" {
//         let animationDuration = self.animationView?.animationDuration
//        let animationDuration = self.animationView?.frame
//         result(1000)
        }

        if call.method == "getAnimationProgress" {
            let currentProgress = animationView?.currentProgress
            result(currentProgress)
        }

        if call.method == "getAnimationSpeed" {
            let animationSpeed = animationView?.animationSpeed
            result(animationSpeed)
        }

        if call.method == "getLoopAnimation" {
            let loopMode = animationView?.loopMode
            result(loopMode)
        }

        if call.method == "getAutoReverseAnimation" {
            let loopMode = animationView?.loopMode
            result(loopMode)
        }

        if call.method == "setValue" {
            let value = props["value"] as! String
            let keyPath = props["keyPath"] as! String
            if let type = props["type"] as? String {
                setValue(type: type, value: value, keyPath: keyPath)
            }
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
            animationView!.setValueProvider(value, keypath: keypath)
        case "LOTOpacityValue":
            let number = NumberFormatter().number(from: value)!
            let value = FloatValueProvider(CGFloat(truncating: number) * 100)
            let keypath = AnimationKeypath(keypath: keyPath + ".Opacity")
            animationView!.setValueProvider(value, keypath: keypath)
        default:
            break
        }
    }
}
