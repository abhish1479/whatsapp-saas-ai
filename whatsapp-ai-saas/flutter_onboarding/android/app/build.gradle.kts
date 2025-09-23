plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // modern Kotlin plugin id
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.abhi.whatsappai.onboarding"

    // Use explicit SDKs (works well with Flutter 3.35+ and modern plugins)
    compileSdk = 34

    defaultConfig {
        applicationId = "com.abhi.whatsappai.onboarding"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    // Java/Kotlin 17 to satisfy recent Android Gradle Plugin & plugins like file_picker v8+
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    // Optional: keep if you rely on NDK (otherwise you can remove)
    // ndkVersion = "26.1.10909125"

    buildTypes {
        release {
            // For quick testing; replace with your own signing when publishing
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
        }
        debug { /* defaults */ }
    }

    // (Optional) If you hit META-INF merge issues, uncomment:
    // packaging {
    //     resources {
    //         excludes += setOf("META-INF/AL2.0", "META-INF/LGPL2.1")
    //     }
    // }
}

flutter {
    source = "../.."
}
