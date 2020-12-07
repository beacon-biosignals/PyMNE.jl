module PyMNE

using PyCall
const mne = PyNULL()
const ph = PyNULL()

function __init__()
    copy!(mne, pyimport("mne"))
    return nothing
end

include("wrappers.jl")

# delegate everything else to mne
for pn in propertynames(mne)
    @isdefined(pn) && continue
    prop = getproperty(mne, pn)
    @eval $pn = $prop
end

end # module