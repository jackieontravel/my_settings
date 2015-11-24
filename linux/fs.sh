#!/bin/sh

FS_REL_VER="v3.2"
FS_REL_DATE="2015/11/24"

#############################################################################
### Usage: 
###	1. source fs.sh in .bashrc.
### 2. Add PATH to where fs.py is located
################################################################################
function fs() 
{ 
	# Make sure the quoted searching pattern can be handled 
	pattern=$1

	if [ "$#" -gt "1" ] ; then
	shift;
		FS_REL_VER=$FS_REL_VER FS_REL_DATE=$FS_REL_DATE fs.py fs "$pattern" $*;
	else
		FS_REL_VER=$FS_REL_VER FS_REL_DATE=$FS_REL_DATE fs.py fs "$pattern";
	fi
	
	if [ $? == 0 ]; then 
		source $HOME/.fs_cmd_file
	fi
}; 



fshelp()
{
echo -e "**********"
echo -e "fs ${FS_REL_VER}"
echo -e "~Jackie Yeh ${FS_REL_DATE}"
echo -e "**********"
echo -e "shell function to find string in all subdirectory, exclude:"
echo -e " -- binary files (*.o; *.so; *.map; )"
echo -e " -- all files version control: .svn, .git"
echo -e " -- tagging system files:ctags, ctags.tmp, GPATH, GRTAGS, GTAGS, tags"
echo -e " -- *.d"
echo -e " "
echo -e "Usage:"
echo -e "     [f2=<2nd_grep_opt>][f3=<3rd_grep_opt>][f4=<4th_grep_opt>][fst=<fs_Type>] [fsd=<fs_Depth>] [fsopt=<Find_option>] fs <String> [other grep options]"
echo -e "NOTE:"
echo -e "     wildcard pattern: in.*de will match inde, incde, inclde, include, ..."
echo -e "Command-line Switch:"
echo -e "	  fst	  Search assigned file types"
echo -e "		Predefined types:"
echo -e "	  		fst=c	  Search *.c,*.cpp only"
echo -e "	  		fst=h	  Search *.h,*.hpp only"
echo -e "	  		fst=ch  Search *.c, *.cpp, *.h, *.hpp"
echo -e "	  		fst=hc  Same as 'fst=ch'"
echo -e "		Other examples:"
echo -e "			fst=Makefile"
echo -e "			fst=Kconfig"
echo -e "	  fsd	  Search only assigned depth"
echo -e "		Examples:"
echo -e "			fsd=1"
echo -e "	  fsopt	Specify find option"
echo -e "	  f2/f3/f4/f5/f6/f7/f8	2nd/3rd/4th/.../8th \"grep in reuslts\" options"
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
echo -e "     -e      use PATTERN as a regular expression"
echo -e "     -l      only print FILE names containing matches"
echo -e "     -NUM    print NUM lines of output context, NUM can be 1, 2, 3, ..."
echo -e "     --include=PATTERN     files that match PATTERN will be examined"
echo -e "     --exclude=PATTERN     files that match PATTERN will be skipped."
echo -e "     --color=never         don't use color. Useful for file output"
echo -e "Example:"
echo -e " --Find 'layers_dbglist' in all subdirectories"
echo -e "     fs layers_dbglist"
echo -e " --Find 'layers_dbglist' and "match only whole words" in all subdirectories"
echo -e "     fs layers_dbglist -w"
echo -e " --Find 'layers_dbglist' and "ignore the case" in all subdirectories"
echo -e "     fs layers_dbglist -i"
echo -e " --Find 'layers_dbglist' and "print only filenames" in all subdirectories"
echo -e "     fs layers_dbglist -l"
echo -e " --Find 'layers_dbglist' and "show 3 lines context" in all subdirectories"
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
echo -e "     fsc(): find pattern only in '*.c'"
echo -e "     fsh(): find pattern only in '*.h'"
echo -e "     fsd(): find <function declaration> or <structure definition> in *.c or *.cpp or *.h"
echo -e "     fsds(): find <structure definition> in *.c or *.cpp or *.h"

}


# special version of fs(): find in cUrrent directory, no recursion
fsu()
{
    fsd=1 fs $*
}

# special version of fs(): find pattern only in '*.c' or '*.cpp'
fsc()
{
    fst=c fs $*
}

# special version of fs(): find pattern only in '*.h'
fsh()
{
    fst=h fs $*
}

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
        option=$*
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
        option=$*
    fi

    fst=ch fs "^.*}.*$pattern\|struct.*$pattern" -e $option
}




################################################################################
# Tricks about not expanding the glob. 
# See https://stackoverflow.com/questions/11456403/stop-shell-wildcard-character-expansion/22945024#22945024
# So that we can use 'ff *.c' to find files, this is a great improvement since v3.2

