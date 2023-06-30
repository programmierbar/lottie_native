package de.lotum.lottie_native

import android.animation.Animator
import android.animation.Animator.AnimatorListener
import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.ImageView
import com.airbnb.lottie.LottieAnimationView
import com.airbnb.lottie.LottieDrawable
import com.airbnb.lottie.LottieProperty
import com.airbnb.lottie.model.KeyPath
import com.airbnb.lottie.value.LottieValueCallback
import io.flutter.FlutterInjector
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import kotlin.math.roundToInt

class LottieView internal constructor(
        context: Context,
        id: Int,
        args: Any,
        binaryMessenger: BinaryMessenger,
) : PlatformView, MethodCallHandler, EventChannel.StreamHandler, AnimatorListener {
    private val animationView: LottieAnimationView = LottieAnimationView(context)
    private val channel = MethodChannel(binaryMessenger, "de.lotum/lottie_native_$id")
    private val onPlaybackFinishedEventChannel = EventChannel(binaryMessenger, "de.lotum/lottie_native_stream_play_finished_$id")
    private var onPlaybackFinishedEventSink: EventSink? = null
    private var maxFrame = 0f

    init {
        animationView.scaleType = ImageView.ScaleType.CENTER_INSIDE

        channel.setMethodCallHandler(this)
        onPlaybackFinishedEventChannel.setStreamHandler(this)

        @Suppress("UNCHECKED_CAST", "NAME_SHADOWING") val args = args as Map<String, Any?>

        if (args["url"] != null) {
            animationView.setFailureListener {
                Log.e("lottie_native", "Failed to set animation from URL.", it)
            }
            animationView.setAnimationFromUrl(args["url"] as String)
        }
        if (args["filePath"] != null) {
            val loader = FlutterInjector.instance().flutterLoader()
            val key = loader.getLookupKeyForAsset(args["filePath"] as String)
            animationView.setAnimation(key)
        }
        if (args["json"] != null) {
            animationView.setAnimationFromJson(args["json"] as String, null)
        }
        val loop: Boolean = if (args["loop"] != null) args["loop"] as Boolean else false
        val reverse: Boolean = if (args["reverse"] != null) args["reverse"] as Boolean else false
        val autoPlay: Boolean = if (args["autoPlay"] != null) args["autoPlay"] as Boolean else false
        animationView.repeatCount = if (loop) -1 else 0
        maxFrame = animationView.maxFrame
        if (reverse) {
            animationView.repeatMode = LottieDrawable.REVERSE
        } else {
            animationView.repeatMode = LottieDrawable.RESTART
        }
        if (autoPlay) {
            animationView.playAnimation()
        }
        animationView.addAnimatorListener(this)
    }

    override fun getView(): View {
        return animationView
    }

    override fun dispose() {
        animationView.cancelAnimation()
        channel.setMethodCallHandler(null)
        onPlaybackFinishedEventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        @Suppress("UNCHECKED_CAST") val args = (call.arguments as Map<String, Any?>?) ?: mapOf()
        when (call.method) {
            "play" -> {
                animationView.setMinAndMaxFrame(0, maxFrame.toInt())
                animationView.setMinAndMaxProgress(0f, 1f)
                animationView.playAnimation()
                result.success(null)
            }
            "resume" -> {
                animationView.resumeAnimation()
                result.success(null)
            }
            "playWithProgress" -> {
                if (args["fromProgress"] != null) {
                    val fromProgress = (args["fromProgress"] as Double).toFloat()
                    animationView.setMinProgress(fromProgress)
                }
                val toProgress = (args["toProgress"] as Double).toFloat()
                animationView.setMaxProgress(toProgress)
                animationView.playAnimation()
                result.success(null)
            }
            "playWithFrames" -> {
                if (args["fromFrame"] != null) {
                    val fromFrame = args["fromFrame"] as Int
                    animationView.setMinFrame(fromFrame)
                }
                val toFrame = args["toFrame"] as Int
                animationView.setMaxFrame(toFrame)
                animationView.playAnimation()
                result.success(null)
            }
            "stop" -> {
                animationView.cancelAnimation()
                animationView.progress = 0.0f
                val mode = animationView.repeatMode
                animationView.repeatMode = LottieDrawable.RESTART
                animationView.repeatMode = mode
                result.success(null)
            }
            "pause" -> {
                animationView.pauseAnimation()
                result.success(null)
            }
            "setAnimationSpeed" -> {
                animationView.speed = (args["speed"] as Double).toFloat()
                result.success(null)
            }
            "setLoopAnimation" -> {
                val loop = if (args["loop"] != null) args["loop"] as Boolean else false
                animationView.repeatCount = if (loop) -1 else 0
                result.success(null)
            }
            "setAutoReverseAnimation" -> {
                val reverse = args["reverse"] as Boolean
                if (reverse) {
                    animationView.repeatMode = LottieDrawable.REVERSE
                } else {
                    animationView.repeatMode = LottieDrawable.RESTART
                }
                result.success(null)
            }
            "setAnimationProgress" -> {
                animationView.progress = (args["progress"] as Double).toFloat()
                result.success(null)
            }
            "setProgressWithFrame" -> {
                animationView.frame = args["progress"] as Int
                result.success(null)
            }
            "isAnimationPlaying" -> result.success(animationView.isAnimating)
            "getAnimationDuration" -> result.success(animationView.duration.toDouble())
            "getAnimationProgress" -> result.success(animationView.progress.toDouble())
            "getAnimationSpeed" -> result.success(animationView.speed.toDouble())
            "getLoopAnimation" -> result.success(animationView.repeatCount == LottieDrawable.INFINITE)
            "getAutoReverseAnimation" -> result.success(animationView.repeatMode == LottieDrawable.REVERSE)
            "setValue" -> {
                val value = args["value"] as String
                val keyPath = args["keyPath"] as String
                val type = args["type"] as String
                setValue(type, value, keyPath)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(o: Any?, eventSink: EventSink) {
        onPlaybackFinishedEventSink = eventSink
    }

    override fun onCancel(o: Any?) {}

    override fun onAnimationStart(animation: Animator) {}

    override fun onAnimationEnd(animation: Animator) {
        onPlaybackFinishedEventSink?.success(true)
    }

    override fun onAnimationCancel(animation: Animator) {
        onPlaybackFinishedEventSink?.success(false)
    }

    override fun onAnimationRepeat(animation: Animator) {}

    private fun setValue(type: String, value: String, keyPath: String) {
        val keyPathSegments = keyPath.split("\\.".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()
        val parsedKeyPath = KeyPath(*keyPathSegments)
        when (type) {
            "LOTColorValue" -> {
                val callbackValue = LottieValueCallback(convertColor(value))
                animationView.addValueCallback(parsedKeyPath, LottieProperty.COLOR, callbackValue)
            }
            "LOTOpacityValue" -> {
                val opacity = value.toFloat() * 100
                val callbackValue = LottieValueCallback(opacity.roundToInt())
                animationView.addValueCallback(parsedKeyPath, LottieProperty.OPACITY, callbackValue)
            }
        }
    }

    private fun convertColor(value: String): Int {
        val alpha = value.substring(2,4).toInt(16)
        val red = value.substring(4, 6).toInt(16)
        val green = value.substring(6, 8).toInt(16)
        val blue = value.substring(8, 10).toInt(16)
        return Color.argb(alpha, red, green, blue)
    }
}