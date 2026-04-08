## 0.2.0

- **FEAT**: Add runtime animation replacement methods (`setAnimationFromURL`, `setAnimationFromAsset`, `setAnimationFromJson`) on `LottieController`
- **PERF**: Android: Enable async updates and simplify platform view for better performance
- **FIX**: Replace deprecated `Color.value` with `toARGB32()`
- **FIX**: Android: Move failure listener to init for all animation sources
- **FIX**: Validate dynamic value updates on iOS and Android to avoid crashes on malformed color or opacity inputs
- **FIX**: Android: Align `setAnimationProgress` and `setProgressWithFrame` behavior with iOS
- **BUILD**: Upgrade Kotlin to 2.1.0, AGP to 8.7.0, Java to 17
- **BUILD**: Upgrade lottie-android 6.3.0 → 6.7.1
- **BUILD**: Upgrade lottie-ios ~> 4.4.3 → ~> 4.6.0
- **BUILD**: Upgrade appcompat 1.6.1 → 1.7.1

## 0.1.4

 - **FEAT**: Provide animation state changes as stream to lottie controller

## 0.1.3

 - **FEAT**: Update lottie ios dependency to 4.4.3. ([ff28c637](https://github.com/lotum/lottie_native/commit/ff28c63772b4b720538f8b37adf4374de76ae959))

## 0.1.2

 - **FEAT**: Update lottie android dependency to 6.3.0. ([53dc3eac](https://github.com/lotum/lottie_native/commit/53dc3eac984082b7a1d35d4356776a53d78282cf))
 - **FEAT**: Update lottie ios dependency to 4.4.1. ([1ef3b598](https://github.com/lotum/lottie_native/commit/1ef3b598117d9f335e3a3bf585c56886b9f44b0f))

## 0.1.1

 - **FEAT**: upgrade iOS Lottie SDK to 4.3.4. ([3306e209](https://github.com/lotum/lottie_native/commit/3306e20919f85465362be6d5c25d050796c0f0da))
 - **FEAT**: upgrade Android lottie SDK to 6.2.0. ([d447cd25](https://github.com/lotum/lottie_native/commit/d447cd2526353ff4c20e808b739769cf9665af51))
 - **FEAT**: upgrade to AGP 8.2. ([cd87dfac](https://github.com/lotum/lottie_native/commit/cd87dfac78a5daf6c8ca046c0900450719c791f4))

## 0.1.0+1

 - **FIX**: complete all method channel calls from native platform ([#4](https://github.com/lotum/lottie_native/issues/4)). ([fc8f1cc2](https://github.com/lotum/lottie_native/commit/fc8f1cc2a9be5e162b37c2726d424eebd0ca0f13))

## 0.1.0

- Initial release
