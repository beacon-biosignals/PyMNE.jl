using PyMNE
using Random
using Test

@testset "create_info and get_info" begin
    dat = rand(1, 100)
    info = PyMNE.create_info(pylist(["a"]), 100)
    @test info isa Py
    @test pyconvert(String, only(info.ch_names)) == "a"
    # XXX why all the pyconvert? well comparisons of python objects give you
    # a python boolean, so we need to explicitly convert for @OTDE
    # this is fine because it shows usage and tests out a bit more code
    @test pyconvert(Bool, info.ch_names == info["ch_names"])
    # if this ever works after a compat bump then we know we need to change things
    @test_broken info.ch_names == info["ch_names"]
    @test pyconvert(Bool, info["sfreq"] == 100)
    @test pyconvert(Number, info["sfreq"]) == 100
    raw = PyMNE.io.RawArray(dat, info)
    @test pyconvert(Number, raw.n_times) == 100
    @test pyconvert(Number, raw.n_times) isa Int
    @test pyconvert(Number, raw.info["sfreq"]) == 100
    # we want elementwise precise equality
    @test all(pyconvert(AbstractArray, raw.get_data()) .== dat)
end
