module Testing

using PyMNE
PyMNE.@load_pymne()

using PyCall
using Test

using PyCall: PyError

@testset "create_info and get_info" begin
    dat = zeros(1, 100)
    naive_info = PyMNE.mne.create_info([:a], 100)
    wrapped_info = PyMNE.create_info([:a], 100)
    raw = PyMNE_API.io.RawArray(dat, wrapped_info)
    @test raw.get_data() == dat
    @test get_info(raw) isa PyObject
    @test raw.info isa Dict
    @test_throws PyError PyMNE_API.io.RawArray(dat, naive_info)
end

end # module
