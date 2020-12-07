@info "Installing MNE-Python"
using PyCall
pip = pyimport("pip")
flags = split(get(ENV, "PIPFLAGS", ""))
packages = ["mne==0.20.8"]

@info "Package requirements:" packages
@info "Flags for pip install:" flags

pip.main(["install"; flags; packages])
