module Pure.Control.Sync (sync, sync', fork, forkSync) where

import Control.Concurrent (forkIO, newEmptyMVar, readMVar, tryPutMVar)
import Control.Monad (void)

-- | Synchronize an asynchronous callback with the calling context through 
-- a functional reification of putMVar/takeMVar. Useful for synchronizing
-- with implicitly asynchronous effects, e.g. websocket requests.
--
-- > result <- sync (request myAPI myClient myEndpoint myPayload)
--
-- Note: discards any return result from the outer context
sync :: ((a -> IO ()) -> IO r) -> IO a
sync f = snd <$> sync' f

-- | Synchronize an asynchronous callback with the calling context through 
-- a functional reification of putMVar/takeMVar. Useful for synchronizing
-- with implicitly asynchronous effects, e.g. websocket requests.
--
-- > (x,result) <- sync' (request myAPI myClient myEndpoint myPayload)
--
-- Calling the supplied return callback more than once will silently fail.
sync' :: ((a -> IO ()) -> IO r) -> IO (r, a)
sync' f = do
  mv <- newEmptyMVar
  r  <- f (void . tryPutMVar mv)
  a  <- readMVar mv
  pure (r, a)

-- | A convenient synonym for the common pattern `void . forkIO . void`.
fork :: IO a -> IO ()
fork = void . forkIO . void

-- | Fork an effectful computation with a one-time-use return callback.
-- 
-- In the below example, `r` will be available for use in the calling context
-- before `longCleanup` has necessarily finished running.
--
-- >>> r <- forkSync $ \k -> compute >>= k >> longCleanup
--
-- Calling the supplied return callback more than once will silently fail.
forkSync :: ((a -> IO ()) -> IO ()) -> IO a
forkSync = sync . (fork .)

