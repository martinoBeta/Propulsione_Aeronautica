function [T0I, P0I, T_in, P_in, rho_in, V_in, A0, Ain, pi_d, CPR] = ...
    presaDaria(T_inf, P_inf, rho_inf, M0, mDot, machIn, eta_d, propFluidi)

    gamma = propFluidi.gamma;
    Rgas  = propFluidi.R;

 
    a_inf = sqrt(gamma * Rgas * T_inf);
    V_inf = M0 * a_inf;

    T00 = T_inf * (1 + (gamma - 1)/2 * M0^2);
    P00 = P_inf * (1 + (gamma - 1)/2 * M0^2)^(gamma/(gamma - 1));

    % Condizioni totali in uscita presa = ingresso compressore
    T0I = T00;           % presa adiabatica
    P0I = eta_d * P00;   % perdita di pressione totale

    % Condizioni statiche uscita presa / ingresso compressore
    T_in = T0I / (1 + (gamma - 1)/2 * machIn^2);
    P_in = P0I / (1 + (gamma - 1)/2 * machIn^2)^(gamma/(gamma - 1));
    rho_in = P_in / (Rgas * T_in);

    a_in = sqrt(gamma * Rgas * T_in);
    V_in = machIn * a_in;

    % Area cattura  = area di ingresso presa
    A0  = mDot / (rho_inf * V_inf);
    % Area ingresso compressore
    Ain = mDot / (rho_in * V_in);

    % Coefficiente di recupero pressione statica del diffusore
    q_inf = 0.5 * rho_inf * V_inf^2;
    CPR = (P_in - P_inf) / q_inf;

end