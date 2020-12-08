module PyMNE

using PyCall
const mne = PyNULL()

function __init__()
    # all of this is __init__() so that it plays nice with precompilation
    # see https://github.com/JuliaPy/PyCall.jl/#using-pycall-from-julia-modules

    copy!(mne, pyimport("mne"))

    include(joinpath(@__DIR__, "wrappers.jl"))

    # TODO: examine how to do wrappers for subsubmodules. for now it's not a huge deal
    #       because the wrapper just gets put in the top-level package namespace and so
    #       is still accessible

    # delegate everything else to mne
    for pn in propertynames(mne)
        isdefined(@__MODULE__, pn) && continue
        prop = getproperty(mne, pn)
        @eval $pn = $prop
    end

    return nothing
end

export get_info

end # module