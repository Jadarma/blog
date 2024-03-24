---
title: 'Parallel Integration Tests With Ktor'
description: "An example of how to achieve highly concurrent integration tests with Ktor, Postgres, and Test Containers."
date: 2024-03-24
category: 'programming'
tags: [ 'kotlin', 'ktor', 'tutorial' ]
---

Backend unit tests tend to be tedious to write, difficult to maintain, and costly to execute, but it doesn't have to be
that way.
Here's how I leverage the power of Kotlin to make writing integration tests for Ktor backends a breeze, while also
keeping them _🔥 blazingly fast 🚀_.

<!--more-->

### A Bit Of Backstory

Like many others, I started my backend journey with [Spring Boot](https://spring.io/projects/spring-boot).
It's a cool project, it's enterprise-ready, loved and hated by countless devs.
It suffers from a lot of legacy and black magic annotation processing, but it has made great progress in recent 
years, so this is _not_ a hit piece against Spring, although I will show why I think Ktor is a better fit if you start a
greenfield project.

One of my many gripes with Spring is the way that it is configured and glued together by annotations, which do
work quite well when you write your code, but have the potential to fail catastrophically when you want to write tests.
Well, not all tests, but _parallel_ tests, because I like to write a lot of tests, and I want them to run fast.

Spring introduced support for
[parallel test execution](https://docs.spring.io/spring-framework/reference/testing/testcontext-framework/parallel-test-execution.html)
from 5.0 onwards, but with a lot of caveats, mainly as a consequence of the fact that Spring creates its magical
contexts in a global scope you have little control over.

Basically, when you want to use database connections, or spy or mock dependencies, or any other useful thing, you have
to mess with the context, and since parallel tests will mutate the same context, that's a no-no.
Spring has the `@DirtiesContext` annotation which cleans it up for you, but if you use it, you are supposed to have
those tests sequential.
And there are many other ways in which you might want to customize your app's configuration environment for some
particular test, and you guessed it, that's also done via annotations.

I am sure there are ways around it, but they seem hacky to me and I don't want to go down that rabbit hole again.
Feel free to _skill issue_ me on this one, I will graciously accept your rebuttal.

### Project Description & Mission Statement

The following is a contrived, but common scenario.
I will describe the project, what our aim is, and how we can achieve it.
It is not a one-size-fits-all solution, as you will soon be able to tell, but if your project resembles this one,
I'm sure you will find it useful.

#### The Tech Stack

- [Ktor](https://ktor.io/) backend service, which will be deployed as a simple container.
- [PostgreSQL](https://www.postgresql.org/) database, connecting via R2DBC.
- [Koin](https://insert-koin.io/) for dependency injection.
- [TestContainers](https://testcontainers.com/) for provisioning a test database for unit tests.
- [Kotest](https://kotest.io/) for modern and Kotlin-first testing.
- [MockK](https://mockk.io/) for test mocks.

#### Goals

- **No `src/main` hacks**:
  We should have no special cases in the main source-set to handle behavior for when we run tests.
  Tests should be as close to _prod_ as possible.
- **Parallel Execution**:
  We should be able to run as many parallel tests as we want (usually one per CPU core).
- **Context Isolation**:
  We should be able to mess with everything inside Ktor's application without affecting other tests.
- **Data Isolation**:
  We should be able to freely write to our database during tests without affecting other tests.

### Methodology

For the sake of brevity, this won't be a hands-on tutorial, but rather a high-level overview of how I tackled the 
task, and show only the relevant code, or examples of using it.
This way, we focus on the concepts involved.
I will warn you, there is quite a bit of code to these custom utils, it's not something you get out of box, but rather
something bespoke you set up for your own projects, depending on your needs.
That being said, _let me cook_ 👨‍🍳!

#### The 'Hello World' Test

Ktor's [testing documentation](https://ktor.io/docs/testing.html) gives a very good overview on how to set up tests,
and what you can do.
Right out the bat, we have an advantage: Ktor is designed to be an isolated environment, or a basic engine loop with
our modules on top.
It provides the `testApplication` function that neatly configures a Ktor stub and you have very good control over what
goes on.

But here comes the first caveat.
We want to run it from Kotest, but Ktor [clashes](https://github.com/kotest/kotest/issues/3134) with it due to its
use of custom coroutine dispatchers.
Are our plans foiled?
No.
That only affects nested tests, and luckily Kotest allows us to use
[Annotation Spec](https://kotest.io/docs/framework/testing-styles.html#annotation-spec) to bring it more closely to
something like JUnit, which works!

With this in mind, the basic test would be:

```kotlin
class HelloWorldTest : AnnotationSpec() {

    @Test
    suspend fun helloWorldTest() = testApplication {
        client.get("/").apply {
            status shouldBe HttpStatusCode.OK
            bodyAsText() shouldBe "Hello World!"
        }
    }
}
```

#### Configuring DI

Let's configure Koin, so we can make use of dependency injection _(yes, yes, it's a service locator, shush)_.
Nothing could be simpler:

```kotlin
fun Application.configureDI() {
  // The `KoinIsolated` feature will keep everything scoped to this Application. 
  install(KoinIsolated) { 
    slf4jLogger()

    val ktor = module(createdAtStart = true) {
      single { environment }.bind(ApplicationEnvironment::class)
      single { Clock.System }.bind(Clock::class)
    }

    modules(ktor, /* Your other modules here */)
  }

  with(environment.monitor) {
    subscribe(KoinApplicationStarted) { log.info("Koin started.") }
    subscribe(KoinApplicationStopPreparing) { log.info("Koin stopping...") }
    subscribe(KoinApplicationStopped) { log.info("Koin stopped.") }
  }
}
```

Let's keep it simple and use the `Clock` to provide the date header to our responses:

```kotlin
fun Application.configureHTTP() {
    val appClock by inject<Clock>()

    install(DefaultHeaders) {
        header("X-Engine", "Ktor")
        clock = DefaultHeadersConfig.Clock { appClock.now().toEpochMilliseconds() }
    }
}
```

Now let's configure out test DSL to allow us to control this DI.
There are other ways to do it, this might seem hacky at first, but I have my reasons!
What I want to achieve here is let the tests always use the real DI config by default, but allow us to swap some of them
with mocks, or spies.
For this, I made the following helpers:

```kotlin
/**
 * Define a new mock module to be injected into the test [Application].
 * Will override the previously configured modules, useful for mocking.
 */
fun Application.koinMock(mockModule: ModuleDeclaration) {
    koin {
        allowOverride(true)
        modules(module { mockModule() })
    }
}

/**
 * Swap an existing Koin dependency with a new mock, whose behaviour can
 * be defined in the [stub]. Returns the reference to the mock.
 */
context(Application)
inline fun <reified T : Any> Module.swapMockk(
  qualifier: Qualifier? = null,
  noinline stub: T.() -> Unit,
): T {
  @Suppress("UNUSED_VARIABLE") // Ensure we only swap things that exist.
  val original: T = get<T>(qualifier)
  val mock: T = mockk<T> { stub() }
  single<T>(qualifier, createdAtStart = true) { mock }.bind(T::class)
  return mock
}

/**
 * Swap an existing Koin dependency with a new spy of the original, 
 * whose behaviour can be defined in the [stub].
 * Returns the reference to the spy.
 */
context(Application)
inline fun <reified T : Any> Module.swapSpyk(
  qualifier: Qualifier? = null,
  noinline stub: T.() -> Unit,
): T {
  val original: T = get<T>(qualifier)
  val spy: T = spyk<T>(original) { stub() }
  single<T>(qualifier, createdAtStart = true) { spy }.bind(T::class)
  return spy
}
```

This may look like a bit of magic, but it really is quite simple.
We configure Koin to accept overrides, then create a new module where we swap existing bindings with our mocks.
You can do something similar with spies as well.
With this util in place, our tests can look like this:

```kotlin
class HelloWorldTest : AnnotationSpec() {

  @Test
  suspend fun helloWorldTest() = testApplication {
    application {
      koinMock {
        swapMockk<Clock> {
          every { now() } returns Instant.DISTANT_FUTURE
        }
      }
    }
    client.get("/").apply {
      status shouldBe HttpStatusCode.OK
      headers[HttpHeaders.Date] shouldBe "Sat, 01 Jan 100000 00:00:00 GMT"
      bodyAsText() shouldBe "Hello World!"
    }
  }
}
```

We can now safely inject mocks in our tests to specific isolated instances.
Great!

#### Configuring the Database

To provide connection details, the common practice is to supply them to the "container" via environment variables,
and to read them from Ktor via the `ApplicationEnvironment` type you are supplied.
For example, in your `application.yaml` or similar:

```yaml
datasource:
  host: "$DB_HOST"
  port: "$DB_PORT:5432"
  database: "$DB_DATABASE:postgres"
  user: "$DB_USER"
  pass: "$DB_PASS"
  pool: "$DB_ENABLE_POOLING:false"
```

Then, in your application modules, you create the instance, apply your migrations, configure connection factories,
pooling, all the bits and bobs.
I will hide this under pseudocode, imagine `Database` here is an interface you use to manage your connections, run
SQL, apply migrations, and so on.

```kotlin
class DatabaseConfig {

    fun createDatabase(config: ApplicationConfig): Database {
        val connections: ConnectionFactory = builder()
          .option(DRIVER, "postgresql")
          .option(HOST, dbConfig.property("host").getString())
          .option(PORT, dbConfig.property("port").getString().toInt())
          .option(USER, dbConfig.property("user").getString())
          .option(PASSWORD, dbConfig.property("pass").getString())
          .option(DATABASE, dbConfig.property("database").getString())
          .build()
          .let(ConnectionFactories::get)

        return Database(connections, applyMigrations = true)
    }

    val module: Module = module {
      single<Database>(createdAtStart = true) { 
          val datasourceConfig = get<ApplicationEnvironment>().config.config("datasource")
          database(datasourceConfig) 
      }
    }
}
```

We can now use a Docker container to spin up a database for local development, but we cannot use it from tests yet.
This is our next step.

#### Test Containers

What we need is a database test container that spins up for our tests, and cleans itself up afterward.
But starting and stopping so many containers will still eat a few seconds per test.
We can work around that as well!
See, our backend only really connects to _one_ database, but a Postgres container can run _multiple_!
So, instead of using one container per test, we use one container per test suite, but use one _database_ per test.
We can automate all of this as well, using a Kotest extension!

First, let's see what our extension might look like:

```kotlin
/** Used to manage test database instances that are safe for concurrency. */
interface TestDatabaseProvider {

    /**
     * Create a new isolated database within the Postgres test container
     * and return an [ApplicationConfig] containing authentication credentials.
     */
    suspend fun createDatabase(): ApplicationConfig

    /** Drop a test database as best effort. */
    suspend fun cleanupDatabase(name: String)

    /**
     * An extension that handles resource cleanup after a project run if the
     * Postgres test container has been used.
     */
    companion object Extension : AfterProjectListener,
                                 TestDatabaseProvider by PostgresTestContainer {
        override suspend fun afterProject() {
            if(PostgresTestContainer.isRunning) PostgresTestContainer.stop()
        }
    }
}
```

We have a provider, which can create a new database for us every time `createDatabase()` is called.
We can also be nice and do cleanup with the `cleanupDatabase()`, but only as _"best effort"_ policy.
Because either way, the Kotest extension will dispose of the entire container along with our created databases at the
end of the test suite.

Next, let's see what the container code looks like:

```kotlin
object PostgresTestContainer : TestDatabaseProvider, GenericContainer<PostgresTestContainer>(
    DockerImageName.parse("postgres:16.0-alpine")
) {
    private const val DB_HOST = "0.0.0.0"
    private const val DB_PORT = 15432
    private val DB_USER = Uuid.randomUUID().toString()
    private val DB_PASS = Uuid.randomUUID().toString()

    init {
        addEnv("POSTGRES_USER", DB_USER)
        addEnv("POSTGRES_PASSWORD", DB_PASS)
        addFixedExposedPort(DB_PORT, 5432)
        startupAttempts = 1
    }

    @Synchronized
    private fun ensureContainerRunning() {
        if(!isRunning) start()
    }

    // Create a new connection to the default `postgres` database.
    // Also lazy! Starts up the container only upon first connection request.
    private suspend fun connect(): Connection {
        ensureContainerRunning()
        for(attempt in 0..<10) {
            val connection = runCatching { attemptConnection() }.getOrNull()
            if(connection != null) return connection
            delay(500.milliseconds)
        }
        error("Could not connect to the test container.")
    }

    override suspend fun createDatabase(): ApplicationConfig {

        // Create random credentials for the database.
        val tempDb = Uuid.randomUUID().toString()
        val tempUser = tempDb.take(8)
        val tempPass = tempDb.takeLast(12)

        // Yes, I'm using string interpolation.
        // No, I'm not worried about SQL injection with values I control
        // in an ephemeral test database.
        // Just treat it as pseudocode.
        with(connect()) {
            execute("""CREATE DATABASE "$databaseId";""")
            execute("""
                CREATE USER "$tempUser" WITH PASSWORD '$tempPass';
                ALTER DATABASE "$tempDb" OWNER TO "$tempUser";
            """)
            close()
        }

        // Return the config that Ktor can use to connect to this database.
        return MapApplicationConfig(
            "datasource.host" to DB_HOST,
            "datasource.port" to DB_PORT.toString(),
            "datasource.database" to tempDb,
            "datasource.user" to tempUser,
            "datasource.pass" to tempPass,
            "datasource.pool" to "false",
        )
    }

    // Try our best to close it off early.
    override suspend fun cleanupDatabase(name: String) = runCatching {
        val databaseId = Uuid.fromString(name)
        with(connect()) {
            execute("""DROP DATABASE IF EXISTS "$databaseId" WITH (FORCE);""")
            close()
        }
    }
}
```

A bit of a mouthful, but not a lot is going on here.
Basically, our container self-manages the `postgres` database, and every time we request a database, it randomly
creates a new database and a new user, giving us back the config we need to let Ktor know how to connect to it.

#### Integrating The Integrations

Now, in an effort to hide as much boilerplate away, let's create _even more_ helpers.

The next one is optional, but I quite like it, because it allows us to see at a glace which tests do what, and also
programmatically ignoring their execution if we want to, say, only run unit tests without separating them in different
source-sets.

```kotlin
/** Specs annotated by this annotation are marked as integration tests. */
@Tags("IntegrationTest")
@Target(AnnotationTarget.CLASS)
@Retention(AnnotationRetention.RUNTIME)
annotation class IntegrationTestSpec
```

We will slap this on top of all specs which we know spin up a Ktor context.
Next though, we deal with the actual boilerplate.
Whenever we want to make use of our database, we need to create one, get the env, update our test Ktor instance with it,
run our tests, then do cleanup.
Let's extract all that into a helper function!

```kotlin
/**
 * Bootstraps a test application with all configs necessary for an integration test:
 * - Uses the base config in `application.yaml`.
 * - Connects to an isolated test database.
 */
suspend fun integrationTest(block: suspend ApplicationTestBuilder.() -> Unit) {
    val testConfig = listOf(
        ApplicationConfig("application.yaml"),
        createDatabase(),
    ).reduce(ApplicationConfig::mergeWith)

    testApplication {
        environment { config = testConfig }
        block()
    }

    cleanupDatabase(testConfig.property("datasource.database").getString())
}
```

We also would need clients to connect with.
Ktor does provide a default one, but you need to configure features like `ContentNegotiation` on your own.
Let's do that too!

```kotlin
/**
 * A helper around [ApplicationTestBuilder.createClient] that also automatically
 * preconfigures common features.
 */
fun ApplicationTestBuilder.createTestClient(
    block: HttpClientConfig<out HttpClientEngineConfig>.() -> Unit = {},
): HttpClient = createClient {
    install(ContentNegotiation) {
        json()
        cbor()
    }
    block()
}
```

Let's not forget the most crucial part!
Registering our extension and actually enabling parallel tests!

```kotlin
object ProjectConfig : AbstractProjectConfig() {

    override fun extensions(): List<Extension> = listOf(
        TestDatabaseProvider.Extension,
    )

    // I paid for the whole CPU, imma use the whole CPU.
    override val parallelism: Int = Runtime.getRuntime().availableProcessors()
}
```

#### Putting It All Together

With the hard part of configuring all the plumbing and neatly tucking it away in some `util` package of our test suite,
we can now finally reap the rewards!

```kotlin
@IntegrationTestSpec
class HelloWorldTest : AnnotationSpec() {

  @Test
  suspend fun helloWorldTest() = integrationTest {

    val frozenTime = Instant.parse("2023-12-21T12:34:56Z")
    lateinit var callLoggerService: CallLoggerService

    application {
      koinMock {
        swapMockk<Clock> { every { now() } returns frozenTime }
        callLoggerService = swapSpyk<CallLoggerService>()
      }
    }

    val bobsClient = createClient {
      defaultRequest {
        header("X-User-Trust-Me-Bro", "bob")
      }
    }

    withClue("The request did not complete successfully.") {
      bobsClient.get("/").apply {
        status shouldBe HttpStatusCode.OK
        headers[HttpHeaders.Date] shouldBe "Thu, 21 Dec 2023 12:34:56 GMT"
        bodyAsText() shouldBe "Hello, Bob!"
      }
    }

    withClue("The call was not logged to the database.") {
      verify(exactly = 1) {
        callLoggerService.writeLogToDatabase(
          path = "/",
          user = "bob",
          access = frozenTime,
        )
      }
    }
  }
}
```

Now we can do whatever we want inside the `integrationTest` clojure, without any risk of concurrency issues between
tests, as again, each call to this function represents a fully isolated context.
Ktor's, Kotest's, Mockk's, and our DSL all combine neatly together to provide the maximum amount of control with a
reasonable degree of expressiveness, making tests easier to write and maintain.

### How about End-To-End? Why not!

The cool thing about Ktor is that it's also an HTTP client, and a multiplatform one at that.
If you build your backend using Ktor, and need to access that very API from a webclient or mobile app, it would be a
crime not to use Ktor!
You can develop it alongside the backend, and even use it to make your tests more useful!

What I like to do is create some test accounts, for example:

```kotlin
enum class TestUser(val id: Int, val username: String, val password: String) {
    Alice(0, "Alice", "password0"),
    Bob(1, "Bob", "b0bermeister"),
    Eve(2, "Eve", "sourApple1");
}

fun Application.loadTestUsers() {
    val database = get<Database>()
    database.connect {
        for(user in TestUser.entries) {
            // Insert user in DB here, etc.
        }
    }
}
```

Now let's imagine how we would define a typesafe client, let's take the very boring example of a To-Do app.

```kotlin
interface ToDoClient {

    val account: AccountOps
    val reminders: RemindersOps

    interface AccountOps {
        suspend fun logIn(username: String, password: Password)
        suspend fun logout()
        suspend fun deleteAccount()
    }

    interface RemindersOps {
        suspend fun findById(id: Int): Reminder?
        suspend fun deleteById(id: Int): Boolean
        suspend fun create(title: String, details: String): Reminder
    }

    class Config {
        var developmentMode = false
        var baseUrl = ""
        var extendFromClient: HttpClient? = null
    }
}

fun ToDoClient(config: ToDoClient.Config.() -> Unit): ToDoClient {
  val clientConfig = ToDoClient.Config().apply(config)
  return ToDoClientImpl(clientConfig)
}
```

You could, of course, decide on your own DSL, but at the end of the day all you care about is mapping the functionality
of your API into neat functions that abstract away the nitty-gritty details of the underlying HTTP protocol,
serialization, etc.

Now, we can create the concept of an end-to-end test!
Come to think of it, it's still an integration test, but we're not allowed to mess with the server-side.
That means no mocks, no stubbing, only good ol' interactions between network clients.
This sounds very close to an automated Postman-like collection of requests, because it kinda is!

So let us define that in code:

```kotlin
@Tags("EndToEndTest")
@Target(AnnotationTarget.CLASS)
@Retention(AnnotationRetention.RUNTIME)
annotation class EndToEndTestSpec

/**
 * An end-to-end test context that hides away all test builders and provides
 * a clean scope to test client code against a server instance.
 * @param client The test client generated by Ktor to use in this scope.
 */
class EndToEndTestContext(private val client: HttpClient) {

  /**
   * Creates a new instance of [ToDoClient], automatically configured to connect
   * to the running test server.
   *
   * @param boundedUser If provided, permanently logging in as them.
   */
  fun createClient(boundedUser: TestUser? = null): ToDoClient = ToDoClient {
    baseUrl = ""
    developmentMode = true
    extendFromClient = client.config {
        if(boundedUser == null) return@config
        defaultRequest {
            basicAuth(boundedUser.username, boundedUser.password)
        }
    }
  }
}

/**
 * Bootstraps a test application with all configs for an end-to-end test:
 * - Uses the base config in `application.yaml`.
 * - Connects to an isolated test database.
 * - Registers all test users.
 *
 * Tests provided in the [block] are executed against the test application.
 * As this is an end-to-end test, mocking is not allowed, and all interactions
 * with the server should be done via the API client.
 */
suspend fun e2eTest(block: suspend EndToEndTestContext.() -> Unit) {

  val testConfig = listOf(
    ApplicationConfig("application.yaml"),
    createDatabase(),
  ).reduce(ApplicationConfig::mergeWith)

  testApplication {
    environment { config = testConfig }
    application { loadTestUsers() }
    startApplication()
    with(EndToEndTestContext(client)) { block() }
  }

  cleanupDatabase(testConfig.property("datasource.database").getString())
}
```

Very similar to our `integrationTest`, we define a function that takes care of all the bootstrapping.
A difference here is that the lambda we expose has a custom context, that only has access to creating
an API client.
We cannot do anything with the underlying Ktor app, or the database, because we cannot access it from here.

Now that we have all that in place, we can write tests like these:

```kotlin
@EndToEndTestSpec
class ToDoApiTests : AnnotationSpec() {

    @Test
    suspend fun `ToDo Visibility Tests`() = e2eTest {
        val alice = createClient(TestUser.Alice)
        val bob = createClient(TestUser.Bob)

        val alicesReminder = withClue("Users should be able to create reminders.") {
            alice.reminders.create("Grocery List", "Eggs, Bread, Milk, Cheese")
        }

        withClue("Users should be able to fetch their reminder") {
            alice.reminders.findById(alicesReminder.id) shouldBe alicesReminder
        }

        withClue("Users should only be able to work with their own reminders") {
            bob.reminders.findById(alicesReminder).shouldBeNull()
            bob.reminders.deleteById(alicesReminder).shouldBeFalse()
        }

        withClue("Users should be able to delete their reminders") {
            alice.reminders.deleteById(alicesReminder).shouldBeTrue()
            alice.reminders.findById(alicesReminder).shouldBeNull()
        }
    }
}
```

Now _this_ is what proper tests should be like.
We are testing the outcomes we expect from users interacting with our HTTP clients.
If you are unfortunate enough to deal with JIRA, this is how you'd be able to test user stories and protect against
regressions: high-level, low-noise!

### Conclusion

This was a lot of code to go through, but hopefully the end result is worth it.
For me personally, it improved my development workflow substantially.
I can write tests faster, easier, and even use them as scratch-pads while I'm developing, since I have all the
environment set up by them already.
There is no need to call endpoints manually, I can keep my server and client in sync _(feature parity wise)_.

And when it comes to refactoring, I am much less worried about making mistakes, because this results in naturally high
_(and actually useful kind of)_ code coverage, and I can run tests often without interrupting my flow to wait for their
execution.
If you run them all in parallel, you can reduce minutes to mere seconds if you have a reasonably fast CPU with many
cores.

It might not be easy to do similar things for all projects, especially if you have many dependencies, like more
databases, ELK-stacks, third party API clients you need mocked, and so on.
Nonetheless, this works for me, and hopefully it will for you too.

Have `fun`, cheers!
