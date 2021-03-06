module PyMNE

#####
##### Dependencies
#####

using PyCall

#####
##### Exports
#####

export get_info

######
###### Actual functionality
######

const mne = PyNULL()

# TODO: examine how to do wrappers for subsubmodules. for now it's not a huge deal
#       because the wrapper just gets put in the top-level package namespace and so
#       is still accessible

include("wrappers.jl")

function __init__()
    # all of this is __init__() so that it plays nice with precompilation
    # see https://github.com/JuliaPy/PyCall.jl/#using-pycall-from-julia-modules
    copy!(mne, pyimport("mne"))
    # don't eval into the module while precompiling; this breaks precompilation
    # of downstream modules (see #4)
    if ccall(:jl_generating_output, Cint, ()) == 0
        # delegate everything else to mne
        for pn in propertynames(mne)
            isdefined(@__MODULE__, pn) && continue
            prop = getproperty(mne, pn)
            @eval $pn = $prop
        end
    end
    return nothing
end

end # module
