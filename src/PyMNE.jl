module PyMNE

#####
##### Dependencies
#####

using Reexport

@reexport using PythonCall

######
###### Actual functionality
######

const mne = PythonCall.pynew()

function __init__()
    # all of this is __init__() so that it plays nice with precompilation
    # see https://github.com/cjdoris/PythonCall.jl/blob/5ea63f13c291ed97a8bacad06400acb053829dd4/src/Py.jl#L85-L96
    PythonCall.pycopy!(mne, pyimport("mne"))
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

#####
##### Onda-related stubs
#####

function set_montage! end
function mne_info end
function mne_raw end
function onda_info end
function onda_samples end

export mne_info, set_montage!, mne_raw, onda_samples, onda_info


end # module
