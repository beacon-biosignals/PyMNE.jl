using Aqua
using Dates
using Onda
using PyMNE
using Random
using Test
using TestSetExtensions
using TimeSpans

using Legolas: record_merge

function sine_waves(freq_hz...; phase=0, amplitude=1, sample_rate=200, duration=Minute(10))
    n_channels = length(freq_hz)
    n_samples = index_from_time(sample_rate, duration)
    data = zeros(n_channels, n_samples)

    info = SamplesInfoV2(; channels=string.(("c$i" for i in 1:n_channels)),
                         sample_unit="microvolt", sample_resolution_in_unit=0.25,
                         sample_offset_in_unit=0, sample_type=Int16,
                         sample_rate=sample_rate,
                         sensor_type="eeg")

    ts = range(0, duration / Second(1);
               length=size(data, 2))
    for (amp, row, freq, ph) in zip(amplitude, eachrow(data), freq_hz, phase)
        row .= amp .* sin.(2π .* freq .* ts .+ ph)
    end

    return Samples(data, info, false)
end
