# Install both supported Juliaup channels before running these recipes.
default:
    @just --list

test channel="1.10":
    julia +{{channel}} --startup-file=no --project=. -e 'using Pkg; Pkg.test()'

test-all:
    just test 1.10
    just test 1.13

dev-setup:
    julia +1.10 --startup-file=no --project=dev -e 'using Pkg; Pkg.instantiate()'

format: dev-setup
    julia +1.10 --startup-file=no --project=dev dev/format.jl write

format-check: dev-setup
    julia +1.10 --startup-file=no --project=dev dev/format.jl check

docs-setup channel="1.10":
    julia +{{channel}} --startup-file=no --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'

docs channel="1.10": (docs-setup channel)
    julia +{{channel}} --startup-file=no --project=docs docs/make.jl

check:
    just format-check
    just test-all
    just docs 1.10
    just docs 1.13
