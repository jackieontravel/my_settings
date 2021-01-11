#!/usr/bin/env python

# This script works on Python 2.7
import os
import sys
import cStringIO
from subprocess import *

#### User-specific variables, change to meet actual situations  ##############
# Default DISK_LETTER is U: for outside of MOCK
if os.environ.get('WINDOWS_DISK'):
    DISK_LETTER_NORMAL=os.environ.get('WINDOWS_DISK')
else:    
    DISK_LETTER_NORMAL="U:"
    
# Default DISK_LETTER is W: for MOCK
if os.environ.get('WINDOWS_DISK'):
    DISK_LETTER_MOCK=os.environ.get('WINDOWS_DISK')
else:    
    DISK_LETTER_MOCK="W:"
    
# Default editor is  "notepad++"
if os.environ.get('WINDOWS_EDITOR'):
    EDITOR=os.environ.get('WINDOWS_EDITOR')
else:    
    EDITOR="notepad++"

if EDITOR == "notepad++":
    LN_NUM_FORMAT=" -n"
else:    # Linux default, mainly for vscode
    LN_NUM_FORMAT=":"

# Default path for Windows, option to keep Linux
if os.environ.get('FS_PATH_TYPE'):
    PATH_TYPE=os.environ.get('FS_PATH_TYPE')
else:
    PATH_TYPE="WINDOWS"



FS_EXCLUDE_DIRS="-name .svn -o -name AppLibs -o -path ./BSEAV/bin -o -path ./out -o -name .git -o -name .repo -o -name objs"
EXCLUDE_FILES="--exclude='*.d' --exclude='*.o' --exclude='*.so' --exclude='*.map' --exclude='ctags.tmp' --exclude='GPATH' --exclude='GRTAGS' --exclude='GTAGS' --exclude='gtags.conf' --exclude='tags'"

# We don't skip too many dirs for ff, hopefully we can still find *.o
FF_EXCLUDE_DIRS="-name .svn -o -name .git -o -name .repo"

FS_REL_VER=os.environ.get('FS_REL_VER')
FS_REL_DATE=os.environ.get('FS_REL_DATE')

##############################################################################


#### Common global variables, !!! DONT'T CHANGE !!! ##########################
NPROC=2
FS_CMD_FILE=os.environ.get('FS_CMD_FILE')
FF_CMD_FILE=os.environ.get('FF_CMD_FILE')
NOT_IN_MOCK=0
sudo_cmd=""
DISK_ROOT=""
D_HOME=""
DISK_LETTER=""
##############################################################################

# Check if we are in Mock. original Linux command:
# REF: http://stackoverflow.com/questions/75182/detecting-a-chroot-jail-from-within
### export NOT_IN_MOCK=$(mount |grep chroot>/dev/null; echo $?)
def checkIfRunningInMock():
    global NOT_IN_MOCK, sudo_cmd, DISK_ROOT, D_HOME, DISK_LETTER

    p1 = Popen(["mount"], stdout=PIPE)
    p2 = Popen(["grep", "chroot"], stdin=p1.stdout, stdout=PIPE)
    output = p2.communicate()[0]
    if output:
        NOT_IN_MOCK = 0
        # setup other parameters under Mock
        DISK_LETTER = DISK_LETTER_MOCK
        sudo_cmd=""
        if os.path.isfile("/builddir/.mock_name"):
            f=open("/builddir/.mock_name")
            MOCK_PREFIX=f.read().replace("\n", "")
            f.close()
            DISK_ROOT= "/" + MOCK_PREFIX + "/root"
        else:
            DISK_ROOT="Please get /builddir/.mock_name from external"
        D_HOME=os.environ.get('HOME')
    else:
        NOT_IN_MOCK = 1
        # setup other parameters in normal environment
        DISK_LETTER = DISK_LETTER_NORMAL
        sudo_cmd="sudo"
        DISK_ROOT=""
        D_HOME=""


