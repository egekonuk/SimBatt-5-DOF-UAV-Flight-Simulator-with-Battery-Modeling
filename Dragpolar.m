function [CD,CL,D_unit]=Dragpolar(params, aoa, Uinf)
    % Calculates total aircraft drag and lift coefficients based on detailed physics.

    % --- Unpack required parameters from the params struct ---
    
    % Atmosphere
    rho = params.atmosphere.rho;
    mu = params.atmosphere.mu;
    
    % Aircraft Geometry
    Srefw = params.aircraft.Srefw;
    Srefvt = params.aircraft.Srefvt;
    Srefht = params.aircraft.Srefht;
    Swetf = params.aircraft.Swetf;
    Sreff = params.aircraft.Sreff;
    LF = params.aircraft.LF;
    DF = params.aircraft.DF;
    
    % Configuration
    gear = params.config.gear;
    flaps = params.config.flaps;
    kappa = params.config.kappa;
    
    % Current State
    isTakeoff = params.initial.TO;
    
    % Aerodynamic Models (from Aero3D.m)
    CD0_AOA_fit = params.aero.CD0_AOA;
    CDI_AOA_fit = params.aero.CDI_AOA;
    CL_AOA_fit = params.aero.CL_AOA;
    CDI_AOA_TO_fit = params.aero.CDI_AOA_TO;
    CL_AOA_TO_fit = params.aero.CL_AOA_TO;

    % --- Start Drag Buildup Calculation ---

    Qf = 1.1; Qlg = 1.5; Qlift = 1.1; 
    
    ReL = rho * Uinf / mu; 

    % 1. Fuselage Drag Calculation
    Ref = ReL * LF;
    Refcut = 38.21 * (LF / kappa)^1.053;
    if Ref > Refcut, Ref = Refcut; end
    
    Xtr_C = 0.05;
    X0_c = 36.9 * (Xtr_C)^0.625 * (1 / Ref)^0.375;
    Cf = 0.074 / (Ref^0.2) * (1 - Xtr_C + X0_c)^0.8;
    
    f = LF / DF;
    FF = 2.939 - 0.7666*f + 0.1328*f^2 - 0.01074*f^3 + 3.275e-4*f^4; 
    Cdf = (Cf * FF * Qf * Swetf) / Sreff;
    
    % 2. Landing Gear Drag Calculation
    if gear == true
        ntire = params.aircraft.ntire;
        Tirewidth = params.aircraft.Tirewidth;
        Tirediameter = params.aircraft.Tirediameter;
        Sfrontal = Tirediameter * Tirewidth;
        Dq = 0.25 * ntire * Sfrontal;
        Dqstrut = 0.05 * ntire * Sfrontal;
        Cdlg = ((Dq + Dqstrut) / Srefw) * Qlg;
    else
        Cdlg = 0;
    end
    
    % 3. Select Aero Model and Domain based on Flight Phase (Takeoff or Flaps Deployed)
    % MODIFIED: Use high-lift/drag model if flaps are deployed OR during takeoff run
    if isTakeoff || flaps
        CDI_fit = CDI_AOA_TO_fit;
        CL_fit = CL_AOA_TO_fit;
        domain = params.aero.domain_AOA_TO;
    else
        CDI_fit = CDI_AOA_fit;
        CL_fit = CL_AOA_fit;
        domain = params.aero.domain_AOA;
    end
    
    % 4. Check if AoA is within the model's domain and issue warning if not
    % if aoa < domain(1) || aoa > domain(2)
    %     warning('Angle of Attack (%g) is outside the model range [%g, %g]; results are extrapolated.', aoa, domain(1), domain(2));
    % end

    % 5. Calculate Total Drag Coefficient (CD)
    CD0_liftsurf = CD0_AOA_fit(Uinf);
    CD0_additive = Cdf + Cdlg;
    CD0 = Qlift * CD0_liftsurf + CD0_additive;
    CDi = CDI_fit(aoa);
    CD = CD0 + CDi;

    % 6. Calculate Lift Coefficient (CL)
    CL = CL_fit(aoa);
    
    % 7. Calculate D_unit (Drag Force Factor)
    D_unit = 0.5 * rho * CD * (Srefw + Srefvt + Srefht);
end