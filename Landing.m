function [xcoor, ycoor, zcoor, vel, Trvel, fpa, pitch, Beta, bank, T, P_Batt, P, SOC, SOC_2, VoltIns, VoltIns_2, Current, Current_2, effprop, CP, CT, t, aoa, RPM, CL, CD] = ...
         Landing(app, xcoor, ycoor, zcoor, i, vel, Trvel, Beta, ~, fpa, pitch, params, bank, T, P_Batt, P, SOC, SOC_2, VoltIns, VoltIns_2, Current, Current_2, effprop, CP, CT, t, aoa, RPM, CL, CD)

    h = params.sim.h;
    landing_rpm = 2000;
    
    % --- CORRECTED: More robust plotting timer ---
    next_plot_time = floor(t(i-1)) + 1.0;
    
    fprintf('Landing phase initiated.\n');
    
    while zcoor(i-1) > 0.1
        if app.StopSimulation, disp('Simulation stopped.'); return; end

        current_aoa = pitch(i-1) - fpa(i-1);
        [CD(i-1), CL(i-1), D_unit] = Dragpolar(params, current_aoa, Trvel(i-1));
        
        target_fpa = -3.0; % 3-degree descent
        pitch(i) = target_fpa + current_aoa;
        bank(i) = 0;

        [VAL] = Rungeforth(params, t(i-1), vel(i-1), fpa(i-1), Beta(i-1), h, current_aoa, T(i-1), CL(i-1), D_unit, bank(i-1), 0, 0);
        vel(i)=VAL(1); fpa(i)=VAL(2); Beta(i)=VAL(3);
        
        t(i) = t(i-1) + h;
        aoa(i) = pitch(i) - fpa(i);
        Trvel(i) = vel(i);
        
        x_step=vel(i)*cosd(Beta(i))*cosd(fpa(i))*h; y_step=-vel(i)*sind(Beta(i))*cosd(fpa(i))*h; z_step=vel(i)*sind(fpa(i))*h;
        xcoor(i)=xcoor(i-1)+x_step; ycoor(i)=ycoor(i-1)+y_step; zcoor(i)=zcoor(i-1)+z_step;

        [CD(i),CL(i),D_unit_new]=Dragpolar(params, aoa(i), Trvel(i));
        [P(i),P_Batt(i),T(i),SOC(i),SOC_2(i),VoltIns(i),VoltIns_2(i),effprop(i),CP(i),CT(i),Current(i),Current_2(i),RPM(i),~] = Power(params, Trvel(i),CL(i),D_unit_new,t(1:i),SOC(i-1),SOC_2(i-1),landing_rpm);
        
        if t(i) >= next_plot_time
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
            next_plot_time = next_plot_time + 1.0;
        end
        i = i + 1;
    end
    fprintf('Landing complete at Z = %.2f m.\n', zcoor(end));
end