# Minor modification to original function as described in above web, as we need 2 arguments at least for fs.py
function reset_expansion()
{
    CMD="$1"
    shift
    if [ $# -gt 1 ]; then
        CMD="$CMD $1"
        shift
    fi
    
    eval $CMD "$*"
    set +f
}

alias ff='set -f; reset_expansion fs.py ff'

ffhelp()
{
	echo -e "**********"
    echo -e "ff ${FS_REL_VER}"
    echo -e "~Jackie Yeh ${FS_REL_DATE}"
	echo -e "**********"
	echo -e "shell function to find files"
	echo -e " "
	echo -e "Usage can be illustrated by examples:"
	echo -e "    ff example.c    -- Find the file: example.c"
	echo -e "    ff *.c         -- Find all *.c files"
	echo -e "    ff *.[ch]      -- Find all *.c or *.h files"
	echo -e "    ff Makefile 1   -- Find 'Makefile' in current dir"
	echo -e "    ff Makefile src -- Find 'Makefile' in 'src' dir"
	echo -e "    ff .bashrc 1 ~  -- Find '.bashrc' in $HOME dir, don't search sub-dirs"
	echo -e " Variants of ff:"
	echo -e "     ffll(): find files, but don't convert to DOS format, instead show in ls long format"
	echo -e "     ffls(): find files, but don't convert to DOS format, instead show in ls short format"
	echo -e "     ffrm(): find files then remove it"

}



##varian: Find File then List in Long-format
alias ffll='set -f; reset_expansion fft=ll fs.py ff'



##varian: Find File then List in single-line mode: so that I can do further shell operation
alias ffls='set -f; reset_expansion fft=ls fs.py ff'


##varian: Find File and remove it
alias ffrm='set -f; reset_expansion fft=rm fs.py ff'



































############################################# BACK UP #################################
# move fs to ofs() to temporarily back "old" fs()
ofs()
{
    # If we are in mock, sudo is not necessary.
    if [ "$NOT_IN_MOCK" -eq "1" ] ; then
        sudo_cmd="sudo"                
    else
        sudo_cmd=""                
    fi        
    LINE_OUTPUT_FORMAT="\e[90m"   # Set to GRAY, see http://misc.flogisoft.com/bash/tip_colors_and_formatting for color details
    LINE_OUTPUT_NORMAL="\e[0m"    # Restore to default
    CMD_FILE=$HOME/.fs_cmd_file


    pattern=$1
    option=
    if [ "$#" -gt "1" ] ; then
        shift
        option=$*
    fi
    
    # fst: fs (t)ype
    # Find only specific file types to descrease searching time.
    if [ "$fst" == "" ] ; then
        file_type="-type f"                
    elif [ "$fst" == "c" ] ; then
        file_type="-regex '.*cp*$'"
    elif [ "$fst" == "h" ] ; then
        file_type="-name '*.h'"
    else
        file_type="-name '$fst'"
    fi
    fst=""
    

    # fsd: fs (d)epth
    # default set maxdepth to 9999
    if [ "$fsd" == "" ] ; then
        md=9999               
    else
        md=$fsd
    fi

    echo -e "fs v2.6 (20150904) - Find strings. Use 'fshelp' to check the usage.\n"
    # Save current GREP_COLORS. see grep man page: http://linux.die.net/man/1/grep
    echo -e "cur_grep_color=\"$GREP_COLORS\"" > $CMD_FILE
    # set GREP_COLORS: unset the colors of fn (filename), ln (line #), and se (separators) -- so that we can control the line output format by LINE_OUTPUT_FORMAT
    echo -e "export GREP_COLORS=\"ms=01;31:mc=01;31:sl=:cx=:fn=:ln=:bn=32:se=\"\n" >> $CMD_FILE
    echo -e "time find $fsopt -maxdepth $md -type d \( -name '\.svn' -o -name 'AppLibs' -o -path './BSEAV/bin' \) -prune -o $file_type -print0 | xargs -0 grep -nIH --exclude='$CMD_FILE' --exclude='*.d' --exclude='*.o' --exclude='*.so' --exclude='*.map' --exclude='*.cmd' --exclude='ctags.tmp' --exclude='tags' --color=always $option '$pattern' \
    | awk -F':' -v prog=\"$WINDOWS_PROGRAM\" -v disk=$DISK_LETTER -v root_path=\`pwd | sed \"s;$HOME;$D_HOME;\" | sed \"s;^;$DISK_ROOT;\"\` -v fmt=$LINE_OUTPUT_FORMAT -v fmt_normal=$LINE_OUTPUT_NORMAL -v lnfmt=\"$LN_NUM_FORMAT\" -v last_path="" '
        BEGIN {}
        {
            path=root_path\"/\"\$1;
            if ( path != last_path ) 
			{
                file_count++;
                last_path = path;
            }
            gsub(\"/\", \"\\\\\\\", path);
            printf(\"%s%s %s%s%s%s%s\\\n\", fmt, prog, disk, path, lnfmt, \$2, fmt_normal);
            printf(\"%s\\\n\", substr(\$0, 3+length(\$1)+length(\$2)));
        }
        END {printf(\"\\\n\\\nTotal %d occurrences in %d files\\\nRun again:\\\nbash $CMD_FILE\\\n\", NR, file_count)}'" >> $CMD_FILE
#        END {printf(\"\\\n\\\nTotal %d occurrences in %d files\\\nRun again:\\\nbash $CMD_FILE\\\n\", NR, file_count)}'" | tee $CMD_FILE -a
    echo -e "( \"Regular expression\" style wildcard. Ex: fs 'in.*de' to find 'inde', 'include', 'inc abde',... )\n\n"

    # restor GREP_COLORS
    echo -e "export GREP_COLORS=\"$cur_grep_color\"" >> $CMD_FILE
    
    # restore control parameters
    unset fsopt
    unset fsd
    
    $sudo_cmd bash $CMD_FILE
    #rm -rf .fs_cmd_file  #keep it to run again!

}

