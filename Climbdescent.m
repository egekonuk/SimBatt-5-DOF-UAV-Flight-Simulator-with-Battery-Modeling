function [pitch_out, cd_out, h_out, fpakep_old_out, step_disp_out] = Climbdescent(params, aoa, vel, fpa, h, cd, zcoor, T, bank, pitch, fpakep_old, step_disp)
% Refactored to use the original algorithm with the params struct.

    % --- Unpack parameters from params struct ---
    cruiseh = params.mission.cruise_h;
    g = params.atmosphere.g;
    mtot = params.aircraft.mtot;
    CL_fit = params.aero.CL_AOA; % Replaces global C4
    pitchrate = params.sim.pitchrate; % Replaces global pitchchange
    pitch_cmd = params.sim.pitch_cmd;
    const = 0.5 * params.atmosphere.rho * params.aircraft.Srefw;
    
    % Define hmin relative to the main time step h
    hmin = params.sim.h;
    
    % Initialize output variables to their input state
    pitch_out = pitch;
    cd_out = cd;
    h_out = h;
    fpakep_old_out = fpakep_old;
    step_disp_out = step_disp;
    
    % --- Original Algorithm Logic ---

        if pitch_cmd < pitch
            pitchrate_signed = -abs(pitchrate);
        else
            pitchrate_signed = abs(pitchrate);
        end
        
    if pitch_cmd > pitch

        
        i = 1;
        fpakep = 1000;
        % Calculate target flight path angle
        while fpakep > fpa && fpakep > fpakep_old_out && i < 300
            fpakep = (cruiseh - zcoor) / i;
            i = i + 1;
            if (fpakep) < 0.05
                fpakep = 0;
                break
            end
        end

        fpakep_old_out = fpakep;
        i = 2;
        aoa_goal(1) = 100;
        aoa_goal(2) = 1000;
        % Iteratively find the required angle of attack for the climb
        while round(aoa_goal(end), 3) ~= round(aoa_goal(end-1), 3)
            CLkep = (((fpakep-fpa)*h+(g/vel)*cosd(fpa))*(mtot*vel)/cosd(bank)-T*sind(aoa))/(const*vel^2);
            aoa_goal(i) = fzero(@(x) CL_fit(x) - (CLkep), 0);
            aoa = aoa_goal(end);
            i = i + 1;
            % if i > 50, break; end % Safety break
        end
        
        pitch_test = fpa + aoa;
        if pitch_test > pitch - h*pitchrate_signed && pitch_test < pitch + h*pitchrate_signed
            if bank ~= 0 && abs(abs(pitch_test) - abs(pitch)) > 0.005
                pitch_out = pitch_test;
            elseif abs(fpa) >= 0.001
                pitch_out = pitch_test;
            elseif bank == 0
                step_disp_out = 20;
            end
            return;
        end
    else
        cd_out = 1;
    end
    


    
    % Altitude correction logic
    if cd_out == 1 % in climb mode
        h_old = h;
        h_out = hmin;
        if round(cruiseh - (vel*sind(fpa - (pitchrate*h_out)/1.7) + vel*sind(pitchrate*h_out))/0.2, 3) <= round(zcoor, 3) && fpa > 0
            pitch_out = pitch - h_out*pitchrate;
        elseif fpa < 0 % recover if flight path goes negative
            pitch_out = pitch + h_out*pitchrate;
        else
            h_out = h_old;
        end
    elseif cd_out == 2 % in descent mode
        h_old = h;
        h_out = hmin;
        if round(cruiseh - (vel*sind(fpa - (-pitchrate*h_out)/1.7) + vel*sind(-pitchrate*h_out))/0.2, 3) <= round(zcoor, 3) && fpa < 0
            pitch_out = pitch + h_out*pitchrate;
        elseif fpa > 0 % recover if flight path goes positive
            pitch_out = pitch - h_out*pitchrate;
        else
            h_out = h_old;
        end
    end
end