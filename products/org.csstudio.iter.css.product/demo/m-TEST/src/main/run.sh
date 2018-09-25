#!/bin/bash
#*******************************************************************************
# * Copyright (c) 2010-2018 ITER Organization.
# * All rights reserved. This program and the accompanying materials
# * are made available under the terms of the Eclipse Public License v1.0
# * which accompanies this distribution, and is available at
# * http://www.eclipse.org/legal/epl-v10.html
# ******************************************************************************

function pause {
    echo -e "\n\n\n"
    read -p "$*"
}

function softIoc {
    ######################################################################
    # Run the IOCs
    # If the IOC fails to start:
    #     CAS: Listen error: Address already in use
    #     Thread CAS-TCP (0x177fa20) suspended
    # Just type in the console <CTRL>+C and then use the button Relaunch
    ######################################################################
    
    echo -e "\n\tStart the IOCs...\n"
    
    tab=" --tab"
    options=" --profile='default'"
    
    cmds[1]="bash -c 'softIoc -d ./epics/CTRL-SUPApp/Db/PSH0-CTRL-SUP-CSS.db'"
    titles[1]="PSH0-CTRL-SUP-CSS.db"
    
    cmds[2]="bash -c 'softIoc -d ./epics/CTRL-SUPApp/Db/PSH0-CTRL-SUP-BOY.db'"
    titles[2]="PSH0-CTRL-SUP-BOY.db"
    
    cmds[3]="bash -c 'softIoc -d ./epics/CTRL-SUPApp/Db/PSH0-CTRL-SUP-BEAS.db'"
    titles[3]="PSH0-CTRL-SUP-BEAS.db"
    
    cmds[4]="bash -c 'softIoc -d ./epics/CTRL-SUPApp/Db/PSH0-CTRL-SUP-BEAU.db'"
    titles[4]="PSH0-CTRL-SUP-BEAU.db"
    
    cmds[5]="bash -c 'softIoc -d ./epics/UTIL-S15App/Db/PSH0-UTIL-S15-0000.db'"
    titles[5]="PSH0-UTIL-S15-0000.db"
     
    for i in {1..5}; do
        options+=($tab -t "\"${titles[i]}\"" -e "\"${cmds[i]}\"")
    done
}

function alarm {
    ######################################################################
    # Configure and start the alarm system
    ######################################################################
    
    echo -e "\n\tConfigure and start the alarm system...\n"
    
    tab=" --tab"
    options=" --profile='default'"
    
    cmds[1]="bash -c 'alarm-configtool -root demo -import -file ./beast/CTRL-beast.xml ; alarm-server -root demo'"
    titles[1]="alarm-server -root demo"
    
    cmds[2]="bash -c 'alarm-notifier -root demo'"
    titles[2]="alarm-notifier -root demo"
    
    cmds[3]="bash -c 'alarm-configtool -root UTIL -import -file ./beast/UTIL-beast.xml ; alarm-server -root UTIL'"
    titles[3]="alarm-server -root UTIL"
    
    cmds[4]="bash -c 'jms2rdb -pluginCustomization ./beast/jms.ini'"
    titles[4]="jms2rdb topic demo"
    
    for i in {1..4}; do
        options+=($tab -t "\"${titles[i]}\"" -e "\"${cmds[i]}\"")
    done
}

function archive {
    ######################################################################
    # Configure and start the archive system
    ######################################################################
    
    echo -e "\n\tConfigure and start the archive system...\n"
    
    tab=" --tab"
    options=" --profile='default'"
    
    cmds[1]="bash -c 'archive-configtool -engine demo -port 5812 -import -config ./beauty/CTRL-beauty.xml -replace_engine; archive-engine -engine demo -port 5812'"
    titles[1]="archive-engine -engine demo -port 5812"
    
    for i in {1..1}; do
        options+=($tab -t "\"${titles[i]}\"" -e "\"${cmds[i]}\"")
    done
}

function css {
    ######################################################################
    # Configure and start cs-studio
    ######################################################################
    
    echo -e "\n\tConfigure and start cs-studio...\n"
    
    tab=" --tab"
    options=" --profile='default'"
    
    cmds[1]="bash -c 'cp ./demo_beast.xml /tmp/demo_beast.xml; sudo cp /tmp/demo_beast.xml /opt/codac/css/css/configuration/diirt/datasources/beast/beast.xml; sudo boy-switch-resolution 4k; rm -rf ~/CSS-Workspaces/Default; css -data ~/CSS-Workspaces/Default'"
    titles[1]="Start cs-studio"
    
    for i in {1..1}; do
        options+=($tab -t "\"${titles[i]}\"" -e "\"${cmds[i]}\"")
    done
}

date

pause 'Press [Enter] key to continue. This will delete previous ~/CSS-Workspaces/Default workspace...'

rm -Rf ~/.css

softIoc

alarm

archive

css

CMD="gnome-terminal "${options[@]}""
echo -e "$CMD"
eval "$CMD"

pause 'Press [Enter] key when finished...'
date

echo -e '\n\n\n\tLooking for SEVERE messages\n\n'
grep -r 'SEVERE' /var/opt/codac/css/
grep -r 'SEVERE' ~/.css/

exit 0
