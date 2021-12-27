# PPX Tailwindcss

A ReScript PPX, which validates the tailwindcss class names

## Motivation

## Install

```
yarn add -D @greenlabs/ppx-tailwindcss
```

```
// bsconfig.json

"ppx-flags": [
  ...,
  "@greenlabs/ppx-tailwindcss/ppx"
],
```

## Development

1. Create a sandbox with opam

```
opam switch create tailwindcss 4.12.1
```

2. Install dependencies

```
opam install dune ppxlib ocaml-lsp-server ocamlformat ocp-indent core yojson ppx_inline_test ppx_expect ppx_deriving.show
```

3. Build

```
dune build
```

4. Test

```
cd test

(install dependencies)
yarn

(build --watch)
yarn res:clean && yarn res:watch

(run test --watch)
yarn test:watch
```
