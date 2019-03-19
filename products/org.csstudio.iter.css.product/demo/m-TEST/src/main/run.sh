#!/bin/bash
#*******************************************************************************
# * Copyright (c) 2010-2019 ITER Organization.
# * All rights reserved. This program and the accompanying materials
# * are made available under the terms of the Eclipse Public License v1.0
# * which accompanies this distribution, and is available at
# * http://www.eclipse.org/legal/epl-v10.html
# ******************************************************************************
#
# This run script can be downloaded with the following command:
# $ svn export https://svnpub.iter.org/codac/iter/codac/dev/units/m-css-iter/trunk/src/main/tycho/org.csstudio.iter/products/org.csstudio.iter.css.product/demo/m-TEST/src/main /tmp --depth files --force
#
# And executed with the following command:
# $ clear; sh /tmp/run.sh
#
trap 'stty echo; error "Command interrupted..."' SIGHUP SIGINT SIGTERM

BOLD='\e[1m'
UNDERLINED='\e[4m'
BLUE='\e[1;34m'
GREEN='\e[0;32m'
RED='\e[1;31m'
NC='\e[0m' # No Color

SCRIPT=$(readlink -f "$0")
SCRIPTNAME=$(basename "${SCRIPT}")
PRODUCT=${SCRIPTNAME%}
VERSION="2.0.0"

# default arguments
PGSQL="/var/lib/pgsql/10"

TABLESPACE=0                        # Will create sample_cbs inheritence and tablespaces

function show_usage {
cat <<EOF
Demo Test Cases script version: $VERSION
show_usage:
    $PRODUCT [-tablespace]

Options:
    -help                           show usage
    -version                        show version
    -tablespace                     will create sample_demo inheritence and tablespaces

Examples:
    sh ./run.sh                     # will start all IOCs, import alarm and archive configuration and run the services
    sh ./run.sh -tablespace         # will create in addition sample_demo inheritence and tablespaces
EOF
}

function pause {
    echo -e "\n\n\n"
    read -p "$*"
}

function svn_co {
    SVN_UNIT="https://svnpub.iter.org/codac/iter/codac/dev/units/m-css-iter/trunk/src/main/tycho/org.csstudio.iter/products/org.csstudio.iter.css.product/demo/m-TEST"
    SVN_EXPORT_DIR="/tmp/m-TEST"

    echo -e "\nSVN Unit: $SVN_UNIT"
    echo -e "SVN Export dir: $SVN_EXPORT_DIR\n"
    rm -rf $SVN_EXPORT_DIR; svn export $SVN_UNIT $SVN_EXPORT_DIR
    
    cd $SVN_EXPORT_DIR/src/main
}

function init {
    pause 'Press [Enter] key to continue. This will reinitialise all databases...'

    # Delete .css metadata and log files
    rm -Rf ~/.css

    # Initialise all databases - requires rdb user codac-dev password
    css-dbmanager -init all

    # Restrict the PV communication
    PORT=$((20000 + RANDOM % 50000))
    export EPICS_CA_REPEATER_PORT=$PORT
    SERVER_PORT=$((20000 + RANDOM % 90000))
    export EPICS_CA_SERVER_PORT=$SERVER_PORT

    DEMO_INI_FILE="/tmp/demo_$PORT.ini"
    echo "# Restrict the PV communication to the local host">$DEMO_INI_FILE
    echo "org.csstudio.diirt.util.core.preferences/diirt.ca.repeater.port=$PORT">>$DEMO_INI_FILE
    echo "org.csstudio.diirt.util.core.preferences/diirt.ca.server.port=$SERVER_PORT">>$DEMO_INI_FILE

    DEMO_LOCK="/tmp/demo_$PORT.lock"
    WORKSPACE_FILE="/tmp/CSS-Workspaces_$PORT" 

    # Set multibeast datasources
    echo -e "\n\tSet multibeast datasoures...\n"
    codac-configure codac_cbs "demo BUIL UTIL"

    # stop CODAC Core System services - only Demo services will run
    css-alarm-server stop
    css-alarm-notifier stop
    css-alarm-annunciator stop
    css-archive-engine stop

    # Start cs-studio GUI
    echo "# OPI settings">>$DEMO_INI_FILE
    echo "org.csstudio.opibuilder/macros=MIMIC_FILE,templates/ITER_Mimic|TITLE, DEMO SUPERVISION|ALARM_ROOT,/ITER">>$DEMO_INI_FILE
    
    echo -e '\n\n'
    echo -e "\tConfiguration file: $DEMO_INI_FILE"
    echo -e "\tWorkspace: $WORKSPACE_FILE"
    echo -e "\tLock file: $DEMO_LOCK"
}

