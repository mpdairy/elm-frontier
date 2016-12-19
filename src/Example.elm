port module Example exposing (..)

import Html.App as Html
import Html exposing (..)
import Frontier exposing (toJson, fromJson, toJsonTask, fromJsonTask, taskPort)
import Task exposing (Task)
import Html.Events exposing (onFocus, onInput, onBlur, onClick)


type Msg
    = EncodeObject Movie
    | Encoded String
    | TestTaskInt
    | SetInt Int
    | Error String
    | DecodeMovie String


type alias Model =
    { json : String
    , movie : Maybe Movie
    , testInt : Int
    , error : String
    }


port movieIn : (Movie -> x) -> Sub x


port movieOut : Movie -> Cmd x



--


port intOut : Int -> Cmd x


port intIn : (Int -> x) -> Sub x


addingTask : Int -> Task String Int
addingTask =
    taskPort "kobeJones" intOut intIn



--


type alias Movie =
    { title : String
    , year : Int
    , plot : String
    , posters : List Poster
    , imdb : Maybe String
    , rottenTomatoes : Maybe Int
    }


type alias Poster =
    { url : String
    , width : Int
    , height : Int
    }


megamovie : Movie
megamovie =
    { title = "Jim's Revenge"
    , year = 1959
    , plot = "Jim is left on a beach with only one hotel and a thousand dollars."
    , posters =
        [ { url = "https://i.ytimg.com/vi/QjCCBdZ4Frg/maxresdefault.jpg"
          , width = 300
          , height = 900
          }
        , { url = "http://cdn.pursuitist.com/wp-content/uploads/2013/02/Somerset-Hotel-on-Grace-Bay-Beach-in-Turks-and-Caicos-Reviewed.jpg"
          , width = 900
          , height = 330
          }
        ]
    , imdb = Just "34M3992"
    , rottenTomatoes = Nothing
    }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EncodeObject m ->
            model
                ! [ Task.perform Encoded Encoded (toJsonTask movieOut m) ]

        Encoded s ->
            { model | json = s } ! []

        TestTaskInt ->
            model
                ! [ Task.perform Error SetInt (addingTask model.testInt) ]

        SetInt n ->
            { model | testInt = n } ! []

        Error s ->
            { model | error = s } ! []

        DecodeMovie json ->
            { model | movie = Result.toMaybe <| fromJson movieIn json } ! []



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "encoded json:" ]
        , button [ onClick <| EncodeObject megamovie ] [ text "encode it now ok" ]
        , div [] [ text model.json ]
        , h2 [] [ text "decoded movie:" ]
        , button [ onClick <| DecodeMovie model.json ] [ text "decode movie json" ]
        , div [] [ text <| Maybe.withDefault "nothing" (Maybe.map toString model.movie) ]
        , button [ onClick <| TestTaskInt ] [ text "Test Task Int" ]
        , div [] [ text <| "Int is: " ++ toString model.testInt ]
        , div [] [ text <| "Error: " ++ model.error ]
        ]



-- APP


main : Program Never
main =
    Html.program
        { init = { movie = Nothing, json = "", testInt = 0, error = "" } ! []
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
