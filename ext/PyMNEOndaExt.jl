module PyMNEOndaExt

using PyMNE
using Onda
using TimeSpans

using PyMNE: mne

"""
    set_montage!(object, montage; match_case=false)

Set the montage for `object`, assumed to be a `Py` with a `set_montage` method,
to `montage`.
It is a shorthand for

```julia
object.set_montage(mne.channels.make_standard_montage(montage); match_case)
```
"""
function PyMNE.set_montage!(object, montage, match_case=false)
    return object.set_montage(mne.channels.make_standard_montage(montage); match_case)
end

"""
    mne_info(info::SamplesInfoV2; kwargs...)
    mne_info(channels, sample_rate; ch_types="eeg, kwargs...)

Create an `mne.Info` Python object.

`ch_types` is extracted from the `sensor_type` field of `SamplesInfoV2`

Keyword arguments are set as extra information stored in the Python object.
"""
PyMNE.mne_info(info; kwargs...) = PyMNE.mne_info(SamplesInfoV2(info); kwargs...)

function PyMNE.mne_info(info::SamplesInfoV2; kwargs...)
    channels = pylist(info.channels)
    sample_rate = pyfloat(info.sample_rate)
    ch_types = pystr(info.sensor_type)
    return mne_info(channels, sample_rate; ch_types, kwargs...)
end

function PyMNE.mne_info(channels, sample_rate; ch_types="eeg", kwargs...)
    info = mne.create_info(channels, sample_rate; ch_types=ch_types)
    for (k, v) in pairs(kwargs)
        info[String(k)] = v
    end
    return info
end


"""
    mne_raw(samples::Samples)

Construct an [`mne.io.RawArray`](https://mne.tools/stable/generated/mne.io.RawArray.html)
instance from a [`Onda.Samples`](https://beacon-biosignals.github.io/Onda.jl/stable/#Samples).
"""
function PyMNE.mne_raw(samples::Samples)
    samples = Onda.decode(samples)
    info = mne_info(samples.info)

    # scale _to_ volt
    if samples.info.sample_unit == "microvolt"
        scale = 1e-6
    elseif samples.info.sample_unit == "volt"
        scale = 1
    else
        throw(ArgumentError("Unknown unit, please file a pull request to add support."))
    end

    # Scale to volts
    return mne.io.RawArray(samples.data .* scale, info)
end

# TODO: convenience method for dealing fusing EEG and EOG from the same recording into a single MNE raw
# TODO: accept and attach annotations to raw

"""
    PyMNE.onda_info(info::Py; sensor_type="eeg",
                    sample_unit="microvolt", sample_resolution_in_unit=0.25,
                    sample_offset_in_unit=0, sample_type=Int16)

Create an `Onda.SamplesInfoV2` from an MNE `Info` object.
"""
function PyMNE.onda_info(info::Py; sensor_type="eeg",
                         sample_unit="microvolt", sample_resolution_in_unit=0.25,
                         sample_offset_in_unit=0, sample_type=Int16)
    sample_rate = pyconvert(Float64, info["sfreq"])
    channels = pyconvert(Vector{String}, info["ch_names"])

    return SamplesInfoV2(; sample_unit,
                         sample_resolution_in_unit,
                         sample_offset_in_unit,
                         sample_type,
                         sample_rate,
                         sensor_type,
                         channels)
end

"""
    PyMNE.onda_samples(raw::Py; kwargs...)

Create an `Onda.Samples` from an MNE `Raw` (or `RawArray`) object.

`kwargs...` are forwarded to [`onda_info`](@ref).

!!! note "Multiple source sensor types not supported"
    MNE can store multiple channel types in a single `Raw` entity,
    while Onda stores each set of sensor types in a separate signal.
    Currently, this function will return only a single `Samples` object
    and as such cannot handle multiple channel types in the source
    MNE object.
"""
function PyMNE.onda_samples(raw::Py; kwargs...)
    allequal(raw.get_channel_types()) ||
        error("Converting from raw with multiple channel types is not currently supported.")
    sensor_type = pyconvert(String, first(raw.get_channel_types()))
    info = onda_info(raw.info; sensor_type, kwargs...)

    # scale _from_ volt
    if info.sample_unit == "microvolt"
        scale = 1e6
    elseif info.sample_unit == "volt"
        scale = 1
    else
        throw(ArgumentError("Unknown unit, please file a pull request to add support."))
    end

    # we always copy the data because we don't want to mess with the scaling of the original object
    data = PyArray(raw.get_data()) .* scale

    return Samples(data, info, false)

end

end # module
