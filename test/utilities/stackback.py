#!/usr/bin/env python2.7


import os,platform,sys,re
import argparse,tempfile
from subprocess import Popen, PIPE



class Engine:
    def __init__(self):
        pass

    def findPIDs(self):
        p = Popen(["ps", "axo", "pid,comm"], stdout=PIPE)
        res = p.communicate()[0].split('\n')
        sst_pids = []
        for line in res:
            if line.endswith(("sst", "sstsim.x")):
                info = line.split()
                sst_pids.append(info[0])
        if not len(sst_pids):
            print "Unable to find any sst / sstsim.x processes"
        return sst_pids

    def findChildPIDs(self, pid):
        p = Popen(["ps", "axo", "ppid,pid"], stdout=PIPE)
        res = p.communicate()[0].split('\n')
        sst_pids = []
        for line in res:
            info = line.split()
            if info and info[0] == str(pid):
                sst_pids.append(info[1])
        if not len(sst_pids):
            print "Unable to find any children of mpirun process", pid
        return sst_pids

    def getCombinedStacks(self, pids):
        comb = dict()
        for pid in pids:
            stacks = self.getStackTrace(pid)
            if stacks:
                self._combineStacks(pid, stacks, comb)
            else:
                print "Failed to parse any stacks for pid", pid
        return comb




    def getStackTrace(self, pid):
        pass


    def _combineStacks(self, pid, stacks, res):
        for stack in stacks:
            self._combineStack("%s.%s"%(pid, stack['tid']), self._trimBelowFrame('start_simulation', stack), res)
        return res
    
    def _combineStack(self, name, frames, into):
        for frame in reversed(frames):
            if frame not in into:
                into[frame] = dict()
            into = into[frame]
        if 'sites' not in into:
            into['sites'] = []
        into['sites'].append(name)

    def _trimBelowFrame(self, funcName, stack):
        newFrames = []
        for frame in stack['frames']:
            newFrames.append(frame)
            if frame[1].startswith(funcName):
                break;
    
        return newFrames


class LLDBEngine(Engine):
    def __init__(self):
        Engine.__init__(self)
        self.threadRE = re.compile('^(?:\(lldb\))?[ \*]+thread #(\d+): tid =.*')
        self.frameRE = re.compile('^[ \*]+frame #(\d+): 0x[0-9a-zA-Z]+ ([^`]+)`([^[+]+)(?:\+ \d+|\[inlined\][^\)]+)(?: at (.*))?')

    def _lldb(self, pid):
        p = Popen(["lldb", "-p", str(pid)], stdout=PIPE, stdin=PIPE)
        res = p.communicate("""
bt all
exit
""")[0]
        return res.split('\n');


    def _cleanFuncName(self, func):
        pidx = func.find('(')
        if pidx > 0:
            return func[0:pidx] + '()'
        return func


    def _parse(self, output):
        stacks = dict()
        currThread = None
        for line in output:
            res = self.threadRE.match(line)
            if res:
                tid = res.group(1)
                if tid not in stacks:
                    stacks[tid] = {'tid': tid, 'nframes': 0, 'frames': []} 
                currThread = stacks[tid]
            else:
                res = self.frameRE.match(line)
                if res:
                    currThread['nframes'] += 1
                    lib = res.group(2)
                    func = self._cleanFuncName(res.group(3))
                    loc = res.group(4)
                    currThread['frames'].append((lib, func, loc))
        return stacks.values()

    def getStackTrace(self, pid):
        return self._parse(self._lldb(pid))



class GDBEngine(Engine):
    def __init__(self):
        Engine.__init__(self)
        self.threadRE = re.compile('^Thread (\d+) \(Thread 0x[0-9a-zA-Z]+ \(LWP \d+\)\):')
        self.frameRE = re.compile('^#(\d+)[ ]+(?:0x[0-9a-zA-Z]+ in )?(.*) (?:at|from) (.*)$')
        self.cmdFile = tempfile.NamedTemporaryFile()
        self.cmdFile.write("set width unlimited\n")
        self.cmdFile.write("thread apply all bt\n")
        self.cmdFile.write("quit\n")
        self.cmdFile.flush()

    def _gdb(self, pid):
        cmd = ["timeout", "-k", "30s", "15s", "gdb", "-q", "-n", "-x", self.cmdFile.name, "-p", str(pid)]
        p = Popen(cmd, stdout=PIPE, stdin=PIPE)
        res = p.communicate()[0]
        return res.split('\n')


    def _cleanFuncName(self, func):
        pidx = func.find(' (')
        if pidx > 0:
            return func[0:pidx] + '()'
        return func
    def _parse(self, output):
        stacks = dict()
        currThread = None
        for line in output:
            res = self.threadRE.match(line)
            if res:
                tid = res.group(1)
                if tid not in stacks:
                    stacks[tid] = {'tid': tid, 'nframes': 0, 'frames': []} 
                currThread = stacks[tid]
            else:
                res = self.frameRE.match(line)
                if res:
                    currThread['nframes'] += 1
                    func = self._cleanFuncName(res.group(2))
                    loc = res.group(3)
                    currThread['frames'].append((func, loc))
        return stacks.values()

    def getStackTrace(self, pid):
        gdbout = self._gdb(pid)
        return self._parse(gdbout)





def printStacks(frames, indent=0):
    for frame in frames:
        if frame == 'sites':
            print 4*indent*' ', frames[frame]
        else:
            print 4*indent*' ', frame
            printStacks(frames[frame], indent+1)




argParser = argparse.ArgumentParser(description='Print SST Stack traces')
argParser.add_argument('pids', type=int, nargs="*", help="Process IDs to trace")
group = argParser.add_mutually_exclusive_group(required=False)
group.add_argument('--all', action="store_true", help="Search for all SST processes")
group.add_argument('--mpi', type=int, metavar='PID', help="Use child processes of mpi pid <PID>") 

if __name__ == "__main__":
    args = argParser.parse_args()

    if "Darwin" == platform.system():
        engine = LLDBEngine()
    elif "Linux" == platform.system():
        engine = GDBEngine()
    else:
        print "No engine specified for platform:", platform.system()
        sys.exit(1)

    if args.all:
        pids = engine.findPIDs()
    elif args.mpi:
        pids = engine.findChildPIDs(args.mpi)
    else:
        pids = args.pids

    if not len(pids):
        print "Must specify PIDs of SST, or specify --all to find SST PIDs"
        print "Use --help for more information"
        sys.exit(1)

    print "Tracing PIDs", pids
    comb = engine.getCombinedStacks(pids)

    printStacks(comb)


