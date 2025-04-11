plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Google services plugin
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin
}

android {
    namespace = "com.example.flutter_prueba_mil"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.flutter_prueba_mil"
        minSdk = 30
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Configuración de firma para debug
        }
    }
}

flutter {
    source = "../.."
}

// Dependencias en Kotlin DSL (cambiando a la sintaxis correcta)
dependencies {
    implementation("com.google.android.gms:play-services-auth:20.0.6")
}
