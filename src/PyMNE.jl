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
    copy!(mne, pyimport("mne"))
end

macro load_pymne()
    assignments = []
    for pn in propertynames(PyMNE.mne)
        isdefined(@__MODULE__, pn) && continue
        prop = getproperty(PyMNE.mne, pn)
        push!(assignments, Expr(:(=), pn, prop))
    end
    Expr(:block, assignments...)
end

end # module
