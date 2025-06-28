function prop_data_out = PropMotor(params)
    % This function loads all propeller-related data, including performance
    % data for curve fitting and RPM-vs-throttle data for SELRPM.
    
    % Copy the incoming prop parameters to preserve existing fields like RPMval
    prop_data_out = params.prop;
    
    % --- Robust Path Finding ---
    % Get the path of the directory where this .m file is located
    try
        [base_path, ~, ~] = fileparts(mfilename('fullpath'));
    catch
        % Fallback for older MATLAB versions or specific environments
        base_path = pwd;
    end
    
    % --- Load RPM vs Throttle Data (for SELRPM function) ---
    rpm_dir = fullfile(base_path,'RPMvsV');
    if ~isfolder(rpm_dir)
        error('Could not find the "RPMvsV" folder. It must be in the same directory as your .m files.');
    end
    try
        prop_data_out.RPM_T1 = load(fullfile(rpm_dir, 'RPM_V_1.mat'));
        prop_data_out.RPM_T08 = load(fullfile(rpm_dir, 'RPM_V_08.mat'));
        prop_data_out.RPM_T06 = load(fullfile(rpm_dir, 'RPM_V_06.mat'));
        prop_data_out.RPM_T04 = load(fullfile(rpm_dir, 'RPM_V_04.mat'));
    catch ME
        error('Could not load RPMvsV .mat files. Ensure they exist in the RPMvsV folder. Error: %s', ME.message);
    end

    % --- Find, Load, and Process Propeller Performance Data ---
    s1 = num2str(prop_data_out.PropDiameter);
    s2 = num2str(prop_data_out.PropPitch);
    prop_db_dir = fullfile(base_path, 'UIUC-propDB');
    if ~isfolder(prop_db_dir)
        error('Could not find the "UIUC-propDB" folder. It must be in the same directory as your .m files.');
    end

    prop_files_struct = dir(fullfile(prop_db_dir, ['*_',s1,'x',s2,'_*']));
    if isempty(prop_files_struct)
        error('No propeller data files found for size %sx%s in UIUC-propDB.', s1, s2);
    end
    
    all_filenames = {prop_files_struct.name};
    prop_types = unique(strtok(all_filenames,'_'));
    selected_prop_type = char(prop_types(1));
    fprintf('Selected propeller type: %s\n', selected_prop_type);

    data_files_struct = dir(fullfile(prop_db_dir, [selected_prop_type, '_', s1, 'x', s2, '_*.txt']));
    data_filenames = {data_files_struct.name};
    
    is_static = contains(data_filenames, 'static');
    static_filenames = data_filenames(is_static);
    dynamic_filenames = data_filenames(~is_static);

    % Load static data if it exists (not used in curve fitting but loaded per original logic)
    if ~isempty(static_filenames)
        try
            readpropdata(fullfile(prop_db_dir, static_filenames{1}));
        catch read_err
            warning('Could not read static prop data file: %s. Skipping. Error: %s', static_filenames{1}, read_err.message);
        end
    end
    
    % Load and group dynamic data by RPM
    rpm_values_from_files = zeros(length(dynamic_filenames), 1);
    probdata = cell(length(dynamic_filenames), 1);
    for i = 1:length(dynamic_filenames)
        try
            temp_rpm_str = split(dynamic_filenames{i}, ["_","."]);
            rpm_values_from_files(i) = str2double(temp_rpm_str{4});
            probdata{i} = readpropdata(fullfile(prop_db_dir, dynamic_filenames{i}));
        catch read_err
            warning('Could not read or parse dynamic prop data file: %s. Skipping. Error: %s', dynamic_filenames{i}, read_err.message);
        end
    end
    
    % Group data by rounded RPM values
    rounded_rpms = unique(round(rpm_values_from_files / 1000) * 1000);
    RPMdata = cell(length(rounded_rpms), 1);
    for i = 1:length(rounded_rpms)
        current_rpm = rounded_rpms(i);
        indices = find(abs(rpm_values_from_files - current_rpm) < 500);
        combined_data = [];
        for j = 1:length(indices)
            if ~isempty(probdata{indices(j)})
                combined_data = [combined_data; probdata{indices(j)}];
            end
        end
        RPMdata{i} = combined_data;
    end
    
    % --- Curve Fitting Algorithm ---
    for i = 1:length(RPMdata)
        if isempty(RPMdata{i}), continue; end
        % Delete rows where J (first column) is negative
        RPMdata{i}(RPMdata{i}(:,1) < 0, :) = [];
        % Remove duplicate rows based on J
        [~, ind] = unique(RPMdata{i}(:, 1), 'rows');
        RPMdata{i} = RPMdata{i}(ind,:);
    end
    
    warning('off','curvefit:fit:noStartPoint');
    T_fits=cell(length(RPMdata),1); PP_fits=cell(length(RPMdata),1); ETA_fits=cell(length(RPMdata),1);
    
    for i=1:length(RPMdata)
        if isempty(RPMdata{i}) || size(RPMdata{i},1) < 2, continue; end
        method = 'poly9';
        if size(RPMdata{i},1) < 10, method = 'poly6'; end
        T_fits{i} = fit(RPMdata{i}(:,1),RPMdata{i}(:,2),method);   % Thrust coefficient (CT)
        PP_fits{i} = fit(RPMdata{i}(:,1),RPMdata{i}(:,3),method);  % Power coefficent (CP)
        ETA_fits{i} = fit(RPMdata{i}(:,1),RPMdata{i}(:,4),method); % Propeller efficieny (ETA)
    end
    warning('on','curvefit:fit:noStartPoint');

    % --- Finalize output struct ---
    prop_data_out.RPM_values = rounded_rpms;
    prop_data_out.D = prop_data_out.PropDiameter / 39.37; % Diameter in meters
    prop_data_out.T = T_fits;
    prop_data_out.PP = PP_fits;
    prop_data_out.ETA = ETA_fits;
    
    fprintf('Successfully loaded and fitted models for %d RPM settings.\n', length(rounded_rpms));
end