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
alias llsort='/bin/ls -l --color=always --sort=time'    #sort on time: postive order. add "|more" to see in pages
alias llsortr='/bin/ls -l --color=always --sort=time -r'    #sort on time: reverse order. add "|more" to see in pages
alias ls='/bin/ls -A --color=always'
alias lsc='/bin/ls --color=always'
alias lls='/bin/ls --color=always'
alias lm='function __lm() { ls -Al --color=always $* |more; }; __lm '
alias la='/bin/ls -al --color=always'
alias md='mkdir'
alias mkcd='function __mkcd() { mkdir $1 && cd $1; }; __mkcd $1'
alias grep='grep --color' # in case grep w/o color is needed. use 'grep --color=never'
# Find the latest files, default 10 files -- can be set to new number
# NOTE: exclude files by SVN, GIT or others which store at .repo
llnew() {
    find . \( -name '.git*'  -o -name .svn -o -name .repo \) -prune -o -type f \
    -printf '%T@ %TY/%Tm/%Td %TH:%TM:%.2TS %p\n' | \
    sort -k 1nr | cut -d' ' -f 2- | head -n ${1:-10}
}


# Apply colordiff if the system installed it
if [ -x "`which colordiff 2>/dev/null`" ]; then
    alias diff=colordiff
fi
# Apply pygmentize if the system installed it. pl: pygmentize-less, it works for normal command and pipe
if [ -x "`which pygmentize 2>/dev/null`" ]; then
    export LESSOPEN='|pygmentize -g %s'
fi

export LESS='--quit-if-one-screen -X -R --use-color -DNGk '
# lx:   'less' with syntax color ( use "-g" option of pygmentize to guess), and apply "$LESSOPEN"
# lxx:  'less' with "$LESS", and ignore "$LESSOPEN" -- Looks like we don't need it, just keep for record
alias lx='less'
alias lxx='less -L'

alias mkctags='time ctags --extra=f --links=no --verbose -R . '

#########################################################################
#   gtags
#########################################################################
# mkgtags: defauot to skip unreadable and symlink
function mkgtags()
{
    if [ -f ./GTAGS.CONF ]; then
        local GCONF=./GTAGS.CONF
    elif [ -f $HOME/.globalrc ]; then
        local GCONF=$HOME/.globalrc
    else
        echo "* ERROR: user-defined configuration file not found"
        echo "* NEXT:"
        echo "    wget https://raw.githubusercontent.com/namhyung/global/master/gtags.conf -O $HOME/.globalrc"
        echo "    sed 's/:skip=/:skip=.svn\/,/g' -i $HOME/.globalrc"
        return -1
    fi
    
    echo "gtags --config=skip --gtagsconf $GCONF"
    gtags --config=skip --gtagsconf $GCONF
    echo
    sleep 1
    time gtags --skip-unreadable --skip-symlink --verbose --gtagsconf $GCONF $*
}

# arguments ($1, $2, ...) are the dir's w/ or w/o trailing "/", will be skipped
# You may add "-i" to do a incremental update
function mkgtags_skipdirs()
{
    # REF: $HOME/.globalrc coming from https://raw.githubusercontent.com/namhyung/global/master/gtags.conf
    #      Then add ".svn/"
    local GCONF=$HOME/.globalrc
    local dirs=""
    local IncUpdate=""
    
    for dir in "$@"
    do
        if [ "$dir" = "-i" ]; then
            IncUpdate="-i"
        else
            # Make sure trailing "/" is not included in case user input add it
            dir_noTraSlh=${dir%/}
            
            # Convert each "/" into "\/" to meet sed rule. This is necessary if dir has more than one level
            dir_sed=$(echo "$dir_noTraSlh" | awk '{ p=$0; gsub("/","\\/",p ); printf ( "%s", p)}')
            # Add trailing "/" as this will indicate it's a dir actually
            dirs+="${dir_sed}\/,"
        fi
    done
    
    sed "s/:skip=/:skip=${dirs}/g" $GCONF > GTAGS.CONF;
    mkgtags $IncUpdate
}


# mkgtags_bsp4 ...... Create GTAGS for bsp4
# mkgtags_bsp4 -i ... Update GTAGS for bsp4
function mkgtags_bsp4()
{
    mkgtags_skipdirs build_dir $*
}

# Don't use updgtags as it will 
# alias updgtags='time global -u' # To update gtags

# A handly alias to show timeout on Linux ping. REF: http://superuser.com/questions/270083/linux-ping-show-time-out
# 2025/1/23 Improved by chatting with GPT: https://chatgpt.com/share/6791bad0-2494-8000-9266-7ec967ac52d9
function pingt() {
    local ip=$1
    local s=0 p=0 f=0
    local start_time end_time elapsed_time sleep_time result timestamp
    
    if [[ -z "$ip" ]]; then
        echo "Usage: pingt <IP_ADDRESS>"
        return 1
    fi

    while :; do
        s=$((s + 1))
        start_time=$(awk '{print $1}' /proc/uptime)
        
        timestamp=$(date '+%Y/%m/%d %H:%M:%S')
        
        if result=$(ping "$ip" -c1 -W1 2>&1 | /bin/grep from); then
            p=$((p + 1))
            echo "$timestamp - $result, seq=$s, P=$p, F=$f"
            sleep_time=1  # Success case always sleeps 1 second
        else
            f=$((f + 1))
            echo "$timestamp - timeout seq=$s, P=$p, F=$f"
            end_time=$(awk '{print $1}' /proc/uptime)
            elapsed_time=$(awk -v start="$start_time" -v end="$end_time" 'BEGIN {print end - start}')
            sleep_time=$(awk -v elapsed="$elapsed_time" 'BEGIN {sleep = 1 - elapsed; if (sleep > 0) print sleep; else print 0}')
        fi
        
        sleep "$sleep_time"
    done
}

