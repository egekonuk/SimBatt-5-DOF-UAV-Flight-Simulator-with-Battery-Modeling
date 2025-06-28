function [P, P_avail, T, SOC_out, SOC_2_out, V_terminal, V_terminal_2, effprop, CP, CT, Current, Current_2, RPM_out, ROC_Data] = Power(params, Vel, CL, D_unit, t, SOC_in, SOC_2_in, RPM_in)
% Corrected refactoring with robust logic for Simulink model call.

    % --- Unpack All Necessary Parameters ---
    Crtd = params.battery.Crtd;
    Voltage_fit = params.battery.Voltage_fit;
    n_curve = params.battery.n_curve;
    CellNum = params.battery.CellNum;
    int_res = params.motor.int_res;
    no_load_I = params.motor.no_load_I;
    Kv = params.motor.Kv;
    Amp_Max = params.motor.max_amp;
    max_rpm = params.motor.max_rpm;
    W = params.aircraft.W;
    Srefw = params.aircraft.Srefw;
    rho = params.atmosphere.rho;
    h = params.sim.h;
    step_disp = params.sim.step_disp;
    
    % --- Manage Persistent State Variables ---
    persistent DCHARGE Ampold tstart SOC2old;
    if length(t) <= 1
        DCHARGE = (1 - SOC_in) * Crtd;
        Ampold = 0;
        tstart = 0;
        SOC2old = SOC_2_in;
    end
    
    % --- Core Calculations ---
    Preq = D_unit * Vel^2 * Vel;
    [effprop, CP, CT, PropPower, T, RPM_out] = PropCall(params, Vel, RPM_in);
    P = PropPower;

    V_terminal_est = (Voltage_fit(SOC_in) / (P^n_curve))^(1/(1-n_curve));
    if V_terminal_est > 4.2 * CellNum, V_terminal_est = 4.2 * CellNum; end
    if isnan(V_terminal_est) || isinf(V_terminal_est), V_terminal_est = params.battery.Volt; end
    
    elec_motor_eff = (1-no_load_I*int_res/(V_terminal_est*RPM_out/max_rpm-RPM_out/Kv))*RPM_out/(V_terminal_est*RPM_out/max_rpm*Kv);
    elec_motor_eff = max(0.1, min(elec_motor_eff, 0.95));
    
    P_avail = V_terminal_est * Amp_Max * elec_motor_eff;

    % --- Power Limiting Logic ---
    if P > P_avail
        warning('Time =%g\n Insufficient Battery Power. Reducing RPM.', t(end));
        x0 = RPM_out;
        options = optimoptions('fmincon', 'Display', 'off');
        [RPM_out, ~] = fmincon(@objectiveFun, x0, [], [], [], [], 1000, max_rpm, @constraintFun, options);
        [effprop, CP, CT, P, T, RPM_out] = PropCall(params, Vel, RPM_out);
    end

    % --- Final Battery State Calculation ---
    P_elec = P / elec_motor_eff;
    if isnan(P_elec), P_elec = P / 0.85; end
    
    V_terminal = (Voltage_fit(SOC_in) / (P_elec^n_curve))^(1/(1-n_curve));
    if V_terminal > 4.2 * CellNum, V_terminal = 4.2 * CellNum; end
    if isnan(V_terminal) || isinf(V_terminal), V_terminal = params.battery.Volt; end
    
    Current = P_elec / V_terminal;
    DCHARGE = Current * h / 3600 + DCHARGE;
    SOC_out = (Crtd - DCHARGE) / Crtd;
    
    % --- CORRECTED: Simulink Model Logic ---
    if params.sim.useSimulink && mod(length(t), step_disp) == 0
       % Call the Simulink model on specified steps, passing params struct
       [SOC_2, V_terminal_2] = Simulink_Battery_Model(params, tstart, t(end), SOC2old, [Ampold Current]);
       SOC2old = SOC_2;
       tstart = t(end);
       V_terminal_2 = V_terminal_2 * CellNum;
       Current_2 = P_elec / V_terminal_2;
    else
       % For all other cases, carry the previous values forward
       SOC_2 = SOC_2_in;
       V_terminal_2 = 0;
       Current_2 = 0;
    end
    SOC_2_out = SOC_2;

    % --- Rate of Climb (ROC) Data Calculation ---
    ROC_avail = (P_avail - Preq) / W;
    ROC2_avail = (T - D_unit * Vel^2) * Vel / W;
    ROC_actual = (effprop * V_terminal * Current - Preq) / W;
    CLBANG = T/W - D_unit / (0.5 * rho * CL * Srefw);
    ROC_Data = [ROC_avail ROC2_avail ROC_actual CLBANG];

    % --- Nested Functions for fmincon ---
    function f = objectiveFun(rpm)
        [~, ~, ~, f, ~, ~] = PropCall(params, Vel, rpm);
    end

    function [c, ceq] = constraintFun(rpm)
        c = [];
        [~, ~, ~, propPower, ~, ~] = PropCall(params, Vel, rpm);
        ceq = propPower - P_avail;
    end
end