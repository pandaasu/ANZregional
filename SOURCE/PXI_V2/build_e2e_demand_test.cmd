@echo off
echo Environment : TEST 
echo About to Commencing Recompiliation of all Automatically 
echo Generated Interface Packages. Ctrl-C to cancel.
echo ==================================================================
pause
sqlplus.exe -s /nolog @build_e2e_demand_test.sql 
echo ==================================================================
echo Compilation Completed
pause