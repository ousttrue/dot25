$ErrorActionPreference = "Stop"

$env:XDG_CONFIG_HOME = "$HOME/.config"
if($IsWindows)
{
  $env:_CL_ = "/utf-8"
  $shada_dir = (Join-Path ${env:LOCALAPPDATA} "\nvim-data\shada") 
} else
{
  $shada_dir = (Join-Path ${env:HOME} ".local/state/nvim/shada") 
}

$SEP = [System.IO.Path]::DirectorySeparatorChar
$env:FZF_DEFAULT_OPTS = "--layout=reverse --preview-window down:70%"
$env:LUA_PATH = "${HOME}${SEP}lua${SEP}?.lua;${HOME}${SEP}lua${SEP}?${SEP}init.lua"

#
# Aliases
#
Remove-Item alias:* -force
Set-Alias cd Set-Location
Set-Alias pwd Get-Location
Set-Alias echo Write-Output
Set-Alias % ForEach-Object
Set-Alias ? Where-Object
Set-Alias vswhere "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
$NVIM_PREFIX = Join-Path $HOME "neovim"
Set-Alias v (Join-Path $NVIM_PREFIX "\bin\nvim")

#
# Path
#
function has($cmdname)
{
  try
  {
    # CmdletInfo | ApplicationInfo | AliasInfo | FunctionInfo
    switch (Get-Command $cmdname -ErrorAction Stop)
    {
      { $_ -is [System.Management.Automation.AliasInfo] }
      {
        $_.Definition
      }
      { $_ -is [System.Management.Automation.ApplicationInfo] }
      {
        $_.Definition
      }
      { $_ -is [System.Management.Automation.CmdletInfo] }
      {
        $_
      }
      { $_ -is [System.Management.Automation.FunctionInfo] }
      {
        $_
      }
      default
      {
        $_.GetType()
      }
    }
  } catch
  {
    return $false;
  }
}
if (!(has 'which'))
{
  Set-Alias which has
}
if(has ov)
{
  $env:PAGER="ov"
}
function insertPath($path)
{
  if (-not $env:PATH.Contains($path))
  {
    $env:PATH = $path + [System.IO.Path]::PathSeparator + $env:PATH
    $path
  } else
  {
    $null
  }
}
#
function addPath($path)
{
  if (-not $env:PATH.Contains($path))
  {
    $env:PATH = $env:PATH + [System.IO.Path]::PathSeparator + $path
    $path
  } else
  {
    $null
  }
}

function Get-Python
{
  $pyenv_py = Join-Path $HOME ".pyenv/shims/python"
  if(Test-Path $pyenv_py)
  {
    Join-Path $HOME ".pyenv/shims"
  } elseif($IsWindows)
  {
    py -c "import sys; print(sys.base_prefix)"
  } elseif(has python)
  {
    python -c "import sys; print(sys.base_prefix)"
  } elseif(has python3)
  {
    python3 -c "import sys; print(sys.base_prefix)"
  }
}

addPath(Join-Path $HOME "\ghq\github.com\junegunn\fzf\bin")
addPath(Join-Path $HOME "\.fzf\bin")
addPath(Join-Path $HOME "\.deno\bin")
addPath(Join-Path $HOME "\.cargo\bin")
addPath(Join-Path $HOME "\go\bin")
addPath(Join-Path $HOME "\gtk\bin")
addPath(Join-Path $HOME "\.local\bin")
addPath(Join-Path $HOME "\zig")
insertPath(Join-Path $HOME "\local\bin")
if ($IsWindows)
{
  addPath("C:\Program Files\qemu")
  addPath('C:\Program Files\Erlang OTP\bin')
} else
{
  addPath("/usr/local/go/bin")
}
if ($IsMacOS)
{
  addPath("/opt/homebrew/bin")
}
addPath(join-Path $HOME '/Downloads/Visual Studio Code.app/Contents/Resources/app/bin')

# if (has py)
# {
$PY_PREFIX = Get-Python
insertPath($PY_PREFIX)
insertPath(Join-Path $PY_PREFIX "Scripts")
# }

if ($IsMacOS)
{
  $env:N_PREFIX = (Join-Path $env:HOME "/.n")
  addPath(Join-Path $env:N_PREFIX "/bin")
}

if($null -eq $env:JAVA_HOME)
{
  $jbr_dir = "C:\java\jbr_jcef-17.0.10-windows-x64-b1207.14"
  if(Test-Path $jbr_dir)
  {
    $env:JAVA_HOME = $jbr_dir
    addPath (Join-Path $jbr_dir "bin")
  }
}

# For zoxide v0.8.0+
if (has zoxide)
{
  Invoke-Expression (& {
      $hook = if ($PSVersionTable.PSVersion.Major -lt 6)
      {
        'prompt' 
      } else
      {
        'pwd' 
      }
    (zoxide init --hook $hook powershell | Out-String)
    })
}

# cd ghq
function gg
{
  $dst = $(ghq list -p | fzf --reverse +m --preview "bat --color=always --style=header,grid --line-range :100 {}/README.md")
  if ($dst)
  {
    Set-Location "$dst"
  }
}
function grm
{
  $dst = $(ghq list -p | fzf --reverse +m --preview "bat --color=always --style=header,grid {}/README.md")
  if ($dst)
  {
    $parent = (Split-Path -Parent $dst)
    "remove : ${dst}" | Out-Host 
    Remove-Item -Recurse -Force $dst
    if (!(Get-ChildItem $parent))
    {
      # empty
      "remove parent: ${parent}" | Out-Host 
      Remove-Item -Recurse -Force $parent
    }
  }
}
function vv
{
  $dst = $(ghq list -p | fzf --reverse +m)
  if ($dst)
  {
    Set-Location "$dst"
    git pull
    nvim
  }
}

# git switch
function gs
{
  $dst = $(git branch | fzf)
  if ($dst)
  {
    git switch $args $dst.Trim()
  }
}
# git switch remote
function gsr
{
  $dst = $(git branch -r | fzf)
  if ($dst)
  {
    git switch -c $dst.Trim() $dst.Trim()
  }
}

function git_rm_merged
{
  git branch --merged
  | Select-String -NotMatch -Pattern "(\*|develop|master)" 
  | ForEach-Object { git branch -d $_.ToString().Trim() }
}

# meson wrap
function mewrap
{
  $dst = $(meson wrap list | fzf --preview "meson wrap info {}")
  if ($dst)
  {
    meson wrap install $dst.Trim()
  }
}

# git cd root
function root()
{
  Set-Location $(git rev-parse --show-toplevel)
}
# git status
function gt()
{
  git status -sb
}
function glg()
{
  git lga
}
# pip
function pipup()
{
  py -m pip install pip --upgrade
}

$env:PSModulePath = "$PSScriptRoot\modules;${env:PSModulePath}" 
Import-Module prompt -ErrorAction SilentlyContinue
