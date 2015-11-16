
# helper function for cenv:
# Usage: add_toolchain_path <TOOLCHAIN_BIN_PATH>
add_toolchain_path()
{
    # this AWK script make a clean path so that there is no any "opt/toolchains" inside the the $PATH
    clean_path=`echo $PATH |awk -F: '{ for (i=1; i<=NF; i++) if (! match($i, "opt/toolchains")) oStr = sprintf("%s%s", length(oStr)? oStr ":" : "", $i); print oStr}'`
    export PATH=$1:$clean_path
}

# helper funciton for cenv
# Usage: set_if_empty <var> <value>
#   set <value> to <var> if <var> is empty
set_if_empty()
{
	if [ "$#" != "2" ] ; then
	    echo $#
        echo "Wrong parameters!"
        echo "Usage: set_if_empty <var> <value>"
        return;
	fi
	
	var=$1
	value=$2
	curvalue=`eval echo -n '$'$var`
	if [  "$curvalue" == "" ] ; then
        eval `echo -e "export $var=\"$value\""`
	fi
}

cenv_print_usage_Galio_7405()
{
    /bin/echo "*******************************************************"
    /bin/echo "$TITLE"
    /bin/echo "*******************************************************"
    /bin/echo "export UCLINUX_DIR=${UCLINUX_DIR}"
    /bin/echo "export GALIO_DIR=${GALIO_DIR}"
    /bin/echo "export TOOLCHAINS_DIR=${TOOLCHAINS_DIR}"
    /bin/echo "refsw_dir=${refsw_dir}"
    /bin/echo ""
    /bin/echo -ne "\33[31;1mkernel:  \33[0m  \n"
    /bin/echo "build.bash $model_name kernel $opt_kernel"
    /bin/echo "build.bash $model_name kernel $opt_kernel rootfs image"
    /bin/echo -ne "\33[31;1mbrutus:  \33[0m  \n"
    /bin/echo "build.bash $model_name $opt_brutus $opt_vendor $extra_feature"
    /bin/echo -ne "\33[31;1mgalio:  \33[0m  \n"
    /bin/echo "build.bash $model_name galio $opt_galio $opt_vendor $extra_feature"
    /bin/echo -ne "\33[31;1mimage:  \33[0m  \n"
    /bin/echo "build.bash $model_name $opt_brutus $opt_vendor $extra_feature install $opt_install"
    /bin/echo -ne "\33[33;1mimage is '$image_name' and saved at $refsw_dir/BSEAV/bin \33[0m  \n"

    /bin/echo ""
    /bin/echo -ne "\33[31;1mupgrade:  \33[0m  \n"
    /bin/echo "At CFE:"
    /bin/echo "1. ifconfig eth0 -auto"
    /bin/echo "2. flash -noheader $host_ip:$image_name flash0.kernel"
    /bin/echo -ne "3. setenv -p STARTUP \"boot -z -tag -elf flash0.kernel: 'root=/dev/mtdblock0  ro mem=96M rootfstype=cramfs'\" \n"
    /bin/echo ""
    /bin/echo "At kernel:"
    /bin/echo "Usage:   upgrade [upgrade_url] [reboot]"
    /bin/echo "Example: upgrade ftp://$host_ip/$image_name 1"
}

