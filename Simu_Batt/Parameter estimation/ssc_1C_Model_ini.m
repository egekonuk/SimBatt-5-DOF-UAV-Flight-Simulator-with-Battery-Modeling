% Temp independent battery Model

clear,clc
%% Lookup Table Breakpoints

SOC_LUT = [0.5 0.6 0.7 0.8 0.9 1]'; % SOC breakpoints (same length to the estimated parameters

%% Battery capacity (matches with the exp battery)
% % Measured by coulomb counting the discharge curve
Capacity = 3.3; %Ampere*hours

%% Table values comes from parameter estimation to experimantal results
% C1_LUT = [10668 ;16023 ;26987;20297;21870;13930;12742];
% % C1_LUT = horzcat(C1_LUT-100,C1_LUT,C1_LUT+100);
% Em_LUT = [3.4972 ;3.5598;3.6304;3.7079;3.9222 ;4.076;4.1928];
% % Em_LUT = horzcat(Em_LUT-1e-1,Em_LUT,Em_LUT+1e-1);
% R0_LUT = [0.0084223 ;0.0084719 ;0.0087373;0.0082857;0.0082289 ;0.0083725 ;0.008290];
% % R0_LUT = horzcat(R0_LUT-1e-3,R0_LUT,R0_LUT+1e-3);
% R1_LUT = [0.003164;0.0023447;0.0024493;0.0015292;0.0022668;0.0018949;0.001764 ];
% % R1_LUT = horzcat(R1_LUT-1e-3,R1_LUT,R1_LUT+1e-3);
% C1_LUT = [12447;18872;40764;18721;33630;18360;23394];
% Em_LUT = [3.5057;3.566;3.6337;3.7127;3.9259;4.0777;4.1928];
% R0_LUT = [0.0085;0.0085;0.0087;0.0082;0.0083;0.0085;0.0085];
% R1_LUT = [0.0029;0.0024;0.0026;0.0016;0.0023;0.0018;0.0017];

%% Initial Conditions

% Charge deficit
Qe_init = 0; % %Ampere*hours


%% Estimated Parameters - Initial starting points before estimation (not needed after estimation)

% Em open-circuit voltage vs SOC
Em = 3.8*ones(size(SOC_LUT)); %Volts

% R0 resistance vs SOC
R0 = 0.01*ones(size(SOC_LUT));%Ohms

% R1 Resistance vs SOC
R1 = 0.005*ones(size(SOC_LUT)); %Ohms

% C1 Capacitance vs SOC
C1 = 10000*ones(size(SOC_LUT)); %Farads

 C1_LUT =C1;  R0_LUT =R0;  Em_LUT =Em; R1_LUT =R1;
%% Load Dataset
 load('6Sbatt_Pulsedata.mat') % temp independent data for estimation
PulseData.current= -PulseData.current;
%load simulink
 open_system('ssc_1C_Model_NT_MATLABfunc_est')



