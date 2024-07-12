@echo off

Powershell.exe -noprofile -executionpolicy Bypass -File ".\Invoke-PostDeploymentTasks.ps1" -Verb runas