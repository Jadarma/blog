---
title: 'Be Cool About Type Safety'
description: "Avoid common mistakes and gotchas in programming by leveraging the power of the type system, and use 
the same features to simplify domain modelling and make coding a pleasure."
date: 2024-03-18
category: 'programming'
tags: [ 'kotlin', 'javascript' ]
---

I very often praise Kotlin for its powerful and flexible type system, and bash on JavaScript for its lack thereof.
But I want to show that, while it is personal preference _(even if a popular opinion)_, there are actual merits to
having a good type system.
While Kotlin and JS are used as examples here, these points can be extrapolated to most languages.

<!--more-->

### You Don't Program Alone!

You probably have heard the concept of the
"[Four Eyes Principle](https://www.openriskmanual.org/wiki/Four_Eyes_Principle)" which the "Agile" people love to
reduce it down to just "always having at least one other person approve on your PRs".
Which, don't get me wrong, is a good idea, you should always double-check your work!

The good thing about _(modern)_ programming is that most of the time your hand is being held, and nowadays there are
many more pairs of "eyes" involved.
Here's a simplified list of what goes on in the typical software development lifecycle, but you can imagine it more
like a stack.
Fortunately, we humans are at the top, but if we start removing layers, those responsibilities are reassigned to us,
and our slice gets bigger.

- **Humans** - A pair of human eyes: pair programming, code reviewers, etc.
- **CI / Tests** - A pair of computer eyes that automatically check for regressions.
- **Linters / Static Analyzers** - A pair of computer eyes that check for anti-patterns and code smells.
- **Type Checker** - A pair of computer eyes that check the correctness of your code _(except logic errors)_.
- **Compiler** - A pair of computer eyes that check that your code can be understood by machines _(if you use a
  scripting language, replace with the interpreter)_.

The logic here is simple:
you remove CI or tests, you need to manually test the whole product before deploying;
you remove linters, you will waste time peeling your eyes for misaligned braces;
you remove type checkers, you have to stare into the code's soul, but no matter how close you look, you can't verify
types in an untyped language from the web view of that PR;
you remove compilers, well… you start writing assembly.
You get the point.

Our goal is to delegate as much of the menial work to the computers _(no, not AI!)_, and let developers worry about the
thing they're building: the domain layer.
Next we will look at how having a good type system helps achieve just that.

### Enforced Types Could've Prevented That

First off, let's examine some common mistakes we can make that almost never happen when using a strongly typed language.

#### You Didn't Parse The Right Type

What goes wrong in this code snippet?

```javascript
// The `.env` file contains:
// BUCKETS_PER_REQUEST=50
const buckets = process.env.BUCKETS_PER_REQUEST
for (let i = 1; i < buckets + 1; i++) {
  console.log(`Mock work for bucket ${i}`)
}
```

The environment variables are always strings, so this will evaluate to `'50' + 1 = '501'` instead of `51` because of
type coercion.
_Oops!_
We forgot to wrap that in a `Number.parseInt` call.

Enforced types would've prevented that.

#### You Returned The Wrong Type

What about this one?

```javascript
async function getEmailOf(userId) {
  const result = await fetch('/users/${userId}')
  return result.json().email
}
```

We do await the `fetch` call, but we forgot to also await the decoding of the payload, which is also an asynchronous
operation.
The caller of this function probably expects a string back, but I _promise_ you they'll be in for a nice surprise!

Enforced types would've prevented that.

#### You Didn't Refactor Everything

Does this code look good to you?

```javascript
const sendOnboardingEmailTo = async (user) =>
  await MailService.getInstance().enqueue(
    address = user.email,
    greeting = `Dear ${user.firstName ?? `user`},`,
    templateName = `simpleOnboardingTemplate`,
  )
```

It sure would look to me, until we both remember that a feature request we rushed through last week said we should store
both work and personal emails for our users, so now just `.email` is `undefined`.
Dang regressions!

Enforced types would've prevented that.

#### You Trusted NPM

