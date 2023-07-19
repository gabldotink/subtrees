import System.Environment
import Control.Monad

main :: IO ()
main = do
    args <- getArgs
    forever $ putStrLn (if null args then "y" else unwords args)