c125() # Compiling option for XTV125
{
    #########
    ## History
    ##  2010/5/26:  Copied from c7405. add opt_install
    ##  2011/10/12: Update for leopard
    ##  2011/11/03: Update path to ${HOME}/src/125h/...
    ##  2011/11/18: Derived from cgtd
    ##  2012/7/30:  Call cenv_print_usage_Galio_7405() to simplify script
    ##  2012/8/1:   Use add_toolchain_path to add MIPS toolchain
    ##
    ##########   Edit your personal data begin ############################
    ### export environment variables for compiler use
    export TITLE="Compiling environment for 7405 R8.0 for XTV125"

    export TOOLCHAINS_DIR=/opt/toolchains/crosstools_hf-linux-2.6.18.0_gcc-4.2-11ts_uclibc-nptl-0.9.29-20070423_20090508
    export UCLINUX_DIR=${HOME}/src/125/2618-7.1/
    export GALIO_DIR=${HOME}/src/125/ant_galio_3.1.7-gwi-wx-cjka

    ### Add mipsel-linux-gcc path
    add_toolchain_path $TOOLCHAINS_DIR/bin


    ### setup following variables for help message
    refsw_dir=${HOME}/src/125/refsw-20110228.97405-r8.0
    host_ip=10.10.10.25
    
    ### set default option 
    opt_vendor=""
    opt_kernel=""
    opt_brutus="brutus mp3_full nowlan c99 dlna hls"
    opt_galio="mp3_full nowlan c99 dlna hls"
    opt_install=""
    ##########   Edit your personal directory end #########################

	if [ "$#" == 0 ] ; then
        model_name=XTV125
        extra_feature=
    else
        model_name=$1
        extra_feature="$2 $3 $4 $5 $6 $7 $8 $9"
	fi
    image_name=$model_name.img

    cd $refsw_dir
    cenv_print_usage_Galio_7405
}
               
   
alias c125h='cgtd $*'
cgtd() # Compiling option for GTD, copied from c7405
{
    #########
    ## History
    ##  2010/5/26:  Copied from c7405. add opt_install
    ##  2011/10/12: Update for leopard
    ##  2011/11/03: Update path to ${HOME}/src/125h/...
    ##  2012/7/30:  Call cenv_print_usage_Galio_7405() to simplify script
    ##  2012/8/1:   Use add_toolchain_path to add MIPS toolchain
    ##
    ##########   Edit your personal data begin ############################
    ### export environment variables for compiler use
    export TITLE="Compiling environment for refsw-20110228.97405-r8.0 (7405 R8.0 ) for *GTD* "

    export TOOLCHAINS_DIR=/opt/toolchains/crosstools_hf-linux-2.6.18.0_gcc-4.2-11ts_uclibc-nptl-0.9.29-20070423_20090508
    export UCLINUX_DIR=${HOME}/src/125h/2618-7.1/
    export GALIO_DIR=${HOME}/src/125h/ant_galio_3.1.7-gwi-wx-cjka
    export APPLIBS_DIR=${HOME}/src/125h/applibs_release_20110311

    ### Add mipsel-linux-gcc path
    add_toolchain_path $TOOLCHAINS_DIR/bin


    ### setup following variables for help message
    refsw_dir=${HOME}/src/125h/refsw-20110228.97405-r8.0
    host_ip=10.10.10.25
    
    ### set default option 
    opt_vendor="gtd"
    opt_kernel="gtd"
    opt_brutus="brutus verimatrix mp3_full nowlan c99 cg3210 dlna hls"
    opt_galio="verimatrix mp3_full nowlan c99 cg3210 dlna hls"
    opt_install="aes sign"
    ##########   Edit your personal directory end #########################

	if [ "$#" == 0 ] ; then
        model_name=XTV125h
        extra_feature=
    else
        model_name=$1
        extra_feature="$2 $3 $4 $5 $6 $7 $8 $9"
	fi
    image_name=$model_name.img

    cd $refsw_dir
    cenv_print_usage_Galio_7405
}
               

