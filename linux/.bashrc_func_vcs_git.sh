# .bashrc_func_vcs_git.sh
##############################################
# History
# 2025/3/6      - Rename to .bashrc_func_vcs_git.sh to be called by bashrc_func_vcs.sh
# 2025/2/27     - Initial release for .bashrc_git_func.sh, to support handy functions and aliases for git.
##############################################
GIT_HELP_VERSION="V0.9 2025/3/11"

########################################################################################################
#   Default Values: 
#   they are supposed to be set in the calling script (.bashrc), if not set, below are the default values
########################################################################################################
# Basic colors
cDEF='\e[0m'
cBLUE='\e[34m'

########################################################################################################
#   Handy aliases
########################################################################################################


#########################################################################
#   Functions
#########################################################################
# Show a command with predefined color
# $1: command to be shown
show_cmd() {
    local cmd="$1"
    echo -e "${cBLUE}$cmd${cDEF}"
}


# Show a command then run it
# $1: command to be shown and run
show_then_run_cmd() {
    local cmd="$1"
    echo -e "${cBLUE}$cmd${cDEF}"
    eval "$cmd"
}


# githelp: Automatically list all git-related functions with descriptions "^#help: " and "^#cmd: "
githelp() {
    local script_file="$HOME/.bashrc_func_vcs_git.sh"
    local search_func="$1"  # Capture search pattern
    local help_sum=$(md5sum $script_file | awk '{print substr($1, length($1)-7)}')
    
    awk -v search_func="$search_func" -v help_sum="$help_sum" -v ver="$GIT_HELP_VERSION" '
        BEGIN { 
            ORS = "";  # Disable automatic newline
            printf "githelp: %s (%s)\n", ver, help_sum
        }

        # Extract help message
        /^#help:/ { 
            gsub("^#help: ", "", $0); 
            if (help_msg) 
                help_msg = help_msg " " $0; 
            else 
                help_msg = $0; 
        }

        # Extract command message
        /^#cmd:/ { 
            gsub("^#cmd: ", "", $0); 
            if (cmd_msg) 
                cmd_msg = cmd_msg " " $0; 
            else 
                cmd_msg = $0; 
        }

        # Detect function definitions
        /^[a-zA-Z_][a-zA-Z0-9_]* *\(\)/ {  
            func_name = $1;
            gsub("\\(\\)", "", func_name);  # Remove "()"

            # Create a temporary search pattern (preventing persistent modification)
            temp_search = search_func;
            gsub("\\*", ".*", temp_search);
            gsub("\\?", ".", temp_search);

            # Print help message if found
            if ((help_msg || cmd_msg) && (!search_func || func_name ~ temp_search)) {  
                printf "\033[1;32m%-20s\033[0m %s\n", func_name, help_msg;
                if (cmd_msg) {
                    printf "  \033[33m%s\033[0m\n", cmd_msg;
                }
            }

            # Reset messages for next function
            help_msg = "";
            cmd_msg = "";
        }
    ' "$script_file" | less -R
}


#help: Get/set git alias
#cmd: git config --global alias.$alias_name $alias_command
gitalias() {
    local cmd
    if [ -z "$1" ]; then
        # If no argument is provided, list all aliases
        cmd="git config --global --list | grep alias"
        show_then_run_cmd "$cmd"
    else
        if [[ "$1" =~ ^([a-zA-Z0-9_-]+)=(.+)$ ]]; then
            alias_name="${BASH_REMATCH[1]}"
            alias_command="${BASH_REMATCH[2]}"
            cmd="git config --global alias.$alias_name $alias_command"
            show_then_run_cmd "$cmd"
            echo "Alias '$alias_name' set to '$alias_command'"
        elif [[ "$1" =~ ^([a-zA-Z0-9_-]+)=$ ]]; then
            alias_name="${BASH_REMATCH[1]}"
            cmd="git config --global --unset alias.$alias_name"
            show_then_run_cmd "$cmd"
            echo "Alias '$alias_name' is unset"
        else
            echo "Invalid format. Use 'alias_name=command'."
        fi
    fi
}

