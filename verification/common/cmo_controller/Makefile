.PHONY: all regression mutation

all: regression

regression:
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run_regression.ps1

mutation:
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run_mutation_check.ps1
