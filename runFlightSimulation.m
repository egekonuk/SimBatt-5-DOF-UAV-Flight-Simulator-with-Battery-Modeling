function results = runFlightSimulation(params)
    % This function orchestrates the entire flight simulation.
    % It takes all simulation parameters in a struct and returns all results in another.

    % --- Takeoff Phase ---
    % The Takeoff function is modified to accept 'params' and return initial state variables.
    [vel, Trvel, fpa, pitch, Beta, Beta_norot, xcoor, ycoor, zcoor, i, ...
     todist, aoa, bank, P_Batt, P, SOC, SOC_2, VoltIns, VoltIns_2, ...
     Current, Current_2, effprop, CP, CT, T, t, RPM] = Takeoff(params);

    % --- Main Mission Phase ---
    % The MissionMain function is also modified to accept the initial state and params.
    % It now returns the final, complete results vectors.
    [xcoor, ycoor, zcoor, vel, Trvel, fpa, pitch, Beta, bank, T, P_Batt, ...
     P, SOC, SOC_2, VoltIns, VoltIns_2, Current, Current_2, effprop, ...
     CP, CT, t, aoa, RPM] = ...
     MissionMain(xcoor, ycoor, zcoor, i, vel, Trvel, Beta, Beta_norot, ...
                 fpa, pitch, params, bank, T, P_Batt, P, SOC, SOC_2, ...
                 VoltIns, VoltIns_2, Current, Current_2, effprop, CP, CT, t, RPM);
    
    % --- Assemble Final Results Struct ---
    % This struct is returned to the app for plotting.
    results.t = t;
    results.xcoor = xcoor;
    results.ycoor = ycoor;
    results.zcoor = zcoor;
    results.vel = vel;
    results.Trvel = Trvel;
    results.fpa = fpa;
    results.pitch = pitch;
    results.Beta = Beta;
    results.aoa = aoa;
    results.bank = bank;
    results.T = T;
    results.P_Batt = P_Batt;
    results.P = P;
    results.SOC = SOC;
    results.SOC_2 = SOC_2;
    results.VoltIns = VoltIns;
    results.VoltIns_2 = VoltIns_2;
    results.Current = Current;
    results.Current_2 = Current_2;
    results.effprop = effprop;
    results.CP = CP;
    results.CT = CT;
    results.RPM = RPM;
    results.todist = todist;
    
    fprintf('Simulation Completed Successfully!\n');
end