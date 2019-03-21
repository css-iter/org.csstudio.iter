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
iEnd=init

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
        iStart = iEnd + 1
        iEnd = direction + 15
        increment = 1
        direction = close
    else:
        iStart = iEnd - 1
        iEnd = direction - 15
        increment = -1
        direction = open
        
    for iMove in range(int(iStart), int(iEnd)+increment, increment):
        print(str(iMove), str(iStart), str(iEnd), str(increment))
        if iMove == int(iStart):
            # Valve status initialisation
            caput('CTRL-SUP-BOY:VC-FB-SIM', init)
            caput('CTRL-SUP-BOY:VC-TRIP-SIM', 0)
            caput('CTRL-SUP-BOY:VC-INTLK-SIM', 0)
            caput('CTRL-SUP-BOY:VC-FOMD-SIM', 0)
            caput('CTRL-SUP-BOY:VC-LOMD-SIM', 0)
            caput('CTRL-SUP-BOY:VC-MAMD-SIM', 0)
            caput('CTRL-SUP-BOY:VC-AUMD-SIM', 0)
            caput('CTRL-SUP-BOY:VC-IOERR-SIM', 0)
            caput('CTRL-SUP-BOY:VC-IOSIM-SIM', 0)
            caput('CTRL-SUP-BOY:VC-CO-SIM', iEnd)
        else:
            caput('CTRL-SUP-BOY:VC-FB-SIM', iMove)
            extra = [  'CTRL-SUP-BOY:VC-FOMD-SIM'
                     , 'CTRL-SUP-BOY:VC-LOMD-SIM'
                     , 'CTRL-SUP-BOY:VC-MAMD-SIM'
                     , 'CTRL-SUP-BOY:VC-AUMD-SIM'
                     , 'CTRL-SUP-BOY:VC-INTLK-SIM'
                     , 'CTRL-SUP-BOY:VC-TRIP-SIM'
                     , 'CTRL-SUP-BOY:VC-IOSIM-SIM'
                     , 'CTRL-SUP-BOY:VC-IOERR-SIM']
            output = (0 if caget(extra[iMove % len(extra)]) else 1)
            caput(extra[iMove % len(extra)], output)
        sleep(scan)