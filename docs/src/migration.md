# Migration

## Upgrading from 0.8 to 0.9

Lowercase `ms` now means milliseconds. Code using `TimeFrame("ms")` for
month start must use `TimeFrame("MS")` instead. This breaking correction
is included in 0.9.0; it is not part of the v0.8.0 tag.

DateTime arithmetic and range construction now reject microsecond/nanosecond
steps that cannot be converted exactly to milliseconds. This also affects
generic frames such as `TimeFrame(Dates.Nanosecond(1))`. Replace DateTime inputs
with `Dates.Time` or NanoDates.NanoDate where submillisecond precision is needed.

## Upgrading from 0.2 to 0.8

The migration described below is available as version 0.8.0 in General.
The earlier 0.7.0 registration attempt was closed without merging; the 0.8.0
registration was merged on 2026-10-05 in JuliaRegistries/General#170649.

## Breaking changes

- **Modern package metadata:** the registered 0.2.0 used `REQUIRE` and declared
  Julia 0.7 compatibility. The migrated package uses `Project.toml` and the Dates
  standard library. Upgrade with modern Julia's Pkg tooling.
- **Minimum Julia version: 1.10.** Julia 1.6 through 1.9 are no longer supported.
  Install Julia 1.10 (LTS) or 1.13 with Juliaup before upgrading.
- **Invalid frequency errors:** invalid strings consistently throw `ArgumentError`
  instead of a mixture of `KeyError`, `ErrorException`, or silent identity frames.
  Replace exception-specific handlers accordingly.
- **Positive string magnitudes:** `TimeFrame("0T")` and numeric-only strings such
  as `TimeFrame("12")` are rejected. Use `TimeFrame()` or `TimeFrame("")` when
  you want an identity frame. Numeric constructors and period multiplication
  retain their existing behavior.
- **Boundary display:** boundary values now belong to the scoped
  `TimeFrames.BoundaryPolicy` enum and display as `BEGIN`, `END`, and `UNDEFINED`.
  The `Boundary` type alias, `Begin` and `End` constants, and integer values are
  preserved. Use these constants rather than parsing printed enum names.

## Corrected behavior

- `TimeFrame("5T"; boundary=End)` now constructs an immutable frame with the
  requested boundary instead of attempting to mutate it.
- String constructors also accept `AbstractString`, including `SubString`.
- `apply(NoTimeFrame(), dt)` returns `dt` unchanged, and
  `String(NoTimeFrame())` returns `""`.
- Arithmetic with a `Date` and `TimeFrame(Dates.Hour(1))`, or other subday generic
  frames, now promotes to `DateTime`, matching the named frame constructors.
- Generic calendar frames reject arithmetic with `Time` using `InexactError`,
  matching the named calendar frame constructors.

## Downstream packages

Julia's compatibility rules treat 0.2, 0.8, and 0.9 as different compatibility series.
Downstream packages must test against the migrated version before extending
their `[compat]` entry. Raising TimeFrames' minimum Julia version may also require
raising the downstream package's supported minimum.

The package UUID remains `51948d2b-02eb-5b28-9840-c902cc6821c9`. Existing units and
their default boundaries remain unchanged. Calendar rounding and exact-endpoint
semantics remain unchanged and are covered by the historical test suite.

## Publication checklist

1. Run tests and Aqua on Julia 1.10 and 1.13.
2. Build documentation without warnings and inspect both LLM documentation files.
3. Review the changelog and compare API changes with the registered 0.2.0 source.
4. Verify the proposed version is not already registered and choose its final
   number according to the documented compatibility changes.
5. Trigger Registrator with release notes containing a `Breaking changes`
   section; follow the resulting registry PR to completion.

General registration is a separate step from publishing a GitHub release.
