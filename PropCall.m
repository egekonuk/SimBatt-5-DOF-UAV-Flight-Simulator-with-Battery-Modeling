function [effprop, CP, CT, PropPower, PropThrust, RPM] = PropCall(params, V, RPM)
% Rewritten for robust interpolation between available data points.

    % --- Unpack data from params struct ---
    ETA_fits = params.prop.ETA;
    PP_fits = params.prop.PP;
    T_fits = params.prop.T;
    D = params.prop.D;
    rho = params.atmosphere.rho;

    % Find which RPM cells actually contain data
    available_indices = find(~cellfun('isempty', ETA_fits));
    if isempty(available_indices)
        error('No propeller data was loaded.');
    end

    RPS = RPM / 60;
    J = V / (RPS * D);

    % --- Find bounding data points ---
    % Find the closest available data point below the current RPM
    lower_idx = find(available_indices*1000 <= RPM, 1, 'last');
    % Find the closest available data point above the current RPM
    higher_idx = find(available_indices*1000 >= RPM, 1, 'first');

    if isempty(lower_idx)
        lower_idx = higher_idx; % If below all data, use the lowest available data
    end
    if isempty(higher_idx)
        higher_idx = lower_idx; % If above all data, use the highest available data
    end
    
    % Get the actual index from the list of available indices
    idx_low = available_indices(lower_idx);
    idx_high = available_indices(higher_idx);
    
    rpm_low = idx_low * 1000;
    rpm_high = idx_high * 1000;

    % --- Interpolate or Extrapolate ---
    if idx_low == idx_high % We are on or outside the bounds, no interpolation
        effprop = ETA_fits{idx_low}(J);
        CP = PP_fits{idx_low}(J);
        CT = T_fits{idx_low}(J);
    else
        % Linear interpolation factor
        factor = (RPM - rpm_low) / (rpm_high - rpm_low);
        
        val_low_eta = ETA_fits{idx_low}(J);
        val_high_eta = ETA_fits{idx_high}(J);
        effprop = val_low_eta + factor * (val_high_eta - val_low_eta);

        val_low_cp = PP_fits{idx_low}(J);
        val_high_cp = PP_fits{idx_high}(J);
        CP = val_low_cp + factor * (val_high_cp - val_low_cp);

        val_low_ct = T_fits{idx_low}(J);
        val_high_ct = T_fits{idx_high}(J);
        CT = val_low_ct + factor * (val_high_ct - val_low_ct);
    end

    % --- Final Power and Thrust Calculation ---
    PropPower = CP * rho * RPS^3 * D^5;
    PropThrust = CT * rho * RPS^2 * D^4;
end