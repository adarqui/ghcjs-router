{-# LANGUAGE CPP               #-}
{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedStrings #-}

#ifdef __GHCJS__
{-# LANGUAGE ForeignFunctionInterface, JavaScriptFFI #-}
#endif

-- | Ripped almost directly from react-flux examples/routing.
-- Not sure why this isn't in an existing repository by itself.
-- Re-formatted to my liking.

module GHCJS.Router.Base (
  setLocationHash,
  getLocationHash,
  onLocationHashChange
) where



#ifdef __GHCJS__

import           Control.Monad          (liftM)
import qualified Data.JSString          as JSS
import           GHCJS.Foreign.Callback
import           GHCJS.Types            (JSString, JSVal)
import           Unsafe.Coerce

#endif



#ifdef __GHCJS__

foreign import javascript unsafe
  "window.onhashchange = function() {$1(location.hash.toString());}"
  js_attachtLocationHashCb :: (Callback (JSVal -> IO ())) -> IO ()

foreign import javascript unsafe
  "window.location.hash = $1"
  js_setLocationHash :: JSString -> IO ()

foreign import javascript unsafe
  "window.location.hash.toString()"
  js_getLocationHash :: IO JSString

setLocationHash :: String -> IO ()
setLocationHash = js_setLocationHash . JSS.pack

getLocationHash :: IO (Maybe String)
getLocationHash = do
  rt <- liftM JSS.unpack js_getLocationHash
  pure $ case rt of
    "" -> Nothing
    _  -> Just rt

onLocationHashChange :: (String -> IO ()) -> IO ()
onLocationHashChange fn = do
  cb <- syncCallback1 ThrowWouldBlock (fn . JSS.unpack . unsafeCoerce)
  js_attachtLocationHashCb cb

# else

setLocationHash :: String -> IO ()
setLocationHash = const $ pure ()

getLocationHash :: IO (Maybe String)
getLocationHash = pure Nothing

onLocationHashChange :: (String -> IO ()) -> IO ()
onLocationHashChange = const $ pure ()

#endif
