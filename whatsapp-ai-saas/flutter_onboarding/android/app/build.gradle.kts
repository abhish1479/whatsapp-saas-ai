plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    // 👇 Add this line
    id("com.google.gms.google-services")
}

android {
    namespace = "com.abhi.whatsappai.onboarding"

    // Compile against the newest SDK (required by your plugins)
    compileSdk = 36

    defaultConfig {
        applicationId = "com.abhi.whatsappai.onboarding"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    // Modern toolchain
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            // Keep debug signing for now so `flutter run --release` works
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // If you later hit META-INF merge issues, you can add:
    // packaging {
    //     resources {
    //         excludes += setOf("META-INF/AL2.0", "META-INF/LGPL2.1")
    //     }
    // }
}

flutter {
    source = "../.."
}
