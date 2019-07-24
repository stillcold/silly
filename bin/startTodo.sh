#!/bin/bash

cd `dirname $0`
pwd
cd ..
nohup ./x process/todolist/entry.config > log/todo.log 2>&1 &
