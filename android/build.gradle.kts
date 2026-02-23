// 1. كتلة الـ buildscript الموحدة (يجب أن تظهر مرة واحدة فقط في بداية الملف)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // محرك خدمات جوجل اللازم لتشغيل الفايربيز في مشروعك
        classpath("com.google.gms:google-services:4.4.0")
    }
}

// 2. إعدادات مسارات البناء المنظمة لمشروع "نبض"
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// 3. تعريف المخازن الموحدة لجميع أجزاء المشروع
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 4. تسجيل مهمة التنظيف البرمجية
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}