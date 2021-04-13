ASSETS := $(shell yq e '.assets.[].src' manifest.yaml)
ASSET_PATHS := $(addprefix assets/,$(ASSETS))
VERSION := $(shell toml get conduit/Cargo.toml package.version)
CONDUIT_SRC := $(shell find ./conduit/src) conduit/Cargo.toml conduit/Cargo.lock
ELEMENT_SRC := $(shell find ./element-web/src)

.DELETE_ON_ERROR:

all: matrix-conduit.s9pk

install: matrix-conduit.s9pk
	appmgr install matrix-conduit.s9pk

matrix-conduit.s9pk: manifest.yaml config_spec.yaml config_rules.yaml image.tar instructions.md $(ASSET_PATHS)
	appmgr -vv pack $(shell pwd) -o matrix-conduit.s9pk
	appmgr -vv verify matrix-conduit.s9pk

instructions.md: README.md
	cp README.md instructions.md

image.tar: Dockerfile docker_entrypoint.sh conduit/target/armv7-unknown-linux-musleabihf/release/conduit element-web/webapp
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/matrix-conduit --platform=linux/arm/v7 -o type=docker,dest=image.tar .

conduit/target/armv7-unknown-linux-musleabihf/release/conduit: $(CONDUIT_SRC)
	docker run --rm -it -v ~/.cargo/registry:/root/.cargo/registry -v "$(shell pwd)"/conduit:/home/rust/src start9/rust-musl-cross:armv7-musleabihf cargo +beta build --release
	docker run --rm -it -v ~/.cargo/registry:/root/.cargo/registry -v "$(shell pwd)"/conduit:/home/rust/src start9/rust-musl-cross:armv7-musleabihf musl-strip target/armv7-unknown-linux-musleabihf/release/conduit

element-web/webapp: element-web/node_modules $(ELEMENT_SRC) element-web/config.json
	NODE_OPTIONS=--max-old-space-size=2048 npm --prefix element-web run build

element-web/node_modules: element-web/package.json
	yarn --prefix element-web install

element-web/config.json: element-web/config.sample.json
	cat element-web/config.sample.json | jq ".default_theme = \"dark\"" > element-web/config.json

manifest.yaml: conduit/Cargo.toml
	yq e -i '.version = $(VERSION)' manifest.yaml
