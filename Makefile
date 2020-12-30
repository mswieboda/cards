.PHONY: default clean clean_if_diff test release

clean = if [ ! -d "./builds" ]; then mkdir "builds"; else env echo "cleaning builds..." && rm -r builds; fi

default: test

builds:
	@if [ ! -d "./builds" ]; then mkdir "builds"; fi

clean:
	@$(call clean)

clean_if_diff:
	@[[ -z `git status -s -uall` ]] || $(call clean)

builds/cards_test: builds
	@echo "compiling test build..."
	@env LIBRARY_PATH="$(PWD)/lib_ext" crystal build src/cards.cr --error-trace -o builds/cards_test

test: clean_if_diff builds/cards_test
	@env LD_LIBRARY_PATH="$(PWD)/lib_ext" ./builds/cards_test

builds/cards: builds
	@echo "compiling release build..."
	@env LIBRARY_PATH="$(PWD)/lib_ext" crystal build --release --no-debug src/cards.cr -o builds/cards

release: clean_if_diff builds/cards
	@env LD_LIBRARY_PATH="$(PWD)/lib_ext" ./builds/cards

pack: clean builds/cards
	@echo "packing to builds/pack"
	@rm -rf ./builds/pack
	@mkdir ./builds/pack
	@mkdir ./builds/pack/bin
	@cp ./builds/cards ./builds/pack/bin
	@cp -r ./assets ./builds/pack
	@cp -r ./lib_ext ./builds/pack
	@cp -r ./cards.sh ./builds/pack
	@open /Applications/Platypus.app ./cards.platypus
