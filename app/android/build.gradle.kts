val supportedJdkRange = JavaVersion.VERSION_17..JavaVersion.VERSION_21
if (JavaVersion.current() !in supportedJdkRange) {
    throw GradleException(
        """
        |This project builds with JDK 17-21 - found ${JavaVersion.current()}.
        |
        |A JDK newer than that (e.g. one bundled with a freshly installed Android Studio)
        |can be ahead of what this project's pinned Gradle/AGP version supports, and
        |Gradle's own failure for that case is a bare, useless version number with no
        |other detail.
        |
        |Fix:
        |  brew install openjdk@17
        |  flutter config --jdk-dir="${'$'}(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home"
        |
        |See app/README.md, "Android flavor setup" section, for details.
        """.trimMargin()
    )
}

allprojects {
    repositories {
        google()
        mavenCentral()
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