#help: Show git local and remote branch
#cmd: git branch -a
gitbr() {
    local cmd="git branch -a $*"
    show_then_run_cmd "$cmd"
}


#help: Show git local and remote branch in verbose
#cmd: git branch -a -vv 
gitbrvv() {
    local cmd="git branch -a -vv $*"
    show_then_run_cmd "$cmd"
}


#help: git commit
#cmd: git commit [-a] [--dry-run]
gitcommit() {
    local cmd="git commit $*"
    show_then_run_cmd "$cmd"
}


#help: Delete git branch (default: -d, force: -D)
#cmd: git branch [-d|-D] <branchname>
gitbrdelete() {
    local args=();
    local delete_opt="-d"
    local cmd branch_name
    
    for arg in "$@";
    do
        if [[ "$arg" == "-d" || "$arg" == "-D" ]]; then
            delete_opt=$arg;
        else
            branch_name=$arg
        fi;
    done;
    
    cmd="git branch $delete_opt $branch_name"
    show_then_run_cmd "$cmd"
}


#help: Set upstream of a local branch (default: HEAD)
#cmd: git branch --set-upstream-to=<upstream> [<branchname>]
gitbrsetups() {
    local cmd="git branch --set-upstream-to=$*"
    show_then_run_cmd "$cmd"
}


#help: List git config
#cmd: git config --list [[--global]|[--local]] [--edit] (overwrite --list)
gitconfig() {
    local cmd
    local args=();
    
    action='--list';
    for arg in "$@";
    do
        if [ "$arg" == "--edit" ]; then
            action='--edit';
        else
            args+=("$arg");
        fi;
    done;
    
    cmd="git config $action ${args[@]}"
    show_then_run_cmd "$cmd"
}


#help: List git config: global
#cmd: git config --list --global [--edit] (overwrite --list)
gitconfigglobal() {
    gitconfig --global "$*"
}


#help: List git config: local
#cmd: git config --list --local [--edit] (overwrite --list)
gitconfiglocal() {
    gitconfig --local "$*"
}


#help: Set git config to apply "xavi" account: jackieyeh-xavi
#cmd: git config user.name and otehrs
gitconfig2xavi() {
    local cmd="git config --local user.name jackieyeh-xavi"
    show_then_run_cmd "$cmd"
    local cmd="git config --local user.email jackie_yeh@xavi.com.tw"
    show_then_run_cmd "$cmd"
    local cmd="git config --local credential.username jackieyeh-xavi"
    show_then_run_cmd "$cmd"
    local cmd="git config --local core.sshCommand \"ssh -i ~/.ssh/id_ed25519_jackieyeh-xavi\""
    show_then_run_cmd "$cmd"
}


#help: Set git config to apply "gmail" account: jackieontravel
#cmd: git config user.name and otehrs
gitconfig2gmail() {
    local cmd="git config --local user.name jackieontravel"
    show_then_run_cmd "$cmd"
    local cmd="git config --local user.email jackieontravel@gmail.com"
    show_then_run_cmd "$cmd"
    local cmd="git config --local credential.username jackieontravel"
    show_then_run_cmd "$cmd"
    local cmd="git config --local core.sshCommand \"ssh -i ~/.ssh/id_ed25519_jackieontravel\""
    show_then_run_cmd "$cmd"
}


#help: Temporarily set user to "gmail" account: jackieontravel, useful fot 'git clone'
#cmd: export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_jackieontravel'
gittempuser2gmail() {
    local cmd="export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_jackieontravel'"
    show_then_run_cmd "$cmd"
}


#help: Temporarily set user to "xavi" account: jackieyeh-xavi, useful fot 'git clone'
#cmd: export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_jackieyeh-xavi'
gittempuser2xavi() {
    local cmd="export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_jackieyeh-xavi'"
    show_then_run_cmd "$cmd"
}



#help: basic git diff 
#cmd: git diff [file]
gitdiff() {
    local cmd="git diff $*"
    show_then_run_cmd "$cmd"
}


