# .bashrc_func.sh
##############################################
# History
# 2015/11/16    - Initial release for .bashrc_func.sh, to support handy functions and aliases for Bash.
##############################################


########################################################################################################
#   Default Values: 
#   they are supposed to be set in the calling script (.bashrc), if not set, below are the default values
########################################################################################################
export WINDOWS_DISK=${WINDOWS_DISK:-"U:"}
export WINDOWS_EDITOR=${WINDOWS_EDITOR:-"notepad++"}


########################################################################################################
#   Handy aliases
########################################################################################################

# hh: Default show 50 historys, can be changed if $2 is assigned. Variables replacement in bash: http://www.suse.url.tw/sles10/lesson10.htm#30
alias h='function __h() { history ${1:-15}; }; __h '
alias hh='function __hh() { history ${1:-50}; }; __hh '
alias ll='/bin/ls -Al --color=always'
alias llc='/bin/ls -l --color=always'    #ll with 'Clean' view
alias lll='/bin/ls -l --color=always'    #lll is more easy to type
alias ls='/bin/ls -A --color=always'
alias lsc='/bin/ls --color=always'
alias lls='/bin/ls --color=always'
alias lm='function __lm() { ls -Al --color=always $* |more; }; __lm '
alias la='/bin/ls -al --color=always'
alias md='mkdir'
alias grep='grep --color' # in case grep w/o color is needed. use 'grep --color=never'
# Apply colordiff if the system installed it
if [ -x "`which colordiff 2>/dev/null`" ]; then
    alias diff=colordiff
fi
# Apply pygmentize if the system installed it. pl: pygmentize-less, it works for normal command and pipe
# Set language: pl -l sh .bashrc
if [ -x "`which pygmentize 2>/dev/null`" ]; then
    function pl()
    {
        pygmentize -g -f 256 $* |less;
    }
    alias pless='pl'
else
    alias pl='less'
fi
alias mkctags='time ctags --extra=f --links=no --verbose -R . '
alias mkgtags='time gtags --skip-unreadable  --verbose '
function mkgtags_nolink()
{
    # $1 to set manually excluded folders seperated by comma (,) 
    linkFolders=$(find -type l -xtype d 2>/dev/null | awk '{ p=substr($0,2); gsub("/","\\/",p ); printf ( "%s\\/,", p)}')
    sed "s/:skip=/:skip=$1,$linkFolders/g" /etc/gtags.conf > gtags.conf;
    mkgtags
}
alias mkgtags_sdk2='mkgtags_nolink "kernel3-KERNEL_ML_3.4.*"'
alias mkgtags_android='mkgtags_nolink'
alias updgtags='time global -u' # To update gtags



### A handy python function to return relative path
### Usage: relpath <dst> <src>
### REF: http://unix.stackexchange.com/questions/85060/getting-relative-links-between-two-paths
function relpath() 
{ 
    python -c 'import os.path, sys; print os.path.relpath(sys.argv[1],sys.argv[2])' "$1" "${2-$PWD}"; 
}


# User specific aliases and functions
function findpdf ()
{

	# <xavi add> Jackie 2015/09/18, So far no way to make the function work! just echo it for manually input. Sad :(
	#find . -name '*.pdf' -exec sh -c 'pdftotext "{}" - | grep --with-filename --label="{}" --color "$1" ' \;
	echo -e "# Use the following command to search 'pattern' in every PDF file under current folder"
	echo -e "find . -name '*.pdf' -exec sh -c 'pdftotext \"{}\" - | grep -n --with-filename --label="{}" --color \"pattern\" ' \;\n"
	
	
	# <xavi add> Jackie 2015/09/18, not working trial:
	# find . -name '*.pdf' -print0 | xargs -0 cat | pdftotext - - | grep -nIH --color "$1"
	# find . -name '*.pdf' -print0 | xargs -0 pdftotext 

} 

### Handy functions to calculate disk usage 
#################################################################################
### shell function to find file
### Usage:
###      duu        #= du --max-depth=1
###      duu 2      #= du --max-depth=2
###      duu -h     #= du --max-depth=1 -h
###      duu 2 -h   #= du --max-depth=2 -h
###      duu 0 -h   #= du -s -h
### NOTE:
###      1. first argument is used to assign --max-depth=N, and can be omitted.
###      2. 'sudo' is always needed to avoid 'Permission denied'
function duu() 
{ 
    re='^[0-9]+$'
    if [[ $1 =~ $re ]] ; then
        # $1 is a number, remove leading space then assign to variable d.
        d=$(sed -e 's/^[[:space:]]*//' <<<$1);
        shift
    else
        d=1
    fi
    
    sudo du --max-depth=$d $*; 
};

