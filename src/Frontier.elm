module Frontier exposing (toJson, fromJson, toJsonTask, fromJsonTask, responsePort)

import Native.Frontier
import Task exposing (Task, succeed, fail)


type alias OutputPort a msg =
    a -> Cmd msg


type alias InputPort a msg =
    (a -> msg) -> Sub msg


type alias JsonString =
    String


toJson : OutputPort elmObject msg -> elmObject -> JsonString
toJson outPort elmObject =
    Native.Frontier.toJson outPort elmObject


fromJson : InputPort elmObject msg -> JsonString -> Result String elmObject
fromJson inPort json =
    Native.Frontier.fromJson inPort json


toJsonTask : OutputPort elmObject msg -> elmObject -> Task String JsonString
toJsonTask outPort elmObject =
    succeed (toJson outPort elmObject)


fromJsonTask : InputPort elmObject msg -> JsonString -> Task String elmObject
fromJsonTask inPort json =
    case fromJson inPort json of
        Err e ->
            fail e

        Ok obj ->
            succeed obj



--


type alias JsFunctionName =
    String


responsePort : JsFunctionName -> OutputPort a x -> InputPort b y -> a -> Result String b
responsePort jsfn outp inp obj =
    Native.Frontier.responsePort jsfn outp inp obj
