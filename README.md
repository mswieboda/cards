# cards

## Installation

clone repo
```
git clone git@github.com:mswieboda/cards.git
```

cd into dir
```
cd cards
```

install crystal specified in `.tool-versions`

on macOS with [asdf](https://github.com/asdf-vm/asdf):
```
asdf install `cat .tool-versions`
```

or other OS's and instructions:
https://crystal-lang.org/install/

install shards
```
shards install
```

make sure to have `make` installed on your OS

## Usage

run using `Makefile`, by default cleans the build and complies a new one, see more options in `Makefile`

```
make
```
