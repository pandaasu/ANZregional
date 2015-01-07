@echo off
echo Environment : PRODUCTION
echo About to Commencing Recompiliation of all Automatically 
echo Generated Interface Packages and Tables. Ctrl-C to cancel.
echo ==================================================================
echo WARNING: This will drop and recreate all End to End Tables.  
echo             ----  DATA WILL BE LOST   -----
echo ==================================================================
pause
sqlplus.exe -s /nolog @build_e2e_demand_prod.sql 
echo ==================================================================
echo Compilation Completed
pause