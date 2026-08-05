plugins {
    id("com.android.application")
    // ❌ ya no se aplica kotlin-android: AGP 9 trae Kotlin integrado ("built-in Kotlin")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mikido.torneo_app"
    // file_picker arrastra flutter_plugin_android_lifecycle, que exige
    // compileSdk 36+; flutter.compileSdkVersion todavía resuelve a 34.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.mikido.torneo_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// ✅ Configuración de Kotlin fuera del bloque android {}, en el nuevo DSL de AGP 9
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}