c125hmfg() # Compiling option for XTV125H, copied from cgtd 2015/9/23
{
    #########
    ## History
    ##  2010/5/26:  Copied from c7405. add opt_install
    ##  2011/10/12: Update for leopard
    ##  2011/11/03: Update path to ${HOME}/src/125h/...
    ##  2012/7/30:  Call cenv_print_usage_Galio_7405() to simplify script
    ##  2012/8/1:   Use add_toolchain_path to add MIPS toolchain
    ##  2015/9/23:  c125hmfg: Compiling option for XTV125H, copied from cgtd 2015/9/23
    ##
    ##########   Edit your personal data begin ############################
    ### export environment variables for compiler use
    export TITLE="Compiling environment for refsw-20110228.97405-r8.0 (7405 R8.0 ) for *XTV125H mfg* "

    export TOOLCHAINS_DIR=/opt/toolchains/crosstools_hf-linux-2.6.18.0_gcc-4.2-11ts_uclibc-nptl-0.9.29-20070423_20090508
    export UCLINUX_DIR=${HOME}/src/125hmfg/2618-7.1/
    unset GALIO_DIR
    unset APPLIBS_DIR

    ### Add mipsel-linux-gcc path
    add_toolchain_path $TOOLCHAINS_DIR/bin


    ### setup following variables for help message
    refsw_dir=${HOME}/src/125hmfg/refsw-20110228.97405-r8.0
    host_ip=10.10.10.25
    
    ### set default option 
    opt_vendor="mfg"
    opt_kernel="mfg"
    opt_brutus="brutus nowlan c99 cg3210"
    opt_galio="verimatrix mp3_full nowlan c99 cg3210 dlna hls"
    opt_install="aes sign"
    ##########   Edit your personal directory end #########################

	if [ "$#" == 0 ] ; then
        model_name=XTV125h
        extra_feature=
    else
        model_name=$1
        extra_feature="$2 $3 $4 $5 $6 $7 $8 $9"
	fi
    image_name=$model_name.img

    cd $refsw_dir
	if [ "$?" != 0 ]; then
		return
	fi
    cenv_print_usage_Galio_7405
}
               
			   
c125hw() # Compiling option for XTV125hw, copied from cgtd
{
    #########
    ## History
    ##  2010/5/26:  Copied from c7405. add opt_install
    ##  2011/10/12: Update for leopard
    ##  2011/11/01: Derived from cgtd to c125hw
    ##  2012/8/1:   Use add_toolchain_path to add MIPS toolchain
    ##
    ##########   Edit your personal data begin ############################
    ### export environment variables for compiler use
    export TITLE="Compiling environment for refsw-20110228.97405-r8.0 (7405 R8.0 ) for *XTV125hw w/ applibs* "

    export TOOLCHAINS_DIR=/opt/toolchains/crosstools_hf-linux-2.6.18.0_gcc-4.2-11ts_uclibc-nptl-0.9.29-20070423_20090508
    export UCLINUX_DIR=${HOME}/src/125hw/2618-7.1/
    export GALIO_DIR=${HOME}/src/125hw/ant_galio_3.1.7-gwi-wx-cjka
    export APPLIBS_DIR=${HOME}/src/125hw/applibs_release_20110311

    ### Add mipsel-linux-gcc path
    add_toolchain_path $TOOLCHAINS_DIR/bin


    ### setup following variables for help message
    refsw_dir=${HOME}/src/125hw/refsw-20110228.97405-r8.0
    host_ip=10.10.10.25
    
    ### set default option 
    opt_vendor="gtd"
    opt_kernel="gtd"
    opt_brutus="brutus verimatrix mp3_full nowlan c99 cg3210 dlna"
    opt_galio="verimatrix mp3_full nowlan c99 cg3210"
    opt_applibs="verimatrix mp3_full nowlan c99 cg3210 dlna"
    opt_install=""
    ##########   Edit your personal directory end #########################

	if [ "$#" == 0 ] ; then
        model_name=XTV125hw
        extra_feature=
    else
        model_name=$1
        extra_feature="$2 $3 $4 $5 $6 $7 $8 $9"
	fi
    image_name=$model_name.img

    cd $refsw_dir
    /bin/echo "*******************************************************"
    /bin/echo "$TITLE"
    /bin/echo "*******************************************************"
    /bin/echo "export UCLINUX_DIR=${UCLINUX_DIR}"
    /bin/echo "export GALIO_DIR=${GALIO_DIR}"
    /bin/echo "export TOOLCHAINS_DIR=${TOOLCHAINS_DIR}"
    /bin/echo "refsw_dir=${refsw_dir}"
    /bin/echo ""
    /bin/echo -ne "\33[31;1mkernel:  \33[0m  \n"
    /bin/echo "build.bash $model_name kernel $opt_kernel"
    /bin/echo "build.bash $model_name kernel $opt_kernel rootfs image"
    /bin/echo -ne "\33[31;1mbrutus:  \33[0m  \n"
    /bin/echo "build.bash $model_name $opt_brutus $opt_vendor $extra_feature"
    /bin/echo -ne "\33[31;1mapplibs:  \33[0m  \n"
    /bin/echo "build.bash $model_name applibs  $opt_applibs $opt_vendor $extra_feature qtwebkit"
    /bin/echo "build.bash $model_name applibs  $opt_applibs $opt_vendor $extra_feature qtwebkit-install"
    /bin/echo -ne "\33[31;1mimage:  \33[0m  \n"
    /bin/echo "build.bash $model_name $opt_brutus $opt_vendor $extra_feature install-applibs $opt_install"
    /bin/echo -ne "\33[33;1mimage is '$image_name' and saved at $refsw_dir/BSEAV/bin \33[0m  \n"

    /bin/echo ""
    /bin/echo -ne "\33[31;1mupgrade:  \33[0m  \n"
    /bin/echo "At CFE:"
    /bin/echo "1. ifconfig eth0 -auto"
    /bin/echo "2. flash -noheader $host_ip:$image_name flash0.kernel"
    /bin/echo -ne "3. setenv -p STARTUP \"boot -z -tag -elf flash0.kernel: 'root=/dev/mtdblock0  ro mem=96M rootfstype=cramfs'\" \n"
    /bin/echo ""
    /bin/echo "At kernel:"
    /bin/echo "Usage:   upgrade [upgrade_url] [reboot]"
    /bin/echo "Example: upgrade ftp://$host_ip/$image_name 1"
}
               
