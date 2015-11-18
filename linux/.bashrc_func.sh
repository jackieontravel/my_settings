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
alias h='function __h() { history ${2:-15}; }; __h '
alias hh='function __hh() { history ${2:-50}; }; __hh '
alias ll='/bin/ls -Al --color=always $*'
alias llc='/bin/ls -l --color=always $*'    #ll with 'Clean' view
alias lll='/bin/ls -l --color=always $*'    #lll is more easy to type
alias ls='/bin/ls -A --color=always $*'
alias lsc='/bin/ls --color=always $*'
alias lls='/bin/ls --color=always $*'
alias lm='function __lm() { ls -Al --color=always $* |more; }; __lm '
alias la='/bin/ls -al --color=always $*'
alias md='mkdir'
# Apply colordiff if the system installed it
if [ -x /usr/bin/colordiff ]; then
    alias diff=colordiff
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

	# <xavi add> Jackie 2015/09/18, So far no way to make the funciton work! just echo it for manually input. Sad :(
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
alias chkmd5='cd ~ && cat a.txt | sed 's/^checksum:.*//g'  | tr -d "\r\n\t: " |  md5sum  | head -c 8'

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

