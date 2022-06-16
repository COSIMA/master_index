#!/usr/bin/env python

import sys

import cosima_cookbook as cc

print(cc)

dirs = sys.argv[1:]

db = 'cosima_master.db'
print('Establishing a DB connection')
session = cc.database.create_session(db, timeout=30)

for dir in dirs:
    print('Indexing: {}'.format(dir))
    cc.database.build_index(dir, session, prune='delete', 
                            force=False, followsymlinks=True,
                            nfiles=1000)
