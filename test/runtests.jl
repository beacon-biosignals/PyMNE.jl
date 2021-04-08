using PyMNE
using PyCall
using Test

using PyCall: PyError

@testset "sklearn" begin
    PyMNE.install_sklearn()
    # requires sklearn
    @test PyMNE.preprocessing.ICA(method="fastica") isa PyObject
end

@testset "create_info and get_info" begin
    dat = zeros(1, 100)
    naive_info = PyMNE.mne.create_info([:a], 100)
    wrapped_info = PyMNE.create_info([:a], 100)
    raw = PyMNE.io.RawArray(dat, wrapped_info)
    @test raw.get_data() == dat
    @test get_info(raw) isa PyObject
    @test raw.info isa Dict
    @test_throws PyError PyMNE.io.RawArray(dat, naive_info)
end
