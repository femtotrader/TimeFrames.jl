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

## Dates.DateTime arithmetic rounds submillisecond periods

Observed with Julia **1.10.12** (Dates **1.10.0**) and Julia **1.13.1**
(Dates **1.11.0**). Status: upstream precision limitation, not an assertion
that Dates' documented millisecond representation is defective; no report filed.

```julia
using Dates
dt = DateTime(2024, 1, 1)
dt + Nanosecond(1) == dt  # true on both tested versions
dt + Microsecond(1) == dt # true on both tested versions
```

TimeFrames converts submillisecond periods exactly to milliseconds before
DateTime arithmetic or range construction. Nonrepresentable steps raise
`InexactError`. Use Dates.Time or NanoDates **2.1.0** for precise subday values.
NanoDates 2.1.0 provides rounding by period type, but not by a period instance
such as `Microsecond(10)`; TimeFrames computes its own integer bucket offsets
without extending or replacing NanoDates' methods.
