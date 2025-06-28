function [SOC, Vterminal] = Simulink_Battery_Model(params, tstart, tend, SOCold, Amp)
% Refactored to accept params struct and use robust pathing.

    % --- Unpack required parameters ---
    Crtd = params.battery.Crtd;
    model = 'ssc_1C_Model_NT_MATLABfunc_2RC';

    % --- Robustly find the Simulink data folder ---
    try
        app_path = fileparts(mfilename('fullpath'));
        simu_dir = fullfile(app_path, 'Simu_Batt');
        cd(simu_dir);
    catch
        error('The "Simu_Batt" folder was not found. Please ensure it is in the same directory as your main scripts.');
    end

    % Define lookup table data for the 2RC model
    SOC_LUT = [0.5 0.6 0.7 0.8 0.9 1]';
    C1_LUT = [10922;18046;10882;11423;10845;10911];
    C2_LUT = [2245.6;1139.5;1242.2;1854.5;923.18;1376.5];
    Em_LUT = [3.8134;3.8694;3.9288;3.996;4.0926;4.1932];
    R0_LUT = [0.0028855;0.0025737;0.002923;0.0035298;0.0033088;0.0050329];
    R1_LUT = [0.0018074;0.0010146;0.0017304;0.001414;0.0011121;0.0087373];
    R2_LUT = [0.0019829;0.0031885;0.0031515;0.0031937;0.0034202;0.0041448];
    
    Capacity = Crtd;

    % --- Initial Conditions for Model ---
    Qe_init = (1 - SOCold) * Crtd; % Charge deficit from last time step
    
    if isnan(Amp(2))
        Amp(2) = Amp(1);
    end
    Amp = -Amp; % Current should be negative for discharge

    % --- Call Simulink Silently ---
    if tstart == 0
        load_system(model);
    else
        tend = tend - tstart;
        tstart = 0;
    end
    
    set_param(model,'StartTime',num2str(tstart),'StopTime',num2str(tend),...
        'SolverType','Variable-step');
        
    % Run simulation and get results
    out = sim(model,'SrcWorkspace','current');

    SOC = out.logsout{2}.Values.Data(end);
    Vterminal = out.logsout{1}.Values.Data(end);
    
    % Return to original directory
    cd(app_path);
end