---
title: "Convenient Detekt Conventions"
description: "A guide to maximizing convenience while setting up Detekt in your multi-module Kotlin projects using
precompiled Gradle scripts."
date: 2025-04-09
category: 'programming'
tags: [ 'kotlin', 'tutorial' ]
---

Detekt is an amazing static analysis tool for Kotlin that easily integrates within your workflows.
However, since it needs to be flexible enough to support as many use-cases as possible, it's not as straightforward to
decide how to go about it.
Here's how I choose to configure Detekt for my Kotlin projects.

<!--more-->

## Project Scope

First, let's agree on what we want to achieve in this guide.
This will be a good fit for you if:

- You have a multi-module Kotlin project.
- You are comfortable tinkering with Gradle.
- You always want to run the advanced Detekt rules.
- You care more about simplicity and utility over collecting metrics themselves or having merged reports.

## Gradle Setup

We will be using Gradle's
[build logic / precompiled script plugins](https://docs.gradle.org/current/samples/sample_convention_plugins.html)
because it's a really cool way to share logic between multiple subprojects, and you're missing out if not using it.
There are plenty of resources to learn how it works and how you can set up your project to use it, so for the purposes
of this guide, I will assume you know the bare essentials and focus on explaining the Detekt-related stuff.

Let's assume the following project structure:

```text
my-project
├── gradle
│   ├── build-logic
│   ├── wrapper
│   └── libs.versions.toml
├── module-A
├── module-B
├── module-C
└── settings.gradle.kts
```

The `build-logic` is our shared config, and it can be placed anywhere, and imported via relative path from the
top-level `settings.gradle.kts` file.
Sometimes I like putting it under `gradle` directory because it's always there and to me, it means
"here's where we put all build-related stuff" and also reduces the amount of top-level directories.
This is entirely subjective!

Let's declare our dependencies:

```toml
# In gradle/libs.versions.toml:
[versions]
detekt = "1.23.8"

[libraries]
detekt-formatting = { module = "io.gitlab.arturbosch.detekt:detekt-formatting", version.ref = "detekt" }
gradlePlugin-detekt = { module = "io.gitlab.arturbosch.detekt:detekt-gradle-plugin", version.ref = "detekt" }

[bundles]
buildLogicGradlePlugins = [
    "gradlePlugin-detekt",
]
```

Notice I added the gradle plugins as Maven notation, and not plugin IDs.
This is because we need them as dependencies in order to work with the precompiled script plugins!
I also made a bundle for them, so we can import them in bulk.

**NOTE:** If you decided to add the `build-logic` under the `gradle` directory, you should
[manually import the version catalog](https://docs.gradle.org/current/userguide/version_catalogs.html#sec:importing-catalog-from-file),
since it won't be in the expected relative position to the project, just something to keep in mind.

Then, let's load the plugins:

```kotlin
// In gradle/build-logic/build.gradle.kts
plugins {
    `kotlin-dsl`
}

dependencies {
    implementation(libs.bundles.buildLogicGradlePlugins)
}
```

**Pro Tip: How to enable the use of version catalogs from within the precompiled build scripts:**

Unfortunately, at the time of writing, we need to do a bit of a workaround so we can use the `libs` accessor in our
precompiled scripts[^1].
Fortunately, the workaround is pretty simple, in the above `dependencies` block, also add:

```kotlin
implementation(files(libs.javaClass.superclass.protectionDomain.codeSource.location))
```

And create this util somewhere in the `build-logic/src/main/kotlin` package:

```kotlin
package util

internal val Project.libs: LibrariesForLibs
    get() =
        (rootProject.project as ExtensionAware)
            .extensions
            .getByName("libs")
            .let { it as LibrariesForLibs }
```

Not pretty, but it is what it is for the time being.
That's enough of that, we can now focus on the Detekt plugin!

## Detekt Convention Plugin

Let's declare a barebones conventions plugin:

```kotlin
// In gradle/build-logic/src/main/kotlin/conventions/detekt.gradle.kts
package conventions

import util.libs

plugins {
    id("io.gitlab.arturbosch.detekt")
}

dependencies {
    detektPlugins(libs.detekt.formatting)
}
```

Kotlin configs are not declared here, those belong in a separate convention!
We can now go to all the subprojects we want Detekt to analyze, and apply the convention:

```kotlin
// In module-(A|B|C)/build.gradle.kts
plugins {
    id("conventions.detekt")
}
```

After a Gradle Sync, the Detekt tasks should be available in all the subprojects, but it's not very useful just yet.
Let's configure it further!

### The Configuration Convention

This is where I stray from the usual tutorials on Detekt.
In essence, Detekt uses two files:

- A configuration file where you enable, disable, or tweak the rule set.
- A baseline file where you check in smells as technical debt.

Thing is, I want them out of my way, and also neatly organised, and with a high degree of flexibility.
And since it's a convention plugin, all projects will use the same logic.
Remember earlier when I said my philosophy for the `gradle` directory is to keep files related to the build?
This is _exactly_ that, so my proposed file structure is this:

```text
gradle/detekt
├── baseline
├── config
│   ├── module-A.yml
│   ├── module-B.yml
│   └── module-C.yml
└── detekt.yml
```

The `detekt.yml` is the common configuration.
This is where you'd put your rules, and would apply to all projects.
Then, in the `config` directory, you have one YML file per subproject, where you may provide overrides for that module
only.
A good example would be enforcing package structure:

```yaml
# In gradle/detekt/config/module-A.yml
naming:
  InvalidPackageDeclaration:
    active: true
    rootPackage: 'example.project.module.a'
    requireRootInDeclaration: true
```

The `baseline` is where we will dump existing code smells or assumed debt.
_(More on this later)_.

Now that we have the mental model of how we want it to work, we should tell Gradle too.

```kotlin
// In detekt.gradle.kts convention plugin file
detekt {
    buildUponDefaultConfig = true
    parallel = true
    autoCorrect = false

    baseline = file("$rootDir/gradle/detekt/baseline/${project.name}.xml")
    config.from(
        files(
            "$rootDir/gradle/detekt/detekt.yml",
            "$rootDir/gradle/detekt/config/${project.name}.yml",
        )
    )
}
```

In our example, we have a flat structure _(i.e.: all subprojects are a single level nest from the root)_ so this works.
If you have a more complicated structure, you may want to either replace the `${project.name}` to some util that
converts the `Project` instance to its path to ensure no collisions, or think of a different path convention to mine,
and store only the common `detekt.yml` in the `rootDir` and keep everything else project-local.
Again, purely subjective!

### Disable Config Generation

Detekt has a QoL task that generates a sample config for you, which is great, but I prefer to do that manually since I'm
using a custom structure.
We can disable the task to ensure we don't modify anything even if running it by accident _(unfortunately Gradle won't
let us unregister it completely)_:

```kotlin
// In detekt.gradle.kts convention plugin file
tasks.withType<DetektGenerateConfigTask>().configureEach {
    enabled = false
}
```

### Sync With Kotlin

You will probably have a separate convention for applying Kotlin settings.
You should also tell Detekt to use the same JVM target.
For this, I recommend extracting that as a util property, which you can reference from both:

```kotlin
// In detekt.gradle.kts convention plugin file
import util.CompileOptions

tasks.withType<Detekt>().configureEach {
    jvmTarget = CompileOptions.Kotlin.jvmTarget.target
}
tasks.withType<DetektBaseline>().configureEach {
    jvmTarget = CompileOptions.Kotlin.jvmTarget.target
}
```

### Local vs. CI

Detekt will, by default, hook itself up to the `:check` task, which may fail your build if any code smells are detected.
This is great for CI, but might be annoying for local development.
Another thing Detekt does by default is enable all the reporting formats.
Some are not useful for humans, we could ignore them locally.

We can fix these by again leveraging Gradle letting us run arbitrary Kotlin code for our configuration!

You can declare a simple util that checks if we are running in CI:

```kotlin
package util

/** Whether the build is run on a CI worker. */
val onCI: Boolean get() = System.getenv("CI").toBoolean()
```

Then, back to our convention:

```kotlin
// In detekt.gradle.kts convention plugin file
detekt {
    // ...
    ignoreFailures = !onCI
}

tasks.withType<Detekt>().configureEach {
    reports {
        html.required = !onCI
        md.required = !onCI
        sarif.required = true
        txt.required = false
        xml.required = onCI
    }
}
```

Now, Detekt will still run and generate reports, but will not fail the local build, while still failing the PR if we
accidentally forget to fix all outstanding issues.

Similarly, you may choose what reports you want where.
For me, Sarif is my favorite because it integrates nicely with IntelliJ, and I disable HTML and MD in CI because I don't
care if my CI reports are human-readable _(those are usually consumed by other tools)_.

### Ignore Generated Files

If you use KSP or any other code generation tools, you might find they are included in the Detekt scans and produce many
false positives.
Since the Detekt task is itself an extension of Gradle's `SourceTask`, we can use Gradle's DSL to exclude them.
I came across this trick on an issue thread[^2].

```kotlin
// In detekt.gradle.kts convention plugin file
tasks.withType<Detekt>().configureEach {
    exclude { it.file.invariantSeparatorsPath.contains("/build/generated/") }
}
tasks.withType<DetektCreateBaselineTask>().configureEach {
    exclude { it.file.invariantSeparatorsPath.contains("/build/generated/") }
}
```

### Enabling Type Resolution

The more advanced _(and more useful)_ rules require using type resolution to work[^3].
The default `detekt` task runs _without_ it, and instead you have many other tasks depending on the platform(s) you are
targeting.
This is especially relevant in Kotlin Multiplatform projects!

This behavior ***might change*** in Detekt 2.0!
But until then, personally I never want to run Detekt without type resolution, and the non-resolution task is the only
one hooked to the `:check` tasks.
What to do then?
Many people suggest making a custom `detektAll` task[^4], but I want to go a step further and make the default `detekt`
task behave like it instead!

```kotlin
// In detekt.gradle.kts convention plugin file
tasks.named<Detekt>("detekt").configure {
    exclude("**")
    dependsOn(tasks.withType<Detekt>().filter { it.name != this.name })
}
tasks.named<DetektCreateBaselineTask>("detektBaseline").configure {
    exclude("**")
    dependsOn(tasks.withType<DetektCreateBaselineTask>().filter { it.name != this.name })
}
```

We use `dependsOn` to tell Gradle it needs to execute the other Detekt tasks.
Here, I choose to depend on all others _(filter out to avoid a circular reference)_, but you may pick and choose, such
as giving them as a whitelist, ignoring the ones ending in `Test`, and so on.
This is, say it together with me: _purely subjective!_

What about that `exclude("**")`?
Well, since the non-type-resolution task is registered by the plugin, we cannot disable or swap it, but we _can_ tell it
to ignore everything, and having no source, there are no files to inspect, meaning no rules will be evaluated, and as
such the non-type-resolution task will become a NOOP, instead simply acting as glue logic to call the other specialized
tasks that it depends on.

By this point, you can run `./gradlew detektBaseline` to generate baseline files according to our conventions.
Note that they will only be created if there are any rule violations.

### All-In-One

For convenience, here's our complete convention:

```kotlin
package conventions

import io.gitlab.arturbosch.detekt.Detekt
import io.gitlab.arturbosch.detekt.DetektCreateBaselineTask
import io.gitlab.arturbosch.detekt.DetektGenerateConfigTask
import util.CompileOptions // The utils are YOUR files in `build-logic` project.
import util.onCI
import util.libs

plugins {
    id("io.gitlab.arturbosch.detekt")
}

dependencies {
    detektPlugins(libs.detekt.formatting)
}

detekt {
    buildUponDefaultConfig = true
    parallel = true
    autoCorrect = false

    ignoreFailures = !onCI

    baseline = file("$rootDir/gradle/detekt/baseline/${project.name}.xml")
    config.from(
        files(
            "$rootDir/gradle/detekt/detekt.yml",
            "$rootDir/gradle/detekt/config/${project.name}.yml",
        )
    )
}

tasks {
    withType<Detekt>().configureEach {
        jvmTarget = CompileOptions.Kotlin.jvmTarget.target

        exclude { it.file.invariantSeparatorsPath.contains("/build/generated/") }

        reports {
            html.required = !onCI
            md.required = !onCI
            sarif.required = true
            txt.required = false
            xml.required = onCI
        }
    }

    withType<DetektCreateBaselineTask>().configureEach {
        jvmTarget = CompileOptions.Kotlin.jvmTarget.target

        exclude { it.file.invariantSeparatorsPath.contains("/build/generated/") }
    }

    withType<DetektGenerateConfigTask>().configureEach {
        enabled = false
    }

    named<Detekt>("detekt").configure {
        exclude("**")
        dependsOn(tasks.withType<Detekt>().filter { it.name != this.name })
    }

    named<DetektCreateBaselineTask>("detektBaseline").configure {
        exclude("**")
        dependsOn(tasks.withType<DetektCreateBaselineTask>().filter { it.name != this.name })
    }
}
```

## Usage

All your configs are conveniently stored in one place, you always know where to find them.

To run, all you need is:

```shell
./gradlew detekt
```

You will find reports, as usual, in the `build/reports/detekt` of every subproject.
If you enabled Sarif reports, double-clicking them should open them in your IDE for very easy navigation.

To update the baseline and mark all smells as debt, simply run the task then commit the XMLs.

```shell
./gradlew detektBaseline
```

Finally, if you wish to do a local sanity check, pretend you're a CI:

```shell
CI=true ./gradlew detekt
```

If you have Gradle caching enabled, you might need to pass the `--rerun-tasks` option if you want to force
re-evaluating the rules without having made any source changes.

That's all there is to it!
Neat, isn't it?

## Conclusion

This takes a bit to set up, and perhaps a few comments to explain, but the end result is really convenient and I quite
like it.
I hope it proves useful when you develop your Kotlin projects, providing support while staying out of the way.

And while Detekt is a great showcase for this, the real takeaway here is embracing Gradle as a build tool, and using its
flexible DSLs to create powerful abstractions for your projects.
I recommend you use a similar approach to configuring most Gradle plugins!

[^1]: https://github.com/gradle/gradle/issues/15383

[^2]: https://github.com/detekt/detekt/issues/5611

[^3]: https://detekt.dev/docs/gettingstarted/type-resolution

[^4]: https://github.com/detekt/detekt/issues/3663
