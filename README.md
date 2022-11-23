# Master Index

This repo contains the script that is used to generate and keep
updated the master COSIMA Cookbook database.

It is resides in

```
/g/data/ik11/databases
```

and the status of the jenkins job that runs the update daily is accessible
here:

https://accessdev.nci.org.au/jenkins/blue/organizations/jenkins/COSIMA%2FCC%20Database%20Build/activity


Currently all model outputs in the `outputs` directory are indexed, as as
all forcing datasets under `inputs/JRA55`


# File permissions and group ownership

For the indexing to work properly (and for users to be able to access the data
from the cookbook), the files and directories being indexed need to have
appropriate permissions and belong to the correct group. All files need to be
readable by the group while directories need also to be executable.

Two scripts are provided to check and fix incorrect permissions and group
ownership: `check_permissions` and `fix_permissions`. Note that the former will
check all files and directories, while the later will only fix files and
directories that are owned by the user invoking the script.
