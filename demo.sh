#!/bin/sh -e
project_name=amiq_i2c
run_mode="interactive";
seed=1;
compile="yes"
example_name=ms
test="amiq_i2c_ex_ms_test_basic"
regression="no"
in_reg="no"

SCRIPT_DIR=`dirname $0`
SCRIPT_DIR=`cd ${SCRIPT_DIR}&& pwd`
PROJECT_DIR=`cd ${SCRIPT_DIR}/.. && pwd`
PROJECT_LOCATION=`cd ${PROJECT_DIR}/.. && pwd`

export SPECMAN_PATH=${SPECMAN_PATH}:${PROJECT_DIR}

########################################################################################
################################        METHODS       ##################################
########################################################################################

help() {
    echo "Usage:  demo.sh [-r[un_mode]  { interactive | batch}]"
    echo "                [-t[est] <name>]"
    echo "                [-s[eed] <value>]"
    echo "                [-c[ompile] {yes | no | only}]"
    echo "                [-ex[ample] {ms | multi | vr_ad}]"
	 echo ""
    echo "        demo.sh -reg[ression]"
    echo ""
    echo "        demo.sh -h[elp]"
}

clean() {
	rm -rf work
	mkdir work
}

compile() {

	echo Compiling...
	#building stub file
	specman -c "load  amiq_i2c/examples/${example_name}/e/amiq_i2c_ex_${example_name}_config; write stubs -ncvlog ./specman.v"

	#compile verilog files
	#vlib work
	ncvlog -message ./specman.v
	ncvlog -message `sn_which.sh amiq_i2c/examples/${example_name}/tb/amiq_i2c_ex_${example_name}_tb.v`
	ncelab -message -access +rcw worklib.amiq_i2c_ex_tb worklib.specman worklib.specman_wave

}

run() {

	test_full_path=`sn_which.sh amiq_i2c/examples/${example_name}/tests/${test}.e`
	echo $test_full_path

	if [ -f $test_full_path ]; then
		test_path=amiq_i2c/examples/${example_name}/tests/${test}

		case $run_mode in
			interactive)
				specrun  -p  "load $test_path;load /apps/amiq/dvt/libs/dvt_sn_debug/e/dvt_sn_debug_top.e;test -seed=$seed; " ncsim   worklib.${project_name}_ex_tb:module -covoverwrite -gui
				;;
			batch)
				if [ $in_reg == "yes" ]; then
               ln -s ${BRUN_CHAIN_DIR}/INCA_libs
					ln -s ../../work
				fi
				specrun  -p  "load $test_path;test -seed=$seed" ncsim  worklib.${project_name}_ex_tb:module -covoverwrite -run -exit
				;;
			*)
				echo "ERROR:"
				echo "-r[un_mode] option must be called with \"batch\" or \"interactive\""
				exit 0
		esac
	else
		echo "ERROR:"
		echo "Test name provided in demo.sh call - $test - is an invalid test name!"
		exit 1;
	fi
};

########################################################################################
########################################################################################



########################################################################################
############################        EXTRACT OPTIONS       ##############################
########################################################################################

while [ $# -gt 0 ]; do
   case `echo $1 | tr "[A-Z]" "[a-z]"` in
      -h|-help)
                        help
                        exit 0
                        ;;
      -s|-seed)
                        seed=$2
                        ;;
      -r|-run_mode)
                        run_mode=$2
                        ;;
      -c|-compile)
      					compile=$2
      					;;
      -t|-test)
      					test=$2
      					;;
      -reg|-regression)
      					regression="yes"
						;;
      -in_reg)
      					in_reg="yes"
      					;;
      -ex|-example)
      					example_name=$2
      					;;
    esac
    shift
done

########################################################################################
########################################################################################



########################################################################################
##############################        RUNNING FLOW       ###############################
########################################################################################


case $regression in
	yes)
		vmanager -pre " setup; compute vm_manager.start_session(\"amiq_i2c/examples/vm/amiq_i2c_${example_name}_reg.vsif\", \"\") "
		exit 1
		;;
esac



case $compile in
	yes)
		clean
		cd work
		compile
		;;
	no)
		if [ $in_reg == "no" ]; then
			cd work
		fi
		;;
	only)
		if [ $in_reg == "no" ]; then
			cd work
		fi
		compile
		exit 0
		;;
	*)
		echo "ERROR:"
		echo "-c[ompile] option must be called with \"yes\" or \"no\" or \"only\""
		exit 1
		;;
esac

run

########################################################################################
########################################################################################
