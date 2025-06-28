function params = traub_clps_battery(params)
% Fully refactored battery model function.
% It uses the B-spline fitting from the original file and the modular
% input/output structure of the new file, with no global variables or plotting.

    % Unpack necessary parameters from the input struct
    CellNum = params.battery.CellNum;

    % Safely navigate to the battery data folder
    try
        current_dir = pwd;
        cd([current_dir,'\Traub_Batt']);
    catch
        error('The "Traub_Batt" folder was not found in the current directory. Please ensure it is present.');
    end
    
    % Load the raw battery pulse data
    load('6Sbatt_data_10A_mod.mat');
    load('6Sbatt_data_20A_mod.mat');
    load('6Sbatt_data_30A_mod.mat');
    
    % Return to the original directory
    cd(current_dir);

    % Scale the loaded voltage data by the number of cells in the pack
    PulseData_10A.voltage = PulseData_10A.voltage*CellNum;
    PulseData_20A.voltage = PulseData_20A.voltage*CellNum;
    PulseData_30A.voltage = PulseData_30A.voltage*CellNum;
    
    % Define a common State of Charge (SOC) vector for interpolation
    minSOC = max([PulseData_10A.SOC(end) PulseData_20A.SOC(end) PulseData_30A.SOC(end)]);
    maxSOC = min([PulseData_10A.SOC(1) PulseData_20A.SOC(1) PulseData_30A.SOC(1)]);
    SOC = maxSOC:-0.001:minSOC;
    
    % --- Use B-spline least-squares approximation from the original file ---
    % This provides a smoothed fit to the experimental data points.
    
    % 10A data fit
    sp2 = spap2(18,4,PulseData_10A.SOC(:),PulseData_10A.voltage(:));
    sp2 = spap2(newknt(sp2),4,PulseData_10A.SOC(:),PulseData_10A.voltage(:));

    % 20A data fit
    sp1 = spap2(14,4,PulseData_20A.SOC(:),PulseData_20A.voltage(:));
    sp1 = spap2(newknt(sp1),4,PulseData_20A.SOC(:),PulseData_20A.voltage(:));

    % 30A data fit
    sp3 = spap2(32,4,PulseData_30A.SOC(:),PulseData_30A.voltage(:));
    sp3 = spap2(newknt(sp3),4,PulseData_30A.SOC(:),PulseData_30A.voltage(:));

    % Evaluate the spline fits over the common SOC vector
    V1 = fnval(sp2,SOC)'; 
    V2 = fnval(sp1,SOC)'; 
    V3 = fnval(sp3,SOC)';
    
    % --- Perform the Curve Collapse calculation ---
    % Average current values from experimental data
    I1 = 10.2764; I2 = 18.28; I3 = 28.6;
    
    % Define the cost function to find the optimal exponent 'n'
    fun = @(n) ((V1.*I1.^n-((V1.*I1.^n+V2.*I2.^n+V3.*I3.^n)./3))).^2+((V2.*I2.^n-((V1.*I1.^n+V2.*I2.^n+V3.*I3.^n)./3))).^2 + ...
        ((V3.*I3.^n-((V1.*I1.^n+V2.*I2.^n+V3.*I3.^n)./3))).^2;
    
    % Use a non-linear least squares solver to find the exponent
    n0 = 0.05;
    n_curve = lsqnonlin(fun,n0);
    
    % Calculate the "collapsed" voltage curves using the solved exponent
    V1_CLPS = V1.*I1.^n_curve;
    V2_CLPS = V2.*I2.^n_curve;
    V3_CLPS = V3.*I3.^n_curve;
    
    % Average the three collapsed curves to get a single characteristic voltage curve
    AVE_V = mean(horzcat(V1_CLPS,V2_CLPS,V3_CLPS),2);
    
    % --- Create the final fit object for the simulation model ---
    x = SOC';
    y = AVE_V;
    
    % Define the rational polynomial fit type
    ft = fittype('(a+c*x+e*x^2)/(1+b*x+d*x^2+f*x^3)');
    options = fitoptions('Method', 'NonlinearLeastSquares','StartPoint',[1 1 1 1 1 1]);
    
    % Create the final fit object
    Voltage_fit = fit(x,y,ft,options);

    % --- Add the final results back into the params struct ---
    params.battery.Voltage_fit = Voltage_fit;
    params.battery.n_curve = n_curve;

end