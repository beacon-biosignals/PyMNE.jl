include("set_up_tests.jl")

@testset ExtendedTestSet "PyMNE" begin
    @testset "Aqua" begin
        Aqua.test_all(PyMNE; ambiguities=false)
    end

    @testset "info" include("info.jl")
    @testset "onda" include("onda.jl")
end
