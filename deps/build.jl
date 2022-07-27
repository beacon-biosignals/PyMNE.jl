# @info "Installing MNE-Python"
# using PyCall
# pip = pyimport("pip")
# flags = split(get(ENV, "PIPFLAGS", ""))
# ver = get(ENV, "MNEVERSION", "")
# packages = ["""mne$(isempty(ver) ? "" : "==")$(ver)"""]

# @info "Package requirements:" packages
# @info "Flags for pip install:" flags
# ver = isempty(ver) ? "latest" : ver
# @info "MNE version:" ver
# pip.main(["install"; flags; packages])
