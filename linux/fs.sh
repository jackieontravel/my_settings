#!/bin/sh

export FS_REL_VER="v3.5.0"
export FS_REL_DATE="2015/12/22"
#############################################################################
### Revison History
###	2015/12/22  v3.5.0
###     [add] Add '-i' to 'ff' to allow search filename and ignore case
###     [add] Add '-h' and '--help' option to fs/ff to show usage
###     [change] fshelp/ffhelp improvement
###	2015/11/26  v3.4.0
###     [change] Run 'ff' by Linux native shell command, instead of python 'Popen', this greatly improve the running performance
###     [add] Support 'fsp' for 'fs'
###     [add] Add fsj to search Java and fsm to search Makefile
###     [bugfix] Fix the globing issue for fsc/fsh when current directory contains *.c/*.h
###     [change] Show version when running 'ff' -- align to 'fs'
###     [change] Use 'less' to shwo fshelp and ffhelp as they are growing bigger.
###	    [change] Update fshelp and ffhelp
###	    [change] Use alias instead of functions for fs variants (fsc, fsh,...), this makes fs.sh simpler
###     [change] Exclude 'gtags.conf' by default in 'fs'. It's a huge file and we don't need it.
###     [change] Add color to 'ffls'
###     [code] Replace all '$*' in shell function to '$@' which is the right parameters although they are similar.
###	2015/11/25  v3.3.0
###	    [add] Add 'fsd' and 'fsp' switch for 'ff' command
###	    [change] Update fshelp and ffhelp
###	    [code] Code refactoring for 'ff'
###	    [code] Remove useless code snippet: 'ofs'
###	2015/11/25  v3.2.1
###	    [bugfix] Fix the bug that 'fst=*.c' may not working for 'fs' if current folder contains *.c file
###	    [change] ffrm now confirms before really removes
###	    [change] Add color display to 'ffll' results.
###	    [code] Code refactoring for 'ff'
################################################################################


export FS_CMD_FILE="$HOME/.fs_cmd_file"
export FF_CMD_FILE="$HOME/.ff_cmd_file"


#############################################################################
### Installation: 
### 1. Put fs.sh and fs.py in the same folder
### 2. In $HOME/.bashrc, do the following:
###     export WINDOWS_DISK="L:"    # Set your own disk name. defualt U: for normal env. W: for Mock
###     export WINDOWS_EDITOR="notepad++"   # default is notepad++, this can be skipped if you use notepad++
###     source <path_where_fs.sh_is_located>/fs.sh 
###     export PATH=$PATH:<path_where_fs.sh_is_located>
################################################################################
function fs() 
{ 
	# Make sure the quoted searching pattern can be handled 
	pattern=$1

	if [ $# -gt 1 ] ; then
        shift;
		FS_REL_VER=$FS_REL_VER FS_REL_DATE=$FS_REL_DATE fs.py fs "$pattern" $@;
	else
        case "$pattern" in
            "-h")
                fshelp
                return
                ;;
            "--help")
                fshelp
                return
                ;;
            *) 
                FS_REL_VER=$FS_REL_VER FS_REL_DATE=$FS_REL_DATE fs.py fs "$pattern";
                ;;
        esac
	fi
	
	if [ $? == 0 ]; then 
		source $FS_CMD_FILE
	fi
}; 



