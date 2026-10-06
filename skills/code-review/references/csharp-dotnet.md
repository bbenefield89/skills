# C# and .NET rules

Inspect `.csproj`, solution files, `global.json`, `.editorconfig`, and relevant package configuration when present.
Identify the target frameworks, language version, nullable settings, and application framework.
Apply framework-specific advice only where that framework is present.
Combine this profile with an engine profile when C# operates inside an engine.

## CS1. Asynchronous operations

Trace task completion, exceptions, cancellation, and caller expectations.
Inspect `async void` outside event-handler contracts for lost completion or failure handling.
Inspect unobserved tasks and synchronous waits on asynchronous work.
Establish the execution context before claiming a deadlock. UI blocking and thread-pool starvation have different causes.
Accept required asynchronous event handlers with appropriate failure handling.
Accept background tasks when a defined owner observes failures and controls their lifetime.
Judge `ConfigureAwait` and cancellation requirements from the application or library contract.

## CS2. Resource and service ownership

Trace ownership of `IDisposable`, `IAsyncDisposable`, streams, handles, and subscriptions.
Check cleanup on successful, exceptional, and cancelled paths.
Distinguish caller-owned resources from resources borrowed from another owner.
In dependency-injection code, check service lifetimes and container ownership.
Do not recommend disposing container-owned or shared services without evidence that the caller owns them.

## CS3. Nullability and type contracts

Check nullable annotations, guards, casts, and null-forgiving operators against real inputs and external boundaries.
Inspect default values and deserialization paths where invariants can fail.
Respect the configured nullable mode. Enabling a mode is a recommendation unless repository policy requires it.
Use concrete null or type failures to support defects.

## CS4. Collections and framework behavior

Inspect deferred enumeration, repeated queries, mutation during enumeration, and avoidable materialization where relevant.
Check ordering and equality against the data contract.
For database-backed queries, establish provider behavior before claiming execution cost or translation failure.
Check UI thread affinity, request scope, and engine object access only for the detected framework.
Keep naming and formatting findings tied to repository rules. Consolidate relevant compiler or analyzer findings rather than repeating them.

Example: A library save method returns `async void`, while its caller must await persistence before closing.
Report the broken completion contract and recommend an awaitable return type.
An asynchronous UI event handler is a valid exception to the return-type preference.

## Official references

Use documentation applicable to the detected target and framework.

- [Asynchronous programming scenarios](https://learn.microsoft.com/en-us/dotnet/csharp/asynchronous-programming/async-scenarios): Awaiting and asynchronous operation choices.
- [Async return types](https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/async/async-return-types): Task returns and event-handler exceptions.
- [Implement a Dispose method](https://learn.microsoft.com/en-us/dotnet/standard/garbage-collection/implementing-dispose): Resource ownership and cleanup.
- [Nullable reference types](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/null-safety/nullable-reference-types): Static analysis and nullability contracts.
