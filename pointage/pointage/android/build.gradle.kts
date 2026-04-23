


import org.gradle.api.tasks.Delete
import java.io.FileInputStream
import java.util.Properties

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // ✅ Mise à jour du plugin Android Gradle
        classpath("com.android.tools.build:gradle:8.9.1")

        // Google services
      //  classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Changement du dossier de build pour tous les modules
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// ✅ Forcer l'évaluation de :app avant les autres
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Résolution des conflits de dépendances Google Play Services
subprojects {
    configurations.all {
        resolutionStrategy {

            force("com.google.android.gms:play-services-basement:18.4.0")
            force("com.google.android.gms:play-services-tasks:18.0.2")
        }
    }
}

// ✅ Tâche clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

/*
import org.gradle.api.tasks.Delete
import java.io.FileInputStream
import java.util.Properties

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // ✅ Mise à jour du plugin Android Gradle
        classpath("com.android.tools.build:gradle:8.9.1")

        // Google services
     //   classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Changement du dossier de build pour tous les modules
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// ✅ Forcer l'évaluation de :app avant les autres
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Résolution des conflits de dépendances Google Play Services
subprojects {
    configurations.all {
        resolutionStrategy {
            //force("com.google.android.gms:play-services-ads:23.0.0")
            force("com.google.android.gms:play-services-basement:18.4.0")
            force("com.google.android.gms:play-services-tasks:18.0.2")
        }
    }
}

// ✅ Tâche clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
*/