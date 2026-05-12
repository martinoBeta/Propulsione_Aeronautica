clc
clear 
close all
addpath("FunzioniMotore")
propFluidi = structFluidi();
motoreBase = structMotore();

motore = runnerMotore(motoreBase,propFluidi);