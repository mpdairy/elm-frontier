# Elm-Frontier

This library helps you operate more easily at the frontier of Elm
and JavaScript. It provides three main functions:

* `toJson` - automatically encodes an Elm object to a Json string
* `fromJson` - automatically decodes a Json string to an Elm object
* `call` - calls foreign JavaScript function that returns a value to
Elm

Each function returns as an Elm `Task` with a response value or an explanatory
String error.

## Why?

Using `toJson` and `fromJson` provides an easy and non-tedious way to
serialize and desearialize Elm objects. The normal method is to write Json
Encoders or Decoders, but this takes a long time and is prone to
programming errors. `fromJson` and `toJson` automatically convert
without the use of developer-specified encoders/decoders.

Since `toJson`, `fromJson`, and `call` each return a `Task`, they can
be easily chained together with other `Task`s using `Task.andThen`. For example,
`fromJson` could be chained after a call to `Http.getString`
to convert Json from a REST Api.

Using the standard ports system in Elm, to call into JavaScript
requires that you make a separate `Cmd` call to run the JavaScript
function, and then subscribe to a response as a `Sub`. This
disconnect between the call and return of a function makes for some
difficulties. For instance, you won't be sure which response `Sub`
corresponds to which call you made with the `Cmd` unless you pass back
some id or the original args. But, worst of all, it makes calling
externel JavaScript functions impossible to chain together using
`Task.andThen`.

Frontier's `call` allows you to call any JavaScript function and
receive the results as a normal Elm `Task`.

## How?

You may have noticed that the Elm ports system already automatically
converts Elm objects to JavaScript and vice versa. Whenever you declare
an outgoing port, the Elm compiler will generate a converter function
that converts Elm object to JavaScript, and generates a converter from
JavaScript to Elm when you declare an incoming port.

Elm-Frontier uses these converter functions that the Elm compiler
generates for ports. With Frontier, ports are used merely to convert
data and are passed in as arguments to `toJson`, `fromJson`, or
`call`. Ports are not mapped to individual JavaScript functions, so
you need only declare one port per datatype and direction
(input/output).

The Elm objects that you can convert automatically are limited to the
ones that can be converted by Elm's port system: Ints, Floats, Bools,
Strings, Maybes, Lists, Arrays, Tuples, Json.Values, and concrete records.

### OutputPort
```
type alias OutputPort a msg =
    a -> Cmd msg
```
This is a standard port definition for an output port. For example, `port intOut : Int -> Cmd x
` would declare an `OutputPort` named `intOut` that converts outgoing
Elm Ints.

### InputPort
```
type alias InputPort a msg =
    (a -> msg) -> Sub msg
```
Standard input port definition. `port intIn : (Int -> x) -> Sub x`
would declare an input port named `intIn` that converts incoming
JavaScript ints.

### `toJson`

```
toJson : OutputPort elmObject msg -> elmObject -> Task String JsonString
```

Converts `elmObject` to a Json string. It uses JavaScript's `JSON.stringify`.
`JsonString` is just a type alias for `String`. It's guaranteed to
succeed if `JSON.stringify` is available in JavaScript.


### `fromJson`

```
fromJson : InputPort elmObject msg -> JsonString -> Task String elmObject
```

Tries to convert a Json string to an `elmObject`. It uses JavaScript's
`JSON.parse` to convert the Json to a JavaScript object, then Elm's
port converter to turn it into an Elm object. If there is an error in
either of these conversions, the task will return an explanatory
String error.

`fromJson` is best used to convert Json that was created with
Frontier's `toJson`, but you can also use it to convert well-formed
foreign Json. Just use the same field names and use `Maybe` for
nullable Json values. It's ok to ignore some Json fields.

You might run into trouble if the json field names have dashes. In
this case, you might want to make a custom Decoder, manually convert
the field names, or use `call` to convert the field names in
JavaScript before passing the Json to `fromJson`.

### `call`

```
call : OutputPort a x -> InputPort b y -> OuterFunctionName -> a -> Task String b
```

Calls a JavaScript function named `OuterFunctionName` (a
`String`), passing it argument `a`.

The JavaScript function should take two arguments. The first is a
`ret` object that has two functions, `succeed (a)` and `fail
(String)`, which you call to return the computation. The second
argument is the actual value from Elm.

Using the ports `intOut` and `intIn` declared above, here is a trite
example of using a JavaScript function that returns `n + n/2` three
seconds after it is called.

In Elm:

```
delayedAddingTask : Int -> Task String Int
delayedAddingTask =
    Frontier.call intOut intIn "delayedAddOne"
```

In JavaScript:
```
    <script>
    var app = Elm.Example.fullscreen();

    function delayedAddOne(ret, n) {
        setTimeout(function(){ret.succeed(parseInt(n/2));}, 3000);
    }
    </script>
```

Then calling `delayedAddingTask 8` using `Task.attempt` or
`Task.perform` would return `12` three seconds later.

If want to indicate that the JavaScript function has failed, you can use
`ret.fail("The function failed because...");` to send back an error to
Elm.

## Installation

Elm-Frontier uses a native javascript file and hasn't been approved
from above to be included in the Elm package repository (I haven't tried),
so to use you must currently download `src/Frontier.elm` into the
`src/` folder of your project, and `src/Native/Frontier.js` into
`src/Native/`.

Then, open up your `src/Native/Frontier.js` in a test editor. The
first line of the file is this:

```
var _mpdairy$elm_frontier$Native_Frontier = function() {
```

You must change `mpdairy` and `elm_frontier` to the github username
and github project name specified as the `repository` in your
project's `elm-package.json` file. You also need to add
`"native-modules": true` to your `elm-package.json` file.

For example, if this were your project's `elm-package.json` file (with the
`native-modules` option added):

```
{
    "version": "2.0.1",
    "summary": "this is my special project that I love",
    "repository": "https://github.com/jburleydog/my-special-project.git",
    "license": "UNLICENSED",
    "source-directories": [
      "src"
    ],
    "exposed-modules": [],
    "dependencies": {
        "elm-lang/core": "4.0.5 <= v < 5.0.0",
        "elm-lang/html": "1.0.0 <= v < 2.0.0"
    },
  "native-modules": true,
  "elm-version": "0.17.1 <= v < 0.18.0"
}
```

You would change the first line of your `src/Native/Frontier.js` file
to:

```
var _jburleydog$my_special_project$Native_Frontier = function() {
```

## Complete Example Usage

See `example.html` and `src/Example.elm` for using `elm-frontier` with
complex Elm objects.

## Compatibility

Elm-Frontier works with Elm 0.17 and 0.18. It is my hope that Evan
will build "official" functionality similar to Frontier's into 0.19.

However, there is no guarantee that he will and he might even somehow
block access to the port converter functions that are essential for
Frontier to work.
