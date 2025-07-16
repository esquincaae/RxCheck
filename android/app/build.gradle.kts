plugins {
    id("com.android.application")
    id("kotlin-android") // Puedes mantenerlo, aunque 'kotlin("android")' ya lo implica
    kotlin("android")
    // El Flutter Gradle Plugin debe aplicarse después de los plugins de Android y Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

// --- Importaciones de clases de Java (¡Esto es CLAVE!) ---
import java.io.FileInputStream
        import java.util.Properties
// --------------------------------------------------------

// Carga las propiedades de tu archivo key.properties
val keystorePropertiesFile = rootProject.file("key.properties")
// Ahora podemos usar 'Properties()' y 'FileInputStream()' directamente
// porque ya están importados arriba.
val keystoreProperties = Properties().apply {
    load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.CodeCraft.RxCheck" // ¡Asegúrate de que este sea el namespace correcto de tu app!
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.CodeCraft.RxCheck" // ¡Asegúrate de que este sea el ID de aplicación correcto de tu app!
        minSdk = 23
        targetSdk = 35
        versionCode = flutter.versionCode.toInt() // Asegúrate de convertir a Int
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Usa .getProperty() para un acceso más seguro a los valores String de Properties
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file(keystoreProperties.getProperty("storeFile")) // 'file()' es importante aquí
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Opcional: Habilitar ProGuard/R8 para reducir el tamaño de la app
            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
