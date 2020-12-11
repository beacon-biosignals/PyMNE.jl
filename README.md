# PyMNE
Julia interface to MNE-Python via PyCall

[![Build Status][build-img]][build-url] [![CodeCov][codecov-img]][codecov-url]

[build-img]: https://github.com/beacon-biosignals/PyMNE.jl/workflows/CI/badge.svg
[build-url]: https://github.com/beacon-biosignals/PyMNE.jl/actions
[codecov-img]: https://codecov.io/github/beacon-biosignals/PyMNE.jl/badge.svg?branch=master
[codecov-url]: https://codecov.io/github/beacon-biosignals/PyMNE.jl?branch=master


## Installation
This package uses [`PyCall`](https://github.com/JuliaPy/PyCall.jl/) to make
[MNE-Python](https://mne.tools) available from within Julia. Unsurprisingly,
MNE-Python and its dependencies need to be installed in order for this to work
and PyMNE will attempt to install when the package is built.

By default, this installation happens in the "global" path for the Python used
by PyCall. If you're using PyCall via its hidden Miniconda install, your own
Anaconda environment, or a Python virtual environment, this is what you want.
(The "global" path is sandboxed to the Conda/virtual environment.) If you are
however using system Python, then you should set `ENV["PIPFLAGS"] = "--user"`
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
`python -m pip install --upgrade mne` or
```julia
using PyCall
pip = pyimport("pip")
pip.main(["install", "--upgrade", "mne"])
```

You can test your setup with `using PyCall; pyimport("mne")`.

## Usage

In the same philosophy as PyCall, this allows for the transparent use of
MNE-Python from within Julia.
The major things the package does are wrap the installation of MNE in the
package `build` step, load all the MNE functionality into the module namespace,
and provide a few accessors.


### Exposing MNE-Python in Julia

For example, in Python you can access the MNE docs like this:

```python
import mne

mne.open_docs()
```

With PyMNE, you can do this from within Julia.

```julia
using PyMNE

PyMNE.open_docs()
```

The PyCall infrastructure also means that Python docstrings are available
in Julia:

```julia
help?> PyMNE.open_docs
Launch a new web browser tab with the MNE documentation.

    Parameters
    ----------
    kind : str | None
        Can be "api" (default), "tutorials", or "examples".
        The default can be changed by setting the configuration value
        MNE_DOCS_KIND.
    version : str | None
        Can be "stable" (default) or "dev".
        The default can be changed by setting the configuration value
        MNE_DOCS_VERSION.
```

### Helping with type conversions

PyCall can be rather aggressive in converting standard types, such as
dictionaries, to their native Julia equivalents, but this can create problems
due to differences in the way inheritance is traditionally used between
languages.
As a concrete example, MNE-Python defines an `Info` type that extends the
Python dictionary.
If an `Info` object is accessed naively from Julia, then it is converted to a
dictionary and the subtyping is lost when passed back to Python, which can
result in type/method errors.
(There is [some discussion](https://github.com/JuliaPy/PyCall.jl/issues/629)
about not automatically converting derived types in PyCall 2.0, exactly
because of this.)
To avoid this problem, PyMNE wraps a few methods to avoid this conversion,
namely Python's `mne.create_info` and the `info` property of many MNE types.

```julia
julia> using PyMNE
julia> using Random # for generating fake data
julia> dat = rand(MersenneTwister(42), 1, 100); # fake data
julia> PyMNE.mne # direct access to the mne Python module without any wrapping
PyObject <module 'mne' from '/home/ubuntu/.julia/conda/3/lib/python3.8/site-packages/mne/__init__.py'>
julia> naive_info = PyMNE.mne.create_info([:a], 100) # gets converted to a Julia dictionary
Dict{Any,Any} with 36 entries:
  "projs"           => Any[]
  "utc_offset"      => nothing
  "dev_head_t"      => Dict{Any,Any}("trans"=>[1.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0; 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 1.0],"to"=>4,"from"=>1)
  "experimenter"    => nothing
  "proj_name"       => nothing
  "nchan"           => 1
  "ctf_head_t"      => nothing
  "acq_stim"        => nothing
  "events"          => Any[]
  "lowpass"         => 50.0
  "helium_info"     => nothing
  "proc_history"    => Any[]
  "xplotter_layout" => nothing
  "dig"             => nothing
  "kit_system_id"   => nothing
  "file_id"         => nothing
  ⋮                 => ⋮
julia> PyMNE.io.RawArray(dat, naive_info) # RawArray requires an Info object and not a 'simple' dictionary
ERROR: PyError ($(Expr(:escape, :(ccall(#= /home/ubuntu/.julia/packages/PyCall/BcTLp/src/pyfncall.jl:43 =# @pysym(:PyObject_Call), PyPtr, (PyPtr, PyPtr, PyPtr), o, pyargsptr, kw))))) <class 'TypeError'>
TypeError("info must be an instance of Info, got <class 'dict'> instead")
  File "<decorator-gen-158>", line 21, in __init__
  File "/home/ubuntu/.julia/conda/3/lib/python3.8/site-packages/mne/io/array/array.py", line 56, in __init__
    _validate_type(info, 'info', 'info')
  File "/home/ubuntu/.julia/conda/3/lib/python3.8/site-packages/mne/utils/check.py", line 379, in _validate_type
    raise TypeError('%s must be an instance of %s, got %s instead'

Stacktrace:
 [1] pyerr_check at /home/ubuntu/.julia/packages/PyCall/BcTLp/src/exception.jl:62 [inlined]
. . .

julia> wrapped_info = PyMNE.create_info([:a], 100) # preserves Python type and show method
PyObject <Info | 7 non-empty values
 bads: []
 ch_names: a
 chs: 1 MISC
 custom_ref_applied: False
 highpass: 0.0 Hz
 lowpass: 50.0 Hz
 meas_date: unspecified
 nchan: 1
 projs: []
 sfreq: 100.0 Hz
>

julia> PyMNE.io.RawArray(dat, wrapped_info) # now has right type
Creating RawArray with float64 data, n_channels=1, n_times=100
    Range : 0 ... 99 =      0.000 ...     0.990 secs
Ready.
PyObject <RawArray | 1 x 100 (1.0 s), ~8 kB, data loaded>
```

If other automatic type conversions are found to be problematic or there are
particular MNE functions that don't play nice via the default PyCall mechanisms,
then issues and pull requests are welcome.
