function bank_cmd_out = heading_hold_PID(params, Cmd_HDG, BETA, current_bank, dt)
%HEADING_HOLD_PID Controls aircraft bank angle to achieve a target heading using a PID controller.
%
%   This function calculates the necessary bank angle to turn the aircraft
%   to a desired heading (Cmd_HDG). It respects bank angle and bank rate
%   limits specified in the params struct.
%
%   Inputs:
%       params        - Struct containing simulation parameters. Expected fields:
%                       - params.sim.bankrate: Maximum bank rate (deg/s)
%       Cmd_HDG       - The commanded/desired heading (degrees).
%       BETA          - The current heading (azimuthal) of the aircraft (degrees).
%       current_bank  - The current bank angle of the aircraft (degrees).
%                       Needed to properly apply the bank rate limit.
%       dt            - Simulation time step (s).
%
%   Output:
%       bank_cmd_out  - The calculated bank angle command for the next time step (degrees).

    % --- State variables that persist between function calls ---
    % These store the integral of the error and the previous error for the derivative term.
    persistent integral_error previous_error;
    
    % Initialize persistent variables on the first run.
    if isempty(integral_error)
        integral_error = 0;
        previous_error = 0;
    end

    % --- PID Gains (TUNABLE PARAMETERS) ---
    % These gains will need to be tuned for your specific aircraft dynamics.
    % Kp: Proportional gain. A larger value creates a more aggressive turn.
    % Ki: Integral gain. Corrects for steady-state heading errors (e.g., due to wind).
    % Kd: Derivative gain. Dampens the turn to prevent overshooting the target heading.
    
    Kp = 2.5;   % Proportional gain
    Ki = 0.1;   % Integral gain
    Kd = 1.0;   % Derivative gain

    % --- Get Mission and Aircraft Parameters ---
    max_bank_rate  = params.sim.bankrate; % Max bank rate from params
    max_bank_angle = 30; % Per user request, max bank angle is 30 degrees.
    
    % --- PID Controller Logic ---

    % 1. Calculate the heading error. 
    % Using angdiff is crucial for correctly handling the 360->0 degree crossover.
    % It automatically finds the shortest path (e.g., -20 deg instead of +340 deg).
    % The result is in radians, so we convert it to degrees.
    error = rad2deg(angdiff(deg2rad(BETA), deg2rad(Cmd_HDG)));

    % 2. Proportional Term: Proportional to the current heading error.
    % This will command a bank in the correct direction.
    p_term = Kp * error;

    % 3. Integral Term: Accumulates error over time to correct for steady-state drift.
    i_term = Ki * integral_error;

    % 4. Derivative Term: Reacts to the rate of change of the heading error.
    % This dampens the turn as the aircraft approaches the target heading.
    derivative_error = (error - previous_error) / dt;
    d_term = Kd * derivative_error;

    % 5. Combine the terms to get the raw desired bank angle command
    desired_bank = p_term + i_term + d_term;

    % --- Apply Aircraft Physical Constraints ---

    % A. Limit the rate of change of the bank command. An aircraft cannot
    % instantly change its bank angle.
    max_bank_change = max_bank_rate * dt;
    bank_cmd_rate_limited = current_bank + max(-max_bank_change, min(max_bank_change, desired_bank - current_bank));

    % B. Saturate the command at the aircraft's absolute maximum bank angle.
    bank_cmd_out = max(-max_bank_angle, min(max_bank_angle, bank_cmd_rate_limited));

    % --- Anti-Windup for Integral Term ---
    % If the output command was saturated at the max_bank_angle, we stop
    % accumulating the integral term to prevent overshoot after a long turn.
    if desired_bank == bank_cmd_out
        integral_error = integral_error + (error * dt);
    end
    
    % --- Update state for the next iteration ---
    previous_error = error;

end
