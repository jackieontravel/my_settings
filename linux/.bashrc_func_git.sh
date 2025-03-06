# .bashrc_git_func.sh
##############################################
# History
# 2025/2/27    - Initial release for .bashrc_git_func.sh, to support handy functions and aliases for git.
##############################################


########################################################################################################
#   Default Values: 
#   they are supposed to be set in the calling script (.bashrc), if not set, below are the default values
########################################################################################################


########################################################################################################
#   Handy aliases
########################################################################################################


#########################################################################
#   Functions
#########################################################################
# Show a command then run it
# $1: command to be shown and run
show_then_run_cmd() {
    local cmd="$1"
    local cDEF='\e[0m'
    local cBLUE='\e[34m'
    echo -e "${cBLUE}$cmd${cDEF}"
    eval "$cmd"
    
}


# githelp: Automatically list all git-related functions with descriptions "^#help: " and "^#cmd: "
githelp() {
    local script_file="$HOME/.bashrc_func_git.sh"
    local search_func="$1"  # Capture search pattern

    awk -v search_func="$search_func" '
        BEGIN { 
            ORS = "";  # Disable automatic newline
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
        /^[a-zA-Z_][a-zA-Z0-9_]* *\(\) *\{/ {  
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



#help: git diff 
#cmd: git diff 
gitdiff() {
    local cmd="git diff $*"
    show_then_run_cmd "$cmd"
}


#help: Fetch remote <repo> and optional <branch>
#cmd: git fetch [<repo> [branch]]
gitfetch() {
    local cmd="git fetch $*"
    show_then_run_cmd "$cmd"
}


#help: Show git logs in oneline with optimized format. use "-j" to exclude Jenkins
#cmd: git log --oneline [-j] [--name-status] [--pretty] [[branch]/[commit]] ["<commit1>..<commit2>"]
gitlog() { 
    local num_logs=-15;
    local exclude_jenkins=0 author_pattern date_fmt display_fmt;
    local args=();
    
    author_pattern='';
    for arg in "$@";
    do
        if [[ "$arg" == "--jj" || "$arg" == "-j" ]]; then
            exclude_jenkins=1;
            author_pattern='^((?!.*enkins).*)$';
        else
            if [[ "$arg" =~ ^-?[0-9]+$ ]]; then
                num_logs="$arg";
            else
                args+=("$arg");
            fi;
        fi;
    done;
    date_fmt="format:%Y-%m-%d %H:%M:%S";
    display_fmt="%C(green)%h%C(reset) %C(cyan)%<(12,trunc)%an%C(reset) %C(yellow)%cd%C(reset)%C(magenta)%d%C(reset) %<(60,trunc)%s";
    git log "$num_logs" --oneline --date="$date_fmt" --format="$display_fmt" --perl-regexp --author="$author_pattern" "${args[@]}"
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


