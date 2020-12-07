# PyMNE
Julia interface to MNE-Python via PyCall

[![Build Status](https://github.com/''/PyMNE.jl/workflows/CI/badge.svg)](https://github.com/''/PyMNE.jl/actions)


This package uses [`PyCall`](https://github.com/JuliaPy/PyCall.jl/) to make
[MNE-Python](https://mne.tools) available from within Julia. Unsurprisingly,
MNE-Python and  its dependencies need to be installed in order for this to work
and PyMNE  will attempt to install when the package is built.

By default, this installation happens in the "global" path for the Python used
by PyCall. If you're using PyCall via its hidden Miniconda install, your own
Anaconda environment, or a Python virtual environment, this is what you want.
(The "global" path is sandboxed to the Conda/virtual environment.) If you are
however using system python, then you should set `ENV["PIPFLAGS"] = "--user"`
before `add`ing / `build`ing the package. By default, PyMNE will use the latest
MNE release available on [PyPI](https://pypi.org/project/mne/), but this can also
be changed via the `ENV["MNEVERSION"] = version_number` for your preferred
`version_number`. Note that PyMNE explicitly does not try to abstract out
the rather rapid API changes and deprecation cycle in MNE and as such, it is
incumbent upon the user to manage these versions accordingly.


MNE-Python can also be installed them manually ahead of time.
From the shell, use `python -m pip install mne` for the latest stable release
or `python -m pip install mne==version_number` for a given `version_number`,
ensuring  that `python` is the same one that PyCall is using. Alternatively,
you can run this from within Julia:
```julia
using PyCall
pip = pyimport("pip")
pip.main(["install", "mne==version_number"]) # specific version
```

If you do not specify a version via `==version`, then the latest versions will be
installed. If you wish to upgrade versions, you can use
`python -m pip install --upgrade mne philistine` or
```julia
using PyCall
pip = pyimport("pip")
pip.main(["install", "--upgrade", "mne", "philistine"])
```

You can test your setup with `using PyCall; pyimport("mne")`.