using TestItemRunner

@testitem "Package quality" begin
    using Aqua
    Aqua.test_all(TimeFrames)
end
