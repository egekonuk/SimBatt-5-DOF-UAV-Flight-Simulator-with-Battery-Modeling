function params = create_aero_model(params)
% This function loads aerodynamic data from Excel files, creates fit objects,
% and adds them to the params struct for use in the simulation.

    % --- Find the Aero_Data folder relative to this M-file ---
    try
        app_path = fileparts(mfilename('fullpath'));
        aero_dir = fullfile(app_path, 'Aero_Data');
        cd(aero_dir);
    catch
        error('The "Aero_Data" folder was not found. Please ensure it is in the same directory as your main scripts.');
    end
    
    % --- Read data from Excel files using readmatrix ---
    try
        CD0_data = readmatrix('CD0vsAOA.xlsx');
        CDI_data = readmatrix('CDIvsAOA.xlsx');
        CL_data = readmatrix('CLvsAOA.xlsx');        
        CDI_dataTO = readmatrix('CDIvsAOA_TO.xlsx');
        CL_dataTO = readmatrix('CLvsAOA_TO.xlsx');
    catch ME
        cd(app_path); % Return to original directory before erroring
        rethrow(ME);
    end
    
    cd(app_path); % Return to original directory
    
    % --- Create fit objects based on the loaded data ---
    params.aero.CL_AOA = fit(CL_data(:,1),CL_data(:,2),'pchipinterp');
    params.aero.CDI_AOA = fit(CDI_data(:,1),CDI_data(:,2),'pchipinterp');
    params.aero.CL_AOA_TO = fit(CL_dataTO(:,1),CL_dataTO(:,2),'pchipinterp');
    params.aero.CDI_AOA_TO = fit(CDI_dataTO(:,1),CDI_dataTO(:,2),'pchipinterp');
    % Use a polynomial fit for zero-lift drag vs. velocity, as in the original script
    params.aero.CD0_AOA = fit(CD0_data(2:end,1),CD0_data(2:end,2),'poly5');

    % Store the valid angle of attack domains for bounds checking
    params.aero.domain_AOA = [min(CL_data(:,1)), max(CL_data(:,1))];
    params.aero.domain_AOA_TO = [min(CL_dataTO(:,1)), max(CL_dataTO(:,1))];
    
    disp('Aerodynamic models created successfully from files.');
end