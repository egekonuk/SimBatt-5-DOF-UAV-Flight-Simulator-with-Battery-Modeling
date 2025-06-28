function pitch_cmd_out = altitude_hold_PID(params, zcoor, current_pitch, dt)
%ALTITUDE_HOLD_PID Controls aircraft pitch to maintain a target altitude using a PID controller.
%
%   This version includes an improved anti-windup mechanism and more
%   aggressive gains for a faster altitude response.
%
%   Inputs:
%       params        - Struct containing simulation parameters. Expected fields:
%                       - params.mission.cruise_h: Target cruise altitude (m)
%                       - params.sim.pitch_cmd: Maximum absolute pitch command (deg)
%                       - params.sim.pitchrate: Maximum pitch rate (deg/s)
%       zcoor         - Current altitude of the aircraft (m).
%       current_pitch - The current pitch of the aircraft (deg). This is needed
%                       to properly apply the pitch rate limit.
%       dt            - Simulation time step (s).
%
%   Output:
%       pitch_cmd_out - The calculated pitch command for the next time step (deg).

    % --- State variables that persist between function calls ---
    persistent integral_error previous_error;
    
    % Initialize persistent variables on the first run
    if isempty(integral_error)
        integral_error = 0;
        previous_error = 0;
    end

    % --- PID Gains (TUNABLE PARAMETERS) ---
    % The Kp and Ki gains have been significantly increased to produce a
    % faster, more aggressive response to altitude errors. Kd has also been
    % adjusted to help stabilize this more aggressive response.
    
    Kp = 0.2;  % Increased Proportional gain for faster reaction
    Ki = 0.02; % Increased Integral gain to build corrective action faster
    Kd = 0.2;  % Adjusted Derivative gain to dampen the stronger response

    % --- Get Mission and Aircraft Parameters from Struct ---
    target_altitude = params.mission.cruise_h;
    max_pitch_angle = params.sim.pitch_cmd;
    max_pitch_rate  = params.sim.pitchrate;

    % --- PID Controller Logic ---

    % 1. Calculate the error
    error = target_altitude - zcoor;

    % 2. Proportional Term
    p_term = Kp * error;

    % 3. Integral Term
    i_term = Ki * integral_error;

    % 4. Derivative Term
    derivative_error = (error - previous_error) / dt;
    d_term = Kd * derivative_error;

    % 5. Combine the terms to get the raw desired pitch command
    desired_pitch = p_term + i_term + d_term;

    % --- Apply Aircraft Physical Constraints ---

    % A. Limit the rate of change of the pitch command based on max_pitch_rate
    max_pitch_change = max_pitch_rate * dt;
    pitch_cmd_rate_limited = current_pitch + max(-max_pitch_change, min(max_pitch_change, desired_pitch - current_pitch));

    % B. Saturate the command at the aircraft's absolute maximum pitch angle.
    pitch_cmd_out = max(-max_pitch_angle, min(max_pitch_angle, pitch_cmd_rate_limited));

    % --- IMPROVED ANTI-WINDUP LOGIC ---
    % Only allow the integral term to accumulate if the controller is NOT saturated.
    if pitch_cmd_out == desired_pitch
        integral_error = integral_error + (error * dt);
    end

    % --- Update state for the next iteration ---
    previous_error = error;

end