# friendly tree: tt
function tt()
{
    # Always put "-L 1" as the first argument, so that it would be the default level, 
    # could be overriden by user input -L <L> or -R
    echo $* | grep -e '\-L' -e '\-R' > /dev/null 2>/dev/null
    
    if [ "$?" == "0" ]; then
        user_option="$*"
    else
        user_option="-L 1 $*"
    fi

    # tree: dd "-C" to always show colors. 
    # less: "-X" to keep output after quit from less, "-F":--quit-if-one-screen, "-P" to show hint.
    tree $user_option -C | less -X -F -P"tree $user_option  => lines %lt-%lb?L/%L. (less\: press h for help or q to quit) "
}

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

### 'screen' related functions
### Useful command: C-A C-D   === deattach

function schelp()
{
    echo "sc <session name> ---- create a new session w/ name: <session name>"
    echo "scls ----------------- list existing sessions"
    echo "scd ------------------ deattach from current session"
    echo "scr <session name> --- re-attach to <session name>"
    echo "scrm <session name> -- remove <session name>, then list existing session"
}
# list existing sessions
alias scls='screen -ls'

# deattach from current session
alias scd='screen -d "$STY"'

# re-attach, name: $1
function scr()
{
    screen -rD $1
}

# Create a new session, name: $1
# explicitely set buffer size to 20000
function sc()
{
    screen -t $1 -S $1 -h 20000
}

# Remove existing session. name: $1
function scrm()
{
    screen -S $1 -X quit && sleep 0.2; echo -e "\n### Current sessions:"; screen -ls
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


#################################################################################
# "no-ignore" version of svnmod, svnmodl, svnmodt: to deal with libraries
#################################################################################
noisvnmod()
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
    svn status --no-ignore | grep ^[^?" "]| awk -v WINDOWS_DISK=$WINDOWS_DISK -v WINDOWS_EDITOR=$WINDOWS_EDITOR '{status=substr($0, 1, 1);
                            path=root_path"/"substr($0, 9);
                            gsub("/","\\",path );
                            printf("%s:\n%s %s%s\n", status, WINDOWS_EDITOR, WINDOWS_DISK, path)}' root_path=`pwd` | sed -f ~/.sed_svnmod.cmd
}


noisvnmodl()
{
### l stands for Linux format.
### Use svnmodl to show modified file in Linux format, so that I can:
###     - revert it individually with 'svn revert'
###     - check diff with 'svn diff'
svn status --no-ignore | grep ^[^?" "]| awk '{status=substr($0, 1, 1);
                        path=substr($0, 9);
                        printf("%s:\n%s\n",status,path)}'
}



## Generate a command to show modified file in Tortoise GUI. Notation: svnmod+t=svnmodt
## Tips: search ':\\' to be recoginzed as a Windows path
noisvnmodt()
{
    noisvnmod |grep ':\\' | awk -v WINDOWS_DISK=$WINDOWS_DISK 'BEGIN{printf("\n\nTortoiseProc.exe /command:repostatus /path:\"")} {if (match($1, WINDOWS_DISK)) filename=$1; else filename=$2; if (NR==1) printf("%s",filename); else printf("*%s",filename)} END {printf("\"\n\n\nTotal %d files\n", NR)}'
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

# Simple PS1 and PS1 reset:
ORG_PS1=$PS1
alias ps1='export PS1="\[\e[34;1m\][\$(basename \$(dirname \$(pwd)))/\$(basename \$(pwd))]\$ \[\e[0m\]"'
alias ps1reset='export PS1="$ORG_PS1"'
####################################################################################################
# Usage:
#   Show color code:    echo $Red
#   Show color effect:  echo -e "$Red text"

# get whole directory to current directory without creating folder
# NOTE: always add a '/' to the end of URL, this makes sure only the target folder is fetched instead of its parrent
wget_dir()
{
    url="$1/"
    wget -nd -r  --no-parent --reject="index.html*" $url
}


opath () 
{ 
    export PATH=${PATH#*:};
    echo $PATH
}

csv2redmine()
{
    TMPF=`mktemp`
    cp $1 $TMPF -f
    echo >> $TMPF
    sed -i 's/^/|/g' $TMPF
    sed -i ':a;N;$!ba;s/\r\n/|\r\n/g' $TMPF
    sed -i 's/,/|/g' $TMPF
    head -n -1 $TMPF
    rm -f $TMPF
}


#2024/4/12 For Sheldon battery analyzer
# set FR and FD accordingly.
# Assume F is already *.txt, like "syslog.txt"
# Export FR to be syslog.report
# Export FD to be syslog.detail
setf () 
{ 
    if [ -z "$F" ]; then
        echo "Error: syslog filename \$F is missing.";
        return 1;
    fi;
    if [[ "$F" =~ \.txt$ ]]; then
        report_name="${F%.txt}";
        FR="${report_name}.report";
        FD="${report_name}.detail";
        FO="${report_name}.offline";
        echo "Done:";
        echo " F=$F";
        echo "FR=$FR";
        echo "FD=$FD";
        echo "FO=$FO";
    else
        echo "Error: Input is not in the expected format (*.txt).";
        return 1;
    fi
}
