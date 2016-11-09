# Subroutine for Testing
#    The first group are the shunit2 routines that used to be included in every testSuite file.
#
#    The second group are utility routines helpful in testing and printing the test results.
#   

#===============================================================================
# shunit2 Utility Functions
#===============================================================================

#-------------------------------------------------------------------------------
# Function: oneTimeSetUp
# Description:
#   Purpose:
#       If defined, the commands in this function are executed once
#       BEFORE this suite of tests are run. Useful for initialization.
#   Input:
#       none
#-------------------------------------------------------------------------------
oneTimeSetUp() {

    # If directory for SUT outputs does not exist, create it
    if [ ! -d ${SST_TEST_OUTPUTS} ]
    then
        mkdir -p ${SST_TEST_OUTPUTS}
    fi
    scriptStartSeconds=`date +%s`
}

#-------------------------------------------------------------------------------
# Function: oneTimeTearDown
# Description:
#   Purpose:
#       If defined, the commands in this function are executed once
#       AFTER this suite of tests are run. Useful for cleanup.
#   Input:
#       none
#-------------------------------------------------------------------------------
oneTimeTearDown() {


    ### Summary Data on the Testsuite
    WHICH_TEST=`echo $0 | awk -F/ '{ print $NF}'`
    endSeconds=`date +%s`
    elapsedSeconds=$(($endSeconds -$scriptStartSeconds))
    echo "TESTSUITE $WHICH_TEST: Total Suite Wall Clock Time  $elapsedSeconds seconds"

    HOST=`uname -n`
    if [[ $HOST == *sst-test* ]] ; then
       today=`date +%j`
       WHICH_FILE=`echo $WHICH_TEST | awk -F'.' '{print $1}'`
       WHICH_FILE_PATH=~jpvandy/WhichTest/$WHICH_FILE
       if [ ! -e $WHICH_FILE_PATH ] ; then
           touch $WHICH_FILE_PATH
           chmod 777 $WHICH_FILE_PATH
       fi   
       RESULT="$__shunit_testsTotal"
       if [[ "$__shunit_testsFailed" -gt 0 ]] ; then
          RESULT="$RESULT / $__shunit_testsFailed Fail"
       fi
       B_SCEN=`echo $BAMBOO_SCENARIO | sed s/sstmainline_config_//`
       J_PROJ=`echo $JENKINS_PROJECT | sed s/SST__//`

       echo "$today $elapsedSeconds s $B_SCEN $J_PROJ $BUILD_NUMBER $RESULT" >> ~jpvandy/WhichTest/$WHICH_FILE
    fi
}

#-------------------------------------------------------------------------------
# Function: setUp
# Description:
#   Purpose:
#       If defined, the commands in this function are executed BEFORE
#       each test is run. Useful for initialization.
#   Input:
#       none
#-------------------------------------------------------------------------------
# setUp() {
# }

#-------------------------------------------------------------------------------
# Function: tearDown
# Description:
#   Purpose:
#       If defined, the commands in this function are executed AFTER
#       each test is run. Useful for cleanup.
#   Input:
#       none
#-------------------------------------------------------------------------------
# tearDown() {
# }



#===============================================================================
# create subroutine
#===============================================================================
# checkPerCent()
#   I am going to return hundreth of a percent!
# $1 and $2 are values to compare.
#   $1 is reference value, $2 is value to compare

