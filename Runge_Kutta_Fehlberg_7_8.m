function [y0, out, h_next] = Runge_Kutta_Fehlberg_7_8(func, t_current, vel, gamma, head, h, tolerance, params)
% This function implements an adaptive Runge-Kutta-Fehlberg 7(8) method.
% It integrates a system of ODEs from t_current over an interval defined by params.sim.hlook.

    % --- Start of user-specific application logic (preserved as is) ---
    persistent tt_old;
    if isempty(tt_old) || t_current == 0
        tt_old = 0;
    end
    
    hmin = params.sim.h; % Minimum allowed step size

    head_old = head;
    [y0_temp, ~, ~] = Runge_Kutta(func, t_current, vel, gamma, head,h, params);
    vel = y0_temp(1); gamma = y0_temp(2); head = y0_temp(3);
    
    if abs(abs(head_old)-abs(head)) > 300 || t_current > 60
        tt_old = tt_old + t_current;
        t_current = 0;
        [y0, ~, ~] = Runge_Kutta(func, t_current, vel, gamma, head,h, params);
         vel = y0(1); gamma = y0(2); head = y0(3);
    else
        y0 = [vel, gamma, head];
    end
    
    t_start = tt_old + t_current;
    tmax = t_start + params.sim.hlook; % Integration endpoint is determined by hlook
    % --- End of user-specific application logic ---


    % --- Refactored Adaptive Step-Size Algorithm ---
    % Constants from the original Fehlberg implementation
    ATTEMPTS = 12;
    MIN_SCALE_FACTOR = 0.125;
    MAX_SCALE_FACTOR = 4.0;
    SAFETY_FACTOR = 0.75; 
    err_exponent = 1.0/7.0; % As per the original implementation file

    % --- Initial Sanity Checks ---
    if (tmax <= t_start || h <= 0.0)
        out = -2;
        h_next = h;
        return;
    end
   
    % Scale tolerance to be per unit of the integration interval
    tolerance_per_unit = tolerance / (tmax - t_start);
    
    t = t_start;

    % --- Main Integration Loop ---
    while (t < tmax)
        
        % Ensure the last step hits tmax exactly
        if (t + h > tmax)
            h = tmax - t;
        end
        
        % Adaptive step-size core loop: try to take a step of size h
        for i = 1:ATTEMPTS
            [y_trial, ~, err_vec] = Runge_Kutta(func, t, y0(1), y0(2), y0(3), h, params);
            
            err = norm(err_vec);
            
            % Define the error tolerance scale based on the magnitude of the solution
            if norm(y0) == 0.0
                scale_norm = tolerance;
            else
                scale_norm = norm(y0);
            end
            
            % Check if the step is accepted
            if err <= tolerance_per_unit * scale_norm
                % Success: error is within tolerance
                break;
            end
            
            % If error is too large, we must retry with a smaller step.
            if i >= ATTEMPTS
                % Failed to converge within the maximum number of attempts
                out = -1;
                h_next = h;
                % Apply constraints before returning on failure
                h_next = max(h_next, hmin);
                h_next = min(h_next, params.sim.hlook);
                return;
            end

            % Calculate scaling factor to reduce the step size for the next attempt
            if err == 0.0
                scale = MAX_SCALE_FACTOR; % Avoid division by zero, take max scale
            else
                scale = SAFETY_FACTOR * ( (tolerance_per_unit * scale_norm) / err )^err_exponent;
                scale = min(max(scale, MIN_SCALE_FACTOR), MAX_SCALE_FACTOR);
            end
            
            h = h * scale; % Update h for the next attempt in this for-loop
            
            % Ensure the step size does not fall below the minimum
            if h < hmin
                h = hmin;
            end
        end % End of for-loop for attempts
        
        % --- Step Accepted ---
        % Update the time and state variables
        t = t + h;
        y0 = y_trial;
        
        % --- Prepare for the Next Step ---
        % Calculate the optimal step size for the next iteration of the while-loop
        if err == 0.0
            scale = MAX_SCALE_FACTOR;
        else
            scale = SAFETY_FACTOR * ( (tolerance_per_unit * scale_norm) / err )^err_exponent;
            scale = min(max(scale, MIN_SCALE_FACTOR), MAX_SCALE_FACTOR);
        end
        
        h = h * scale; % This is the proposed h for the next loop iteration
    end

    % --- Integration Finished Successfully ---
    out = 0; 
    
    % The last calculated h is our suggestion for the next call to this function
    h_next = h;
    
    % Apply final constraints to the output h_next
    h_next = max(h_next, hmin);
    h_next = min(h_next, params.sim.hlook); % Ensure h_next does not exceed the look-ahead value
end