_fshelp()
{
    echo -e "**********"
    echo -e "fs ${FS_REL_VER}"
    echo -e "~Jackie Yeh ${FS_REL_DATE}"
    echo -e "**********"
    echo -e "shell function to find string in all subdirectory, exclude:"
    echo -e " -- binary files (*.o; *.so; *.map; )"
    echo -e " -- all files version control: .svn, .git"
    echo -e " -- tagging system files:ctags, ctags.tmp, GPATH, GRTAGS, GTAGS, tags, gtags.conf"
    echo -e " -- *.d"
    echo -e " "
    echo -e "Usage:"
    echo -e "     [f2=<grep2_opt>]...[f8=<grep8_opt>][fst=<fs_Type>] [fsd=<fs_Depth>] [fsp=<search_Path>] [fsopt=<Find_option>] fs <String> [other grep options]"
    echo -e "NOTE:"
    echo -e "     wildcard pattern: in.*de will match inde, incde, inclde, include, ..."
    echo -e "Command-line Switch:"
    echo -e "	  fst	  - Search assigned file types"
    echo -e "		Predefined types:"
    echo -e "	  		fsc/fst=c fs    - Search *.c,*.cpp only"
    echo -e "	  		fsh/fst=h fs    - Search *.h,*.hpp only"
    echo -e "	  		fsch/fst=ch fs  - Search *.c, *.cpp, *.h, *.hpp"
    echo -e "	  		fsch/fst=hc fs  - Same as 'fst=ch'"
    echo -e "	  		fsj/fst=j fs    - Search for *.java files"
    echo -e "	  		fsm/fst=m fs    - Search for Makefile files (( '*.mak', 'makefile', 'Makefile', '*.mk', ',*.in')"
    echo -e "		Other examples:"
    echo -e "			fst=Kconfig"
    echo -e "		Search multiple file types:"
    echo -e "			fst='*.java -o -name *.h'"
    echo -e "	  fsd	  - Search only assigned depth"
    echo -e "		Examples:"
    echo -e "			fsd=1"
    echo -e "	  fsp	  - Specify the path to start the search"
    echo -e "	        The path can be set as relative path or absolute path"
    echo -e "	  fsopt	  - Specify find option"
    echo -e "	  f2/f3/f4/f5/f6/f7/f8	- 2nd/3rd/4th/.../8th \"grep in reuslts\" options"
    echo -e "		Examples:"
    echo -e "			f2=\"-E ':[0-9]*:#' -v\" fs include"
    echo -e "			f2=\"'\\.c'\" fs unistd"
    echo -e "Default options:"
    echo -e "     -n      print line number with output lines"
    echo -e "     -r      handle directories recursive"
    echo -e "     ---color=always      Always use colors on match"
    echo -e "Possible options:"
    echo -e "     -w      match only whole words"
    echo -e "     -i      ignore case distinctions"
    echo -e "     -e      use PATTERN as a regular expression. NOTE: This must be the last option"
    echo -e "     -l      only print FILE names containing matches"
    echo -e "     -NUM    print NUM lines of output context, NUM can be 1, 2, 3, ..."
    echo -e "     --include=PATTERN     files that match PATTERN will be examined"
    echo -e "     --exclude=PATTERN     files that match PATTERN will be skipped."
    echo -e "     --color=never         don't use color. Useful for file output"
    echo -e "Example:"
    echo -e " --Find 'layers_dbglist' in all subdirectories"
    echo -e "     fs layers_dbglist"
    echo -e " --Find 'layers_dbglist' and \"match only whole words\" in all subdirectories"
    echo -e "     fs layers_dbglist -w"
    echo -e " --Find 'layers_dbglist' and \"ignore the case\" in all subdirectories"
    echo -e "     fs layers_dbglist -i"
    echo -e " --Find 'layers_dbglist' and \"print only filenames\" in all subdirectories"
    echo -e "     fs layers_dbglist -l"
    echo -e " --Find 'layers_dbglist' and \"show 3 lines context\" in all subdirectories"
    echo -e "     fs layers_dbglist -3"
    echo -e " --Find 'layers_dbglist' in \"*.c;*.cpp;*.h\" under all subdirectories"
    echo -e "     fs layers_dbglist --include='*.c*' --include='*.h'"
    echo -e " --Find 'layers_dbglist' excluding \"*.h\" under all subdirectories"
    echo -e "     fs layers_dbglist --exclude='*.h'"
    echo -e " --Find 'not modal' under all subdirectories"
    echo -e "     fs 'not modal'"
    echo -e " "
    echo -e " Variants of fs:"
    echo -e "     fsu(): find in cUrrent directory, no recursion"
    echo -e "     fsc(): find pattern only in C/C++ files ('*.c', '*.cc', '*.cpp')"
    echo -e "     fsh(): find pattern only in header files ('*.h', '*.hh')"
    echo -e "     fsch():find pattern only in C/C++ and header files ('*.c', '*.cc', '*.cpp', '*.h', '*.hh')"
    echo -e "     fsj(): find pattern only in Java files ('*.java')"
    echo -e "     fsm(): find pattern only in Makefile files (( '*.mak', 'makefile', 'Makefile', '*.mk', ',*.in')"
    echo -e "     fsd(): find <function declaration> or <structure definition> in *.c or *.cpp or *.h"
    echo -e "     fsds():find <structure definition> in *.c or *.cpp or *.h"
    echo -e " Special notes:"
    echo -e "     * '-e' can be used to specify regular expression, be aware to put it as the last option."
    echo -e "     * Search multiple targets: 'fs classpathentry -e ANDROID_FRAMEWORK -e eclipse -e'"
    echo -e "     * When something wrong, check always check the command file: $FS_CMD_FILE"
    echo -e "     * f2 .. f8 are processed before breaking grep resultss into two lines. Therefor it can process the path."
    echo -e "     *** Under such case, the path is divided by '/' instead of '\\'"
}
# Follow the style of man page
alias fshelp='_fshelp |less -P"fshelp line %lj?L/%L. ?e(END). (press h for help or q to quit)\. Use _fshelp to show plain text without less\."'