cenv_print_usage_Applibs_7231()
{
   
    /bin/echo "*******************************************************"
    /bin/echo "$TITLE"
    /bin/echo "*******************************************************"
    /bin/echo "export UCLINUX_DIR=${UCLINUX_DIR}"
    /bin/echo "export STBLINUX_VER=${STBLINUX_VER}"
    /bin/echo "export TOOLCHAINS_DIR=${TOOLCHAINS_DIR}"
    /bin/echo "export APPLIBS_DIR=${APPLIBS_DIR}"
    /bin/echo "refsw_dir=${refsw_dir}"
    /bin/echo ""
    /bin/echo -ne "\33[31;1mkernel:  \33[0m  \n"
    /bin/echo "build.bash $model_name kernel $opt_kernel image"
    
    /bin/echo -ne "\33[31;1mbrutus:  \33[0m  \n"
    /bin/echo "build.bash $model_name $opt_brutus $opt_vendor $extra_feature"
    
    /bin/echo -ne "\33[31;1mapplibs:  \33[0m  \n"
    /bin/echo "build.bash $model_name applibs  $opt_applibs $opt_vendor $extra_feature lattice"
    /bin/echo "build.bash $model_name applibs  $opt_applibs $opt_vendor $extra_feature lattice-install"
    
    /bin/echo -ne "\33[31;1mimage:  \33[0m  \n"
    /bin/echo "build.bash $model_name $opt_brutus $opt_vendor $extra_feature install $opt_install"
    /bin/echo -ne "\33[33;1mimage is '$image_name' and saved at $refsw_dir/BSEAV/bin \33[0m  \n"

    /bin/echo ""
    /bin/echo -ne "\33[31;1mupgrade:  \33[0m  \n"
    /bin/echo "At CFE:"
    /bin/echo "1. ifconfig eth0 -auto"
    /bin/echo "2. flash -noheader $host_ip:$image_name flash0.kernel"
    /bin/echo -ne "3. setenv -p STARTUP \"boot -tag -mbu -brutus -z -elf flash0.image: 'root=/dev/mtdblock0 rw bmem=100M@156M bmem=220M@512M bmem=96M@768M rootfstype=squashfs'\" \n"
    /bin/echo ""
    /bin/echo "At kernel:"
    /bin/echo "Usage:   upgrade [upgrade_url] [reboot]"
    /bin/echo "Example: upgrade ftp://$host_ip/$image_name 1"
}

