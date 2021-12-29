# ReScript Tailwindcss

A ReScript PPX, which validates the tailwindcss class names

## Motivation

The [tailwind-ppx](https://github.com/dylanirlbeck/tailwind-ppx) is the only ppx to validate the tailwindcss class names in compile time. But, it was archived, and written by `ocaml-migrate-parsetree`. My team considered taking over the repository and maintaining it but decided to rewrite it from the scratch with `ppxlib` and `menhir`. Additionally, we improve the logic to find the invalid class name with (Spelling Corrector)[https://norvig.com/spell-correct.html] algorithm.

## Install

```
yarn add -D @greenlabs/res-tailwindcss
```

`<path_to_tailwindcss>` should be replaced with the relative location of your generated tailwindcss file from your project root in which the `bsconfig.json` file is located.

```
// bsconfig.json

"ppx-flags": [
  ...,
  ["@greenlabs/res-tailwindcss/ppx", "--path <path_to_tailwindcss>"]
],
```

## Development

1. Create a sandbox with opam

```
opam switch create tailwindcss 4.12.1
```

2. Install dependencies

```
opam install dune ppxlib ocaml-lsp-server ocamlformat ocp-indent core ppx_inline_test ppx_expect ppx_deriving.show
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
