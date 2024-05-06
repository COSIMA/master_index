#!/bin/bash

DB_PATH='/g/data/ik11/databases'
DB_LINK="${DB_PATH}/cosima_master.db"
DB_DATE=$(date +"%Y-%m-%d")
DB="${DB_PATH}/daily/cosima_master_${DB_DATE}.db"

echo $DB

chmod 440 ${DB}
chgrp ik11 ${DB}
ln -sf ${DB} ${DB_LINK}