c131a22() # Compiling option for XTV131 w/ Applibs 2.2, copied from c131
{
    #########
    ## History
    ##  2010/5/26:  Copied from c7405. add opt_install
    ##  2011/10/12: Update for leopard
    ##  2011/11/01: Derived from cgtd to c125hw
    ##  2012/2/21:  Derived from c125hw to c131
    ##  2012/3/26:  Remove unnecessary 'rootfs' option in kernel option
    ##  2012/3/28:  Copied from c131, used for applibs 2.2
    ##  2012/3/28:  Remove 'mp3_full' option
    ##  2012/3/28:  Correct options
    ##  2012/7/30:  1) Call cenv_print_usage_Applibs_7231() to simplify script, 2) Update STARTUP
    ##  2012/8/1:   Use add_toolchain_path to add MIPS toolchain
    ##  2012/9/17:  unset GALIO_DIR: to avoid errors when previously running 7405 compililng
    ##
    ##########   Edit your personal data begin ############################
    ### export environment variables for compiler use
    export TITLE="Compiling environment for refsw-20111201.97231-r30 (7231 R3.0 ) for *XTV131 w/ applibs 2.2* "

    export TOOLCHAINS_DIR=/opt/toolchains/stbgcc-4.5.3-1.3
    export UCLINUX_DIR=${HOME}/src/131a22/2637-2.5/
    export STBLINUX_VER=2.6.37
    export APPLIBS_DIR=${HOME}/src/131a22/refsw-20111201.97231-r30
    unset  GALIO_DIR

    ### Add mipsel-linux-gcc path
    add_toolchain_path $TOOLCHAINS_DIR/bin

    ### setup following variables for help message
    refsw_dir=${HOME}/src/131a22/refsw-20111201.97231-r30
    host_ip=10.10.10.25
    
    ### set default option 
    opt_vendor=""
    opt_kernel=""
    opt_brutus="brutus noipv6 c99 novc1 noDNOT262A"
    opt_applibs="-j4 noipv6 c99 novc1"
    opt_install=""
    ##########   Edit your personal directory end #########################

	if [ "$#" == 0 ] ; then
        model_name=XTV131
        extra_feature=
    else
        model_name=$1
        extra_feature="$2 $3 $4 $5 $6 $7 $8 $9"
	fi
    image_name=$model_name.img

    cd $refsw_dir
    cenv_print_usage_Applibs_7231
}
    
common_reset_option()
{
    ### Reset option 
    opt_vendor=""
    opt_kernel=""
    opt_brutus=""
    opt_applibs=""
    opt_install=""

    export TITLE=""
    export UCLINUX_DIR=""
    export STBLINUX_VER=""
    export TOOLCHAINS_DIR=""
    export APPLIBS_DIR=""
}

