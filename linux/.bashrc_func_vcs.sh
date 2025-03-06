# .bashrc_func_vcs.sh
##############################################
# History
# 2025/3/6    - Initial release for .bashrc_func_vcs.sh, to support handy functions and aliases for vcs.
##############################################

########################################################################################################
#   Common parts for vcs (Version Controlled Software): 
########################################################################################################
# vcsmod: check for modification -- list for Windows editor
vcsmod()
{
    ### Check WINDOWS_DISK to make sure further processing can work
    if [ -z "$WINDOWS_DISK" ]; then
        echo "ERROR. Please set WINDOWS_DISK first... "
        return;
    fi
    
    ### Currently we support only svn and git
    if [[ "$1" != "svn" && "$1" != "git" ]]; then
        echo "ERROR. VCS can support only 'svn' or 'git'"
        return;
    fi
    
    local cmd="$*"
    
    echo -n "$HOME" | sed 's/\//\\\\/g' | awk '{ printf "s/%s//", $1} ' > ~/.sed_svnmod.cmd
    
    local versioned_output_file=~/.vcsmod_versioned_file
    local unversioned_output_file=~/.vcsmod_unversioned_file
    
    # Make sure no remaining files
    rm -f $versioned_output_file
    rm -f $unversioned_output_file
    
    while IFS= read -r line; do
        if [ "$1" == "svn" ]; then
            status="${line:0:1}"
            path="$PWD/${line:8}"
        else
            status="${line:0:2}"
            path="$PWD/${line:3}"
        fi
        
        path_win=$(echo "$path" | sed 's/\//\\/g' | sed -f ~/.sed_svnmod.cmd)

        if [[ "${status:0:1}" == "?" ]]; then
            echo "$WINDOWS_EDITOR $WINDOWS_DISK$path_win" >> $unversioned_output_file
        else
            echo "$status:" >> $versioned_output_file
            echo "$WINDOWS_EDITOR $WINDOWS_DISK$path_win" >> $versioned_output_file
        fi
    done < <($cmd)

    # Print versioned files first
    if [ -f "$versioned_output_file" ]; then
        cat $versioned_output_file
    fi

    # Print unversioned files at the end
    if [ -f "$unversioned_output_file" ]; then
        echo -e "\n\nUnversioned:"
        cat $unversioned_output_file
    fi
    
    # Cleanup
    rm -f $versioned_output_file
    rm -f $unversioned_output_file
}


# vcsmodt: check for modification -- Tortoise version for svn, TortoiseGit version for git
## Generate a command to show modified file in Tortoise/TortoiseGit GUI.
# $1: svn|git
# $2: other svn|git options
## Tips: search ':\\' to be recoginzed as a Windows path
## Tips: 'svnmod' or 'gitmod' is defined later in .bashrc_func_vcs_svn.sh and .bashrc_func_vcs_git.sh
vcsmodt()
{
    ### Currently we support only svn and git
    if [[ "$1" != "svn" && "$1" != "git" ]]; then
        echo "ERROR. VCS can support only 'svn' or 'git'"
        return;
    fi
    
    local vcs_cmd=$1
    shift
    local vcs_option="$*"
    local vcsmod_output=~/.vcsmod_output
    
    if [ "$vcs_cmd" == "svn" ]; then
        svnmod $vcs_option > $vcsmod_output
        PROC_PROG=TortoiseProc.exe
    else
        gitmod $vcs_option  > $vcsmod_output
        PROC_PROG=TortoiseGitProc.exe
    fi
    
    awk -v WINDOWS_DISK="$WINDOWS_DISK" -v prog="$PROC_PROG" '
    BEGIN {
        printf("\n\n%s /command:repostatus /path:\"", prog)
        versioned_count = 0
        unversioned_start = 0
        unversioned_count = 0
        unversioned_files = ""  # Variable to store unversioned file names
    }
    {
        if (match($1, /Unversioned:/)) 
            unversioned_start = 1
        
        if (match($2, /:\\/)) {
            if (match($1, WINDOWS_DISK)) 
                filename = $1
            else 
                filename = $2

            if (unversioned_start == 1) {
                unversioned_count++
                unversioned_files = unversioned_files "    " filename "\n"  # Collect unversioned file names
            } else {
                versioned_count++
            }

            if (versioned_count == 1) 
                printf("%s", filename)
            else 
                printf("*%s", filename)
        }
    }
    END {
        printf("\"\n\n\nTotal %d files\n", (versioned_count + unversioned_count))
        if (unversioned_count != 0) {
            printf("* Unversioned files: %d\n", unversioned_count)
            printf("%s", unversioned_files)  # Print collected unversioned file names
        }
    }' "$vcsmod_output"
    
    # Cleanup
    # rm -f $vcsmod_output
}


# vcsmodd: check for modification -- list for Windows diff tool
vcsmodd()
{
    ### Currently we support only svn and git
    if [[ "$1" != "svn" && "$1" != "git" ]]; then
        echo "ERROR. VCS can support only 'svn' or 'git'"
        return;
    fi
    
    local vcs_cmd=$1
    shift
    local vcs_option="$*"
    local vcsmod_output=~/.vcsmod_output
    
    if [ "$vcs_cmd" == "svn" ]; then
        svnmod $vcs_option > $vcsmod_output
        PROC_PROG=TortoiseProc.exe
    else
        gitmod $vcs_option  > $vcsmod_output
        PROC_PROG=TortoiseGitProc.exe
    fi
    
    sed '/^'"$WINDOWS_EDITOR"'/s|'"$WINDOWS_EDITOR"' |'"$PROC_PROG"' /command:diff /path:"|; /:\\/s|$|"|' "$vcsmod_output"

    # Cleanup
    rm -f $vcsmod_output
}


########################################################################################################
#   Classified Functions: 
#   - svn
#   - git
########################################################################################################
source $HOME/.bashrc_func_vcs_svn.sh
source $HOME/.bashrc_func_vcs_git.sh

