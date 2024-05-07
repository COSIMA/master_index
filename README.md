# Master Index

This repo contains the script that is used to generate and keep
updated the master COSIMA Cookbook database.

It is resides in

```
/g/data/ik11/databases
```

Currently all model outputs in the `outputs` directory are indexed, as as
all forcing datasets under `inputs/JRA55`


## Updating the database

Several scripts are provided to update the database and there are two top-level
scripts:

```
update_db_start.sh
update_db_finish.sh
```

The names should be quite self-explanatory. The reason why the full procedure is
divided in two parts is that it might happen the update fails for some
reason. In that case, the updated database might be unusable and one should
**not** invoke the `update_db_finish.sh` script. Therefore one should always
carefully check the logs produced by the `update_db_start.sh` script before
invoking the `update_db_finish.sh` script.

WARNING: the `update_db_finish.sh` needs to be run the **same** day as the
`update_db_start.sh`, or it will fail.

## File permissions and group ownership

For the indexing to work properly (and for users to be able to access the data
from the cookbook), the files and directories being indexed need to have
appropriate permissions and belong to the correct group. All files need to be
readable by the group while directories need also to be executable.

Two scripts are provided to check and fix incorrect permissions and group
ownership: `check_permissions` and `fix_permissions`. Note that the former will
check all files and directories, while the later will only fix files and
directories that are owned by the user invoking the script.