common_u132() 
{
    #########
    ## History
    ##  2010/5/26:  Copied from c7405. add opt_install
    ##  2011/10/12: Update for leopard
    ##  2011/11/01: Derived from cgtd to c125hw
    ##  2012/2/21:  Derived from c125hw to c131
    ##  2012/3/26:  Remove unnecessary 'rootfs' option in kernel option
    ##  2012/3/28:  Copied from c131, used for applibs 2.2
    ##  2012/3/28:  Remove 'mp3_full' option
    ##  2012/3/28:  Correct options
    ##  2012/7/30:  1) Call cenv_print_usage_Applibs_7231() to simplify script, 2) Update STARTUP
    ##  2012/8/1:   Use add_toolchain_path to add MIPS toolchain
    ##  2012/9/17:  unset GALIO_DIR: to avoid errors when previously running 7405 compililng
    #######################################################################################
    ## c131u131:
    ##  2013/7/29:  copied from c131a22
    ## c131u132:
    ##  2013/9/4:   copied from c131u131
    ## common_u132:
    ##  2013/11/14: copied from c131u132, used as a common script for c*u132
    ##  2014/5/19: Fix the error: "-bash: [: too many arguments" 
    ##########   Edit your personal data begin ############################
    ### export environment variables for compiler use
    ## Jackie: TITLE has spaces in it, needs a special treatment by 'eval'
    eval set_if_empty TITLE `echo -e "\"Compiling environment for refsw-20130612.unified-13.2 (unified 13.2 ) for *${default_model}* \""`

    set_if_empty TOOLCHAINS_DIR /opt/toolchains/stbgcc-4.5.3-2.4
    set_if_empty UCLINUX_DIR `readlink -f ${refsw_dir}/../3.3-2.5/`
    set_if_empty STBLINUX_VER 3.3-2.5
    if [ -z $no_applibs ]; then 
        export APPLIBS_DIR=${refsw_dir}
    else
        unset APPLIBS_DIR
    fi        
    unset  GALIO_DIR

    ### Add mipsel-linux-gcc path
    add_toolchain_path $TOOLCHAINS_DIR/bin

    ### setup following variables for help message
    ## get refsw_dir from upper function
    #refsw_dir=
    host_ip=10.10.10.25
    
    ### set default option -- if not set earlier
    if [ -z "$opt_vendor" ]; then 
        opt_vendor=""
    fi        
    if [ -z "$opt_kernel" ]; then 
        opt_kernel=""
    fi        
    if [ -z "$opt_brutus" ]; then 
        opt_brutus="brutus noipv6 c99 novc1 noDNOT262A"
    fi        
    if [ -z "$opt_applibs" ]; then 
        opt_applibs="-j4"
    fi        
    if [ -z "$opt_install" ]; then 
        opt_install=""
    fi        
    
    
    ##########   Edit your personal directory end #########################

	if [ "$#" == 0 ] ; then
        model_name=${default_model}
        extra_feature=
    else
        model_name=$1
        extra_feature="$2 $3 $4 $5 $6 $7 $8 $9"
	fi
    image_name=$model_name.img

    cd $refsw_dir
    cenv_print_usage_Applibs_7231
}
    

