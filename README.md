# PyMNE
Julia interface to MNE-Python via PythonCall

[![Build Status][build-img]][build-url] [![CodeCov][codecov-img]][codecov-url]

[build-img]: https://github.com/beacon-biosignals/PyMNE.jl/workflows/CI/badge.svg
[build-url]: https://github.com/beacon-biosignals/PyMNE.jl/actions
[codecov-img]: https://codecov.io/github/beacon-biosignals/PyMNE.jl/badge.svg?branch=main
[codecov-url]: https://codecov.io/github/beacon-biosignals/PyMNE.jl?branch=main


## Installation
This package uses [`PythonCall`](https://cjdoris.github.io/PythonCall.jl) to make
[MNE-Python](https://mne.tools) available from within Julia. Unsurprisingly,
MNE-Python and its dependencies need to be installed in order for this to work
and PyMNE will attempt to install when the package is built: this should happen
more or less automatically via [`CondaPkg`](https://github.com/cjdoris/CondaPkg.jl).
You can configure various options via `CondaPkg`. MNE-Python is installed via
Conda, not via pip.

## Usage

In the same philosophy as PythonCall, this allows for the transparent use of
MNE-Python from within Julia.
The major things the package does are wrap the installation of MNE in the
package installation and load all the MNE functionality into the module
namespace.
After that, it's just a Python package accessible via `using PyMNE` in
Julia. The usual conversion rules and behaviors from PythonCall apply.
The [tests](test/runtests.jl) test a few conversion gotchas, especially
compared to prior versions of this package, which were based on
[PyCall](https://github.com/JuliaPy/PyCall.jl).

## Hint:
You need to explicitly convert vectors of strings to a `PyList`. For instance
```julia
data = raw.get_data(picks=["Oz","Cz"])
```
does not work, whereas 
```julia
data = raw.get_data(picks=pylist(["Oz","Cz"]))
```
works. The underlying logic is, that the [automatic conversion](https://cjdoris.github.io/PythonCall.jl/dev/pycall/#Lossiness-of-conversion) of  `["A","B"]`is to a `juliacall.VectorValue` which behaves similar to a `pyList` - but is apparently not recognized properly by MNE (a vector of int, surprisingly, works though).


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

The PythonCall infrastructure also means that Python docstrings are available
in Julia:

```julia
help?> PyMNE.open_docs
  Python function open_docs.

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