function start {
    # Start all IOCs
    softIoc

    # Start the emo alarm services
    alarm

    # Start the demo archive services
    archive

    # Start cs-studio GUI
    echo "# OPI settings">>$DEMO_INI_FILE
    echo "org.csstudio.opibuilder/macros=MIMIC_FILE,templates/ITER_Mimic|TITLE, DEMO SUPERVISION|ALARM_ROOT,/ITER">>$DEMO_INI_FILE
    css

    CMD="gnome-terminal "${options[@]}""
    echo -e "$CMD"
    eval "$CMD"
}

function stop {
    date

    echo -e '\n\n\n\tLooking for SEVERE messages (1)\n\n'
    grep -r 'SEVERE' /var/opt/codac/css/
    echo -e '\n\n\n\tLooking for SEVERE messages (2)\n\n'
    grep -r 'SEVERE' ~/.css/

    # Save all databases content
    css-dbmanager -save all

    # Restore default CODAC CBS1
    codac-configure codac_cbs

    # Restore FullHD configuration
    sudo boy-switch-resolution full

    # Delete temporary file and workspace
    rm -rf $DEMO_LOCK
    rm -rf $DEMO_INI_FILE
    rm -rf $WORKSPACE_FILE; 
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
    
    cmds[2]="bash -c 'sleep 1; softIoc -d ./epics/CTRL-SUPApp/Db/PSH0-CTRL-SUP-BOY.db'"
    titles[2]="PSH0-CTRL-SUP-BOY.db"
    
    cmds[3]="bash -c 'sleep 2; softIoc -d ./epics/CTRL-SUPApp/Db/PSH0-CTRL-SUP-BEAS.db'"
    titles[3]="PSH0-CTRL-SUP-BEAS.db"
    
    cmds[4]="bash -c 'sleep 3; softIoc -d ./epics/CTRL-SUPApp/Db/PSH0-CTRL-SUP-BEAU.db'"
    titles[4]="PSH0-CTRL-SUP-BEAU.db"
    
    cmds[5]="bash -c 'sleep 4; softIoc -d ./epics/UTIL-S15App/Db/PSH0-UTIL-S15-0000.db'"
    titles[5]="PSH0-UTIL-S15-0000.db"
    
    cmds[6]="bash -c 'sleep 5; softIoc -d ./epics/BUIL-SRVYApp/Db/PSH0-BUIL-SRVY.db'"
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
    
    cmds[1]="bash -c 'flock $DEMO_LOCK alarm-configtool -root demo -import -file ./beast/CTRL-beast.xml ; alarm-server -root demo -pluginCustomization $DEMO_INI_FILE'"
    titles[1]="alarm-server -root demo"
    
    cmds[2]="bash -c 'sleep 1; flock $DEMO_LOCK sleep 1; alarm-notifier -root demo'"
    titles[2]="alarm-notifier -root demo"
       
    cmds[3]="bash -c 'sleep 2; flock $DEMO_LOCK alarm-configtool -root UTIL -import -file ./beast/UTIL-beast.xml ; alarm-server -root UTIL -pluginCustomization $DEMO_INI_FILE'"
    titles[3]="alarm-server -root UTIL"
    
    cmds[4]="bash -c 'sleep 3; flock $DEMO_LOCK alarm-configtool -root BUIL -import -file ./beast/BUIL-beast.xml ; alarm-server -root BUIL -pluginCustomization $DEMO_INI_FILE'"
    titles[4]="alarm-server -root BUIL"
    
    cmds[5]="bash -c 'sleep 4; flock $DEMO_LOCK sleep 1; alarm-notifier -root BUIL'"
    titles[5]="alarm-notifier -root BUIL"
    
    cmds[6]="bash -c 'sleep 5; flock $DEMO_LOCK sleep 1; alarm-annunciator'"
    titles[6]="alarm-annunciator"
    
    for i in {1..6}; do
        options+=($tab -t "\"${titles[i]}\"" -e "\"${cmds[i]}\"")
    done
}

