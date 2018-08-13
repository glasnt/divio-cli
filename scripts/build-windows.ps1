# stop on first error
$ErrorActionPreference = "Stop"

$ARCH = "Windows"
$VENV = "venv-" + $ARCH

# cleanup
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue build
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue dist
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue divio_cli.egg-info
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $VENV

# create new venv

#$PIP=$(Get-Command pip  | Select-Object -ExpandProperty Definition)
#& $PIP install virtualenv

#C:\Python27\Scripts\pip.exe list
#C:\Python27\Scripts\pip.exe install --upgrade pip
#C:\Python27\Scripts\pip.exe install virtualenv
#C:\Python27\Scripts\virtualenv.exe $VENV

python -m pip install --upgrade pip
pip install virtualenv
virtualenv $VENV
.\venv-Windows\Scripts\activate

# pip and pyinstaller generate lots of warnings, so we need to ignore them
$ErrorActionPreference = "Continue"

# install build requirements

pip install pyinstaller -r requirements.txt -r requirements-windows.txt -r requirements-build.txt
pip install cryptography

# install divio-cli
pip install -e .

# prepare out folder
md -Force binary

# package app
.\$VENV\Scripts\pyinstaller.exe -F -y scripts\entrypoint.py -n divio-$ARCH.exe --hidden-import=_cffi_backend --distpath=binary

$ErrorActionPreference = "Stop"

# run check
Invoke-Expression ".\binary\divio-$ARCH version"
