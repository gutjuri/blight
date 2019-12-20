# blight

Command line utility for changing the display brightness.

## Installation 

```bash
$ git clone https://github.com/juril33t/blight.git
$ cd blight
$ stack install
$ sudo ./give_permissions # (*)

```

Step (*) is optional. It gives permissions to blight for setting the display brightness.
If you skip this step, you'll have to execute blight as root. 

## Usage

```
blight command line tool (c) 2019 Juri Dispan

Usage: blight COMMAND [-r|--relative] [-m|--max-brightness-file FILE]
              [-f|--brightness-file FILE]
  Manipulate display brightness

Available options:
  -r,--relative            Using relative display brighness (as oppossed to the
                           internal representation)
  -m,--max-brightness-file FILE
                           The file containing the maximum brightness (default:
                           /sys/class/backlight/intel_backlight/max_brightness)
  -f,--brightness-file FILE
                           The file containing the current brightness (default:
                           /sys/class/backlight/intel_backlight/brightness)
  -h,--help                Show this help text

Available commands:
  show                     Show current display brightness
  max                      Show maximum display brightness
  set                      Set display brightness
  inc                      Increase display brightness
  dec                      Decrease display brightness

```

## Examples

### Set display brightness to 100%

```bash
$ blight set 100 -r
```

### Set display brightness to 50%

```bash
$ blight set 50 -r
```

### Decrease display brightness by 5%

```bash
$ blight dec 5 -r
```

### Increase display brightness by 300 (of internal units)

```bash
$ blight inc 300
```

### Show current display brightness

```bash
$ blight show     # using internal units
$ blight show -r  # or using percents
```

### Show maximum display brightness

```bash
$ blight max
```
