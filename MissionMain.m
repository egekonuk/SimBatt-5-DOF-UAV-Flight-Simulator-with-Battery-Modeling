function [xcoor, ycoor, zcoor, vel, Trvel, fpa, pitch, Beta, bank, T, P_Batt, P, SOC, SOC_2, VoltIns, VoltIns_2, Current, Current_2, effprop, CP, CT, t, aoa, RPM, CL, CD] = ...
         MissionMain(app, xcoor, ycoor, zcoor, i, vel, Trvel, Beta, ~, fpa, pitch, params, bank, T, P_Batt, P, SOC, SOC_2, VoltIns, VoltIns_2, Current, Current_2, effprop, CP, CT, t, aoa, RPM, CL, CD)
    
    h = params.sim.h;
    mission_phases = params.mission.phase;
    num_phases = size(mission_phases, 1);
    
    last_plot_time = t(i-1);
    bank(1) = 0;
    % --- Loop through each phase of the mission ---
    for p = 1:num_phases
        phase_type = mission_phases{p, 2}; % 1 for Straight, 2 for Turn
        phase_prop = mission_phases{p, 3};
        phase_rpm = mission_phases{p, 4};
        
        % Store the state at the beginning of the phase
        x_start_phase = xcoor(i-1);
        y_start_phase = ycoor(i-1);
        beta_start_phase = Beta(i-1);

        % --- Define Target Heading for the phase ---
        if phase_type == 2 % Turn
            turn_direction = phase_prop(1); % -1 for left, 1 for right
            turn_angle = phase_prop(2);
            % Calculate the absolute target heading
            target_heading = mod(beta_start_phase + (turn_direction * turn_angle), 360);
        else % Straight
            % For straight legs, the target is to maintain the initial heading
            target_heading = beta_start_phase;
        end

        % --- Inner loop to execute the current phase ---
        while true
            % Allow user to stop simulation from the app
            if app.StopSimulation, disp('Simulation stopped.'); return; end
            
            % --- State at the beginning of the time step (i-1) ---
            current_aoa = pitch(i-1) - fpa(i-1);
            [CD(i-1), CL(i-1), D_unit] = Dragpolar(params, current_aoa, Trvel(i-1));
            
            % --- Control Logic for the current step (i) ---
            
            % LATERAL CONTROL (HEADING)
            % Call the PID controller to get the desired bank angle command.
            % This works for both turning and holding a straight course.


            % LONGITUDINAL CONTROL (ALTITUDE)
            % Call the PID controller to get the desired pitch command.
            pitch(i) = altitude_hold_PID(params, zcoor(i-1), pitch(i-1), h);

            % --- Check for phase completion ---
            if phase_type == 2 % Turn Completion Check
                 bank(i) = heading_hold_PID(params, target_heading, Beta(i-1), bank(i-1), h);
                heading_error = abs(rad2deg(angdiff(deg2rad(Beta(i-1)), deg2rad(target_heading))));
                % End the turn when heading is close to target AND wings are nearly level.
                if heading_error < 1.5 && abs(bank(i-1)) < 1.0
                    bank(i) = 0; % Ensure bank is zeroed for next phase
                    break; 
                end
            else % Straight Leg Completion Check
            bank(i) = bank(i-1);
                distance_flown = sqrt((xcoor(i-1) - x_start_phase)^2 + (ycoor(i-1) - y_start_phase)^2);
                if distance_flown >= phase_prop
                    break;
                end
            end
            
            % --- Dynamics Calculation (using state at i-1) ---
              [VAL] = Rungeforth(params, t(i-1), vel(i-1), fpa(i-1), Beta(i-1), h, current_aoa, T(i-1), CL(i-1), D_unit, bank(i-1), 0, 0);
            vel(i)=VAL(1); fpa(i)=VAL(2); Beta(i)=VAL(3);
            
            % --- Update state for time step i ---
            t(i) = t(i-1) + h;
            aoa(i) = pitch(i) - fpa(i);
            Trvel(i) = vel(i);
            
            x_step=vel(i)*cosd(Beta(i))*cosd(fpa(i))*h; y_step=-vel(i)*sind(Beta(i))*cosd(fpa(i))*h; z_step=vel(i)*sind(fpa(i))*h;
            xcoor(i)=xcoor(i-1)+x_step; ycoor(i)=ycoor(i-1)+y_step; zcoor(i)=zcoor(i-1)+z_step;

            [CD(i),CL(i),D_unit_new]=Dragpolar(params, aoa(i), Trvel(i));
            [P(i),P_Batt(i),T(i),SOC(i),SOC_2(i),VoltIns(i),VoltIns_2(i),effprop(i),CP(i),CT(i),Current(i),Current_2(i),RPM(i),~] = Power(params, Trvel(i),CL(i),D_unit_new,t(1:i),SOC(i-1),SOC_2(i-1),phase_rpm);
            
            % --- Live Plotting ---
            if t(i) - last_plot_time >= 1.0
                res.t=t(1:i); res.xcoor=xcoor(1:i); res.ycoor=ycoor(1:i); res.zcoor=zcoor(1:i);
                res.vel=vel(1:i); res.Trvel=Trvel(1:i); res.fpa=fpa(1:i); res.pitch=pitch(1:i);
                res.Beta=Beta(1:i); res.aoa=aoa(1:i); res.bank=bank(1:i); res.T=T(1:i);
                res.P_Batt=P_Batt(1:i); res.P=P(1:i); res.SOC=SOC(1:i); res.SOC_2=SOC_2(1:i);
                res.VoltIns=VoltIns(1:i); res.VoltIns_2=VoltIns_2(1:i); res.Current=Current(1:i);
                res.Current_2=Current_2(1:i); res.effprop=effprop(1:i); res.CP=CP(1:i);
                res.CT=CT(1:i); res.RPM=RPM(1:i); res.CL=CL(1:i); res.CD=CD(1:i);
                
                app.setSimulationResults(res);
                app.updateAllPlots();
                drawnow;
                last_plot_time = t(i);
            end
            i = i + 1;
        end
    end
end