function duuh() 
{ 
    duu $* -h 
};

function duus() 
{ 
    duu $* | sort -n
};



### Auto update NTP time. Other NTP servers in Taiwan:    
#    * tock.stdtime.gov.tw
#    * time.stdtime.gov.tw
#    * clock.stdtime.gov.tw
#    * tick.stdtime.gov.tw 
#################################################################################
alias ntpupdate='srv="tw.pool.ntp.org"; echo "sudo ntpdate $srv"; sudo ntpdate $srv'
# command to check md5 checksum for software release
alias chkmd5='cat ~/a.txt | sed 's/^checksum:.*//g'  | tr -d "\r\n\t: " |  md5sum  | head -c 8'

# common alias to goto specific directories:
alias mog='killall mongoose; sleep 1; mongoose ~/.mongoose.cfg & echo -e "\n\nURL:\nhttp://172.21.8.173:8025/\n"; sleep 1; echo'


## Shell function to convert google url to normal url (remove the notation by google)
ggurl()
{
     echo $1 |cut -d '&' -f 5 | cut -d = -f 2 | sed 's/%2F/\//g' | sed 's/%3A/:/g'
}

## Shell function to remove ansi color codes (use 'man 5 dir_colrs' to find ANSI color code definitions)
rmcolor()
{
    sed -r "s/\x1B\[[0-9;]*[mK]//g" $1
}

##############################################################################
##
##  SVN related functions
##
##############################################################################

svnmod()
{
    ### Original way with 'convertpath', now just keep it for reference.
    #    /bin/echo "svn status | grep ^[^?] | awk '{if (\$2==\"+\") printf(\"%s:\n%s\n\",\$1,\$3); else  printf(\"%s:\n%s\n\",\$1,\$2)}' | convertpath"
    #    svn status | grep ^[^?] | awk '{if ($2=="+") printf("%s:\n%s\n",$1,$3); else  printf("%s:\n%s\n",$1,$2)}'|convertpath
    
    ### New way without convertpath. Set WINDOWS_DISK to Windows drive, eg. L, V, z, ...
    if [ -z "$WINDOWS_DISK" ]; then
        echo "ERROR. Please set WINDOWS_DISK first... "
        return;
    fi
    
    echo -n "$HOME" | sed 's/\//\\\\/g' | awk '{ printf "s/%s//", $1} ' > ~/.sed_svnmod.cmd
    svn status | grep ^[^?" "]| awk -v WINDOWS_DISK=$WINDOWS_DISK -v WINDOWS_EDITOR=$WINDOWS_EDITOR '{status=substr($0, 1, 1);
                            path=root_path"/"substr($0, 9);
                            gsub("/","\\",path );
                            printf("%s:\n%s %s%s\n", status, WINDOWS_EDITOR, WINDOWS_DISK, path)}' root_path=`pwd` | sed -f ~/.sed_svnmod.cmd
}


svnmodl()
{
### l stands for Linux format.
### Use svnmodl to show modified file in Linux format, so that I can:
###     - revert it individually with 'svn revert'
###     - check diff with 'svn diff'
svn status | grep ^[^?" "]| awk '{status=substr($0, 1, 1);
                        path=substr($0, 9);
                        printf("%s:\n%s\n",status,path)}'
}



## Generate a command to show modified file in Tortoise GUI. Notation: svnmod+t=svnmodt
## Tips: search ':\\' to be recoginzed as a Windows path
svnmodt()
{
    svnmod |grep ':\\' | awk -v WINDOWS_DISK=$WINDOWS_DISK 'BEGIN{printf("\n\nTortoiseProc.exe /command:repostatus /path:\"")} {if (match($1, WINDOWS_DISK)) filename=$1; else filename=$2; if (NR==1) printf("%s",filename); else printf("*%s",filename)} END {printf("\"\n\n\nTotal %d files\n", NR)}'
}


svnup()
{
    svn update |awk '{ \
        if ($1=="C") printf "%c[31;1m%s\n%c[0m",27, $0, 27; \
        else if ($1=="G") printf "%c[35;1m%s\n%c[0m",27, $0, 27; \
        else if ($1=="A") printf "%c[36;1m%s\n%c[0m",27, $0, 27; \
        else if ($1=="D") printf "%c[34;1m%s\n%c[0m",27, $0, 27; \
        else print $0}' | convertpath
}

alias rmbak='find -name "*.bak" -print -exec rm -f {} \;'