If your `package.json` looks like this:

```json
{
  "name": "myFragileJavaScriptApp",
  "version": "1.2.3",
  "dependencies": {
    "what-is-semver-lmao": "^4.2.0"
  }
}
```

You have one more problem to deal with: you need to trust the good practices of other developers.
NPM in particular has its fair share of such stories, but this isn't the article for it.
Here, I will just point out the problem with unpinned dependencies and developers not properly applying
[semantic versioning](https://semver.org/).

In short, unless the major number changes, you would expect that minor updates add new functionality without breaking
existing ones, and patch versions just fix bugs, again without breaking the public API.
Except not all libraries are created equal, and in practice semver is more what we would call "guidelines" than actual
rules.
And in many cases it's attributed to mistakes rather than carelessness or malice, so don't be quick to anger.

In any case, you will play russian roulette every time you update your lock file.
If we were in a typesafe language, no worries!
Your build would just fail to compile, and notify you of the linkage error.
But here?
_Hah!_
Good luck figuring out which of your thousand transitive dependencies made a boo-boo that could potentially break prod
in the sneakiest of edge-cases!

Enforced types would've prevented that.

### Every Language Has Types

There is no such thing as a typeless language.
They are required for computers to make any sense of it.
You have two choices:

- **Statically Typed**:
  Types are a first-class language feature, variables can only hold values of the same type, checked at compile time.
  _(Kotlin, Rust, Go, Haskell, etc.)_
- **Dynamically Typed**:
  Types are an implementation detail, variables change types depending on their values, checked at runtime.
  _(JavaScript, Python, Groovy, PHP, etc. )_

For your consideration, go ahead and open the browser's devtools and run:

```javascript
console.dir({foo: "bar"})
```

You will see that magical prototype value, that describes the object in agonizing detail.
We have a constructor, we know it's name, how many arguments, and so on.
JavaScript does have types - they are needed for the interpreter - it's just that they're not very useful for humans
too.

### The Land of Compromises

> I get your points, but these are all minor errors you quickly learn to avoid.
> Given that a good programmer wouldn't suffer from these, do types offer any other bonuses?
> Is it really worth switching to a statically typed language if this already suits my needs?
>
> — People who like JS

I don't like dealing in absolutes, and I understand the hesitation in jumping ship.
Well, I think it's still worth it, but for the undecided friends, let me show you how you can compromise now and make
up your mind later.

#### Pseudo-Typing With JSDoc

The need for types is closely coupled with the need for good documentation.
And the tooling around JS lets your IDE try to help.
Consider using JSDoc comments whenever possible:

```javascript
/**
 * @typedef  {object}  DieConfig
 * @property {!number} sides       - The number of sides.
 * @property {?number} luckyNumber - Has a 15% chance to skip the roll
 *                                   and return this number, if given.
 */

/**
 * Rolls a die and returns the result.
 *
 * @param   {!DieConfig} config - Params of the die used to roll.
 * @returns {!number}           - A randomly picked side of the die.
 */
function rollDie(config) {
  if (config.luckyDigit && Math.random() < 0.15) return config.luckyNumber
  // Warning! ☝️ Not a valid prop, did you mean `luckyNumber`?
  const rollResult = Math.floor(Math.random() * (config.sides ?? 6)) + 1
  // Warning! Useless null coalescence, sides is never null.  ☝️
  return rollResult >= 10
  // Warning! ☝️ Wrong type returned! Got boolean but number was expected.
}
```

You will get warnings in your IDE because the implementation either breaks the contract, or performs a redundant check.
Still better than finding out at runtime, but while this has the _types_, it doesn't have the _safety_.

The nullability and the type annotations are nothing but comments, which sometimes lie.
If you make a mistake defining them, tooling can't help you.
There are also _no runtime checks_ for those.
I can ignore everything and still pass whatever value I want as a parameter.

It's better than _nothing_, but I still cannot label it as _something_.

#### C'mon! Mention TypeScript Already!

Yes, it's best if we get that elephant out of the room.
My thoughts on TypeScript are a mixed bag:

- Yes, you have types in code rather than comments.
- Yes, you have better linters, and stricter checks.
- Yes, most JS-only libs provide TS definitions.

But I must also consider that:

- No, the types aren't necessarily useful, for example, the
  [enums are terrible](https://www.youtube.com/watch?v=0fTdCSH_QEU).
- No, they aren't types, they're suggestions. You will see plenty of JS libs with `.d.ts` files containing so many
  union pipes you might as well round it down to `any`.
- No, there isn't any runtime, all constructs are ~~compile~~ transpile time hints.

For the last part, I learned the hard way the first time I defined types for my DTOs, and then found out that if I want
to also verify the incoming data conforms with the type assigned at runtime, I need to write validators
_(thank the gods for libraries like [`zod`](https://github.com/colinhacks/zod))_.

I still do think I would prefer TypeScript to vanilla JavaScript, but to me, it only mitigates the issues I
have with JavaScript rather than solving them, all the while introducing other pain points of its own.

I've come to appreciate all the things I realised I took for granted in compiled, strongly-typed languages when I
constantly shot myself in the foot in JS-land.

### Types Are Useful

#### Documentation And Navigation

I won't dwell on this topic too much, since alternative ways of achieving the same is possible and already implemented
for dynamic languages as well, but types have a much greater affinity with documentation.

Apart from the comments that are left to humans, the name of properties, return values, generic bounds and many more
are derived from your code and will never be out of sync.
It's also much easier for IDEs to find the declaration site and take you there if you need to explore, and the
intellisense suggestions, along with the inline documentation popups on hover make it enjoyable for me to work with
code, even libraries I never interacted before, without alt-tabbing to check the docs where it isn't necessary.

#### Null Safety

You cannot ask about the benefits of a language like Kotlin without someone mentioning the
[million billion trillion](https://youtu.be/HZmafy_v8g8?t=10) dollar mistake: `null`.

There's nothing more annoying that to debug segfaults and trace out huge call stacks to figure out where that elusive
[null pointer you were dereferencing](https://www.youtube.com/watch?v=bLHL75H_VEM) came from.

We hate nulls!
They're tricky, sometimes hard to spot, and ruin our day by making us clutter everything in ifs and elses.
Kotlin avoids NPEs while keeping `null` as a language feature _(for interop reasons as well)_ by baking nullability
into the type system.

Non-null types help us make compile time guarantees to avoid this, which means less defensive programming
when calling and using return values of a function, without sacrificing error handling.

And, when null values are expected, the compiler forces you to take that into account, but this time in a concise and
expressive manner, unlike something like Java's `Optional<T>`.

```kotlin
var foo: String? = "bar" // OK
val baz: String = null   // Won't Compile

val len1 = foo.length       // Won't Compile
val len2 = foo?.length      // Compiles, infers len2 to be an Int?
val len3 = foo?.length ?: 0 // Compiles, infers len3 to be an Int.

fun isAdult(id: String, users: Map<String, User>): Boolean {
    val user: User = users[id] ?: return false // Clean early returns. 
    return user.age >= 18
}

val rootUser: User = getUser(0)!! // We know it must exist, skip the check.
                                  // But make it ugly so we avoid it!

val maybeInt: Int? = userInput as? Int // Cafe casts for those that live dangerously.
```

#### Disambiguation

Types are a useful tool when trying to solve disambiguation.
For example, let us look at this simple implementation of a function similar to `setTimeout`.
Nothing fancy, we just set a delay, pass the lambda, and we're done!

```kotlin
suspend inline fun <T> delayedComputation(time: Long, block: () -> T): T {
    delay(time)
    return block()
}

suspend fun main() {
    delayedComputation(2) {
        println("Hello, delayed world!")
    }
}
```

Wait, that ran a bit too quick.
Oh, _duh_!
The `time` parameter actually represents milliseconds, and I passed my value in seconds.
Silly me.
Let's refactor to make it clearer.

```kotlin
suspend inline fun <T> delayedComputation(timeMillis: Long, block: () -> T): T {
    delay(timeMillis)
    return block()
}

suspend fun main() {
    delayedComputation(2) { // 👈 I still forgot to fix this!
        println("Hello, delayed world!")
    }
}
```

However, this still can be accidentally overlooked, especially when working with variables and not manually written
literals like this.
The compiler won't complain, all it wants is a number value, and that's what it gets.

Types to the rescue!
What we actually want to pass as an argument is the duration to wait.
Kotlin has this in the standard library, but let's pretend it doesn't.

```kotlin
value class Duration(val milliseconds: Long) { /* ... */ }

val Int.seconds: Duration get() = Duration(this * 1000L)

suspend inline fun <T> delayedComputation(time: Duration, block: () -> T): T {
    delay(time) // Delay function is duration aware but you could also adapt it:
    // delay(time.milliseconds)
    return block()
}

suspend fun main() {
    delayedComputation(2.seconds) { // 👈 Clear and expressive!
        println("Hello, delayed world!")
    }
}
```

Here, `Duration` is always internally represented by milliseconds, but because it's a type, we are forced to instantiate
it, which allows us to do the conversion and validation of our units.
This also allows us to have much more natural declarations on our call sites.
Better yet, since this is a `value` class, it has no runtime overhead.
Once compiled, it gets unboxed and the `Long` underneath is all that remains.

Did somebody mutter _zero-cost abstractions_?

Note that this is different from a type alias, which cannot achieve the same outcomes.
Here's an example of how ***not*** to use type aliases:

```kotlin
typealias Username = String
typealias Password = String

// Note: Obviously example only, don't do this IRL.
suspend fun validateLogin(username: Username, password: Password): Boolean {
    val user = db.findUser(username) ?: return false
    return user.hashedPassword == hash(password)
}

suspend fun foo() {
    validateLogin("john.doe", "hunter2") // Good
    validateLogin("hunter2", "john.doe") // Oops!
}
```

As you can see, you can still pass the wrong things in the wrong places, if they share the same underlying type.
If these have instead been `value` classes, it would result in a compilation error.

#### Refactoring

Requirements and their implementations always change in a software project.
We should be prepared to refactor.
Here is a simple, rare, but useful example of such a case.

Because our APIs need to support JavaScript clients, you cannot use `Long` anymore, large values might get corrupted
because of precision loss.
So, since you need to switch to stringify IDs anyway, your team decides it's a good opportunity to upgrade to GUID /
UUIDs internally as well!

Good news is that in our server code, we don't really do much with IDs apart from passing them around between the
client and the database.
Bad news is we have a lot of entities, a lot of unit tests, we must be extra careful to make sure we covered everything;
a simple search and replace is not going to cut it.

```kotlin
class User(val id: Long, /* ... */)
class Item(val id: Long, /* ... */)
class Post(val id: Long, /* ... */)
class Comment(val id: Long, /* ... */)
class Review(val id: Long, /* ... */)
class Report(val id: Long, /* ... */)
// Imagine more classes scattered across the codebase.
// Imagine the diffs...
```

Lucky for us, the previous code snippet was just a nightmare.
We planned ahead, and all our mission-critical classes are using type abstractions!

```kotlin
value class ID(val value: Long) { /* ... */ }

class User(val id: ID, /* ... */)
class Item(val id: ID, /* ... */)
class Post(val id: ID, /* ... */)
class Comment(val id: ID, /* ... */)
class Review(val id: ID, /* ... */)
class Report(val id: ID, /* ... */)
```

The database team already did the hard work of migrating the database, now we just need to adapt the code on our side.

```diff
- value class ID(val value: Long) { /* ... */ }
+ value class ID(val value: UUID) { /* ... */ }
```

Oversimplification sure, but any other things we might've forgotten would break the build.

**NOTE:** Value classes aren't required here.
The same would be achievable with something like a `abstract class BaseEntity(val id:Long)` but I'm
generally opposed to inheritance and using ORMs.

#### Domain Modelling

Up until now we have discussed some simple cases, like wrapping values to make sure we don't call functions with
wrong or missing arguments, to help us refactor, and whatever else.
But this isn't even our final form!
The true power comes in the form of domain modelling!

We humans actually like types, and define them all the time, even outside of programming.
We have lots of standards in place, and since in the last century we're starting to move away from paper into the
digital world, we need to make programs that can understand and work with those types.
A very common example would be date and time, where we format them using precise rules, can check if a string value
represents a valid date or not just by _"looking"_ at it, and they are so widely used within our programs that any
decent language provides a first-party implementation of those types in its standard library.

There are many other types that only apply in narrow fields that are nonetheless useful, but don't exist in libraries.
Therefore, we must implement them ourselves.
That is, in fact, our job description, so let's explore an example together!

Let us imagine we have to write code for the Romanian government _(shudder)_.
Every citizen gets issued a national ID _(literally 1984)_, on which the most important piece of information is our
equivalent of a
personal identity number.
It's a 13-digit string that encodes a lot of information, it isn't random.
More explanation on the rules and a playground can be found [here](https://cnpgenerator.ro/).

The structure is: `SYYMMDDJJNNNNC`, where:

- `S` is a digit that encodes your sex, century of birth, and whether you are a resident or not.
- `YY` are the last two digits of the year of birth.
- `MM` is the month of birth.
- `DD` is the day of birth.
- `LL` is a code which determines the location (county) of birth.
- `NNN` is a numeric counter unique per sex and county, resets each day, increases after every
  registered birth.
- `C` is a digit used for error correction.

So, if someone gives me the following number: `1020304056789`, I would know that:

- The person is a male romanian citizen.
- He was born on `1902-03-04`.
- He was the 678th boy born on that day in Bihor county.
- He's **a liar** because the ECC code should've been an `8`, not a `9`!

Let's translate that into a type-safe domain model!

```kotlin
enum class Sex { Male, Female }
enum class County(internal val code: Int) { Alba(1), Arad(2), Arges(3); /* ... */ }

interface NatalityInfo {
    val sex: Sex // yes, please!
    val dateOfBirth: LocalDate
    val countyOfBirth: County
    val isForeigner: Boolean
}
```

Okay, so this is the useful information we can have, how can we associate it with the PIN?

```kotlin
@Serializable
data class PIN(
    override val sex: Sex,
    override val dateOfBirth: LocalDate,
    override val countyOfBirth: County,
    override val isForeigner: Boolean,
    val counter: Int,
) : NatalityInfo {
    override fun toString() = encodeToString(this)

    companion object {
        fun decodeFromString(input: String): PIN =
            TODO("Your parsing and validation rules here.")
        fun encodeToString(pin: PIN): String =
            TODO("Your encoding rules here.")
    }
}
```

Notice that the `counter` is only specific to the PIN, and we also don't even keep the error correction code at the
domain level, that value is automatically checked and generated during serialization.

Speaking of serialization, this neatly brings us in to the dreaded `I/O`!
As any functional programmer will tell you, your worst enemy is the `I/O`.
Theoretically, within your compiled universe is a perfect utopia where all functions are pure and there are no side
effects.
But we write code for the real world, where we need to interact with it _(directly or otherwise)_, so such a fantasy
cannot be achievable.
The next best thing is to establish a clear boundary, that is well-enforced and heavily validated.

That is to say, we should always do validation, and we should do it as soon as possible.
We've seen in previous examples that you can perform validations when instantiating types, guaranteeing that invalid
instances cannot be constructed.

As an example, whenever we would read or write to the outside world values of our domain types, we should handle the
construction of domain types _(and therefore, their validation)_ as quickly as possible.
The simplest way to do it in our case:

```kotlin
@Serializer(forClass = PIN::class)
object PinSerializer : KSerializer<PIN> {
    override val descriptor =
        PrimitiveSerialDescriptor(PIN::class.qualifiedName!!, STRING)

    override fun deserialize(decoder: Decoder): PIN =
        PIN.decodeFromString(decoder.decodeString())

    override fun serialize(encoder: Encoder, value: PIN): Unit =
        encoder.encodeString(PIN.encodeToString(value))
}
```

So now we have the *guarantee* that we will never-ever-ever have an instance of `PIN` that doesn't contain valid data.
**But WAIT! There's more!**

A well-defined domain also helps you write better code!

Our PIN is a property that a person has, but it also provides the same property the person itself shares:
the `NatalityInfo` interface. As such, we can make use of Kotlin's interface delegation to allow us to skip the
middle-man and get the relevant properties directly from our `Citizen` type, increasing readability.

```kotlin
data class Citizen(
    val pin: PIN,
    val email: Email,
    val phone: Phone?,
) : NatalityInfo by pin

val citizen = people.random()
// Instead of:
citizen.pin.dateOfBirth
// You can now do:
citizen.dateOfBirth

```

We can also much more easily create extensions:

```kotlin
fun Citizen.isEligibleToVote(atTime: LocalDate): Boolean =
    time.yearsBetween(dateOfBirth) >= 18
```

Since we have these high-level concepts, we can write concise and expressive code.
Look how easy it is to write custom filtering logic based on the abstractions made earlier.

```kotlin
fun Iterable<Citizen>.filterEligibleForNewGovernmentProgramStuff(now: LocalDate) =
    this.filterNot { it.isForeigner }
        .filter { it.sex == Female }
        .filter { it.countyOfBirth == Cluj }
        .filter { it.isEligibleToVode(now) }
```

And of course, you can achieve similar things in a loosely-typed language, but you won't have the compile-time safety.

#### Domain Modelling 2: DSL-ish Boogaloo

Another great advantage of types is that it makes DSLs _(Domain Specific Languages)_ really shine.
You have finer control over what gets exposed and receive compiler feedback as always.
But the main point of having DSLs is another one entirely: declarative versus imperative code.

You can write DSLs in dynamically typed languages too, but having types makes them safer and easier to work with.
As an example I will give you the Gradle DSL, which used to be just Groovy, but has seen more and more adoption with
Kotlin DSL instead.

```kotlin
plugins {
    kotlin("jvm")
}

repositories {
    mavenCentral()
}

tasks.withType<KotlinCompile>().configureEach {
    jvmTarget = JavaVersion.JAVA_21.toString()
}
```

Another great mention is [kotlinx.html](https://github.com/Kotlin/kotlinx.html), which allows you to use a DLS to
effectively turn Kotlin into a type-safe, first-party HTML templating engine.

### Don't Overdo It

I've been hyping up types _(and for very good reasons)_, but I should also issue a warning that you do not overdo it.
Everything is good in small doses:

- Having sync meetings is useful; doing Scrum is not.
- Writing tests is important; TDD is a waste of time.
- Domain modelling is helpful; everything as an explicit type is overkill.

Please find the balance between useful abstractions and writing types for the sake of it.
Use them to make writing code easier, but if you find yourself battling the type checker, or having hundreds of imports
of custom types, maybe that's a hint that you should step back and re-evaluate your design decisions.

My advice: start small, focus on the critical path, and test it well.
See if you get familiar to this approach, and that it gives you _(and your team)_ a return on investment when
developing.

### Summing Up

To sum up what we've learned today: types are extremely useful, and many languages boast about having powerful type
systems for these reasons.

Types are awesome because they:

- Make exploring unfamiliar code easier.
- Save you from trivial errors and oversights.
- Reduce the cognitive load while writing code as well as reviewing it.
- Provide useful abstractions.
- Facilitate data validation.
- Improve error handling.

When utilized well, they help us across all categories of tasks.
So the next time someone asks you about types, tell them to
[be cool about tyyyyype sayfteh](https://youtu.be/D9XBoYah8gY?t=26)!
