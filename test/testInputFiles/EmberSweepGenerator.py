#
#      This file is adapted from Tester.py in sst/elements/prospero/test.
#      It wraps the output line with a bash subroutine to be sourced
#           and used with shunit2
#
import sys,os
from subprocess import call
import CrossProduct
from CrossProduct import *
import hashlib
import binascii

config = "emberLoad.py"

tests = []
networks = []

net = { 'topo' : 'torus',
        'args' : [
                    [ '--shape', ['2','4x4x4','8x8x8','16x16x16'] ]
                 ]
      }

networks.append(net);

net = { 'topo' : 'fattree',
        'args' : [
                    ['--shape',   ['9,9:9,9:18']]
                 ]
      }

networks.append(net);

net = { 'topo' : 'dragonfly',
        'args' : [
                    ['--shape',   ['8:8:4:8']]
                 ]
      }

networks.append(net);

test = { 'motif' : 'AllPingPong',
         'args'  : [
                        [ 'iterations'  , ['1','10']],
                        [ 'messageSize' , ['0','1','10000','20000']]
                   ]
        }

tests.append( test )

test = { 'motif' : 'Allreduce',
         'args'  : [
                        [ 'iterations'  , ['1','10']],
                        [ 'count' , ['1']]
                   ]
        }

tests.append( test )

test = { 'motif' : 'Barrier',
         'args'  : [
                        [ 'iterations'  , ['1','10']]
                   ]
        }

tests.append( test )

test = { 'motif' : 'PingPong',
         'args'  : [
                        [ 'iterations'  , ['1','10']],
                        [ 'messageSize' , ['0','1','10000','20000']]
                   ]
        }

tests.append( test )

test = { 'motif' : 'Reduce',
         'args'  : [
                        [ 'iterations'  , ['1','10']],
                        [ 'count' , ['1']]
                   ]
        }

tests.append( test )

test = { 'motif' : 'Ring',
         'args'  : [
                        [ 'iterations'  , ['1','10']],
                        [ 'messagesize' , ['0','1','10000','20000']]
                   ]
        }

tests.append( test )

testi = 0

add_nulls = lambda number, zero_count : "{0:0{1}d}".format(number, zero_count)

for network in networks :
    for test in tests :
        for x in CrossProduct( network['args'] ) :
            for y in CrossProduct( test['args'] ):
                testi = testi + 1
                hash_str = "sst --model-options=\"--topo={0} {1} --cmdLine=\\\"{2} {3}\\\"\" {4}".format(network['topo'], x, test['motif'], y, config)
                hash_object  = hashlib.md5(hash_str.encode("UTF-8"))
                hex_dig = hash_object.hexdigest()
                print("test_EmberSweep_" + add_nulls(testi,3) + "_" + hex_dig + "() {")
#                print("echo \"    \" {0} {1} {2} {3}".format(network['topo'], x, test['motif'], y))
                print("ES_start \" {0} {1} {2} {3}\"".format(network['topo'], x, test['motif'], y))
                print("sst --model-options=\"--topo={0} {1} --cmdLine=\\\"Init\\\" --cmdLine=\\\"{2} {3}\\\" --cmdLine=\\\"Fini\\\"\" {4} > tmp_file".format(network['topo'], x, test['motif'], y, config))
                print("ES_fini " + hex_dig)
                print("popd")
                print("}")
                #call("sst --model-options=\"--topo={0} {1} --cmdLine=\\\"{2} {3}\\\"\" {4}".format(network['topo'], x, test['motif'], y, config), shell=True )
