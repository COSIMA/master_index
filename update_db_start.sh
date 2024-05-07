#!/bin/bash

DB_PATH='/g/data/ik11/databases'
DB_LINK="${DB_PATH}/cosima_master.db"
DB_DATE=$(date +"%Y-%m-%d")
export DB="${DB_PATH}/daily/cosima_master_${DB_DATE}.db"

echo $DB

cp ${DB_LINK} ${DB}
chmod 600 ${DB}

qsub -v DB build_master_index
