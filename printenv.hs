import System.Environment
import Text.Printf
import Data.Maybe

main :: IO ()
main = do
    args <- getArgs
    if null args
        then getEnvironment >>= putStr . unlines . map (\(k, v) -> printf "%s=%s" k v)
        else mapM lookupEnv args >>= putStr . unlines . catMaybes