#help: git diff to check name-status
#cmd: git diff --name-status [commit]|[<commit>..<commit>]|[<branch>...<branch>] (merge base)
gitdiffnames() {
    local cmd="git diff --name-status $*"
    show_then_run_cmd "$cmd"
}


#help: Show command to open Windows diff tool. file2 is optional, default the base of file1.
#cmd: gitdifft <file1> [<file2>]
gitdifft() {
    local file1="$1"
    local file2="$2"
    local file1_win file2_win path_opt path2_opt=""
    
    file1_win=$(lrpath2wapath $file1)
    path_opt="/path:\"$file1_win\""

    if [ -n "$file2" ]; then
        file2_win=$(lrpath2wapath $file2)
        path2_opt="/path2:\"$file2_win\""
    fi
    
    echo "TortoiseGitProc.exe /command:diff $path_opt $path2_opt"
}


#help: Fetch remote <repo> and optional <branch>
#cmd: git fetch [<repo> [branch]]
gitfetch() {
    local cmd="git fetch $*"
    show_then_run_cmd "$cmd"
}


#help: Show git logs in oneline with optimized format. use "-j" to exclude Jenkins
#cmd: git log --oneline --graph --decorate [-j] [--author=<author>] [--name-status] [--pretty] [[branch]/[commit]] ["<commit1>..<commit2>"]
gitlog() { 
    local num_logs=-15
    local exclude_jenkins=0 author_pattern="" date_fmt display_fmt user_author=""
    local args=()

    for arg in "$@"; do
        case "$arg" in
            --author=*) 
                user_author="${arg#--author=}"  # Extract author pattern
                ;;
            --jj | -j)
                exclude_jenkins=1
                author_pattern='^((?!.*enkins).*)$'
                ;;
            -[0-9]* | [0-9]*) 
                num_logs="$arg"
                ;;
            *)
                args+=("$arg")
                ;;
        esac
    done

    date_fmt="format:%Y-%m-%d %H:%M:%S"
    display_fmt="%C(green)%h%C(reset) %C(cyan)%<(12,trunc)%an%C(reset) %C(yellow)%cd%C(reset)%C(magenta)%d%C(reset) %<(60,trunc)%s"

    # Use user-provided --author if available; otherwise, apply the default (if -j is used)
    local author_flag=""
    if [[ -n "$user_author" ]]; then
        author_flag="--author=\"$user_author\""
    elif (( exclude_jenkins )); then
        author_flag="--author='$author_pattern'"
    fi

    local cmd="git log --oneline --graph --decorate $num_logs --date=\"$date_fmt\" --format=\"$display_fmt\" --perl-regexp $author_flag ${args[*]}"
    show_then_run_cmd "$cmd"
}


#help: Merge a branch into local active master
#cmd: git merge <branch>
gitmerge() {
    local cmd="git merge $*"
    show_then_run_cmd "$cmd"
}


#help: Move or rename a file, a directory, or a symlink controlled by git
#cmd: git mv <oldname> <newname>
gitmv() {
    local cmd="git mv $*"
    show_then_run_cmd "$cmd"
}


#help: Push local HEAD to remote <repo> and optional <branch>
#cmd: git push [<repo> [branch]]
gitpush() {
    local cmd="git push $*"
    show_then_run_cmd "$cmd"
}


#help: Pull remote <repo> and optional <branch> to local HEAD
#cmd: git pull [<repo> [branch]]
gitpull() {
    local cmd="git pull $*"
    show_then_run_cmd "$cmd"
}


#help: Rebase a branch
#cmd: git rebase [<upstream> [<branch>]]
gitrebase() {
    local cmd="git rebase $*"
    show_then_run_cmd "$cmd"
}



#help: List remote repo in verbose
#cmd: git remote -v
gitremote() {
    local cmd="git remote -v"
    show_then_run_cmd "$cmd"
}

