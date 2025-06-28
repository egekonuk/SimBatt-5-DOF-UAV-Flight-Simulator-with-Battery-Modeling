function [bank, rturn, tc] = Turn(params, vel, bank, T, Cmd_HDG, turnrate, Beta, Dir, tc, h)
% Refactored to read all parameters from the params struct.

    % --- Unpack constants from params struct ---
    W = params.aircraft.W;
    bankrate = params.sim.bankrate;
    t1 = params.sim.t1;  %<-- CORRECTED: Use param from UI
    g = params.atmosphere.g;
    % h = params.sim.h;
        clcdmax = 0;
    for aoa_sample = -11.5:0.1:11
        [CD_sample, CL_sample, ~] = Dragpolar(params, aoa_sample, vel); 
        if CD_sample > 0
            CC = CL_sample/CD_sample;
            if CC > clcdmax
               clcdmax = CC;
            end
        end
    end
    
    % max load factor 
    nmax_ref = (T/W) * clcdmax;
    nmax_str = 1 / cosd(45); % 45deg structural bank limit
    nmax = min(nmax_ref, nmax_str);
    
    % current load factor
    n = 1 / cosd(bank);
    
    % current turn rate
    if turnrate ~= 0
        rturn = vel / turnrate;
    else
        rturn = 0;
    end
    
    if n >= nmax
        warning('Maximum Load factor limit reached: Bank = %g', bank);
        return;
    end
    
    % change bank angle according to the turn direction
    if Dir == 1 % left turn
        bankrateN = -bankrate * h;
    else % right turn
        bankrateN = bankrate * h;
    end
    
    % --- control the bank angle to match the correct turn (autopiloting) ---
    diff_head = rad2deg(angdiff(deg2rad(Beta), deg2rad(Cmd_HDG)));
    
    bank_cmd = vel / (t1 * g) * diff_head;
    
    % Autopilot logic from original file
    if abs(bank_cmd) > abs(bank + bankrateN)
        bank = bank + bankrateN; 
    elseif abs(bank_cmd) < 2 || tc == 1
        tc = 1; % Entering turn completion/stabilization phase
        if abs(bank) >= abs(bank_cmd + (t1/3.5) * bankrateN)
            bank = bank - bankrateN; 
        elseif abs(abs(bank) - abs(bank_cmd)) < abs(bankrateN)
            if bank_cmd < 0 
                bank = ceil(bank_cmd);
            else
                bank = floor(bank_cmd);
            end           
        end
    end
end