#############################################################
## shell function to change Linux-like path to Dos-like path.
## ie. change a/b/c/d to a\b\c\d
#############################################################
l2d()
{
    echo $1 | sed 's/\//\\/g' | sed 's/:/\//g' | sed 's/\\home\\jackieyeh\\/v:\\/g'
}



####################################################################################################
####################################################################################################
## Elapsed time derived from build.bash
# Set the starting time to calculate elpased time
function st()
{
    # To provide the elapsed time for a build, first save the current time.
    start_time=`date '+%j %H %M %S'`
    stfrom=`date`
}

#----------------------------------------------------------------------------
# Compute and print the elapsed time.
#    Input - start_time must be set by st
function et()
{
    # Get and print the elapsed time for this build job.
    echo -e "===\nStarted from:\n$stfrom"
    end_time=`date '+%j %H %M %S'`
    echo "$end_time $start_time" | awk '{et=((($1*24+$2)*60+$3)*60+$4)-((($5*24+$6)*60+$7)*60+$8);es=et%60;em=int(et/60);printf ("\n===> Elapsed time  %dm %02ds\n\n",em,es)}'
    date
}


## Function to show pstree for all logined user
function showpstree()
{
    for user in $(who | awk ' {print $1}'|sort|uniq|xargs echo); do 
        tput setf 2; 
        echo -e "\n*****\n$user\n"; 
        tput setf 7; 
        pstree $user -pa; 
    done
}

## Function to extrace RPM files without installing it.
## Hint: use less <file.rpm> to see the description and files before extract it
function rpmEx() { rpm2cpio $1 | cpio -idmv; }


# Colorful grep: highlight the keywords and keep output others, especially useful in embedded system with full-function grep
function cgrep1()
{
    GREP_COLORS="ms=01;31" grep --color=always -E "$1|$"
}

function cgrep2()
{
    GREP_COLORS="ms=01;32" grep --color=always -E "$1|$"
}

function cgrep3()
{
    GREP_COLORS="ms=01;33" grep --color=always -E "$1|$"
}

function cgrep4()
{
    GREP_COLORS="ms=01;34" grep --color=always -E "$1|$"
}

function cgrep5()
{
    GREP_COLORS="ms=01;35" grep --color=always -E "$1|$"
}

function cgrep6()
{
    GREP_COLORS="ms=01;36" grep --color=always -E "$1|$"
}

