module ChildProcess (ChildProcess, exec, execWithOptions, onExit) where

{-|
@docs ChildProcess, exec, execWithOptions, onExit
-}

import Emitter.Unsafe as Emitter
import Foreign.Marshall as Marshall
import Foreign.Pattern.Get as Get
import Foreign.Pattern.Member as Member
import Foreign.Types exposing (JSRaw)
import Process.Types as Process
import Streams.Marshall
import Streams.Types as Streams
import Task exposing (Task)


{-|
-}
type ChildProcess
  = ChildProcess JSRaw


type alias Options =
  { cwd : String }


defaultOptions : Options
defaultOptions =
  { cwd = "." }


childProcess : JSRaw
childProcess =
  Marshall.unsafeRequire "child_process"


{-|
-}
execWithOptions : Options -> String -> Task x ChildProcess
execWithOptions options command =
  Get.getAsync2 "exec" childProcess command options


{-|
-}
exec : String -> Task x ChildProcess
exec =
  execWithOptions defaultOptions


{-|
-}
onExit : ChildProcess -> (Maybe Process.ExitCode -> Task x ()) -> Task x (Task x ())
onExit cp f =
  Emitter.on1 "exit" cp (f << Process.intToExit)


standardOut : ChildProcess -> Streams.Readable {}
standardOut cp =
  Member.unsafeRead "stdout" cp
    |> Streams.Marshall.marshallReadable


standardError : ChildProcess -> Streams.Readable {}
standardError cp =
  Member.unsafeRead "stderr" cp
    |> Streams.Marshall.marshallReadable
