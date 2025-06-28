function [vel,Trvel,fpa,pitch,Beta,Beta_norot,xcoor,ycoor,zcoor,i,todist,aoa,bank,P_Batt,P,SOC,SOC_2,VoltIns,VoltIns_2,Current,Current_2,effprop,CP,CT,T,t,RPM,CL,CD]=Takeoff(app, params)
    
    rho = params.atmosphere.rho;
    W = params.aircraft.W;
    h = params.sim.h;
    
    Velinit = params.initial.Velinit;
    initcoor = params.initial.initcoor;
    aoaTO = params.takeoff.aoaTO;
    muf = params.takeoff.muf;
    
    takeoff_rpm = params.mission.phase{1, 4};
    
    % Initialize vectors
    i=2; 
    t(1)=0;
    vel(1)=Velinit; Trvel(1)=Velinit;
    xcoor(1)=initcoor(1); ycoor(1)=initcoor(2); zcoor(1)=initcoor(3);
    Beta(1)=0; Beta_norot(1)=0;
    aoa(1) = aoaTO; bank(1)=0; fpa(1)=0; pitch(1)=aoaTO;
    RPM(1) = takeoff_rpm;
    
    % Initial aerodynamic and power calculation for t=0
    [CD(1), CL(1), D_unit] = Dragpolar(params, aoa(1), vel(1)); 
    [P(1),P_Batt(1),T(1),SOC(1),SOC_2(1),VoltIns(1),VoltIns_2(1),effprop(1),CP(1),CT(1),Current(1),Current_2(1),~,~] = Power(params, Trvel(1),CL(1),D_unit,t,1,1,RPM(1));  

    while true
        if app.StopSimulation, disp('Simulation stopped.'); return; end
        
        RPM(i) = RPM(i-1);

        [CD(i-1), CL(i-1), D_unit] = Dragpolar(params, aoa(i-1), Trvel(i-1));
        
        [VAL,h]=Rungeforth(params, t(i-1),vel(i-1),fpa(i-1),Beta(i-1),h,aoa(i-1),T(i-1),CL(i-1),D_unit,bank(i-1), muf, 0);
        vel(i) = VAL(1); fpa(i) = VAL(2); Beta(i) = VAL(3); Beta_norot(i) = VAL(4);
        
        % --- CORRECTED: Update time vector inside the loop ---
        t(i) = t(i-1) + h;
        
        pitch(i) = aoaTO + fpa(i); bank(i) = 0;
        Trvel(i) = vel(i); aoa(i) = aoaTO;
        
        x_step = vel(i)*cosd(Beta(i))*cosd(fpa(i))*h;
        y_step = -vel(i)*sind(Beta(i))*cosd(fpa(i))*h;
        z_step = vel(i)*sind(fpa(i))*h;
        xcoor(i) = xcoor(i-1) + x_step; 
        ycoor(i) = ycoor(i-1) + y_step; 
        zcoor(i) = zcoor(i-1) + z_step;
        
        [CD(i),CL(i),D_unit_new]=Dragpolar(params, aoa(i),Trvel(i));
        [P(i),P_Batt(i),T(i),SOC(i),SOC_2(i),VoltIns(i),VoltIns_2(i),effprop(i),CP(i),CT(i),Current(i),Current_2(i),~,~] = Power(params, Trvel(i),CL(i),D_unit_new,t(1:i),SOC(i-1),SOC_2(i-1),RPM(i));      
        
        if fpa(i) > 0.001 && zcoor(i) > 0.1
           todist = xcoor(i);
           fprintf('Take-off successful at %g m/s.\n', Trvel(i));
           break;
        end
       i=i+1;
    end
end