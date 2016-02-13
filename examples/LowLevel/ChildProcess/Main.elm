module Main (..) where

import ChildProcess exposing (ChildProcess)
import Chunk exposing (encodeBuffer)
import Console exposing (print, log, error)
import FileSystem.Read as FS
import Json.Decode as Decode
import Task exposing (Task)


port run : Task String ()
port run =
  readFile depsFile
    |> (flip Task.andThen) parseDeps
    |> (flip Task.andThen) getDocs
    |> (flip Task.andThen) print
    |> (flip Task.onError) error
    |> (flip Task.andThen) (always (Task.succeed ()))


depsFile : String
depsFile =
  "elm-stuff/exact-dependencies.json"


readFile : String -> Task String String
readFile path =
  FS.readFile path
    |> Task.map encodeBuffer
    |> Task.mapError (\_ -> "Could not read file at: " ++ path)


type alias Doc =
  { basename : String
  , dirname : String
  , local : String
  , network : String
  }


parseDeps : String -> Task String (List Doc)
parseDeps json =
  let
    deps =
      Decode.decodeString (Decode.keyValuePairs Decode.string) json

    buildDocPath ( name, version ) =
      let
        -- Don't use `documentation.json` as basename as this gets automatically created by elm-oracle.
        basename =
          "docs.json"

        dirname =
          "elm-stuff/packages/" ++ name ++ "/" ++ version ++ "/"

        local =
          dirname ++ basename

        network =
          "http://package.elm-lang.org/packages" ++ "/" ++ name ++ "/" ++ version ++ "/" ++ name
      in
        Doc basename dirname local network

    result =
      case deps of
        Ok packages ->
          Ok <| List.map buildDocPath packages

        Err _ ->
          Err "Could not decode the dependencies file."
  in
    Task.fromResult result


makeDoc : Doc -> Task String ChildProcess
makeDoc doc =
  let
    make =
      ChildProcess.execWithOptions
        { cwd = doc.dirname }
        ("elm make --yes --docs " ++ doc.basename)
  in
    make



--|> (flip Task.andThen)
--    (\cp ->
--      ChildProcess.onExit cp (\_ -> Task.succeed ())
--    )


readDoc : Doc -> Task String String
readDoc doc =
  readFile doc.local


getDocs : List Doc -> Task String (List String)
getDocs docPaths =
  let
    get doc =
      makeDoc doc
        |> (flip Task.andThen) (\_ -> (readDoc doc))
  in
    Task.sequence (List.map get docPaths)