function [f_val, diff, out] = Runge_Kutta(func, time, vel, gamma, head, h, params)
    % This sub-function performs a single RKF7(8) step and remains unchanged.

    isTakeoffPhase = (params.takeoff.muf > 0);

    c_1_11 = 41.0 / 840.0;
    c6 = 34.0 / 105.0;
    c_7_8= 9.0 / 35.0;
    c_9_10 = 9.0 / 280.0;
    
    a2 = 2.0 / 27.0;
    a3 = 1.0 / 9.0;
    a4 = 1.0 / 6.0;
    a5 = 5.0 / 12.0;
    a6 = 1.0 / 2.0;
    a7 = 5.0 / 6.0;
    a8 = 1.0 / 6.0;
    a9 = 2.0 / 3.0;
    a10 = 1.0 / 3.0;
    
    b31 = 1.0 / 36.0;
    b32 = 3.0 / 36.0;
    b41 = 1.0 / 24.0;
    b43 = 3.0 / 24.0;
    b51 = 20.0 / 48.0;
    b53 = -75.0 / 48.0;
    b54 = 75.0 / 48.0;
    b61 = 1.0 / 20.0;
    b64 = 5.0 / 20.0;
    b65 = 4.0 / 20.0;
    b71 = -25.0 / 108.0;
    b74 =  125.0 / 108.0;
    b75 = -260.0 / 108.0;
    b76 =  250.0 / 108.0;
    b81 = 31.0/300.0;
    b85 = 61.0/225.0;
    b86 = -2.0/9.0;
    b87 = 13.0/900.0;
    b91 = 2.0;
    b94 = -53.0/6.0;
    b95 = 704.0 / 45.0;
    b96 = -107.0 / 9.0;
    b97 = 67.0 / 90.0;
    b98 = 3.0;
    b10_1 = -91.0 / 108.0;
    b10_4 = 23.0 / 108.0;
    b10_5 = -976.0 / 135.0;
    b10_6 = 311.0 / 54.0;
    b10_7 = -19.0 / 60.0;
    b10_8 = 17.0 / 6.0;
    b10_9 = -1.0 / 12.0;
    b11_1 = 2383.0 / 4100.0;
    b11_4 = -341.0 / 164.0;
    b11_5 = 4496.0 / 1025.0;
    b11_6 = -301.0 / 82.0;
    b11_7 = 2133.0 / 4100.0;
    b11_8 = 45.0 / 82.0;
    b11_9 = 45.0 / 164.0;
    b11_10 = 18.0 / 41.0;
    b12_1 = 3.0 / 205.0;
    b12_6 = - 6.0 / 41.0;
    b12_7 = - 3.0 / 205.0;
    b12_8 = - 3.0 / 41.0;
    b12_9 = 3.0 / 41.0;
    b12_10 = 6.0 / 41.0;
    b13_1 = -1777.0 / 4100.0;
    b13_4 = -341.0 / 164.0;
    b13_5 = 4496.0 / 1025.0;
    b13_6 = -289.0 / 82.0;
    b13_7 = 2193.0 / 4100.0;
    b13_8 = 51.0 / 82.0;
    b13_9 = 33.0 / 164.0;
    b13_10 = 12.0 / 41.0;
       
    err_factor  = -41.0 / 840.0;
    h2_7 = a2 * h;
    
    k1 = func{1}(time, vel, gamma);
    l1 = func{2}(time, vel, gamma);
    p1 = func{3}(time, vel, gamma);
    
    k2 = func{1}(time+h2_7, vel + h2_7 * k1, gamma + h2_7 * l1);
    l2 = func{2}(time+h2_7, vel + h2_7 * k1, gamma + h2_7 * l1);
    p2 = func{3}(time+h2_7, vel + h2_7 * k1, gamma + h2_7 * l1);
    
    k3 = func{1}(time+a3*h, vel + h * (b31*k1 + b32*k2), gamma + h *...
        (b31*l1 + b32*l2));
    l3 = func{2}(time+a3*h, vel + h * (b31*k1 + b32*k2), gamma + h *...
        (b31*l1 + b32*l2));
    p3 = func{3}(time+a3*h, vel + h * (b31*k1 + b32*k2), gamma + h *...
        (b31*l1 + b32*l2));
    
    k4 = func{1}(time+a4*h, vel + h * (b41*k1 + b43*k3), gamma + h *...
        (b41*l1 + b43*l3));
    l4 = func{2}(time+a4*h, vel + h * (b41*k1 + b43*k3), gamma + h *...
        (b41*l1 + b43*l3));
    p4 = func{3}(time+a4*h, vel + h * (b41*k1 + b43*k3), gamma + h *...
        (b41*l1 + b43*l3));
    
    k5 = func{1}(time+a5*h, vel + h * (b51*k1 + b53*k3 + b54*k4), gamma + h *...
        (b51*l1 + b53*l3 + b54*l4));
    l5 = func{2}(time+a5*h, vel + h * (b51*k1 + b53*k3 + b54*k4), gamma + h *...
        (b51*l1 + b53*l3 + b54*l4));
    p5 = func{3}(time+a5*h, vel + h * (b51*k1 + b53*k3 + b54*k4), gamma + h *...
        (b51*l1 + b53*l3 + b54*l4));
    
    k6 = func{1}(time+a6*h, vel + h * (b61*k1 + b64*k4 + b65*k5), gamma + h *...
        (b61*l1 + b64*l4 + b65*l5));
    l6 = func{2}(time+a6*h, vel + h * (b61*k1 + b64*k4 + b65*k5), gamma + h *...
        (b61*l1 + b64*l4 + b65*l5));
    p6 = func{3}(time+a6*h, vel + h * (b61*k1 + b64*k4 + b65*k5), gamma + h *...
        (b61*l1 + b64*l4 + b65*l5));
    
    k7 = func{1}(time+a7*h, vel + h * (b71*k1 + b74*k4 + b75*k5 + b76*k6),...
        gamma + h * (b71*l1 + b74*l4 + b75*l5 + b76*l6));
    l7 = func{2}(time+a7*h, vel + h * (b71*k1 + b74*k4 + b75*k5 + b76*k6),...
        gamma + h * (b71*l1 + b74*l4 + b75*l5 + b76*l6));
    p7 = func{3}(time+a7*h, vel + h * (b71*k1 + b74*k4 + b75*k5 + b76*k6),...
        gamma + h * (b71*l1 + b74*l4 + b75*l5 + b76*l6));
    
    k8 = func{1}(time+a8*h, vel + h * (b81*k1 + b85*k5 + b86*k6 + b87*k7),...
        gamma + h * (b81*l1 + b85*l5 + b86*l6 + b87*l7));
    l8 = func{2}(time+a8*h, vel + h * (b81*k1 + b85*k5 + b86*k6 + b87*k7),...
        gamma + h * (b81*l1 + b85*l5 + b86*l6 + b87*l7));
    p8 = func{3}(time+a8*h, vel + h * (b81*k1 + b85*k5 + b86*k6 + b87*k7),...
        gamma + h * (b81*l1 + b85*l5 + b86*l6 + b87*l7));
    
    k9 = func{1}(time+a9*h, vel + h * (b91*k1 + b94*k4 + b95*k5 + b96*k6 + ...
        b97*k7 + b98*k8), gamma + h * (b91*l1 + b94*l4 + b95*l5 + b96*l6...
        + b97*l7 + b98*l8));
    l9 = func{2}(time+a9*h, vel + h * (b91*k1 + b94*k4 + b95*k5 + b96*k6 + ...
        b97*k7 + b98*k8), gamma + h * (b91*l1 + b94*l4 + b95*l5 + b96*l6...
        + b97*l7 + b98*l8));
    p9 = func{3}(time+a9*h, vel + h * (b91*k1 + b94*k4 + b95*k5 + b96*k6 + ...
        b97*k7 + b98*k8), gamma + h * (b91*l1 + b94*l4 + b95*l5 + b96*l6...
        + b97*l7 + b98*l8));
    
    k10 = func{1}(time+a10*h, vel + h * (b10_1*k1 + b10_4*k4 + b10_5*k5 + b10_6*k6...
      + b10_7*k7 + b10_8*k8 + b10_9*k9)...
        , gamma + h * (b10_1*l1 + b10_4*l4 + b10_5*l5 + b10_6*l6...
      + b10_7*l7 + b10_8*l8 + b10_9*l9));
    l10 = func{2}(time+a10*h, vel + h * (b10_1*k1 + b10_4*k4 + b10_5*k5 + b10_6*k6...
      + b10_7*k7 + b10_8*k8 + b10_9*k9)...
        , gamma + h * (b10_1*l1 + b10_4*l4 + b10_5*l5 + b10_6*l6...
      + b10_7*l7 + b10_8*l8 + b10_9*l9));                                      
    p10 = func{3}(time+a10*h, vel + h * (b10_1*k1 + b10_4*k4 + b10_5*k5 + b10_6*k6...
      + b10_7*k7 + b10_8*k8 + b10_9*k9)...
        , gamma + h * (b10_1*l1 + b10_4*l4 + b10_5*l5 + b10_6*l6...
      + b10_7*l7 + b10_8*l8 + b10_9*l9));
    
    k11 = func{1}(time+h, vel + h * (b11_1*k1 + b11_4*k4 + b11_5*k5 + b11_6*k6...
                               + b11_7*k7 + b11_8*k8 + b11_9*k9 + b11_10 * k10)...
       , gamma + h * (b11_1*l1 + b11_4*l4 + b11_5*l5 + b11_6*l6...
                               + b11_7*l7 + b11_8*l8 + b11_9*l9 + b11_10 * l10));
    l11 = func{2}(time+h, vel + h * (b11_1*k1 + b11_4*k4 + b11_5*k5 + b11_6*k6...
                               + b11_7*k7 + b11_8*k8 + b11_9*k9 + b11_10 * k10)...
       , gamma + h * (b11_1*l1 + b11_4*l4 + b11_5*l5 + b11_6*l6...
                               + b11_7*l7 + b11_8*l8 + b11_9*l9 + b11_10 * l10));                       
    p11 = func{3}(time+h, vel + h * (b11_1*k1 + b11_4*k4 + b11_5*k5 + b11_6*k6...
                               + b11_7*k7 + b11_8*k8 + b11_9*k9 + b11_10 * k10)...
       , gamma + h * (b11_1*l1 + b11_4*l4 + b11_5*l5 + b11_6*l6...
                               + b11_7*l7 + b11_8*l8 + b11_9*l9 + b11_10 * l10));
                           
    k12 = func{1}(time, vel + h * (b12_1*k1 + b12_6*k6 + b12_7*k7 + b12_8*k8...
                                                     + b12_9*k9 + b12_10 * k10)...
        , gamma + h * (b12_1*l1 + b12_6*l6 + b12_7*l7 + b12_8*l8...
                                                     + b12_9*l9 + b12_10 * l10));
    l12 = func{2}(time, vel + h * (b12_1*k1 + b12_6*k6 + b12_7*k7 + b12_8*k8...
                                                     + b12_9*k9 + b12_10 * k10)...
        , gamma + h * (b12_1*l1 + b12_6*l6 + b12_7*l7 + b12_8*l8...
                                                     + b12_9*l9 + b12_10 * l10));
    p12 = func{3}(time, vel + h * (b12_1*k1 + b12_6*k6 + b12_7*k7 + b12_8*k8...
                                                     + b12_9*k9 + b12_10 * k10)...
        , gamma + h * (b12_1*l1 + b12_6*l6 + b12_7*l7 + b12_8*l8...
                                                     + b12_9*l9 + b12_10 * l10));
                                                 
    k13 = func{1}(time+h, vel + h * (b13_1*k1 + b13_4*k4 + b13_5*k5 + b13_6*k6...
                    + b13_7*k7 + b13_8*k8 + b13_9*k9 + b13_10*k10 + k12)...
        , gamma + h * (b13_1*l1 + b13_4*l4 + b13_5*l5 + b13_6*l6...
                    + b13_7*l7 + b13_8*l8 + b13_9*l9 + b13_10*l10 + l12));
    l13 = func{2}(time+h, vel + h * (b13_1*k1 + b13_4*k4 + b13_5*k5 + b13_6*k6...
                    + b13_7*k7 + b13_8*k8 + b13_9*k9 + b13_10*k10 + k12)...
        , gamma + h * (b13_1*l1 + b13_4*l4 + b13_5*l5 + b13_6*l6...
                    + b13_7*l7 + b13_8*l8 + b13_9*l9 + b13_10*l10 + l12));            
    p13 = func{3}(time+h, vel + h * (b13_1*k1 + b13_4*k4 + b13_5*k5 + b13_6*k6...
                    + b13_7*k7 + b13_8*k8 + b13_9*k9 + b13_10*k10 + k12)...
        , gamma + h * (b13_1*l1 + b13_4*l4 + b13_5*l5 + b13_6*l6...
                    + b13_7*l7 + b13_8*l8 + b13_9*l9 + b13_10*l10 + l12));
    
    diff1 = h * (c_1_11 * (k1 + k11)  + c6 * k6 + c_7_8 * (k7 + k8)...
                                               + c_9_10 * (k9 + k10));
    diff2 = h * (c_1_11 * (l1 + l11)  + c6 * l6 + c_7_8 * (l7 + l8)...
                                               + c_9_10 * (l9 + l10));   
    
    if isTakeoffPhase && diff2 <= 0, diff2 = 0; end
    
    diff3 = h * (c_1_11 * (p1 + p11)  + c6 * p6 + c_7_8 * (p7 + p8)...
                                               + c_9_10 * (p9 + p10));
                                                                          
                                                                                
    diff = [diff1 diff2 diff3];                                       
    f_val(1) = vel + diff1;
    f_val(2) = gamma + diff2;                                     
    f_val(3) = mod(head + diff3, 360);  
                                           
    out(1) = err_factor * (k1 + k11 - k12 - k13) * h;
    out(2) = err_factor * (l1 + l11 - l12 - l13) * h;
    out(3) = err_factor * (p1 + p11 - p12 - p13) * h;
end