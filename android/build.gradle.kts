allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Algunos plugins (p. ej. file_picker 8.1.2) traen su propio módulo Android
// con compileSdk fijo en una versión vieja (34), pero arrastran
// flutter_plugin_android_lifecycle 2.0.35, que exige compileSdk 36+. En vez
// de esperar a que cada plugin publique un fix, forzamos compileSdk 36 en
// todos los subproyectos (solo sube el SDK contra el que compila, no afecta
// minSdk/targetSdk de la app).
subprojects {
    afterEvaluate {
        extensions.findByType(com.android.build.api.dsl.CommonExtension::class.java)
            ?.let { ext ->
                if ((ext.compileSdk ?: 0) < 36) {
                    ext.compileSdk = 36
                }
            }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
