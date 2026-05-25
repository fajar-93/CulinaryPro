plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Plugin Firebase
}

android {
    // Sesuaikan namespace dengan nama paket aplikasi Anda jika berbeda
    namespace = "com.example.aplikasi_resep" 
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // PENTING: Ubah ini sesuai dengan nama paket/Application ID Anda yang terdaftar di Firebase
        applicationId = "com.example.aplikasi_resep"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Cukup ini saja, tidak perlu classpath atau bom manual karena sudah diatur Flutter
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

flutter {
    source = "../.."
}


