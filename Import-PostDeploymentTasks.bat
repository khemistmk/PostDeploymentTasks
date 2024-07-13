@echo off
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module ""%~dp0%PostDeploymentTasks.psm1"" }" -Verb runas