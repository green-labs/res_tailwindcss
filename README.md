# ReScript Tailwindcss

A ReScript PPX, which validates the tailwindcss class names

## Motivation

The [tailwind-ppx](https://github.com/dylanirlbeck/tailwind-ppx) is the only ppx to validate the tailwindcss class names in compile time. But, it was archived, and written by `ocaml-migrate-parsetree`. My team considered taking over the repository and maintaining it but decided to rewrite it from the scratch with `ppxlib` and `menhir`. Additionally, we improve the logic to find the invalid class name with [Spelling Corrector](https://norvig.com/spell-correct.html) algorithm.

Plus, the arbitrary values in the JIT mode of Tailwindcss are supported!

```html
<!-- arbitrary value examples -->
<div className=%twc("p-[75px]")> ... </div>
<div className=%twc("p-[calc(75px)]")> ... </div>
<div className=%twc("p-[calc(100%-40px)]")> ... </div>
<div className=%twc("bg-[#1da1f1]")> ... </div>
<div className=%twc("grid-cols-[1fr,700px,2fr]")> ... </div>
<div className=%twc("translate-x-[calc(-50%+27px)]")> ... </div>
<div className=%twc("!pb-[270px]")> ... </div>

```

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

## Example

```rescript
<div className=%twc("flex justify-center items-center")>
  ...
</div>
```

## Development

1. Create a sandbox with opam

```
opam switch create tailwindcss 4.12.1
```

2. Install dependencies

```
opam install . --deps-only --with-test
```

3. Build

```
opam exec -- dune build
```

4. Test

```
cd rescript

(install dependencies)
yarn

(build --watch)
yarn res:clean && yarn res:watch

(run test --watch)
yarn test:watch
```
