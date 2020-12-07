"""
    create_info(args...; kwargs...)

A type-preserving wrapper around `mne.create_info`.

See [`PyMNE.mne.create_info`](@ref) for the associated MNE docstring.
"""
function create_info(args...; kwargs...)
    # `mne.create_info(...)` on its own gives us back a Julia `Dict`, but we actually
    # want the Python object, so we have to use `pycall`
    info = pycall(mne.create_info, PyObject, args...; kwargs...)
end

"""
    get_info(::PyObject)

Extract an `Info` property from an MNE object while preserving Python type.
"""
function get_info(o::PyObject)
   o."info"
end

# TODO: add a converting for Julia Dict to Python Info <: Dict