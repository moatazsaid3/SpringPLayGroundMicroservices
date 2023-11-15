#!/bin/bash

# Unsets Environment Variables Used Within The Script.
unset_environemnt_variables() {
    unset DATABASE_HOST=localhost
    unset DATABASE_PORT=3306
    unset DATABASE_USERNAME=root
    unset PGPASSWORD=learning
    unset DATABASE_NAME=hello
    unset MODULE_NAME=hello-world
    unset ENTRY_POINT=java -XX:MaxNewSize=64M -Xmx128M -XX:MaxRAM=265m -jar hello-world-service.ja
    unset DATABASE_SCRIPTS_LOCATION=database-scripts
    unset OUTPUT_SCRIPT=scripts.sql
}

# Compare Semantic Version.
# Return 0 If $1 = $2
# Return 1 If $1 > $2
# Return 2 If $1 < $2
compare_versions() {

    # Return 0 If They Are Identical.
    if [[ "$1" == "$2" ]]; then
        echo 0;
        return
    fi
    # Create Local Variables For The Versions.
    local regex="^(.*)-r([0-9]*)$" va1=() vr1=0 va2=() vr2=0 len i IFS="."

    # Split Version Strings Into Arrays And Extract Trailing Revisions.
    if [[ "$1" =~ ${regex} ]]; then
        va1=(${BASH_REMATCH[1]})
        [[ -n "${BASH_REMATCH[2]}" ]] && vr1=${BASH_REMATCH[2]}
    else
        va1=($1)
    fi
    if [[ "$2" =~ ${regex} ]]; then
        va2=(${BASH_REMATCH[1]})
        [[ -n "${BASH_REMATCH[2]}" ]] && vr2=${BASH_REMATCH[2]}
    else
        va2=($2)
    fi

    # Bring Them To The Same Length (The Longest) And Add Tailing Zeros.
    (( ${#va1[@]} > ${#va2[@]} )) && len=${#va1[@]} || len=${#va2[@]}
    for ((i=0; i < len; ++i)); do
        [[ -z "${va1[i]}" ]] && va1[i]="0"
        [[ -z "${va2[i]}" ]] && va2[i]="0"
    done

    # Append Revision And Increment Length.
    va1+=($vr1)
    va2+=($vr2)
    len=$((len+1))

    # Compare Version Elements.
    # Return 1 If $1 > $2
    # Return 2 If $1 < $2
    for ((i=0; i < len; ++i)); do
        if (( 10#${va1[i]} > 10#${va2[i]} )); then
            echo 1
            return
        elif (( 10#${va1[i]} < 10#${va2[i]} )); then
            echo 2
            return
        fi
    done

    # Return 0 If $1 = $2
    echo 0
    return
}

# Check Access To Server By Executing If Database Exists Query.
if DATABASE_EXISTS=$(psql --set ON_ERROR_STOP=1 --host "${DATABASE_HOST}" --port "${DATABASE_PORT}" --username "${DATABASE_USERNAME}" -tAc "SELECT 1 FROM pg_catalog.pg_database WHERE datname='${DATABASE_NAME}'" 2>&1 | cat); then

    # Initialize Latest Deployed Version Variable.
    LATEST_DEPLOYED_VERSION=""
    if [[ "$DATABASE_EXISTS" = "1" ]]; then # Database Already Exists Branch:
        # Get The Latest Deployed Version Of Database.
        if LATEST_DEPLOYED_VERSION_QUERY_RESULT=$(psql --set ON_ERROR_STOP=1 --host "${DATABASE_HOST}" --port "${DATABASE_PORT}" --username "${DATABASE_USERNAME}" --dbname "${DATABASE_NAME}" -tAc "SELECT version FROM public.versions ORDER BY deployment_time DESC LIMIT 1;" 2>&1 | cat); then
            LATEST_DEPLOYED_VERSION=$LATEST_DEPLOYED_VERSION_QUERY_RESULT
        fi
    else # Database Does Not Exist Branch:
        # Try To Create Database.
        if ! psql --set ON_ERROR_STOP=1 --host "${DATABASE_HOST}" --port "${DATABASE_PORT}" --username "${DATABASE_USERNAME}" -c "CREATE DATABASE ${DATABASE_NAME};"; then
            # Database Creation Failed Branch:
            echo -e "\033[31mCreating Database Failed." >/dev/stderr

            exit 1
        fi
    fi

    # Create Aggregated Output Script File.
    rm -f "${OUTPUT_SCRIPT}"
    touch "${OUTPUT_SCRIPT}"

    # Looping Script Files
    for SCRIPT in "${DATABASE_SCRIPTS_LOCATION}"/*.sql;
    do
        # Extract Script Version From File Name Pattern.
        SCRIPT_VERSION=$(echo "$SCRIPT" | sed "s/.*${MODULE_NAME}_v\(.*\).sql.*/\1/")

        # Check If There Is Not A Deployed Version Or Current Script File
        # Version Is Greater Than The Current Deployed Version Branch:
        if [[ "$LATEST_DEPLOYED_VERSION" = "" || $(compare_versions "$SCRIPT_VERSION" "$LATEST_DEPLOYED_VERSION") -eq 1 ]]; then
            # Concatinate The Content Of The Script File To The Aggregated Script File.
            cat "$SCRIPT" >> "${OUTPUT_SCRIPT}"
            # Set The Latest Script Version To The Current Script Version.
            LATEST_SCRIPT_VERSION=$SCRIPT_VERSION
        fi
    done

    if [[ "$LATEST_SCRIPT_VERSION" != "" ]]; then # Check If There Are Some New Scripts To Execute Branch:
        # Append Insert Query Of The The Latest Version To The
        # Aggregated Script That Will Be Executed On The Database.
        echo "INSERT INTO public.versions(version) VALUES ('$LATEST_SCRIPT_VERSION');" >> "${OUTPUT_SCRIPT}"
        # Execute The Aggregated Script On The Database (Single Transaction).
        if psql --set ON_ERROR_STOP=1 --host "${DATABASE_HOST}" --port "${DATABASE_PORT}" --username "${DATABASE_USERNAME}" --dbname "${DATABASE_NAME}" --single-transaction -f "$OUTPUT_SCRIPT" -eq 0; then
            # The Output Script Execution Succeeded Branch:

            echo -e "\033[32mExecuting Database Script Succeeded."

        else # The Output Script Execution Failed Branch:

            # Clear All The Used Environmental Variables.
            unset_environemnt_variables
            echo -e "\033[31mExecuting Database Script Failed." >/dev/stderr

            exit 1
        fi
    fi

    # Set The Entry Point Of The Application To Be Executed
    # After The Database Deployment.
    ENTRY_POINT_EXECUTION=${ENTRY_POINT}
    # Clear All The Used Environmental Variables.
    unset_environemnt_variables
    # Execute The Entry Point Command.
    eval "$ENTRY_POINT_EXECUTION"
    exit 0
else # Database Exists Query Execution Succeeded Failed.
    echo -e "\033[31m$DATABASE_EXISTS" >/dev/stderr

    exit 1
fi 