function archive {
    ######################################################################
    # Configure and start the archive system
    ######################################################################
    
    echo -e "\n\tConfigure and start the archive system...\n"

    if [ $TABLESPACE -eq 1 ];
    then
        echo -e '\n\tArchive demo CBS tables and tablespaces creation (requires root and postgres privileges)\n'
        PGPASSWORD=""
        if [ ! $PGPASSWORD ] ; then
            read -s -p "Enter Password for RDB user postgres: " password
            export PGPASSWORD="$password"
        fi;
        
        SCOPE="tcr36"
        CBS="demo"

        psql -v ON_ERROR_STOP=1 -U postgres -d css_archive_3_0_0 -h localhost -c "DROP TABLE IF EXISTS sample_"$CBS" CASCADE"
        psql -v ON_ERROR_STOP=1 -U postgres -d css_archive_3_0_0 -h localhost -c "DROP TABLE IF EXISTS sample_"$CBS"_month_raw CASCADE"
        psql -v ON_ERROR_STOP=1 -U postgres -d css_archive_3_0_0 -h localhost -c "DROP TABLE IF EXISTS sample_"$CBS"_year_raw CASCADE"
        for tablespace in short_term_store medium_term_store long_term_store raw_store; do
            if sudo test -d "$PGSQL"/data_"$SCOPE"_"$CBS"_"$tablespace"; then
                psql -v ON_ERROR_STOP=1 -U postgres -d css_archive_3_0_0 -h localhost -c "DROP TABLESPACE IF EXISTS sample_"$CBS"_"$tablespace""
                sudo rm -rf $PGSQL/data_"$SCOPE"_"$CBS"_"$tablespace"
            fi

            sudo mkdir -pv $PGSQL/data_"$SCOPE"_"$CBS"_"$tablespace"
            sudo chown postgres:postgres $PGSQL/data_"$SCOPE"_"$CBS"_"$tablespace"
        done
        
        sed 's/%pgsql_version%/10/g' /opt/codac/css/rdb/ARCHIVE_POSTGRES_SAMPLE_TABLESPACES.sql > /tmp/sample_psql_version_tablespaces.sql
        sed 's/%cbs%/'$CBS'/g' /tmp/sample_psql_version_tablespaces.sql > /tmp/sample_cbs_tablespaces.sql
        sed 's/%scope%/'$SCOPE'/g' /tmp/sample_cbs_tablespaces.sql > /tmp/sample_scope_cbs_tablespaces.sql
        sudo /opt/codac/bin/initdb database css_archive_3_0_0 --file /tmp/sample_scope_cbs_tablespaces.sql
        
        sed 's/%cbs%/'$CBS'/g' /opt/codac/css/rdb/ARCHIVE_POSTGRES_SAMPLE_CBS_TABLES.sql > /tmp/sample_cbs_tables.sql
        sudo /opt/codac/bin/initdb database css_archive_3_0_0 --file /tmp/sample_cbs_tables.sql
        sudo /opt/codac/bin/initdb user "codac-dev" --create-or-update --password "md5d8db27cd68331cb86718b0bbd60179b4" --priv-all css_archive_3_0_0
        sudo /opt/codac/bin/initdb user "archive" --create-or-update --password "md580ca812fc55d59c8b3c7bb624f24f6cd" --priv-all css_archive_3_0_0
        sudo /opt/codac/bin/initdb user "archive_ro" --create-or-update --password "md5a70d8b53af6dba0fba197e905d84bfcc" --priv-ro css_archive_3_0_0
    fi
    
    tab=" --tab"
    options=" --profile='default'"
    
    cmds[1]="bash -c 'archive-configtool -engine demo -port 5812 -import -config ./beauty/CTRL-beauty.xml -replace_engine; archive-engine -engine demo -port 5812 -pluginCustomization $DEMO_INI_FILE'"
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
    
    cmds[1]="bash -c 'sleep 30; flock $DEMO_LOCK sleep 1; sudo boy-switch-resolution 4k; caput -a CTRL-SUP-BOY:SETPOINT 8 1 1 1 1 1 1 1 1; css -data $WORKSPACE_FILE -pluginCustomization $DEMO_INI_FILE'"
    titles[1]="Start cs-studio"
    
    for i in {1..1}; do
        options+=($tab -t "\"${titles[i]}\"" -e "\"${cmds[i]}\"")
    done
}

# read arguments
while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -help)
            show_usage
            exit 0
            ;;
        -version)
            echo -e "\n\t$PRODUCT script version: $VERSION"
            echo -e ""
            exit 0
            ;;
        -tablespace)
            TABLESPACE=1
            ;;
        *)
            show_usage
            error "Unknown Option \"$1\""
            ;;
    esac
    shift # past argument or value
done 

echo -e "\nScript: $0"
date

codac-version -f

svn_co

init

start

pause 'Press [Enter] key when finished - databases content will be saved...'

stop

exit 0
