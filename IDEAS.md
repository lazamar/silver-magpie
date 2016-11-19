# BroadcastMsg

When building submodules we have to tackle the question of inter communication.

In an ideal world, these modules wouldn't need to communicate, we would just pass some parameters to them and they would do their thing, without the top modules ever needing to worry about what is going on. But in reality things don't work like that.

You may, for example, have routes in your program, and the route should just worry about itself. But if the route needs to allow the user to navigate to a different route, the top module will need to be informed when the user decide to do that. Then we need some parent-child module communication.

One way to do it is to have the top module accept some global messages, and the submodules submit those when needed. For that, however, the top module needs to know about the submodule and the submodule needs to know about the top module. We would really not like that to be the case. This way they are too coupled.

// CODE EXAMPLE

We can instead just have the submodule have a `BroadcastMsg` option type, where it says all the messages it could possibly emmit. This way the submodule doesn't need to know anything about the parent, we cut half of the coupling.

// CODE EXAMPLE

If you stop to think about it, this way we are making our submodule more of a pure function because it will not need to know about anything other than its parameters.
