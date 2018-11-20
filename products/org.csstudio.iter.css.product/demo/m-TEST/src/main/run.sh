#!/bin/bash
#*******************************************************************************
# * Copyright (c) 2010-2018 ITER Organization.
# * All rights reserved. This program and the accompanying materials
# * are made available under the terms of the Eclipse Public License v1.0
# * which accompanies this distribution, and is available at
# * http://www.eclipse.org/legal/epl-v10.html
# ******************************************************************************

PGSQL="/var/lib/pgsql/10"

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
    
    cmds[6]="bash -c 'softIoc -d ./epics/BUILApp/Db/PSH0-BUIL.db'"
    titles[6]="PSH0-BUIL.db"
     
    for i in {1..6}; do
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
    
    cmds[3]="bash -c 'alarm-annunciator'"
    titles[3]="alarm-annunciator"
    
    cmds[4]="bash -c 'alarm-configtool -root UTIL -import -file ./beast/UTIL-beast.xml ; alarm-server -root UTIL'"
    titles[4]="alarm-server -root UTIL"
    
    cmds[5]="bash -c 'alarm-configtool -root BUIL -import -file ./beast/BUIL-beast.xml ; alarm-server -root BUIL'"
    titles[5]="alarm-server -root BUIL"
    
    cmds[6]="bash -c 'alarm-notifier -root BUIL'"
    titles[6]="alarm-notifier -root BUIL"
    
    cmds[7]="bash -c 'jms2rdb -pluginCustomization ./beast/jms.ini'"
    titles[7]="jms2rdb topic demo"
    
    for i in {1..7}; do
        options+=($tab -t "\"${titles[i]}\"" -e "\"${cmds[i]}\"")
    done
}

function archive {
    ######################################################################
    # Configure and start the archive system
    ######################################################################
    
    echo -e "\n\tConfigure and start the archive system...\n"

    echo -e '\n\tArchive demo CBS tables and tablespaces creation (requires root and postgres privileges)\n'
    PGPASSWORD=""
    if [ ! $PGPASSWORD ] ; then
        read -s -p "Enter Password for RDB user postgres: " password
        export PGPASSWORD="$password"
    fi;

    psql -v ON_ERROR_STOP=1 -U postgres -d css_archive_3_0_0 -h localhost -c "DROP TABLE IF EXISTS sample_demo CASCADE"
    psql -v ON_ERROR_STOP=1 -U postgres -d css_archive_3_0_0 -h localhost -c "DROP TABLE IF EXISTS sample_demo_month_raw CASCADE"
    psql -v ON_ERROR_STOP=1 -U postgres -d css_archive_3_0_0 -h localhost -c "DROP TABLE IF EXISTS sample_demo_year_raw CASCADE"
    for tablespace in short_term_store medium_term_store long_term_store raw_store; do
        if sudo test -d "$PGSQL"/data_demo_"$tablespace"; then
            psql -v ON_ERROR_STOP=1 -U postgres -d css_archive_3_0_0 -h localhost -c "DROP TABLESPACE IF EXISTS sample_demo_$tablespace"
            sudo rm -rf $PGSQL/data_demo_$tablespace
        fi

        sudo mkdir -pv $PGSQL/data_demo_$tablespace
        sudo chown postgres:postgres $PGSQL/data_demo_$tablespace
        psql -v ON_ERROR_STOP=1 -U postgres -d css_archive_3_0_0 -h localhost -c "CREATE TABLESPACE sample_demo_$tablespace LOCATION '$PGSQL/data_demo_$tablespace'"
    done
    
    sed 's/%cbs%/demo/g' /opt/codac/css/rdb/ARCHIVE_POSTGRES_SAMPLE_CBS_TABLES.sql > /tmp/sample_cbs_tables.sql
    sudo /opt/codac/bin/initdb database css_archive_3_0_0 --file /tmp/sample_cbs_tables.sql
    sudo /opt/codac/bin/initdb user "codac-dev" --create-or-update --password "md5d8db27cd68331cb86718b0bbd60179b4" --priv-all css_archive_3_0_0
    sudo /opt/codac/bin/initdb user "archive" --create-or-update --password "md580ca812fc55d59c8b3c7bb624f24f6cd" --priv-all css_archive_3_0_0
    sudo /opt/codac/bin/initdb user "archive_ro" --create-or-update --password "md5a70d8b53af6dba0fba197e905d84bfcc" --priv-ro css_archive_3_0_0
    
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
    
    cmds[1]="bash -c 'sudo boy-switch-resolution 4k; rm -rf ~/CSS-Workspaces/Default; caput -a CTRL-SUP-BOY:SETPOINT 8 1 1 1 1 1 1 1 1; css -data ~/CSS-Workspaces/Default'"
    titles[1]="Start cs-studio"
    
    for i in {1..1}; do
        options+=($tab -t "\"${titles[i]}\"" -e "\"${cmds[i]}\"")
    done
}

date

codac-version -f

pause 'Press [Enter] key to continue. This will delete previous ~/CSS-Workspaces/Default workspace and reinitialise all databases...'

# Delete .css metadata and log files
rm -Rf ~/.css

# Initialise all databases - requires rdb user password
css-dbmanager -init all

# Start all IOCs
softIoc

# Set CBS1 = demo
codac-configure codac_cbs demo

# Start the alarm services
alarm

# Start the archive services
archive

# Start cs-studio GUI
css

CMD="gnome-terminal "${options[@]}""
echo -e "$CMD"
eval "$CMD"

pause 'Press [Enter] key when finished - databases content will be saved...'
date

echo -e '\n\n\n\tLooking for SEVERE messages\n\n'
grep -r 'SEVERE' /var/opt/codac/css/
grep -r 'SEVERE' ~/.css/

# Save all databases content
css-dbmanager -save all

# Restore default CODAC CBS1
codac-configure codac_cbs CODAC

exit 0
