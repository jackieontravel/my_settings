# .bashrc_func_vcs_svn.sh
##############################################
# History
# 2025/3/6      - Initial release for .bashrc_func_vcs_svn.sh to be a standalone file
##############################################


##############################################################################
##
##  SVN related functions
##
##############################################################################
# svnmod: svn check for modification -- basic version
# Updated at 2025/3/6:
#   - List unversioned files as well
#   - Allow to accept optional arguments -- can be called by noisvnmod
#   - Achieved by calling vcsmod
# $1: svn options
svnmod()
{
    vcsmod svn status $*
}


# svnmodl: svn check for modification -- linux version: with linux path
svnmodl()
{
### l stands for Linux format.
### Use svnmodl to show modified file in Linux format, so that I can:
###     - revert it individually with 'svn revert'
###     - check diff with 'svn diff'

    local svn_option="$*"
    svn status $svn_option | awk '{status=substr($0, 1, 1);
                                    path=substr($0, 9);
                                    printf("%s:\n%s\n",status,path)}'
}


# svnmodt: svn check for modification -- Tortoise version
svnmodt()
{
    vcsmodt svn $*
}


#################################################################################
# "no-ignore" version of svnmod, svnmodl, svnmodt: to deal with libraries
#################################################################################
noisvnmod()
{
    svnmod --no-ignore
}


noisvnmodl()
{
### l stands for Linux format.
### Use svnmodl to show modified file in Linux format, so that I can:
###     - revert it individually with 'svn revert'
###     - check diff with 'svn diff'
    svnmodl --no-ignore
}



## Generate a command to show modified file in Tortoise GUI. Notation: svnmod+t=svnmodt
## Tips: search ':\\' to be recoginzed as a Windows path
noisvnmodt()
{
    svnmodt --no-ignore
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