# special version of fs(): find in cUrrent directory, no recursion
alias fsu='fsd=1 fs'

# special version of fs(): find pattern only in C/C++ files ('*.c', '*.cc', '*.cpp')
alias fsc='fst=c fs'

# special version of fs(): find pattern only in header files ('*.h', '*.hh')
alias fsh='fst=h fs'

# special version of fs(): find pattern only in C/C++ and header files ('*.c', '*.cc', '*.cpp', '*.h', '*.hh')
alias fsch='fst=ch fs'

# special version of fs():  find pattern only in Java files ('*.java')
alias fsj='fst=j fs'

# special version of fs():  find pattern only in Makefile files (( '*.mak', 'makefile', 'Makefile', '*.mk', ',*.in')
alias fsm='fst=m fs'

# special version of fs(): find function Declaration in *.c or *.cpp and *.h
# How it works:
#	"Normally" the following assumptions are made for the FUNCTION declarations:
#		1. it exists in *.c/cpp or *.h
#		2. There is no indent, and there are two possible conditions:
#		2.1 : the first character is [a-zA-Z] and this line contains the function name
#		2.2 : the line begins with function name and coming with others
fsd()
{
    pattern=$1
    option=
    if [ "$#" -gt "1" ] ; then
        shift
        option=$@
    fi

    fst=ch fs "^[a-zA-Z].*$pattern\|^$pattern.*" -e $option
}


# special version of fsd(): find Structure declaration in *.c or *.cpp and *.h
# How it works:
#	"Normally" the following assumptions are made for the STRUCTURE declarations:
#		1. it exists in *.c/cpp or *.h
#		2. No indent, and the same line contains '}' and structure name
#		3. The same line contains 'struct' and structure name
# I said "normally" because it's not always the case, jsut an assumption...
# NOTE: Difference between fsd and fsds:
#	fsd: to find funciton declaration
#	fsds: to find structure declaration
fsds()
{
    pattern=$1
    option=
    if [ "$#" -gt "1" ] ; then
        shift
        option=$@
    fi

    fst=ch fs "^.*}.*$pattern\|struct.*$pattern" -e $option
}




################################################################################
# Tricks about not expanding the glob. 
# See https://stackoverflow.com/questions/11456403/stop-shell-wildcard-character-expansion/22945024#22945024
# So that we can use 'ff *.c' to find files, this is a great improvement since v3.2

reset_ffopt()
{
    unset fft
    unset fsd
    unset fsp
}

noGlob_getOption()
{
    set -f
    
    unset FF_SHOPT
    if [ z"$fft" != z ]; then
        FF_SHOPT="$FF_SHOPT fft=$fft"
    fi
    if [ z"$fsd" != z ]; then
        FF_SHOPT="$FF_SHOPT fsd=$fsd"
    fi
    if [ z"$fsp" != z ]; then
        FF_SHOPT="$FF_SHOPT fsp=$fsp"
    fi
    reset_ffopt
}

