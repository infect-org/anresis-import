#!/bin/bash

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

host=$(node "$scriptDir/setup/dbHost.js");
user=$(node "$scriptDir/setup/dbUser.js");
pass=$(node "$scriptDir/setup/dbPass.js");


PGPASSWORD="$pass"

# execute sql
echo "dropping existing db"
psql -h "$host" --quiet -U "$user" -c "drop database IF EXISTS \"mothershipTest\";" 
psql -h "$host" --quiet -U "$user" -c "drop schema IF EXISTS \"mothershipTest\" CASCADE;" 

echo "creating new db"
psql -h "$host" --quiet -U "$user" -c "create database \"mothershipTest\";"
psql -h "$host" --quiet -U "$user" mothershipTest -f "$scriptDir/data/sql/createdb.sql"

# insert data
echo "calling data creation create scripts"
node "$scriptDir/setup/dbData.js"
echo "done!"