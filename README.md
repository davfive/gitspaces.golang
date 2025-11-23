<picture>
   <source media="(prefers-color-scheme: dark)" srcset="./docs/files/gitspaces.dark.png">
   <img width="150" alt="Light and Dark logos" src="./docs/files/gitspaces.light.png">
</picture>

# gitspaces - A git development workspace manager

# DEPRECATED

This module is deprecated and archived at [gitspaces.golang](https://github.com/davfive/gitspaces). v3 is now a [gitspaces pypi package](https://pypi.org/project/gitspaces/).

## What is GitSpaces

If you're familiar with ClearCase Views, think of GitSpaces as their counterpart for Git projects. If not, you're in for a treat.

GitSpaces manages multiple independent clones of a project for you so you can switch between them as you work on new features or bugs.

Instead of using `git clone url/to/repo-abc` use `gitspaces create url/to/repo-abc.git` and you will get

```
~/.../projects
 └── repo-abc
     ├── __GITSPACES_PROJECT__              
     ├── space-1/
     │   └── ... repo cloned here
     ├── space-2-...
     ├── space-N/
     └── .zzz         # extra clone copies for different tasks
         ├── zzz-0/
         │   └── ... and cloned here
         ├── zzz-1/
         │   └── ... and here here
         ├── zzz-...
         └── zzz-N/
```

Where you will be able to work independently on features, bugs, etc

### Commands

The `gitspaces` command 

#### USAGE
`gitspaces COMMAND`  

or simplify your life with `alias gs=gitspaces`.

#### WHERE
COMMAND  | Description
---------|------------------------
`setup`  | Helps user setup config.yaml and 'cd' shell wrappers.
`create` | Creates a new GitSpace project from a git repo url
`switch` | Switch spaces. Default, same as `gitspaces` w/o a command.
`rename` | Rename a current gitspace
`sleep`  | Archive a gitspace and wakes up another one
`code`   | Launches Visual Studio Code Workspace for the space


## Installation

gitspaces is implemented in Go, so

1. [Install Go](https://go.dev/doc/install)
   
2. Install GitSpaces  
   [![Go Reference](https://pkg.go.dev/badge/github.com/davfive/gitspaces/v2.svg)](https://pkg.go.dev/github.com/davfive/gitspaces/v2)
   ```
   $ go install github.com/davfive/gitspaces/v2@latest
     -> installs to ~/go/bin/gitspaces

   $ gitspaces setup
     -> run once to install .gitspaces config directory and start user setup
   ```

## Initial Setup and Use

Run `gitspaces setup` to be walked through first-time configuration. 

If you run any `gitspaces <cmd>` and your environment isn't setup properly, `gitspaces setup` setup will automatically run.

GitSpaces configuration directory is created on first run.

### Step 1 - Configure where you keep your git projects

GitSpaces config.yaml file contains a ProjectPaths field.
This field defines a list of paths to your project directories.

Instructions for setting up ProjectPaths field is in the config file.

**Windows:**

    %USERPROFILE%/.gitspaces/config.yaml

**Mac/Linux**

    `MacOS:   ~/.gitspaces/config.yaml`

### Step 2 - Configure the gitspaces shell wrapper

Some gitspaces commands change the current working directory of the user. To accomplish this, gitspaces is run through a shell (bash / powershell) wrapper. Once you've setup your shell wrapper, restart your terminal and start using GitSpaces.

**Bash/Zsh (Mac/Linux/Windows)**

Copy the following lines into your .bashrc or .zshrc file.

    . ~/.gitspaces/gitspaces.function.sh
    alias gs=gitspaces  # optional

**PowerShell (Mac/Windows)**

Copy the following lines into your PowerShell $PROFILE

For more information, see [PowerShell > About Profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles)

Copy the following to your $PROFILE

    . $HOME/.gitspaces/gitspaces.scriptblock.ps1
    Set-Alias -Name gs -Value gitspaces           # optional

### Step 3 - Create your first GitSpaces project

Open a terminal and run

   gitspaces create https://github.com/davfive/gitspaces -n 3

This will create a new GitSpaces project with three clones of this gitspaces project. By default all spaces are "asleep". You will be asked to wake one up and give it a name.