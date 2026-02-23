plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // 👈 ضيف السطر ده هنا
}


android {
    namespace = "com.example.nabd_app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        // تم التعديل هنا لتتوافق مع Kotlin (أصبحت 11 بدلاً من 1.8)
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    defaultConfig {
    applicationId = "com.example.nabd_app"
    minSdk = 26 // ممتاز عشان مكتبة Health والفايربيز
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    multiDexEnabled = true // 👈 ضيف السطر ده هنا ضرورى جداً
  }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}