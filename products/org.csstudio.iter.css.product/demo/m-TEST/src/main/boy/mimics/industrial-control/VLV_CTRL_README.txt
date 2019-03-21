#
# Template to be instantiated
# Macros:
#   COMPONENT    - the valve component prefix
#   TAG          - the valve tag
#   FB-SIM       - FEEDBACK simulation PV
#   TRIP-SIM     - TRIP simulation PV
#   INTLK-SIM    - INTERLOCK simulation PV
#   FOMD-SIM     - FORCE MODE simulation PV
#   LOMD-SIM     - LOCAL MODE simulation PV
#   MAMD-SIM     - MANUAL MODE simulation PV
#   AUMD-SIM     - AUTO MODE simulation PV
#   IOERR-SIM    - IO ERROR simulation PV
#   IOSIM-SIM    - IO SIM simulation PV
#   CO-SIM       - OUTPUT VALUE simulation PV
#
# Usage:
# 
rm /tmp/VLV_CTRL.out
for i in `seq 101 350`;
do
    sed -e 's/$(COMPONENT)/CTRL-SUP-BOY:VC'"$i"'/g' \
    -e 's/$(TAG)/VC'"$i"'/g' \
    -e 's/$(FB-SIM)/CTRL-SUP-BOY:VC-FB-SIM/g' \
    -e 's/$(TRIP-SIM)/CTRL-SUP-BOY:VC-TRIP-SIM/g' \
    -e 's/$(INTLK-SIM)/CTRL-SUP-BOY:VC-INTLK-SIM/g' \
    -e 's/$(FOMD-SIM)/CTRL-SUP-BOY:VC-FOMD-SIM/g' \
    -e 's/$(LOMD-SIM)/CTRL-SUP-BOY:VC-LOMD-SIM/g' \
    -e 's/$(MAMD-SIM)/CTRL-SUP-BOY:VC-MAMD-SIM/g' \
    -e 's/$(AUMD-SIM)/CTRL-SUP-BOY:VC-AUMD-SIM/g' \
    -e 's/$(IOERR-SIM)/CTRL-SUP-BOY:VC-IOERR-SIM/g' \
    -e 's/$(IOSIM-SIM)/CTRL-SUP-BOY:VC-IOSIM-SIM/g' \
    -e 's/$(CO-SIM)/CTRL-SUP-BOY:VC-CO-SIM/g' \
    /tmp/m-TEST/VLV_CTRL.db >> /tmp/VLV_CTRL.out
done
#