# Generate command file of fs which is then to be executed by shell.
def genFsCmdFile(pattern, *options):
    global NOT_IN_MOCK, sudo_cmd

    print ( "fs %s (%s) - Find strings by Python pre-processing. Use 'fshelp' to check the usage ('fs4linux' to keep Linux path).\n" % (FS_REL_VER, FS_REL_DATE ))

    LINE_OUTPUT_FORMAT="\033[90m"   # Set to GRAY, see http://misc.flogisoft.com/bash/tip_colors_and_formatting for color details
    LINE_OUTPUT_NORMAL="\033[0m"    # Restore to default

    # collect all options as grep_opt:
    # v3.4.0 update: in order to support multiple target search. we don't process '-e' option any more.
    # The user is requested to pay attention to put '-e' as the last option
    grep_opt = ""
    for opt in options[0]:
        grep_opt += opt + " "
    
    # Get options from OS: fst(file_type), fsd(md) and fsopt(extra_opt)
    fsType = os.environ.get('fst')
    if fsType == "c":
        # file_type="-regex '.*cp*$'"
        file_type="-type f -name '*.[c\|cc\|cpp]'"
    elif fsType == "h":
        file_type="-type f -name '*.[h\|hh]'"
    elif (fsType == "ch") | (fsType == "hc") :
        file_type="-type f -name '*.[c\|cc\|cpp\|h\|hh]'"
    elif (fsType == "m")  | (fsType == "makefile")  | (fsType == "Makefile"):  # Search for Makefiles: *.mak, makefile, Makefile, *.mk, *.in
        file_type="-type f \( -name '*.mak' -o -name makefile -o -name Makefile -o -name '*.mk' -o -name '*.in' \)"
    elif (fsType == "j") | (fsType == "java"): # Search for Java
        file_type="-type f -name '*.java'"
    elif fsType:
        # Use this to assign multiple file type: fst='*.java -o -name *.h'
        file_type="-type f \( -name " + fsType + " \)"
    else:
        file_type="-type f"

    fsDepth = os.environ.get('fsd')
    if fsDepth:
        md=int(fsDepth)
    else:
        md=9999

    # Then check if searching path is assigned
    # NOTE: Put a 'smart' check on the path: first check if it's a relative path, otherwise treat it as a absolute path.
    spath = "."
    # OS env 'fsp' has higher priority than options to assign searching path
    _spath = ""
    if os.environ.get('fsp'):
        _spath = os.environ.get('fsp')

    if len(_spath) > 0:
        if os.path.exists( "./" + _spath ):
            spath = "./" + _spath
        else:
            spath = os.path.relpath( _spath, "." )
            
    # fsopt is used to specify find options.
    if os.environ.get('fsopt'):
        find_opt=os.environ.get('fsopt')
    else:
        find_opt=""

    cmd_find = "time find " + find_opt + " " + spath + " -maxdepth " + str(md) + " -type d \\( " + FS_EXCLUDE_DIRS + " \\) -prune -o " + file_type + " -print0"
    cmd_grep = "xargs -0 -P" + str(NPROC) + " grep -nIH " + EXCLUDE_FILES + " --color=always " + grep_opt + " '" + pattern + "'"

    # f2/f3/f4/.../f8 are used to specify second grep option. This  is also called a search filter
    # default color to f2: bold GREEN
    if os.environ.get('f2'):
        f2_opt = os.environ.get('f2')
        cmd_grep2 = '| GREP_COLORS="ms=01;32" grep ' + f2_opt + ' --color=always '
    else:
        cmd_grep2 = ""
    
    # default color to f3: bold YELLOW
    if os.environ.get('f3'):
        f3_opt = os.environ.get('f3')
        cmd_grep3 = '| GREP_COLORS="ms=01;33" grep ' + f3_opt + ' --color=always '
    else:
        cmd_grep3 = ""
    
    # default color to f4: bold BLUE
    if os.environ.get('f4'):
        f4_opt = os.environ.get('f4')
        cmd_grep4 = '| GREP_COLORS="ms=01;34" grep ' + f4_opt + ' --color=always '
    else:
        cmd_grep4 = ""
    
    # default color to f5: bold PINK
    if os.environ.get('f5'):
        f5_opt = os.environ.get('f5')
        cmd_grep5 = '| GREP_COLORS="ms=01;35" grep ' + f5_opt + ' --color=always '
    else:
        cmd_grep5 = ""
    
    # default color to f6: underline RED
    if os.environ.get('f6'):
        f6_opt = os.environ.get('f6')
        cmd_grep6 = '| GREP_COLORS="ms=04;31" grep ' + f6_opt + ' --color=always '
    else:
        cmd_grep6 = ""
    
    # default color to f7: underline GREEN
    if os.environ.get('f7'):
        f7_opt = os.environ.get('f7')
        cmd_grep7 = '| GREP_COLORS="ms=04;32" grep ' + f7_opt + ' --color=always '
    else:
        cmd_grep7 = ""
    
    # default color to f8: underline YELLOW
    if os.environ.get('f8'):
        f8_opt = os.environ.get('f8')
        cmd_grep8 = '| GREP_COLORS="ms=04;33" grep ' + f8_opt + ' --color=always '
    else:
        cmd_grep8 = ""
    
    # The path under DISK_LETTER which we'll use in DOS 
    if PATH_TYPE == "WINDOWS":
        path_under_disk = DISK_ROOT + os.getcwd().replace(os.environ.get('HOME'), D_HOME)
    else:
        path_under_disk = ""
    
    awk_opt  = "-F':' "
    awk_opt += ' -v editor="' + EDITOR + '"'
    awk_opt += ' -v disk=' + DISK_LETTER 
    awk_opt += ' -v root_path=' + path_under_disk
    awk_opt += ' -v fmt=' + LINE_OUTPUT_FORMAT 
    awk_opt += ' -v fmt_normal=' + LINE_OUTPUT_NORMAL 
    awk_opt += ' -v lnfmt="' + LN_NUM_FORMAT + '"'
    awk_opt += ' -v last_path='
    # Escape noteice: use '\\' to reprent '\' in awk programe
    awk_line = []
    awk_line.append( 'BEGIN {}' )
    awk_line.append( '{' )
    awk_line.append( '    if ( NF >= 3 )' )
    awk_line.append( '    {' )
    awk_line.append( '        path=root_path"/"$1;' )
    awk_line.append( '        if ( path != last_path )' )
    awk_line.append( '        {' )
    awk_line.append( '            file_count++;' )
    awk_line.append( '            last_path = path;' )
    awk_line.append( '        }' )
    if PATH_TYPE == "WINDOWS":
        awk_line.append( '        gsub("/", "\\\\", path);' )
    awk_line.append( '        printf("%s%s %s%s%s%s%s\\n", fmt, editor, disk, path, lnfmt, $2, fmt_normal);' )
    awk_line.append( '        printf("%s\\n", substr($0, 3+length($1)+length($2)));' )
    awk_line.append( '        line_count++;' )
    awk_line.append( '    }' )
    awk_line.append( '    else' )
    awk_line.append( '    {' )
    awk_line.append( '        printf("%s\\n", $0);' )
    awk_line.append( '    }' )
    awk_line.append( '}' )
    awk_line.append( 'END {printf("\\n--- Total %d lines in %d files. Show command:\\ncat ' +  FS_CMD_FILE + '\\n", line_count, file_count)}' )
    
    # concatenate above awk script with new line ('\n') to be read easily
    nl="\n"
    awk_prog = nl.join(awk_line)
    
    cmd_awk = "awk " + awk_opt + " '" + awk_prog + "'"

    f = open(FS_CMD_FILE, 'w')
    # Save current GREP_COLORS. see grep man page: http://linux.die.net/man/1/grep
    f.write ('cur_grep_color=$GREP_COLORS\n')
    # set GREP_COLORS: unset the colors of fn (filename), ln (line #), and se (separators) -- so that we can control the line output format by LINE_OUTPUT_FORMAT
    f.write ('export GREP_COLORS="ms=01;31:mc=01;31:sl=:cx=:fn=:ln=:bn=32:se="\n')

    f.write ( cmd_find + " | " + cmd_grep + cmd_grep2 + cmd_grep3 + cmd_grep4 + cmd_grep5 + cmd_grep6 + cmd_grep7 + cmd_grep8 + " | " + cmd_awk )
    
    f.write ('\nexport GREP_COLORS=$cur_grep_color\n')

    f.close()
    