checkPerCent() {

if [ $# != 2 ] 
then
    echo 20000     ## Bad Return Value  i.e. greater than "good"
    return
fi

d=$(($2-$1))
r=$1

sign=" "
if [ $d -lt 0 ]
then
   sign="-"
fi
d=${d#-}
g=$(($d*10000))

pc=$(($g/$r))

echo "${sign}${pc}"
}

# convert to hundreths in ascii
pc100() {
in=$1
sign=" "
if [ $in -lt 0 ]
then
   sign="-"
   in=${in#-}
fi 

w=$(($in/100))
tmp=$(($w*100))
t=$(($in-$tmp))
if [ ${#t} == 2 ]
then
    echo "${sign}${w}.${t}"
else
    echo "${sign}${w}.0${t}"
fi
}

#  Reduce the size of output xml files, if they are very large by removing some of the diff information
#    squashXML()
#
#    copy the difftoxml.pl output xml file removing lines from the error
#    reporting if they exceed 16k bytes for an individual test.
#    One argument, the original xml file.
#
squashXML() {
XMLIN=$1
wc $XMLIN

cat > squash.c << .EOF.
#include <string.h>
#include <stdio.h>

int main( int argc, char *argv[] )
{
FILE *xml_in, *xml_out;
enum { FAILURE, SKIP, ALL_ELSE};
int mode;
int len, rec_len;
char buffer[4096];
unsigned long *wd, *ewd, *b;
char delMessage[]="    . . .    (many?) lines deleted here     . . .    \n";
int lenDM;

    lenDM =  strlen( delMessage );
    wd = (unsigned long*)"    <failure message";
    ewd = (unsigned long*)"]]></failure>";
    b = (unsigned long*)buffer;
    xml_in = fopen( argv[1], "r" );
    if ( xml_in == NULL ) {
        fprintf(stderr, "failed to located xml file to process, %s\n", argv[1] );
        return 1;
    }

    xml_out = fopen( "temporary.xml", "w" );

    mode = ALL_ELSE;
    while ( (fgets( buffer, 4097, xml_in )) > 0 ) {
        len = strlen(buffer);
        if ( ALL_ELSE == mode ) {
//                                                        BETWEEN DIFFS
            fwrite( buffer, 1, len, xml_out );   //   Should check write
            if ( (wd[0] == b[0]) && (wd[1] == b[1]) ) {
                mode = FAILURE;                         // FOUND ONE
                rec_len = len;
            }
        } else {
//                                                      PROCESSING DIFF
            if ( (rec_len += len) < 0x4001 ) {          // This needs to throw a switch
//                                                             KEEP IT
                fwrite( buffer, 1, len, xml_out );   //   Should check write
                if ( b[0] == ewd[0] ) {
//                                                     //  FOUND THE END OF DIFF
                    mode = ALL_ELSE;
                }
            } else {
//                                                       SKIPPING
                if ( b[0] == ewd[0] ) {
                    fwrite( delMessage, 1, lenDM, xml_out );   //   Should check write
                    fwrite( buffer, 1, len, xml_out );   //   Should check write
                    mode = ALL_ELSE;
                }
            }
        }

    }
    return 0;
}
.EOF.
gcc -o squasher squash.c

./squasher $XMLIN

wc temporary.xml
rm $XMLIN
mv temporary.xml $XMLIN
echo "OUTPUT xml file Reducer has been invoked"
}

###############################################################
# 
#      MyWC -- word count without printing full path name.
#
###############################################################

myWC() {
     wc $*  | awk -F/ '{print $1, $(NF-1) "/" $NF}' | grep -v total
     echo ' '
}

SSTTESTTEMPFILES=${SST_TEST_ROOT}/testTempFiles
preFail() {

cat > $SSTTESTTEMPFILES/prefail.in << .EOF.
test_${L_SUITENAME}_Prefail() {
if [ "$2" != "skip" ] ; then
    fail "$1"
else
    echo "$1" ; echo ' '
    skip_this_test
fi
}
.EOF.

export SHUNIT_OUTPUTDIR=$SST_TEST_RESULTS

cd $SST_ROOT
(. ${SHUNIT2_SRC}/shunit2 $SSTTESTTEMPFILES/prefail.in)
echo ' ' ; echo "Returned from shunit2" ; echo ' '
rm $SSTTESTTEMPFILES/prefail.in
exit
}

#   -----------------------------------------------
#    
#    sort two input files and then compare sorted files
#    exit code is 0 if sorted files match, else 1
#       (if don't match write the wc to stdout.)
#   -----------------------------------------------
compare_sorted() {
   xo=${SSTTESTTEMPFILES}/xo
   xr=${SSTTESTTEMPFILES}/xr
   sort -o $xo $1
   sort -o $xr $2
   diff -b $xo $xr > ${SSTTESTTEMPFILES}/diff_sorted
   if [ $? == 0 ] ; then
      rm $xo $xr
      return 0
   fi
   wc ${SSTTESTTEMPFILES}/diff_sorted
   return 1
}

#  -------------------------------------------------
#        Remove a particular Warning message from stdout
#        noting that it has been done.
#  -------------------------------------------------
RemoveComponentWarning() {
   
   grep 'WARNING: No components are' $outFile > /dev/null
   if [ $? == 0 ] ; then
      echo "##############################################"
      echo "#"
      echo "#   ${testDataFileBase}: Removing lines "
      grep 'WARNING: No components are' $outFile | awk '{ print "#     " $0}'
      echo "#"
      echo "##############################################"
      sed -i.x '/WARNING: No components are/d' $outFile
      rm -f ${outFile}.x
   fi
   
   grep 'Event queue empty' $outFile > /dev/null
   if [ $? == 0 ] ; then
      echo "##############################################"
      echo "#"
      echo "#   ${testDataFileBase}: Removing lines "
      grep 'Event queue empty' $outFile | awk '{ print "#     " $0}'
      echo "#"
      echo "##############################################"
      sed -i.x '/Event queue empty/d' $outFile
      rm -f ${outFile}.x
   fi
}
# ----------------------------------------------------
#    Do the check on Valgrind on a test
# ----------------------------------------------------
checkValgrindOutput() {
VGout=$1        #the Valgrind output file
grep ERROR.SUMMARY $VGout  > /dev/null
if [ $? != 0 ] ; then 
    echo "Valgrind Summary not found"
    fail " No Valgrind Summary"
    wc $VGout
    return
fi
#Add for qsim
    date
    ls -l $VGout
###  ------
    grep ERROR.SUMMARY $VGout | sed s/ERROR//
contextNumber=`grep ERROR.SUMMARY $VGout | awk '{print $7}'`
if [ $contextNumber -gt 0 ] ; then
    sed -n '/ Invalid.read.of.size.4/{N;p;q}' $VGout  | grep opal_os_dirpath_create > /dev/null
    if [ $? == 0 ] ;then
        contextNumber=$(($contextNumber-1))
        echo "Ignoring MPI \"Invalid read of size 4\""
    fi
fi
if [ $contextNumber -gt 0 ] ; then
    echo ' '
    echo "Valgrind found $contextNumber issues"
    fail " $testDataFileBase: Valgind found $contextNumber issues"
    echo ' '
else
    echo ' '
    echo "     $testDataFileBase:  Valgrind found NO issues      "
    echo ' '
fi

}

