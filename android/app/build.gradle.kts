plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin must be applied last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.project.finalyearproject.garbage_detection_android_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // REQUIRED for core library desugaring
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8

        // ✅ Enable desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Must match Java version
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.project.finalyearproject.garbage_detection_android_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug signing for now
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Core Android KTX
    implementation("androidx.core:core-ktx:1.12.0")

    // ✅ Core Library Desugaring dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
