function [f_val,h] = Rungeforth(params, time, vel, gamma, head, h, aoa, T, CL, D_unit, bank, muf, rwslp)
    % This function is a wrapper for the adaptive RKF7(8) solver.
    % It defines the EOMs and calls the solver.

    % 1. Define the equations of motion as three separate function handles
    [func_v, func_gamma, func_head] = EOM(params, T, aoa, CL, D_unit, bank, muf, rwslp);
    func_cell = {func_v, func_gamma, func_head};

    tolerance = params.sim.tolerance;

    % 3. Call the adaptive solver
    [y_new, ~, h] = Runge_Kutta_Fehlberg_7_8(func_cell, time, vel, gamma, head, h, tolerance, params);
    % 4. Format the output for the main simulation loops
    f_val(1) = y_new(1);
    f_val(2) = y_new(2);
    f_val(3) = y_new(3);
    f_val(4) = y_new(3); % No rotation heading placeholder
end

% This sub-function creates and returns the three separate equations of motion
function [func_v, func_gamma, func_head] = EOM(params, T_s, aoa_s, CL_s, D_unit_s, bank_s, muf_s, rwslp_s)
    % Unpack necessary constants from the main params struct
    mtot = params.aircraft.mtot;
    W = params.aircraft.W;
    g = params.atmosphere.g;
    const = 0.5 * params.atmosphere.rho * (params.aircraft.Srefw + params.aircraft.Srefht);
    isTakeoffPhase = (muf_s > 0);

    % CORRECTED: The anonymous functions now use the correct variable names (W, g, mtot)
    % that were defined in the lines above.
    if isTakeoffPhase
        func_v = @(t, v, gam) ((T_s*cosd(aoa_s) - W*sind(gam) - D_unit_s*v^2 - muf_s*(W*cosd(rwslp_s) - const*CL_s*v^2 - T_s*sind(aoa_s))) / mtot) * t;
    else
        func_v = @(t, v, gam) ((T_s*cosd(aoa_s) - D_unit_s*v^2 - W*sind(gam)) / mtot) * t;
    end
    
    func_gamma = @(t, v, gam) ((((T_s*sind(aoa_s) + const*CL_s*v^2)/(mtot*v))*cosd(bank_s) - (g/v)*cosd(gam))) * t;
    func_head = @(t, v, gam) ((((T_s*sind(aoa_s) + const*CL_s*v^2)/(mtot*v))*(sind(bank_s)/cosd(gam)))) * t;
end