common_u134() 
{
    #########
    ## History
    ##  2010/5/26:  Copied from c7405. add opt_install
    ##  2011/10/12: Update for leopard
    ##  2011/11/01: Derived from cgtd to c125hw
    ##  2012/2/21:  Derived from c125hw to c131
    ##  2012/3/26:  Remove unnecessary 'rootfs' option in kernel option
    ##  2012/3/28:  Copied from c131, used for applibs 2.2
    ##  2012/3/28:  Remove 'mp3_full' option
    ##  2012/3/28:  Correct options
    ##  2012/7/30:  1) Call cenv_print_usage_Applibs_7231() to simplify script, 2) Update STARTUP
    ##  2012/8/1:   Use add_toolchain_path to add MIPS toolchain
    ##  2012/9/17:  unset GALIO_DIR: to avoid errors when previously running 7405 compililng
    #######################################################################################
    ## c131u131:
    ##  2013/7/29:  copied from c131a22
    ## c131u132:
    ##  2013/9/4:   copied from c131u131
    ## common_u132:
    ##  2013/11/14: copied from c131u132, used as a common script for c*u132
    ## common_u134:
    ##  2014/5/14: copied from common_u132, used as a common script for c*t21 (Trellis 2.1 based on U13.4)
    ##  2014/5/19: Fix the error: "-bash: [: too many arguments" 
    ##########   Edit your personal data begin ############################
    ### export environment variables for compiler use
    ## Jackie: TITLE has spaces in it, needs a special treatment by 'eval'
    eval set_if_empty TITLE `echo -e "\"Compiling environment for refsw-20131218.unified-13.4 (unified 13.4 ) for *${default_model}* \""`

    set_if_empty TOOLCHAINS_DIR /opt/toolchains/stbgcc-4.5.4-2.5
    set_if_empty UCLINUX_DIR `readlink -f ${refsw_dir}/../3.3-3.1/`
    set_if_empty STBLINUX_VER 3.3-3.1
    if [ -z $no_applibs ]; then 
        export APPLIBS_DIR=${refsw_dir}
    else
        unset APPLIBS_DIR
    fi        
    unset  GALIO_DIR

    ### Add mipsel-linux-gcc path
    add_toolchain_path $TOOLCHAINS_DIR/bin

    ### setup following variables for help message
    ## get refsw_dir from upper function
    #refsw_dir=
    host_ip=10.10.10.25
    
    ### set default option -- if not set earlier
    if [ -z "$opt_vendor" ]; then 
        opt_vendor=""
    fi        
    if [ -z "$opt_kernel" ]; then 
        opt_kernel=""
    fi        
    if [ -z "$opt_brutus" ]; then 
        opt_brutus="brutus noipv6 c99 novc1 noDNOT262A"
    fi        
    if [ -z "$opt_applibs" ]; then 
        opt_applibs="-j4"
    fi        
    if [ -z "$opt_install" ]; then 
        opt_install=""
    fi        
    
    
    ##########   Edit your personal directory end #########################

	if [ "$#" == 0 ] ; then
        model_name=${default_model}
        extra_feature=
    else
        model_name=$1
        extra_feature="$2 $3 $4 $5 $6 $7 $8 $9"
	fi
    image_name=$model_name.img

    cd $refsw_dir
    cenv_print_usage_Applibs_7231
}
    
           
c131u132()
{
    common_reset_option
    export refsw_dir=${HOME}/src/131u132/refsw-20130612.unified-13.2
    export default_model=XTV131
    
    common_u132
}

c131u132dbg()
{
    common_reset_option
    export refsw_dir=${HOME}/src/131u132dbg/refsw-20130612.unified-13.2
    export default_model=XTV131
    
    common_u132 XTV131 debug
}
   
c131u132mfg()
{
    common_reset_option
    export refsw_dir=${HOME}/src/131u132mfg/refsw-20130612.unified-13.2
    export default_model=XTV131
    
    opt_kernel="mfg"
    no_applibs=y
    
    common_u132 XTV131 mfg
}
   
## special version to build coffee fixture   
c131coffee()
{
    common_reset_option
    export refsw_dir=${HOME}/src/coffee/refsw-20120503.97231-r45
    export default_model=XTV131
    
    export UCLINUX_DIR=`readlink -f ${refsw_dir}/../2637-2.8/`
    export STBLINUX_VER="2.6.37"
    export TOOLCHAINS_DIR="/opt/toolchains/stbgcc-4.5.3-1.3"

    opt_kernel="mfg"
    opt_brutus="noipv6 c99 novc1 noDNOT262A coffee_burnin"
    no_applibs=y
    
    common_u132 XTV131 mfg
}
   
   
# 2014/5/14
c131t21()
{
    common_reset_option
    export refsw_dir=${HOME}/src/131t21/refsw-20131218.unified-13.4
    export default_model=XTV131
    
    common_u134
}

   
   
c141u132()
{
    common_reset_option
    export refsw_dir=${HOME}/src/141u132/refsw-20130612.unified-13.2
    export default_model=XTV141
    
    common_u132
}

c141u132dbg()
{
    common_reset_option
    export refsw_dir=${HOME}/src/141u132dbg/refsw-20130612.unified-13.2
    export default_model=XTV141
    
    common_u132 XTV141 debug
}

