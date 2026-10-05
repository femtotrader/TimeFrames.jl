# Modernization requirements

These requirements describe the migration before publication; milestones are not
releases. These requirements record the migration released and registered as
version 0.8.0. Subsequent issue follow-ups are recorded under version 0.9.0 in the
changelog.

| ID | Priority | Requirement | Verification |
| --- | --- | --- | --- |
| TF-001 | Must | The package shall support Julia 1.10 and Julia 1.13. | Run the complete tests on both versions. |
| TF-002 | Must | When a supported frequency is supplied with an explicit boundary, the constructor shall return an immutable frame with that boundary. | Constructor and boundary regression tests. |
| TF-003 | Must | When an invalid frequency or nonpositive magnitude is supplied, the string constructor shall throw `ArgumentError`. | Invalid input regression tests. |
| TF-004 | Must | When an identity frame is applied to a time value, the package shall return that value unchanged. | Identity tests for `Date`, `DateTime`, and `Time`. |
| TF-005 | Must | When a generic subday frame is added to or subtracted from a `Date`, the package shall promote the result to `DateTime`. | Arithmetic tests for hour through millisecond periods. |
| TF-006 | Must | When the documentation is built, the build shall validate examples, fail on documentation warnings, and produce `llms.txt` and `llms-full.txt`. | Strict documentation builds and output checks. |
| TF-007 | Must | Before publication, the project shall document incompatible changes, migration instructions, and release notes. | Changelog and migration guide review. |
| TF-008 | Should | The CI shall test Linux, Windows, and macOS, with nightly failures reported without blocking supported versions. | Workflow review. |
| TF-009 | Should | When contributors run quality checks, Aqua shall check the package without disabled checks. | Aqua test suite. |
| TF-010 | Should | The project shall expose test and documentation commands through a justfile and describe Juliaup setup. | Contributor guide and command validation. |
| TF-011 | Must | The documentation shall use Documenter and DocumenterLandingPage with sources under `docs/`. | Documentation output and landing page checks. |
| TF-012 | Should | The CI shall verify JuliaFormatter style and dependency maintenance shall cover all project environments. | Formatting checks and workflow validation. |

## Milestones

1. Write regression tests and reproduce failures on Julia 1.10.
2. Correct constructors, parsing, identity behavior, and arithmetic.
3. Add documentation, quality checks, and supported-version CI.
4. Validate tests and warning-free documentation on Julia 1.10 and 1.13.
5. Publish only after migration validation, with documented breaking changes.

## Scope deferred

Performance tuning remains deferred. Additional frequency aliases are now
implemented on the development branch. A type-system
redesign and a 1.0 API stabilization are outside this migration.

Assisted-by: AI
