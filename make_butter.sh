#!/bin/sh

## Version 0.2
##
## Usage
## ./make_butter.sh
##
## The script make_butter.sh allows you to setup, and build a version of Butter

execsudo() {
    case $OSTYPE in msys*)
       echo $OSTYPE
       $1
       ;;
    *)
       sudo $1
       ;;
    esac
}

try="True"
tries=0
while [ "$try" = "True" ]; do
    read -p "Do you wish to install the required dependencies for Butter and setup for building? (yes/no) [default is yes] " rd_dep
    if [ -z "$rd_dep" ]; then
        rd_dep="yes"
    fi
    tries=$((tries+1))
    if [ "$rd_dep" = "yes" ] || [ "$rd_dep" = "no" ]; then
        try="False"
    elif [ "$tries" -ge "3" ]; then
        echo "No valid input, exiting"
        exit 3
    else
        echo "Not a valid answer, please try again"
    fi
done

if [ "$rd_dep" = "yes" ]; then
    echo "Installing global dependencies"
    if execsudo "npm install -g bower grunt-cli"; then
        echo "Global dependencies installed successfully."
    else
        echo "Global dependencies encountered an error while installing"
        echo "************************************************************************"
        echo "* Global dependencies encountered an error while installing            *"
        echo "* Please report your issue providing the output at :                   *"
        echo "* https://github.com/butterproject/butter-desktop-angular/issues       *"
        echo "************************************************************************"
        exit 4
    fi

    echo "Installing local dependencies"
    if npm install; then
        echo "Local dependencies installed successfully."
    else
        echo "************************************************************************"
        echo "* Local dependencies encountered an error while installing             *"
        echo "* Please report your issue providing the output at :                   *"
        echo "* https://github.com/butterproject/butter-desktop-angular/issues       *"
        echo "************************************************************************"
        exit 4
    fi

    echo "Successfully setup for Butter"
fi

echo "Building grunt"
if grunt build; then
    echo "************************************************************************"
    echo "* Butter built successfully.                                           *"
    echo "* - Run 'grunt start' from inside the repository to launch the app     *"
    echo "* - Run 'grunt dev' if you want butter to reload when the source code  *"
    echo " is modified.                                                          *"
    echo "* Enjoy.                                                               *"
    echo "************************************************************************"
else
    echo "************************************************************************"
    echo "* Butter encountered an error and couldn't be built                    *"
    echo "* Please report your issue providing the output at :                   *"
    echo "* https://github.com/butterproject/butter-desktop-angular/issues       *"
    echo "************************************************************************"
    exit 5
fi