runCmd_resetGlob()
{
    CMD="$1"
    shift

    if [ $# -gt 1 ]; then
        CMD="$CMD $1"
        shift

        case "$1" in
            "-h")
                ffhelp
                return
                ;;
            "--help")
                ffhelp
                return
                ;;
            *) 
                ;;
        esac
    else
        ffhelp
        return
    fi
    
    eval $FF_SHOPT $CMD "$@"

    if [ $? == 0 ]; then 
		source $FF_CMD_FILE
	fi

    set +f
}

alias ff='noGlob_getOption; runCmd_resetGlob fs.py ff'

_ffhelp()
{
	echo -e "**********"
    echo -e "ff ${FS_REL_VER}"
    echo -e "~Jackie Yeh ${FS_REL_DATE}"
	echo -e "**********"
	echo -e "shell function to find files"
	echo -e " "
    echo -e "Usage:"
    echo -e "     [fft=<ff_Type>] [fsd=<fs_Depth>] [fsp=<search_Path>] ff <file_pattern>[:<line_number>] [depth] [path] [-i]"
    echo -e "Command-line Switch:"
    echo -e "	  fft	    - Display type"
    echo -e "	    fft=ll	  ls long format"
    echo -e "	    fft=ls	  ls short format"
    echo -e "	    fft=rm	  display as 'll' first, remove after conifrmation"
    echo -e "	    "
    echo -e "		'fft' is not set by default, which will allow \$WINDOWS_EDITOR to edit"
    echo -e "	  fsd	    - Search only assigned depth"
    echo -e "		Examples:"
    echo -e "			fsd=1"
    echo -e "	  fsp	    - Specify the path to start the search"
    echo -e "	        The path can be set as relative path or absolute path"
	echo -e "Examples:"
	echo -e "     ff example.c       -- Find the file: example.c"
	echo -e "     ff a.h:100         -- Find the file: a.h and locate to line 100"
	echo -e "     ff *.c             -- Find all *.c files"
	echo -e "     ff *.[ch]          -- Find all *.c or *.h files"
	echo -e "     ff Makefile 1      -- Find 'Makefile' in current dir"
	echo -e "     ff Makefile src    -- Find 'Makefile' in 'src' dir"
	echo -e "     ff .bashrc 1 ~     -- Find '.bashrc' in \$HOME dir, don't search sub-dirs"
	echo -e "     ff *plus*.c -i     -- Find '*plus*.c' and ignore case"
	echo -e "     fsp=\$croot fsd=3 ff Makefile  -- Find 'Makefile' from \$croot dir, search for 3 layers"
	echo -e " Variants of ff:"
	echo -e "     ffll(): find files, but don't convert to DOS format, instead show in ls long format"
	echo -e "     ffls(): find files, but don't convert to DOS format, instead show in ls short format"
	echo -e "     ffrm(): find files remove after conifrmation"

}
# Follow the style of man page
alias ffhelp='_ffhelp |less -P"fshelp line %lj?L/%L. ?e(END). (press h for help or q to quit)\. Use _ffhelp to show plain text without less\."'




##varian: Find File then List in Long-format
alias ffll='fft=ll ff'


##varian: Find File then List in single-line mode: so that I can do further shell operation
alias ffls='fft=ls ff'


##varian: Find File and remove it. it will show all searched files first, then press 'y' to really remove.
ll_rm_resetGlob()
{
    # FF_SHOPT is collected from noGlob_getOption()
    eval $FF_SHOPT fft=ll fs.py ff $@
    if [ $? == 0 ]; then 
		source $FF_CMD_FILE
	fi
    
    echo -e "\n###\n"
    read -p "Are you sure to remove all above files <y/n> (default: n)? " a
    if [ z$a == z"y" ] || [ z$a == z"Y" ]; then 
        eval $FF_SHOPT fft=rm fs.py ff $@
        if [ $? == 0 ]; then 
            source $FF_CMD_FILE
        fi
    fi
    
    set +f
}
alias ffrm='noGlob_getOption; ll_rm_resetGlob'