#help: Add git remote repo
#cmd: git remote add <repo_name> <url>
gitremoteadd() {
    local cmd="git remote add $*"
    show_then_run_cmd "$cmd"
}

#help: Remove git remote repo
#cmd: git remote remove <repo_name>
gitremoteremove() {
    local cmd="git remote remove $*"
    show_then_run_cmd "$cmd"
}


#help: Rename git remote repo
#cmd: git remote rename <old> <new>
gitremoterename() {
    local cmd="git remote rename $*"
    show_then_run_cmd "$cmd"
}


#help: Restore modified files
#cmd: git restore [ . | <file> | --staged <file> ]
gitrestore() {
    local cmd="git restore $*"
    show_then_run_cmd "$cmd"
}


#help: Reset current HEAD to the specified commit with --hard: clears staging and discards uncommitted files
#cmd: git reset --hard <commit>
gitresethard() {
    local cmd="git reset --hard $*"

    # Show the command to be executed
    show_cmd "$cmd"

    # Warn the user about data loss
    echo "⚠ WARNING: This will reset your branch and discard all uncommitted changes!"
    read -p "Are you sure? (y/N): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        eval "$cmd"
    else
        echo "Operation canceled."
    fi
}


#help: Reset current HEAD to the specified commit with --soft: don't clear staging and don't discard uncommitted files
#cmd: git reset --soft <commit>
gitresetsoft() {
    local cmd="git reset --soft $*"
    show_then_run_cmd "$cmd"
}


#help: show git commit with file list
#cmd: git show --name-status [commit]
gitshow() {
    local cmd="git show --name-status $*"
    show_then_run_cmd "$cmd"
}


#help: show git status
#cmd: git status
gitst() {
    local cmd="git status $*"
    show_then_run_cmd "$cmd"
}


#help: Stash all tracked files
#cmd: git stash
gitstash() {
    local cmd="git stash $*"
    show_then_run_cmd "$cmd"
}


#help: Stash all files including tracked and untracked files
#cmd: git stash -u
gitstashuntrack() {
    local cmd="git stash -u $*"
    show_then_run_cmd "$cmd"
}


#help: List all stashed changes
#cmd: git stash list
gitstashlist() {
    local cmd="git stash list $*"
    show_then_run_cmd "$cmd"
}


#help: Pop from stash list and apply to working tree
#cmd: git stash pop [index]
gitstashpop() {
    local cmd="git stash pop $*"
    show_then_run_cmd "$cmd"
}


#help: Show specified stashed changes
#cmd: git stash show [index]
gitstashshow() {
    local cmd="git stash show $*"
    show_then_run_cmd "$cmd"
}


#help: Drop specified stashed changes: all modified files restored, added files removed.
#cmd: git stash drop [index]
gitstashdrop() {
    local cmd="git stash drop $*"
    show_then_run_cmd "$cmd"
}


#help: Clear all stashed changes: drop everything
#cmd: git stash clear
gitstashclear() {
    local cmd="git stash clear $*"
    show_then_run_cmd "$cmd"
}

#help: Show modified files in short format, and convert to DOS path for Windows editor
#cmd: git status --short
gitmod() {
    vcsmod git status --short $*
}

#help: Show modified files in short format, and keep its path
#cmd: git status --short
gitmodl() {
### l stands for Linux format.
### Use gitmodl to show modified file in Linux format, so that I can:
###     - restore it individually with 'svn restore'
###     - check diff with 'git diff'

    local git_option="$*"
    git status --short $svn_option | awk '{status=substr($0, 1, 2);
                                    path=substr($0, 3);
                                    printf("%s:\n%s\n",status,path)}'
}


#help: Generate a command to show modified file in TortoiseGit GUI. Good for small project, long tiime for large project
#cmd: git status --short
gitmodt() {
    echo -e "!!! For TortoiseGit, this may a very very very long time for a big project, use gitmodd instead"
    vcsmodt git $*
}

#help: Show modified files in short format, and convert to DOS path for Windows diff tool
#cmd: git status --short
gitmodd() {
    vcsmodd git $*
}



