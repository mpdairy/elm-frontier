port module Example exposing (..)

import Html.App as Html
import Html exposing (..)
import Frontier
import Task exposing (Task)
import Html.Events exposing (onFocus, onInput, onBlur, onClick)


type Msg
    = EncodeMovie Movie
    | EncodedMovie String
    | TestTaskInt
    | SetInt Int
    | Error String
    | DecodeMovie String
    | DecodedMovie Movie
    | TestTaskMovie
    | KobeMovie Movie


type alias Model =
    { json : Maybe String
    , movie : Maybe Movie
    , kobeMovie : Movie
    , testInt : Int
    , error : String
    }


port movieIn : (Movie -> x) -> Sub x


port movieOut : Movie -> Cmd x


port intOut : Int -> Cmd x


port intIn : (Int -> x) -> Sub x


delayedAddingTask : Int -> Task String Int
delayedAddingTask =
    Frontier.call intOut intIn "delayedAddOne"


kobeJonesMovieTask : Movie -> Task String Movie
kobeJonesMovieTask =
    Frontier.call movieOut movieIn "kobeJones"



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
    , plot = "Jim is left to die on a beach with only one hotel and ten thousand dollars."
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
        EncodeMovie m ->
            model
                ! [ Task.perform Error EncodedMovie <| Frontier.toJson movieOut m ]

        EncodedMovie json ->
            { model | json = Just json } ! []

        TestTaskInt ->
            model
                ! [ Task.perform Error SetInt <| delayedAddingTask model.testInt ]

        SetInt n ->
            { model | testInt = model.testInt + n } ! []

        Error s ->
            { model | error = s } ! []

        DecodeMovie json ->
            model ! [ Task.perform Error DecodedMovie <| Frontier.fromJson movieIn json ]

        DecodedMovie movie ->
            { model | movie = Just movie } ! []

        TestTaskMovie ->
            model ! [ Task.perform Error KobeMovie <| kobeJonesMovieTask model.kobeMovie ]

        KobeMovie m ->
            { model | kobeMovie = m } ! []



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Automatic JSON Conversion" ]
        , h3 [] [ text "Original movie elm object:" ]
        , div [] [ text <| toString megamovie ]
        , button [ onClick <| EncodeMovie megamovie ] [ text "automatically convert movie to Json" ]
        , div [] <|
            case model.json of
                Nothing ->
                    []

                Just json ->
                    [ text json
                    , button [ onClick <| DecodeMovie json ] [ text "automatically decode from Json back into Movie object" ]
                    ]
        , div [] [ text <| Maybe.withDefault "" (Maybe.map toString model.movie) ]
        , h1 [] [ text "Call externel functions: " ]
        , button [ onClick <| TestTaskInt ] [ text <| "Add half of current to three seconds from now" ]
        , div [] [ text <| "Int is: " ++ toString model.testInt ]
        , div [] [ text "$nbsp;" ]
        , button [ onClick <| TestTaskMovie ] [ text <| "Run movie through outer Kobe Jones function" ]
        , div [] [ text <| "Movie is: " ++ toString model.kobeMovie ]
        , h1 [] [ text "Errors" ]
        , div [] [ text model.error ]
        ]



-- APP


main : Program Never
main =
    Html.program
        { init =
            { movie = Nothing
            , json = Nothing
            , testInt = 2
            , kobeMovie = megamovie
            , error = "Nothing"
            }
                ! []
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
