samples = sine_waves(3, 6, 12)

# this also tests the mne_info method for SamplesInfoV2
raw = mne_raw(samples)
@test raw isa Py
# test named tuple method directly
py_info = mne_info(NamedTuple(samples.info))
@test py_info isa Py

@test pyis(raw.get_montage(), Py(nothing))
set_montage!(raw, "standard_1020")
@test !pyis(raw.get_montage(), Py(nothing))

# roundtripping works
@test samples.info == onda_info(py_info; sensor_type="eeg")
roundtripped = onda_samples(raw)
@test roundtripped.info == samples.info
# only approximate equality because of floating point fun when rescaling back and forth
@test PyArray(raw.get_data()) ≈ samples.data * 1e-6
@test roundtripped.data ≈ samples.data

# different scaling factor
volts = Samples(samples.data,
                record_merge(samples.info; sample_unit="volt"),
                false)
raw_volts = mne_raw(volts)
# no scaling, so we should have exact equality
@test PyArray(raw_volts.get_data()) == volts.data
roundtripped_volts = onda_samples(raw_volts; sample_unit="volt")
@test roundtripped_volts.data == samples.data
