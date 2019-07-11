#!/bin/bash

cd `dirname $0`
pwd
cd ..
nohup ./x process/one/entry.config &
