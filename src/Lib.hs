module Lib
       ( mkAppEnv
       , runServer
       , main
       ) where

import Network.Wai.Handler.Warp (run)
import Servant.Server (serve)
import System.Remote.Monitoring (forkServerWith)

import Lib.App (AppEnv (..))
import Lib.Core.Jwt (JwtSecret (..), mkRandomString)
import Lib.Server (API, server)

import qualified Data.HashMap.Strict as HashMap
import qualified System.Metrics as Metrics

mkAppEnv :: IO AppEnv
mkAppEnv = do
  let dbPool = error "Not implemented yet"
  sessions <- newMVar HashMap.empty
  randTxt <- mkRandomString 10
  let jwtSecret = JwtSecret randTxt
  timings <- newIORef HashMap.empty
  ekgStore <- Metrics.newStore
  Metrics.registerGcMetrics ekgStore
  let sessionExpiry = 600
  return AppEnv{..}

runServer :: AppEnv -> IO ()
runServer env = do
    () <$ forkServerWith (ekgStore env) "localhost" 8081
    run 8081 application
  where
    application = serve (Proxy @API) (server env)

main :: IO ()
main = mkAppEnv >>= runServer
