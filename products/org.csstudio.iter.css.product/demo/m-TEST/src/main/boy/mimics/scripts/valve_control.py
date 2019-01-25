from epics import caget, caput, camonitor
from time import sleep

# Settings for the performance test
# open: OPEN THRESHOLD - 75%
# close: CLOSE THRESHOLD - 25%
open = caget('CTRL-SUP-BOY:VC101-COH.VAL')
close = caget('CTRL-SUP-BOY:VC101-COL.VAL')
start = caget('CTRL-SUP-BOY:PERF-SRT.VAL')

init = 40
direction = int(open)
firstValve = 101
lastValve = 350

# scan: scan rate for the valve position
scan = caget('CTRL-SUP-BOY:PERF-SCAN.VAL')
maxLoop = int(caget('CTRL-SUP-BOY:PERF-LOOP.VAL'))

# define a callback function on 'pvname' and 'value'
def onChanges(pvname=None, value=None, **kw):
    scan = caget('CTRL-SUP-BOY:PERF-SCAN.VAL')
    print pvname, str(value), repr(kw)

camonitor('CTRL-SUP-BOY:PERF-SCAN.VAL', callback=onChanges)

for iLoop in range(0, maxLoop):

    if direction == int(open):
        iStart = init + 1
        iEnd = direction + 15
        increment = 1
        direction = close
    else:
        iStart = init - 1
        iEnd = direction - 15
        increment = -1
        direction = open
        
    for iMove in range(int(iStart), int(iEnd)+increment, increment):
        print(str(iMove), str(iStart), str(iEnd), str(increment))
        for iValve in range(firstValve, lastValve+1):
            if iMove == int(iStart):
                # Valve status initialisation
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-FB', init)
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-TRIP', 0)
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-INTLK', 0)
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-FOMD', 0)
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-LOMD', 0)
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-MAMD', 0)
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-AUMD', 0)
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-IOERR', 0)
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-IOSIM', 0)
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-CO', iEnd)
            else:
                caput('CTRL-SUP-BOY:VC'+ str(iValve) + '-FB', iMove)
                extra = [  'CTRL-SUP-BOY:VC'+ str(iValve) + '-FOMD'
                         , 'CTRL-SUP-BOY:VC'+ str(iValve) + '-LOMD'
                         , 'CTRL-SUP-BOY:VC'+ str(iValve) + '-MAMD'
                         , 'CTRL-SUP-BOY:VC'+ str(iValve) + '-AUMD'
                         , 'CTRL-SUP-BOY:VC'+ str(iValve) + '-INTLK'
                         , 'CTRL-SUP-BOY:VC'+ str(iValve) + '-TRIP'
                         , 'CTRL-SUP-BOY:VC'+ str(iValve) + '-IOSIM'
                         , 'CTRL-SUP-BOY:VC'+ str(iValve) + '-IOERR']
                output = (0 if caget(extra[iMove % len(extra)]) else 1)
                caput(extra[iMove % len(extra)], output)
        sleep(scan)