module Main where

import           Options.Applicative
import           Data.Semigroup                 ( (<>) )
import           System.IO

data ShowMode = Current | Max
  deriving (Eq)

data Action = Show ShowMode | Set Int | Inc Int | Dec Int
  deriving (Eq)

data Config =
  Config
    { getAction         :: Action
    , isRelative        :: Bool
    , maxBrightnessFile :: FilePath
    , brightnessFile    :: FilePath }

defaultPath :: FilePath
defaultPath = "/sys/class/backlight/intel_backlight/"

opts :: Parser Config
opts =
  Config
    <$> subparser
          (  command
              "show"
              (info (pure (Show Current))
                    (progDesc "Show current display brightness")
              )
          <> command
               "max"
               (info (pure (Show Max))
                     (progDesc "Show maximum display brightness")
               )
          <> command
               "set"
               (info (Set <$> argument auto (metavar "VALUE"))
                     (progDesc "Set display brightness")
               )
          <> command
               "inc"
               (info (Inc <$> argument auto (metavar "VALUE"))
                     (progDesc "Increase display brightness")
               )
          <> command
               "dec"
               (info (Dec <$> argument auto (metavar "VALUE"))
                     (progDesc "Decrease display brightness")
               )
          )
    <*> switch
          (  long "relative"
          <> short 'r'
          <> help
               "Using relative display brighness (as oppossed to the internal representation)"
          )
    <*> strOption
          (  long "max-brightness-file"
          <> short 'm'
          <> help
               "The file containing the maximum brightness (default: /sys/class/backlight/intel_backlight/max_brightness)"
          <> metavar "FILE"
          <> value (defaultPath ++ "max_brightness")
          )
    <*> strOption
          (  long "brightness-file"
          <> short 'f'
          <> help
               "The file containing the current brightness (default: /sys/class/backlight/intel_backlight/brightness)"
          <> metavar "FILE"
          <> value (defaultPath ++ "brightness")
          )

desc :: InfoMod a
desc = fullDesc <> progDesc "Manipulate display brightness" <> header
  "blight command line tool (c) 2019 Juri Dispan"

toInternal :: Config -> Int -> Int -> Int
toInternal cfg maxB | isRelative cfg = (`div` 100) . (* maxB)
                    | otherwise      = id

fromInternal :: Config -> Int -> Int -> Int
fromInternal cfg maxB | isRelative cfg = (`div` maxB) . (* 100)
                      | otherwise      = id

getBrightness :: FilePath -> IO Int
getBrightness f = read <$> readFile f

setBrightness :: Int -> Int -> FilePath -> IO ()
setBrightness val maxB fp =
  let newBrightness = max 0 $ min maxB val
  in  writeFile fp $ show newBrightness ++ "\n"

adjustBrightness :: Int -> Int -> FilePath -> IO ()
adjustBrightness incr maxB fp = do
  handle            <- openFile fp ReadWriteMode
  currentBrightness <- read <$> hGetLine handle

  let newBrightness = max 0 $ min maxB (currentBrightness + incr)

  hSeek handle AbsoluteSeek 0
  hPutStr handle $ show newBrightness ++ "\n"
  hClose handle

main :: IO ()
main = do
  cfg <- customExecParser (prefs showHelpOnEmpty) (info (opts <**> helper) desc)
  maxBrightness <- if getAction cfg /= Show Current || isRelative cfg
    then getBrightness (maxBrightnessFile cfg)
    else pure 100

  let toInternal' :: Int -> Int
      toInternal' = toInternal cfg maxBrightness
      fromInternal' :: Int -> Int
      fromInternal' = fromInternal cfg maxBrightness

  case getAction cfg of
    Show Current ->
      print <$> fromInternal' =<< getBrightness (brightnessFile cfg)
    Show Max -> putStr $ show maxBrightness
    Set val ->
      setBrightness (toInternal' val) maxBrightness (brightnessFile cfg)
    Inc val ->
      adjustBrightness (toInternal' val) maxBrightness (brightnessFile cfg)
    Dec val ->
      adjustBrightness (toInternal' (-val)) maxBrightness (brightnessFile cfg)
