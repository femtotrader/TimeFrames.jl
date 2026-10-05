# Upstream issues and limitations

## Pkg.compat does not recognize test-only extras

Observed with Julia **1.13.1**, Pkg **1.13.0**, and TestItemRunner **1.3.2** during
this migration. Status: upstream API limitation; no upstream report filed.

Reproduction in a disposable environment:

```julia
using Pkg
Pkg.activate(mktempdir())
Pkg.add("TestItemRunner"; target=:extras)
Pkg.compat("TestItemRunner", "1")
```

The final command raises `No package named TestItemRunner in current Project`
despite the package appearing under `[extras]`. Pkg's compatibility command checks
`[deps]` rather than `[extras]` in this version.

Workaround: add the test dependency with Pkg, then declare its compatibility bound
in `[compat]` and resolve the environment. Aqua verifies these bounds in the
package's test suite. Dependency updates continue to use `Pkg.update()`.