function cgrep()
{
    if [ $# -lt 1 ]; then
        echo "Usage: cgrep [<pattern> [pattern2]...[pattern6]]"
        return
    fi
    
    cmd="cgrep1 $1"
    shift
    
    if [ $# -ge 1 ]; then
        cmd="$cmd | cgrep2 $1"
        shift
    fi
    
    if [ $# -ge 1 ]; then
        cmd="$cmd | cgrep3 $1"
        shift
    fi
    
    if [ $# -ge 1 ]; then
        cmd="$cmd | cgrep4 $1"
        shift
    fi
    
    if [ $# -ge 1 ]; then
        cmd="$cmd | cgrep5 $1"
        shift
    fi
    
    if [ $# -ge 1 ]; then
        cmd="$cmd | cgrep6 $1"
        shift
    fi
    
    eval $cmd
}


#colorful grep variants: highlight the whole line with background color: format cgrep<n>l. 'l' stands for line
# TODO: Not a perfect solution yet, now highlight to the end of line, we need just the pattern itself
# More possibility: http://stackoverflow.com/questions/17236005/grep-output-with-multiple-colors
function cgrep1l()
{
    GREP_COLORS="ms=0;30;100" grep --color=always -E "^.*$1.*$|$" | cgrep1 "$1.*"
}

function cgrep2l()
{
    GREP_COLORS="ms=0;30;100" grep --color=always -E "^.*$1.*$|$" | cgrep2 "$1.*"
}

function cgrep3l()
{
    GREP_COLORS="ms=0;30;100" grep --color=always -E "^.*$1.*$|$" | cgrep3 "$1.*"
}

function cgrep4l()
{
    GREP_COLORS="ms=0;30;100" grep --color=always -E "^.*$1.*$|$" | cgrep4 "$1.*"
}

function cgrep5l()
{
    GREP_COLORS="ms=0;30;100" grep --color=always -E "^.*$1.*$|$" | cgrep5 "$1.*"
}

function cgrep6l()
{
    GREP_COLORS="ms=0;30;100" grep --color=always -E "^.*$1.*$|$" | cgrep6 "$1.*"
}


####################################################################################################
# Explanation about ANSI color codes... used in GREP_COLORS
#                   - summarized by Jackie on 2015/12/29, REF: http://linux-sxs.org/housekeeping/dircolor.html
#
# Below are the color init strings for the basic file types. A color init
# string consists of one or more of the following numeric codes:
# * Attribute codes:
#       00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
# * Text color codes:
#     - Normal intensity
#       30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
#     - High intensity
#       90=black 91=red 92=green 93=yellow 94=blue 95=magenta 96=cyan 97=white
# * Background color codes:
#     - Normal intensity
#       40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white
#     - High intensity
#       100=black 101=red 102=green 103=yellow 104=blue 105=magenta 106=cyan 107=white
#
# Examples:
#    NORMAL 00 # global default, although everything should be something.
#    FILE 00 # normal file
#    DIR 01;34 # directory
#    LINK 01;36 # symbolic link
#    FIFO 40;33 # pipe
#    SOCK 01;35 # socket
#    BLK 40;33;01 # block device driver
#    CHR 40;33;01 # character device driver
#    ORPHAN 40;31;01 # symlink to nonexistent file
#

####################################################################################################
# List of colors for prompt and Bash. REF: https://wiki.archlinux.org/index.php/Color_Bash_Prompt
txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
undblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
bakgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset

function listcolor1()
{
    echo txtblk=$txtblk
    echo txtred=$txtred
    echo txtgrn=$txtgrn
    echo txtylw=$txtylw
    echo txtblu=$txtblu
    echo txtpur=$txtpur
    echo txtcyn=$txtcyn
    echo txtwht=$txtwht
    echo bldblk=$bldblk
    echo bldred=$bldred
    echo bldgrn=$bldgrn
    echo bldylw=$bldylw
    echo bldblu=$bldblu
    echo bldpur=$bldpur
    echo bldcyn=$bldcyn
    echo bldwht=$bldwht
    echo undblk=$unkblk
    echo undred=$undred
    echo undgrn=$undgrn
    echo undylw=$undylw
    echo undblu=$undblu
    echo undpur=$undpur
    echo undcyn=$undcyn
    echo undwht=$undwht
    echo bakblk=$bakblk
    echo bakred=$bakred
    echo bakgrn=$bakgrn
    echo bakylw=$bakylw
    echo bakblu=$bakblu
    echo bakpur=$bakpur
    echo bakcyn=$bakcyn
    echo bakwht=$bakwht
    echo txtrst=$txtrst
}



####################################################################################################
# More readable. again REF: https://wiki.archlinux.org/index.php/Color_Bash_Prompt
# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White


function listcolor2()
{
    echo Color_Off=$Color_Off
    echo Black=$Black
    echo Red=$Red
    echo Green=$Green
    echo Yellow=$Green
    echo Blue=$Green
    echo Purple=$Green
    echo Cyan=$Green
    echo White=$Green
    echo BBlack=$Green
    echo BRed=$Green
    echo BGreen=$Green
    echo BYellow=$Green
    echo BBlue=$Green
    echo BPurple=$Green
    echo BCyan=$Green
    echo BWhite=$Green
    echo UBlack=$Green
    echo URed=$Green
    echo UGreen=$Green
    echo UYellow=$Green
    echo UBlue=$Green
    echo UPurple=$Green
    echo UCyan=$Green
    echo UWhite=$Green
    echo On_Black=$Green
    echo On_Red=$Green
    echo On_Green=$Green
    echo On_Yellow=$Green
    echo On_Blue=$Green
    echo On_Purple=$Green
    echo On_Cyan=$Green
    echo On_White=$Green
    echo IBlack=$Green
    echo IRed=$Green
    echo IGreen=$Green
    echo IYellow=$Green
    echo IBlue=$Green
    echo IPurple=$Green
    echo ICyan=$Green
    echo IWhite=$Green
    echo BIBlack=$Green
    echo BIRed=$Green
    echo BIGreen=$Green
    echo BIYellow=$Green
    echo BIBlue=$Green
    echo BIPurple=$Green
    echo BICyan=$Green
    echo BIWhite=$Green
    echo On_IBlack=$Green
    echo On_IRed=$Green
    echo On_IGreen=$Green
    echo On_IYellow=$Green
    echo On_IBlue=$Green
    echo On_IPurple=$Green
    echo On_ICyan=$Green
    echo On_IWhite=$Green
}

alias listcolor='listcolor1; listcolor2'
####################################################################################################
# Usage:
#   Show color code:    echo $Red
#   Show color effect:  echo -e "$Red text"
