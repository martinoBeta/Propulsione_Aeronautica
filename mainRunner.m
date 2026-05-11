clc
clear 
close all
addpath("FunzioniMotore")

propFluidi = structFluidi();
motoreBase = structMotore();
runnerMotore(motoreBase,propFluidi);