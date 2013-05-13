
init:
	npm install

build:
	coffee -o lib/ -c src/

clean:
	rm -rf lib/

dist: clean build
