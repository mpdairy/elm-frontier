module Frontier exposing (toJson, fromJson, call)

import Native.Frontier
import Task exposing (Task, succeed, fail)


type alias OutputPort a msg =
    a -> Cmd msg


type alias InputPort a msg =
    (a -> msg) -> Sub msg


type alias JsonString =
    String


toJson : OutputPort elmObject msg -> elmObject -> Task String JsonString
toJson outPort elmObject =
    Native.Frontier.toJson outPort elmObject


fromJson : InputPort elmObject msg -> JsonString -> Task String elmObject
fromJson inPort json =
    Native.Frontier.fromJson inPort json



--


type alias OuterFunctionName =
    String


call : OutputPort a x -> InputPort b y -> OuterFunctionName -> a -> Task String b
call outp inp jsfn obj =
    Native.Frontier.call outp inp jsfn obj