def genFfCmdFile(pattern, *options):

    print ( "ff %s (%s) - Find files by Python pre-processing. Use 'ffhelp' to check the usage ('fs4linux' to keep Linux path).\n" % (FS_REL_VER, FS_REL_DATE ))

    # If we are in mock, sudo is not necessary.
    if NOT_IN_MOCK == 1:
        sudo_cmd="sudo"
    else:
        sudo_cmd=""

    # Get options from OS: fft(ff_type)
    convertToDos = 0
    ffType = os.environ.get('fft')
    if ffType == "ll":
        post_op = "-exec ls -ald --color {} \; "
    elif ffType == "ls":
        post_op = "-exec ls -ad --color  {} \; "
    elif ffType == "rm":
        post_op = "-exec /bin/rm -vrf {} \; "
    else:
        #default to use "dos" type
        post_op="-print"
        if PATH_TYPE == "WINDOWS":
            convertToDos = 1

    # default set maxdepth to 9999
    md=9999 
    
    # First check if maxdepth is assigned
    if len(options[0]) > 0:
        if options[0][0].isdigit():
            md = int(options[0][0])
            # delete maxdepth as we've consume it.
            del options[0][0]

    # OS env 'fsd' has higher priority than options to assign depth
    fsDepth = os.environ.get('fsd')
    if fsDepth:
        md=int(fsDepth)
           
    # Then check if searching path is assigned
    # NOTE: Put a 'smart' check on the path: first check if it's a relative path, otherwise treat it as a absolute path.
    spath = "."
    # OS env 'fsp' has higher priority than options to assign searching path
    _spath = ""
    if os.environ.get('fsp'):
        _spath = os.environ.get('fsp')
    else:
        _spath = os.path.dirname(pattern)

    if len(_spath) > 0:
        if os.path.exists( "./" + _spath ):
            spath = "./" + _spath
        else:
            # Unable to locate path, use "." to search everything.
            spath = "."

    # check if "-i" option is set to ignore case
    nameType = "-name"
    if len(options[0]) > 0:
        if options[0][0] == "-i":
            nameType = "-iname"
            del options[0][0]
    

    # check if pattern contains line number
    if ":" in pattern:
        filename=pattern.split(":")[0]
        linenum=pattern.split(":")[1]
    else:
        filename=pattern
        linenum=1
    
    filename_pattern = filename
    filename = os.path.basename(filename)
    cmd_find = sudo_cmd + ' find ' + spath + ' -maxdepth ' + str(md) + ' -type d \\( ' + FF_EXCLUDE_DIRS + ' \\) -prune -o ' +  nameType + ' "' + filename + '" ' + post_op

    # The path under DISK_LETTER which we'll use in DOS 
    path_under_disk = DISK_ROOT + os.getcwd().replace(os.environ.get('HOME'), D_HOME)
    
    awk_opt  = "-F':' "
    awk_opt += ' -v editor="' + EDITOR + '"'
    awk_opt += ' -v disk=' + DISK_LETTER 
    awk_opt += ' -v root_path=' + path_under_disk
    awk_opt += ' -v linenum=' + str(linenum)
    awk_opt += ' -v lnfmt="' + LN_NUM_FORMAT + '"'
    awk_opt += ' -v last_path='
    
    # Escape noteice: use '\\' to reprent '\' in awk programe
    awk_line = []
    awk_line.append    ( 'BEGIN {}' )
    awk_line.append    ( '{' )
    
    if convertToDos:
        awk_line.append( '    path=root_path"/"$1;' )
        awk_line.append( '    gsub("/", "\\\\", path);' )
        awk_line.append( '    if (linenum > 1)' )
        awk_line.append( '        printf("%s %s%s%s%d\\n", editor, disk, path, lnfmt, linenum);' )
        awk_line.append( '    else' )
        awk_line.append( '        printf("%s %s%s\\n", editor, disk, path);' )
    else:
        awk_line.append( '    print' )
        
    awk_line.append    ( '    file_count++' )
    awk_line.append    ( '}' )
    awk_line.append    ( 'END {printf("\\n--- Total %d files (directories). Show command:\\ncat ' +  FF_CMD_FILE + '\\n", file_count)}' )
    
    # concatenate above awk script with new line ('\n') to be read easily
    nl="\n"
    awk_prog = nl.join(awk_line)
    
    cmd_awk = "awk " + awk_opt + " '" + awk_prog + "'"

    f = open(FF_CMD_FILE, 'w')
    #f.write ( cmd_find + " | " + cmd_awk )
    grep_pattern = filename_pattern.replace("*", ".*");
    f.write ( cmd_find + " | grep '" + grep_pattern + "' | " + cmd_awk )
    f.close()

        
def fs(argv):
    options=""
    
    checkIfRunningInMock()

    pattern = argv[0]
    if len(argv) > 1 :
        options = argv[1:]
        
    genFsCmdFile(pattern, options)

    
def ff(argv):
    options=""
    
    checkIfRunningInMock()

    pattern = argv[0]
    if len(argv) > 1 :
        options = argv[1:]
        
    genFfCmdFile(pattern, options)

    
    
def main(argv):
    if argv[1] == "fs":
        fs (argv[2:])
    elif argv[1] == "ff":
        ff (argv[2:])
    else:
        print "Wrong usage! currently supported command: 'fs' and 'ff'"


if __name__ == "__main__":
    main(sys.argv)


