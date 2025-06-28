classdef FlightSimGUI < matlab.apps.AppBase

    % Properties that correspond to app components
  properties (Access = public)
        UIFigure, GridLayout, LeftPanel, RightPanel
        TabGroup
        GeneralTab, BatteryTab, SimulationTab, ConfigMissionTab
        
        MassEditField, SrefwEditField, bEditField, ChordwEditField, TaperwEditField, tcwEditField, incwEditField
        SrefvtEditField, bVTEditField, ChordvtEditField, tcvtEditField, TaperVTEditField, incVTEditField
        SrefhtEditField, bHTEditField, ChordhtEditField, tchtEditField, TaperHTEditField, incHTEditField
        LFEditField, DFEditField, SwetfEditField, SreffEditField, KappaEditField
        ntireEditField, TireWidthEditField, TirediameterEditField
        
        BattCapEditField, BattCellsEditField
        IntResEditField, NoLoadIEditField, KvEditField, MaxMotorRPMEditField, MaxAmpEditField

        TimeStepEditField, RKLookAheadEditField, RPMRateEditField, SimulinkStepEditField, RKToleranceEditField 
        InitXEditField, InitYEditField, InitSpeedEditField
        TakeoffCheckBox, TakeoffAoAEditField, mufEditField
        
        CmdPitchEditField, PitchRateEditField, BankRateEditField, t1EditField 
        
        CruiseHghtEditField
        PropBrandDropDown, PropSizeDropDown
        GearCheckBox, FlapsCheckBox
        
        MissionTable matlab.ui.control.Table
        LandingCheckBox
        AddSegmentButton, DeleteSegmentButton
        
        SimulinkCheckBox, RunSimulationButton, ExitSimulationButton
        
        UIAxes_Trajectory, UIAxes_Coefficients, UIAxes_PropEff, UIAxes_PropRPM
        UIAxes_Current, UIAxes_FlightAngles, UIAxes_AirSpeed, UIAxes_BankAngle
        UIAxes_Power, UIAxes_SOC, UIAxes_Voltage, UIAxes_Thrust
        
        StopSimulation (1,1) logical = false
    end

    % Private properties to store simulation data and propeller DB
    properties (Access = private)
        SimParams, SimResults
        MissionTableSelection = []
        PropDataDB          % Database of available propellers
    end
    
    methods (Access = private)
        function startupFcn(app)
            % This function runs once when the app starts up, after components are created.
            % Load the propeller database from files.
            app.loadPropellerData();
            % Populate the UI dropdowns with the loaded data.
            app.populatePropUI();
        end
        % This method programmatically creates all UI components
        function createComponents(app)
            app.UIFigure = uifigure('Visible', 'off', 'Position', [100 100 1400 900], 'Name', '5-DOF Flight Simulation');
            % app.UIFigure.StartupFcn = createCallbackFcn(app, @startupFcn, true);
            app.GridLayout = uigridlayout(app.UIFigure, 'ColumnWidth', {420, '1x'}, 'RowHeight', {'1x'});
            
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1; app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.Title = 'Simulation Parameters';
            app.LeftPanel.FontWeight = 'bold';
            
            leftGridLayout = uigridlayout(app.LeftPanel, 'ColumnWidth', {'1x'}, 'RowHeight', {'1x', 'fit', 'fit'});
            app.TabGroup = uitabgroup(leftGridLayout);
            app.TabGroup.Layout.Row = 1; app.TabGroup.Layout.Column = 1;

            % --- TAB 1: General & Dimensions ---
            app.GeneralTab = uitab(app.TabGroup, 'Title', 'General & Dimensions');
            tab1_Grid = uigridlayout(app.GeneralTab, 'ColumnWidth', {'1x'}, 'RowHeight', repmat({'fit'},1,4), 'RowSpacing', 2, 'Padding', [5 5 5 5]);
            
            p1 = uipanel(tab1_Grid, 'Title', 'Wing & Mass');
            p1.Layout.Row=1; p1_Grid = uigridlayout(p1, 'ColumnWidth',{'fit','1x'}, 'RowHeight',repmat({'fit'},1,7), 'Padding', [2 2 2 2], 'RowSpacing', 2);
            uilabel(p1_Grid, 'Text', 'Total Mass (kg):'); app.MassEditField = uieditfield(p1_Grid, 'numeric', 'Value', 3.3415);
            uilabel(p1_Grid, 'Text', 'Ref. Area (Srefw m^2):'); app.SrefwEditField = uieditfield(p1_Grid, 'numeric', 'Value', 0.433);
            uilabel(p1_Grid, 'Text', 'Span (b m):'); app.bEditField = uieditfield(p1_Grid, 'numeric', 'Value', 1.587);
            uilabel(p1_Grid, 'Text', 'Chord (m):'); app.ChordwEditField = uieditfield(p1_Grid, 'numeric', 'Value', 0.273);
            uilabel(p1_Grid, 'Text', 'Taper Ratio:'); app.TaperwEditField = uieditfield(p1_Grid, 'numeric', 'Value', 1);
            uilabel(p1_Grid, 'Text', 'Airfoil Thickness/Chord:'); app.tcwEditField = uieditfield(p1_Grid, 'numeric', 'Value', 0.1452);
            uilabel(p1_Grid, 'Text', 'Incidence Angle (deg):'); app.incwEditField = uieditfield(p1_Grid, 'numeric', 'Value', 3.58);

            p2 = uipanel(tab1_Grid, 'Title', 'Vertical Tail');
            p2.Layout.Row=2; p2_Grid = uigridlayout(p2, 'ColumnWidth',{'fit','1x'}, 'RowHeight',repmat({'fit'},1,6), 'Padding', [2 2 2 2], 'RowSpacing', 2);
            uilabel(p2_Grid, 'Text', 'VT Ref. Area (m^2):'); app.SrefvtEditField = uieditfield(p2_Grid, 'numeric', 'Value', 0.04);
            uilabel(p2_Grid, 'Text', 'VT Span (m):'); app.bVTEditField = uieditfield(p2_Grid, 'numeric', 'Value', 0.4);
            uilabel(p2_Grid, 'Text', 'VT Chord (m):'); app.ChordvtEditField = uieditfield(p2_Grid, 'numeric', 'Value', 0.18);
            uilabel(p2_Grid, 'Text', 'VT Taper Ratio:'); app.TaperVTEditField = uieditfield(p2_Grid, 'numeric', 'Value', 2.88);
            uilabel(p2_Grid, 'Text', 'VT Thickness/Chord:'); app.tcvtEditField = uieditfield(p2_Grid, 'numeric', 'Value', 0.08);
            uilabel(p2_Grid, 'Text', 'VT Incidence (deg):'); app.incVTEditField = uieditfield(p2_Grid, 'numeric', 'Value', 2.36);

            p3 = uipanel(tab1_Grid, 'Title', 'Horizontal Tail');
            p3.Layout.Row=3; p3_Grid = uigridlayout(p3, 'ColumnWidth',{'fit','1x'}, 'RowHeight',repmat({'fit'},1,6), 'Padding', [2 2 2 2], 'RowSpacing', 2);
            uilabel(p3_Grid, 'Text', 'HT Ref. Area (m^2):'); app.SrefhtEditField = uieditfield(p3_Grid, 'numeric', 'Value', 0.0931);
            uilabel(p3_Grid, 'Text', 'HT Span (m):'); app.bHTEditField = uieditfield(p3_Grid, 'numeric', 'Value', 0.58);
            uilabel(p3_Grid, 'Text', 'HT Chord (m):'); app.ChordhtEditField = uieditfield(p3_Grid, 'numeric', 'Value', 0.16);
            uilabel(p3_Grid, 'Text', 'HT Taper Ratio:'); app.TaperHTEditField = uieditfield(p3_Grid, 'numeric', 'Value', 1.91);
            uilabel(p3_Grid, 'Text', 'HT Thickness/Chord:'); app.tchtEditField = uieditfield(p3_Grid, 'numeric', 'Value', 0.08);
            uilabel(p3_Grid, 'Text', 'HT Incidence (deg):'); app.incHTEditField = uieditfield(p3_Grid, 'numeric', 'Value', 2.36);

            p4 = uipanel(tab1_Grid, 'Title', 'Fuselage & Gear');
            p4.Layout.Row=4; p4_Grid = uigridlayout(p4, 'ColumnWidth',{'fit','1x'}, 'RowHeight',repmat({'fit'},1,8), 'Padding', [2 2 2 2], 'RowSpacing', 2);
            uilabel(p4_Grid, 'Text', 'Length (m):'); app.LFEditField = uieditfield(p4_Grid, 'numeric', 'Value', 1.2954);
            uilabel(p4_Grid, 'Text', 'Avg. Diameter (m):'); app.DFEditField = uieditfield(p4_Grid, 'numeric', 'Value', 0.127);
            uilabel(p4_Grid, 'Text', 'Wetted Area (m^2):'); app.SwetfEditField = uieditfield(p4_Grid, 'numeric', 'Value', 0.6);
            uilabel(p4_Grid, 'Text', 'Ref. Area (m^2):'); app.SreffEditField = uieditfield(p4_Grid, 'numeric', 'Value', 0.115161);
            uilabel(p4_Grid, 'Text', 'Number of Tires:'); app.ntireEditField = uieditfield(p4_Grid, 'numeric', 'Value', 3);
            uilabel(p4_Grid, 'Text', 'Tire Width (m):'); app.TireWidthEditField = uieditfield(p4_Grid, 'numeric', 'Value', 0.01);
            uilabel(p4_Grid, 'Text', 'Tire Diameter (m):'); app.TirediameterEditField = uieditfield(p4_Grid, 'numeric', 'Value', 0.03);
            uilabel(p4_Grid, 'Text', 'Skin Roughness (kappa):'); app.KappaEditField = uieditfield(p4_Grid, 'numeric', 'Value', 1.2e-5, 'ValueDisplayFormat', '%.2e');

            % --- TAB 2: Battery & Motor ---
            app.BatteryTab = uitab(app.TabGroup, 'Title', 'Battery & Motor');
            tab2_Grid = uigridlayout(app.BatteryTab, 'ColumnWidth', {'1x'}, 'RowHeight', {'fit', 'fit'}, 'Padding', [5 5 5 5]);
            p_batt = uipanel(tab2_Grid, 'Title', 'Battery Specifications');
            p_batt.Layout.Row=1; p_batt_Grid = uigridlayout(p_batt, 'ColumnWidth',{'fit','1x'}, 'RowHeight',repmat({'fit'},1,2));
            uilabel(p_batt_Grid, 'Text', 'Capacity (Ah):'); app.BattCapEditField = uieditfield(p_batt_Grid, 'numeric', 'Value', 5.0);
            uilabel(p_batt_Grid, 'Text', 'Number of Cells (Series):'); app.BattCellsEditField = uieditfield(p_batt_Grid, 'numeric', 'Value', 6);
            p_motor = uipanel(tab2_Grid, 'Title', 'Motor Specifications');
            p_motor.Layout.Row=2; p_motor_Grid = uigridlayout(p_motor, 'ColumnWidth',{'fit','1x'}, 'RowHeight',repmat({'fit'},1,4));
            uilabel(p_motor_Grid, 'Text', 'Internal Resistance (Ohms):'); app.IntResEditField = uieditfield(p_motor_Grid, 'numeric', 'Value', 0.04);
            uilabel(p_motor_Grid, 'Text', 'No-Load Current (Amps):'); app.NoLoadIEditField = uieditfield(p_motor_Grid, 'numeric', 'Value', 4.6);
            uilabel(p_motor_Grid, 'Text', 'Kv Rating (RPM/Volt):'); app.KvEditField = uieditfield(p_motor_Grid, 'numeric', 'Value', 800);
            uilabel(p_motor_Grid, 'Text', 'Max Motor RPM:'); app.MaxMotorRPMEditField = uieditfield(p_motor_Grid, 'numeric', 'Value', 17000);
            uilabel(p_motor_Grid, 'Text', 'Max Amperage (Amps):'); app.MaxAmpEditField = uieditfield(p_motor_Grid, 'numeric', 'Value', 60); % Added this field back

            % --- TAB 3: Simulation ---
            app.SimulationTab = uitab(app.TabGroup, 'Title', 'Simulation');
            tab3_Grid = uigridlayout(app.SimulationTab, 'ColumnWidth', {'1x'}, 'RowHeight', repmat({'fit'},1,3));
            p5 = uipanel(tab3_Grid, 'Title', 'Initial & Takeoff Conditions');
            p5.Layout.Row=1; p5_Grid = uigridlayout(p5, 'ColumnWidth',{'fit','1x'}, 'RowHeight',repmat({'fit'},1,5));
            uilabel(p5_Grid, 'Text', 'Initial X (m):'); app.InitXEditField = uieditfield(p5_Grid, 'numeric', 'Value', 0);
            uilabel(p5_Grid, 'Text', 'Initial Y (m):'); app.InitYEditField = uieditfield(p5_Grid, 'numeric', 'Value', 0);
            uilabel(p5_Grid, 'Text', 'Initial Speed (m/s):'); app.InitSpeedEditField = uieditfield(p5_Grid, 'numeric', 'Value', 0.01);
            app.TakeoffCheckBox = uicheckbox(p5_Grid, 'Text', 'Perform Take-Off', 'Value', true);
            app.TakeoffCheckBox.Layout.Column = [1,2];
            uilabel(p5_Grid, 'Text', 'Take-Off AoA (deg):'); app.TakeoffAoAEditField = uieditfield(p5_Grid, 'numeric', 'Value', 1);
            uilabel(p5_Grid, 'Text', 'Runway Friction Coeff:'); app.mufEditField = uieditfield(p5_Grid, 'numeric', 'Value', 0.04);
            
            p6 = uipanel(tab3_Grid, 'Title', 'Flight Control');
            p6.Layout.Row=2; p6_Grid = uigridlayout(p6, 'ColumnWidth',{'fit','1x'}, 'RowHeight',repmat({'fit'},1,4)); %<-- Increased rows to 4
            uilabel(p6_Grid, 'Text', 'Commanded Pitch (deg):'); app.CmdPitchEditField = uieditfield(p6_Grid, 'numeric', 'Value', 8);
            uilabel(p6_Grid, 'Text', 'Pitch Rate (deg/s):'); app.PitchRateEditField = uieditfield(p6_Grid, 'numeric', 'Value', 1.8);
            uilabel(p6_Grid, 'Text', 'Bank Rate (deg/s):'); app.BankRateEditField = uieditfield(p6_Grid, 'numeric', 'Value', 8);
            uilabel(p6_Grid, 'Text', 'Turn Time Constant (s):'); app.t1EditField = uieditfield(p6_Grid, 'numeric', 'Value', 20); %<-- ADDED UI FIELD
            
            p7 = uipanel(tab3_Grid, 'Title', 'Solver Settings');
            p7.Layout.Row=3; p7_Grid = uigridlayout(p7, 'ColumnWidth',{'fit','1x'}, 'RowHeight',repmat({'fit'},1,5)); % Increased rows
            uilabel(p7_Grid, 'Text', 'Time Step (s):'); app.TimeStepEditField = uieditfield(p7_Grid, 'numeric', 'Value', 0.02);
            uilabel(p7_Grid, 'Text', 'RK Look-Ahead (s):'); app.RKLookAheadEditField = uieditfield(p7_Grid, 'numeric', 'Value', 0.5);
            uilabel(p7_Grid, 'Text', 'RK Tolerance:'); app.RKToleranceEditField = uieditfield(p7_Grid, 'numeric', 'Value', 1e-13, 'ValueDisplayFormat', '%.2e'); % Added back
            uilabel(p7_Grid, 'Text', 'RPM Ramp Rate (RPM/sec):'); app.RPMRateEditField = uieditfield(p7_Grid, 'numeric', 'Value', 2000);
            uilabel(p7_Grid, 'Text', 'Simulink Step Disp:'); app.SimulinkStepEditField = uieditfield(p7_Grid, 'numeric', 'Value', 10);

            % --- TAB 4: Configuration & Mission ---
            app.ConfigMissionTab = uitab(app.TabGroup, 'Title', 'Config & Mission');
            tab4_Grid = uigridlayout(app.ConfigMissionTab, 'ColumnWidth', {'1x'}, 'RowHeight', {'fit', '1x'});
            
            p8 = uipanel(tab4_Grid, 'Title', 'Propeller & Flight Configuration');
            p8.Layout.Row=1; p8_Grid = uigridlayout(p8, 'ColumnWidth',{'fit','1x'}, 'RowHeight',repmat({'fit'},1,5));
            uilabel(p8_Grid, 'Text', 'Prop Brand:'); app.PropBrandDropDown = uidropdown(p8_Grid, 'Items', {'N/A'}, 'ValueChangedFcn', createCallbackFcn(app, @PropBrandChanged, true));
            uilabel(p8_Grid, 'Text', 'Prop Size:'); app.PropSizeDropDown = uidropdown(p8_Grid, 'Items', {'N/A'}, 'ValueChangedFcn', createCallbackFcn(app, @PropSizeChanged, true));
            app.GearCheckBox = uicheckbox(p8_Grid, 'Text', 'Landing Gear Deployed', 'Value', true);
            app.GearCheckBox.Layout.Column = [1,2];
            app.FlapsCheckBox = uicheckbox(p8_Grid, 'Text', 'Flaps Deployed', 'Value', false);
            app.FlapsCheckBox.Layout.Column = [1,2];
            uilabel(p8_Grid, 'Text', 'Cruise Altitude (m):'); app.CruiseHghtEditField = uieditfield(p8_Grid, 'numeric', 'Value', 500);

            p_mission = uipanel(tab4_Grid, 'Title', 'Mission Profile');
            p_mission.Layout.Row = 2; mission_Grid = uigridlayout(p_mission, 'ColumnWidth', {'1x'}, 'RowHeight', {'1x', 'fit'});
            app.MissionTable = uitable(mission_Grid);
            app.MissionTable.Layout.Row=1; app.MissionTable.ColumnEditable=[false, true, true, true]; app.MissionTable.ColumnWidth={'fit', 'auto', '2x', '1x'};
            app.MissionTable.ColumnName = {'Seg #'; 'Type (1=Str, 2=Trn)'; 'Property (m or [Dir,deg])'; 'RPM'};
            app.MissionTable.Data = {1, 1, '200', 8000; 2, 2, '[1, 180]', 8000; 3, 1, '200', 8000};
            app.MissionTable.SelectionChangedFcn = createCallbackFcn(app, @MissionTableSelectionChanged, true);
            
            mission_button_grid = uigridlayout(mission_Grid, 'ColumnWidth',{'1x','1x','1x'}, 'RowHeight',{'fit'});
            mission_button_grid.Layout.Row=2;
            app.AddSegmentButton = uibutton(mission_button_grid, 'push', 'Text', 'Add', 'ButtonPushedFcn', createCallbackFcn(app, @AddSegmentButtonPushed, true));
            app.DeleteSegmentButton = uibutton(mission_button_grid, 'push', 'Text', 'Delete', 'ButtonPushedFcn', createCallbackFcn(app, @DeleteSegmentButtonPushed, true));
            app.LandingCheckBox = uicheckbox(mission_button_grid, 'Text', 'Perform Landing', 'Value', true);
            
            app.SimulinkCheckBox = uicheckbox(leftGridLayout, 'Text', 'Use Simulink Battery Model');
            app.SimulinkCheckBox.Layout.Row = 2;
            
            buttonGrid = uigridlayout(leftGridLayout, 'ColumnWidth',{'1x','1x'}, 'RowHeight',{'1x'}, 'Padding',[0 10 0 10]);
            buttonGrid.Layout.Row = 3;
            app.RunSimulationButton = uibutton(buttonGrid, 'push', 'Text', 'Run Simulation', 'FontWeight', 'bold', 'ButtonPushedFcn', createCallbackFcn(app, @RunSimulationButtonPushed, true));
            app.ExitSimulationButton = uibutton(buttonGrid, 'push', 'Text', 'Exit', 'FontWeight', 'bold', 'FontColor', [0.85 0 0], 'ButtonPushedFcn', createCallbackFcn(app, @ExitSimulationButtonPushed, true));

            % --- Right Panel ---
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row=1; app.RightPanel.Layout.Column=2;
            app.RightPanel.Title = 'Simulation Results'; app.RightPanel.FontWeight = 'bold';
            rightGridLayout = uigridlayout(app.RightPanel, 'ColumnWidth', {'1x', '1x', '1x', '1x'}, 'RowHeight', {'1x', '1x', '1x'});
            app.UIAxes_Trajectory=uiaxes(rightGridLayout); app.UIAxes_Trajectory.Layout.Row=1; app.UIAxes_Trajectory.Layout.Column=1;
            app.UIAxes_Coefficients=uiaxes(rightGridLayout); app.UIAxes_Coefficients.Layout.Row=1; app.UIAxes_Coefficients.Layout.Column=2;
            app.UIAxes_PropEff=uiaxes(rightGridLayout); app.UIAxes_PropEff.Layout.Row=1; app.UIAxes_PropEff.Layout.Column=3;
            app.UIAxes_PropRPM=uiaxes(rightGridLayout); app.UIAxes_PropRPM.Layout.Row=1; app.UIAxes_PropRPM.Layout.Column=4;
            app.UIAxes_Current=uiaxes(rightGridLayout); app.UIAxes_Current.Layout.Row=2; app.UIAxes_Current.Layout.Column=1;
            app.UIAxes_FlightAngles=uiaxes(rightGridLayout); app.UIAxes_FlightAngles.Layout.Row=2; app.UIAxes_FlightAngles.Layout.Column=2;
            app.UIAxes_AirSpeed=uiaxes(rightGridLayout); app.UIAxes_AirSpeed.Layout.Row=2; app.UIAxes_AirSpeed.Layout.Column=3;
            app.UIAxes_BankAngle=uiaxes(rightGridLayout); app.UIAxes_BankAngle.Layout.Row=2; app.UIAxes_BankAngle.Layout.Column=4;
            app.UIAxes_Power=uiaxes(rightGridLayout); app.UIAxes_Power.Layout.Row=3; app.UIAxes_Power.Layout.Column=1;
            app.UIAxes_SOC=uiaxes(rightGridLayout); app.UIAxes_SOC.Layout.Row=3; app.UIAxes_SOC.Layout.Column=2;
            app.UIAxes_Voltage=uiaxes(rightGridLayout); app.UIAxes_Voltage.Layout.Row=3; app.UIAxes_Voltage.Layout.Column=3;
            app.UIAxes_Thrust=uiaxes(rightGridLayout); app.UIAxes_Thrust.Layout.Row=3; app.UIAxes_Thrust.Layout.Column=4;
            
            app.UIFigure.Visible = 'on';
            
            app.populatePropUI();
        end
        
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % Propeller Data Loading and UI Callbacks
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        function loadPropellerData(app)
            % --- ROBUST PATHING LOGIC ---
            app_path = fileparts(mfilename('fullpath'));
            prop_dir = fullfile(app_path, 'Prop_Data');

            if ~exist(prop_dir, 'dir')
                warning('Propeller data directory not found at: %s\nPropeller selection will be disabled.', prop_dir);
                app.PropDataDB = table();
                return;
            end
            
            files = dir(fullfile(prop_dir, '*.txt'));
            if isempty(files)
                warning('No .txt files found in %s.', prop_dir);
                app.PropDataDB = table();
                return;
            end
            
            propList = struct('Brand', {}, 'Size', {}, 'RPM', {}, 'File', {});
            
            for k = 1:length(files)
                fname = files(k).name;
                parts = split(fname, '_');
                % --- MODIFIED: Handle 4-part filename ---
                if length(parts) == 4
                    brand = parts{1};
                    size_str = parts{2};
                    % Part 3 is ignored as per the new format
                    rpm_str = erase(parts{4}, '.txt');
                    rpm = str2double(rpm_str);
                    
                    if ~isnan(rpm)
                        newEntry.Brand = string(brand);
                        newEntry.Size = string(size_str);
                        newEntry.RPM = rpm;
                        newEntry.File = string(fullfile(prop_dir, fname));
                        propList(end+1) = newEntry;
                    end
                end
            end
            app.PropDataDB = struct2table(propList);
            disp('Propeller database loaded successfully.');
            disp(app.PropDataDB);
        end
        
        function populatePropUI(app)
            if isempty(app.PropDataDB) || height(app.PropDataDB) == 0
                return;
            end
            
            uniqueBrands = unique(app.PropDataDB.Brand);
            app.PropBrandDropDown.Items = cellstr(uniqueBrands);
            
            app.PropBrandChanged();
        end

        function PropBrandChanged(app, event)
            if isempty(app.PropDataDB) || height(app.PropDataDB) == 0, return; end
            
            selectedBrand = string(app.PropBrandDropDown.Value);
            
            % --- CORRECTED with strcmp ---
            sizesForBrand = unique(app.PropDataDB.Size(strcmp(app.PropDataDB.Brand, selectedBrand)));
            
            if ~isempty(sizesForBrand)
                app.PropSizeDropDown.Items = cellstr(sizesForBrand);
                app.PropSizeDropDown.Value = sizesForBrand(1); % Select first available size
            else
                app.PropSizeDropDown.Items = {'N/A'};
            end
            app.PropSizeChanged();
        end
        
        function PropSizeChanged(app, event)
            if isempty(app.PropDataDB) || height(app.PropDataDB) == 0, return; end
            
            selectedBrand = string(app.PropBrandDropDown.Value);
            selectedSize = string(app.PropSizeDropDown.Value);
            
            % --- CORRECTED with strcmp ---
            idx = strcmp(app.PropDataDB.Brand, selectedBrand) & strcmp(app.PropDataDB.Size, selectedSize);
            rpmsForProp = sort(app.PropDataDB.RPM(idx));
            
            if ~isempty(rpmsForProp)
                fprintf('Available RPM data for %s %s: %s\n', selectedBrand, selectedSize, num2str(rpmsForProp'));
            end
        end

        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % Main Simulation Callbacks and Logic
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        function RunSimulationButtonPushed(app, event)
            app.clearAllPlots();
            app.RunSimulationButton.Enable = 'off';
            app.RunSimulationButton.Text = 'Running...';
            drawnow;

            try
                app.SimParams = app.gatherInputParameters();
                app.SimParams = traub_clps_battery(app.SimParams);
                app.SimParams = create_aero_model(app.SimParams);

                % --- CORRECTED: Calculate clcdmax AFTER aero models are created ---
                clcdmax = 0;
                vel_for_clcd = 25; % Representative velocity in m/s
                for aoa_sample = -5:0.5:12
                    [CD_sample, CL_sample, ~] = Dragpolar(app.SimParams, aoa_sample, vel_for_clcd); 
                    if CD_sample > 0
                        CC = CL_sample/CD_sample;
                        if CC > clcdmax
                           clcdmax = CC;
                        end
                    end
                end
                app.SimParams.aircraft.clcdmax = clcdmax;
                fprintf('Pre-calculated clcdmax: %f\n', clcdmax);

                app.StopSimulation = false;
                app.SimResults = app.runFlightSimulation(app.SimParams);
                
                if ~app.StopSimulation && ~isempty(app.SimResults)
                    app.updateAllPlots();
                end
                
            catch ME
                uialert(app.UIFigure, ME.message, 'Simulation Error', 'Icon', 'error');
                disp(getReport(ME, 'extended', 'hyperlinks', 'on'));
            end

            app.RunSimulationButton.Enable = 'on';
            app.RunSimulationButton.Text = 'Run Simulation';
        end

        function ExitSimulationButtonPushed(app, event)
            app.StopSimulation = true;
            delete(app);
        end

        function MissionTableSelectionChanged(app, event)
            app.MissionTableSelection = event.Selection;
        end

        function AddSegmentButtonPushed(app, event)
            currentData = app.MissionTable.Data;
            newRowNum = size(currentData, 1) + 1;
            newRow = {newRowNum, 1, '5000', 9000};
            app.MissionTable.Data = [currentData; newRow];
        end

        function DeleteSegmentButtonPushed(app, event)
            if ~isempty(app.MissionTableSelection)
                selectedRows = unique(app.MissionTableSelection(:,1));
                currentData = app.MissionTable.Data;
                currentData(selectedRows, :) = [];
                
                for i = 1:size(currentData,1)
                    currentData{i,1} = i;
                end
                
                app.MissionTable.Data = currentData;
                app.MissionTableSelection = [];
            end
        end
        
        function params = gatherInputParameters(app)
            params = struct();
            params.aircraft=struct(); params.initial=struct(); params.prop=struct();
            params.takeoff=struct(); params.sim=struct(); params.atmosphere=struct();
            params.mission=struct(); params.battery=struct(); params.plots=struct();
            params.config=struct(); params.aero=struct(); params.motor=struct();

            % This function now ONLY gathers values from the UI.
            % All model creation is handled by other functions.

            params.atmosphere.rho = 1.2025; 
            params.atmosphere.g = 9.79893; 
            params.atmosphere.mu = 1.80588E-05;
            
            params.aircraft.Srefw = app.SrefwEditField.Value;
            params.aircraft.Srefvt = app.SrefvtEditField.Value;
            params.aircraft.Srefht = app.SrefhtEditField.Value;
            params.aircraft.LF = app.LFEditField.Value;
            params.aircraft.DF = app.DFEditField.Value;
            params.aircraft.Swetf = app.SwetfEditField.Value;
            params.aircraft.Sreff = app.SreffEditField.Value;
            params.aircraft.ntire = app.ntireEditField.Value;
            params.aircraft.Tirewidth = app.TireWidthEditField.Value;
            params.aircraft.Tirediameter = app.TirediameterEditField.Value;
            params.config.kappa = app.KappaEditField.Value;
            params.config.gear = app.GearCheckBox.Value;
            params.config.flaps = app.FlapsCheckBox.Value;
            
            params.aircraft.mtot = app.MassEditField.Value;       
            params.aircraft.W = params.aircraft.mtot * params.atmosphere.g;
            params.aircraft.b = app.bEditField.Value;
            params.aircraft.Chordw = app.ChordwEditField.Value;
            params.aircraft.Taperw = app.TaperwEditField.Value;
            params.aircraft.tcw = app.tcwEditField.Value;
            params.aircraft.incw = app.incwEditField.Value;
            params.aircraft.bVT = app.bVTEditField.Value;
            params.aircraft.Chordvt = app.ChordvtEditField.Value;
            params.aircraft.TaperVT = app.TaperVTEditField.Value;
            params.aircraft.tcvt = app.tcvtEditField.Value;
            params.aircraft.incVT = app.incVTEditField.Value;
            params.aircraft.bHT = app.bHTEditField.Value;
            params.aircraft.Chordht = app.ChordhtEditField.Value;
            params.aircraft.TaperHT = app.TaperHTEditField.Value;
            params.aircraft.tcht = app.tchtEditField.Value;
            params.aircraft.incHT = app.incHTEditField.Value;
            
            params.battery.Crtd = app.BattCapEditField.Value;
            params.battery.CellNum = app.BattCellsEditField.Value;
            params.motor.int_res = app.IntResEditField.Value;
            params.motor.no_load_I = app.NoLoadIEditField.Value;
            params.motor.Kv = app.KvEditField.Value;
            params.motor.max_rpm = app.MaxMotorRPMEditField.Value;
            params.motor.max_amp = app.MaxAmpEditField.Value;
            
            params.initial.initcoor = [app.InitXEditField.Value, app.InitYEditField.Value, 0];
            params.initial.Velinit = app.InitSpeedEditField.Value;
            params.initial.TO = app.TakeoffCheckBox.Value; 
            params.takeoff.aoaTO = app.TakeoffAoAEditField.Value;
            params.takeoff.muf = app.mufEditField.Value;
            
            params.sim.pitch_cmd = app.CmdPitchEditField.Value;
            params.sim.pitchrate = app.PitchRateEditField.Value;
            params.sim.bankrate = app.BankRateEditField.Value;
            params.sim.t1 = app.t1EditField.Value;
            params.sim.h = app.TimeStepEditField.Value;
            params.sim.hlook = app.RKLookAheadEditField.Value;
            params.sim.rpm_rate = app.RPMRateEditField.Value;
            params.sim.step_disp = app.SimulinkStepEditField.Value;
            params.sim.useSimulink = app.SimulinkCheckBox.Value;
            params.sim.tolerance = app.RKToleranceEditField.Value; 
            
            params.mission.cruise_h = app.CruiseHghtEditField.Value;
            params.mission.perform_landing = app.LandingCheckBox.Value;
            
            selectedBrand = string(app.PropBrandDropDown.Value);
            selectedSize = string(app.PropSizeDropDown.Value);
            
            size_parts = split(selectedSize, 'x');
            if length(size_parts) >= 1
                prop_diameter_in = str2double(size_parts{1});
                params.prop.D = prop_diameter_in * 0.0254;
            else
                error('Invalid propeller size format: %s. Expected format like "12x6".', selectedSize);
            end
            
            idx = strcmp(app.PropDataDB.Brand, selectedBrand) & strcmp(app.PropDataDB.Size, selectedSize);
            propFiles = app.PropDataDB(idx, :);
            
            if isempty(propFiles)
                error('No data files found for propeller %s %s. Please check the Prop_Data folder.', selectedBrand, selectedSize);
            end

            max_rpm_file = max(propFiles.RPM);
            rpm_step = 1000;
            num_rpm_steps = ceil(max_rpm_file / rpm_step) + 1;
            
            params.prop.ETA = cell(num_rpm_steps, 1);
            params.prop.PP = cell(num_rpm_steps, 1);
            params.prop.T = cell(num_rpm_steps, 1);
            
            for i = 1:height(propFiles)
                rpm = propFiles.RPM(i);
                idx_cell = round(rpm / rpm_step);
                
                prop_matrix = readmatrix(propFiles.File(i), 'NumHeaderLines', 1);
                J_data = prop_matrix(:, 1);
                CT_data = prop_matrix(:, 2);
                CP_data = prop_matrix(:, 3);
                eta_data = prop_matrix(:, 4);
                
                eta_data(eta_data < 0) = 0;
                
                params.prop.T{idx_cell} = fit(J_data, CT_data, 'pchipinterp');
                params.prop.PP{idx_cell} = fit(J_data, CP_data, 'pchipinterp');
                params.prop.ETA{idx_cell} = fit(J_data, eta_data, 'pchipinterp');
            end
            
            table_data = app.MissionTable.Data;
            mission_cell_array = cell(size(table_data));
            for r = 1:size(table_data,1)
                mission_cell_array{r,1} = table_data{r,1};
                mission_cell_array{r,2} = table_data{r,2};
                prop_val_str = table_data{r,3};
                try, prop_val = eval(prop_val_str); catch, prop_val = str2double(prop_val_str); end
                mission_cell_array{r,3} = prop_val;
                mission_cell_array{r,4} = table_data{r,4};
            end
            params.mission.phase = mission_cell_array;
        end
        
        function results = runFlightSimulation(app, params)
            if params.initial.TO
                [vel,Trvel,fpa,pitch,Beta,~,xcoor,ycoor,zcoor,i,~,aoa,bank,P_Batt,P,SOC,SOC_2,VoltIns,VoltIns_2,Current,Current_2,effprop,CP,CT,T,t,RPM,CL,CD] = Takeoff(app, params);
            else
                % Simplified non-takeoff start
                i=2; t(1)=0; vel(1)=params.initial.Velinit; Trvel(1)=vel(1);
                xcoor(1)=params.initial.initcoor(1); ycoor(1)=params.initial.initcoor(2); zcoor(1)=params.initial.initcoor(3);
                aoa(1) = 0; fpa(1) = 0; pitch(1) = 0; Beta(1) = 0; bank(1) = 0; RPM(1) = 1000;
                SOC(1) = 1; SOC_2(1)=1; VoltIns(1)=params.battery.Volt; P(1)=0; P_Batt(1)=0; T(1)=0;
                Current(1)=0; Current_2(1)=0; VoltIns_2(1)=0; effprop(1)=0; CP(1)=0; CT(1)=0; CL(1)=0; CD(1)=0;
            end

            if app.StopSimulation, results = struct(); return; end
            
            [xcoor,ycoor,zcoor,vel,Trvel,fpa,pitch,Beta,bank,T,P_Batt,P,SOC,SOC_2,VoltIns,VoltIns_2,Current,Current_2,effprop,CP,CT,t,aoa,RPM,CL,CD] = ...
             MissionMain(app, xcoor, ycoor, zcoor, i, vel, Trvel, Beta, [], fpa, pitch, params, bank, T, P_Batt, P, SOC, SOC_2, VoltIns, VoltIns_2, Current, Current_2, effprop, CP, CT, t, aoa, RPM, CL, CD);
    
            if app.StopSimulation, results = struct(); return; end

            if params.mission.perform_landing
                [xcoor,ycoor,zcoor,vel,Trvel,fpa,pitch,Beta,bank,T,P_Batt,P,SOC,SOC_2,VoltIns,VoltIns_2,Current,Current_2,effprop,CP,CT,t,aoa,RPM,CL,CD] = ...
                 Landing(app, xcoor, ycoor, zcoor, i, vel, Trvel, Beta, [], fpa, pitch, params, bank, T, P_Batt, P, SOC, SOC_2, VoltIns, VoltIns_2, Current, Current_2, effprop, CP, CT, t, aoa, RPM, CL, CD);
            end

            results.t=t; results.xcoor=xcoor; results.ycoor=ycoor; results.zcoor=zcoor;
            results.vel=vel; results.Trvel=Trvel; results.fpa=fpa; results.pitch=pitch;
            results.Beta=Beta; results.aoa=aoa; results.bank=bank; results.T=T;
            results.P_Batt=P_Batt; results.P=P; results.SOC=SOC; results.SOC_2=SOC_2;
            results.VoltIns=VoltIns; results.VoltIns_2=VoltIns_2; results.Current=Current;
            results.Current_2=Current_2; results.effprop=effprop; results.CP=CP;
            results.CT=CT; results.RPM=RPM; results.CL=CL; results.CD=CD;
        end
        
        function clearAllPlots(app)
            cla(app.UIAxes_Trajectory); cla(app.UIAxes_Coefficients); cla(app.UIAxes_PropEff);
            cla(app.UIAxes_PropRPM); cla(app.UIAxes_Current); cla(app.UIAxes_FlightAngles);
            cla(app.UIAxes_AirSpeed); cla(app.UIAxes_BankAngle); cla(app.UIAxes_Power);
            cla(app.UIAxes_SOC); cla(app.UIAxes_Voltage); cla(app.UIAxes_Thrust);
        end
    end
    
    methods (Access = public)
        function app = FlightSimGUI()
            createComponents(app)
            if nargout == 0
                app.startupFcn();
            end
        end
        
        function setSimulationResults(app, results)
            app.SimResults = results;
        end

function updateAllPlots(app)
            if isempty(app.SimResults) || ~isfield(app.SimResults, 't') || isempty(app.SimResults.t), return; end
            res = app.SimResults;
            lw = 2; % LineWidth
            
            % --- CORRECTED: More robust safe_plot function with correct argument order ---
            function safe_plot(ax, x, y, line_spec, varargin)
                % This function's signature now explicitly separates the line style
                % from other name-value pair arguments.
                
                % Defensive check to ensure data is a plottable numeric vector
                if ~isnumeric(y) && iscell(y)
                    warning('Plotting data was a cell array, attempting conversion.');
                    y = cell2mat(y);
                end

                if ~isnumeric(y) || ~isnumeric(x)
                     cla(ax); text(ax, 0.5, 0.5, 'Plot Error: Non-numeric Data', 'HorizontalAlignment', 'center', 'Color', 'red');
                     return;
                end
            
                if numel(x) == numel(y)
                    % The plot command now has the correct argument order:
                    % plot(axes, x, y, LineSpec, Name, Value...)
                    plot(ax, x(:), y(:), line_spec, 'LineWidth', lw, varargin{:});
                else
                    cla(ax); text(ax, 0.5, 0.5, 'Plot Error: Dimension Mismatch', 'HorizontalAlignment', 'center', 'Color', 'red');
                end
            end
            
            % --- Plotting calls (these do not need to be changed) ---
            plot3(app.UIAxes_Trajectory, res.xcoor, res.ycoor, res.zcoor, 'r.-', 'LineWidth', lw);
            title(app.UIAxes_Trajectory, '3D Trajectory'); xlabel(app.UIAxes_Trajectory, 'x (m)'); ylabel(app.UIAxes_Trajectory, 'y (m)'); zlabel(app.UIAxes_Trajectory, 'z (m)');
            grid(app.UIAxes_Trajectory, 'on'); axis(app.UIAxes_Trajectory, 'equal');
            
            cla(app.UIAxes_Coefficients, 'reset'); hold(app.UIAxes_Coefficients, 'on'); grid(app.UIAxes_Coefficients, 'on');
            safe_plot(app.UIAxes_Coefficients, res.t, res.CL, 'b-', 'DisplayName', 'CL');
            safe_plot(app.UIAxes_Coefficients, res.t, res.CD, 'r-', 'DisplayName', 'CD');
            title(app.UIAxes_Coefficients, 'Lift & Drag Coefficients'); xlabel(app.UIAxes_Coefficients, 't (s)'); ylabel(app.UIAxes_Coefficients, 'Coefficient');
            legend(app.UIAxes_Coefficients, 'Location', 'best'); hold(app.UIAxes_Coefficients, 'off');

            safe_plot(app.UIAxes_PropEff, res.t, res.effprop, 'r-'); title(app.UIAxes_PropEff, 'Propeller Efficiency'); xlabel(app.UIAxes_PropEff, 't (s)'); ylabel(app.UIAxes_PropEff, '\eta_{prop}'); grid(app.UIAxes_PropEff, 'on'); ylim(app.UIAxes_PropEff, [0, 1]);
            safe_plot(app.UIAxes_PropRPM, res.t, res.RPM, 'b-'); title(app.UIAxes_PropRPM, 'Propeller RPM'); xlabel(app.UIAxes_PropRPM, 't (s)'); ylabel(app.UIAxes_PropRPM, 'RPM'); grid(app.UIAxes_PropRPM, 'on');
            
            cla(app.UIAxes_Current, 'reset'); hold(app.UIAxes_Current, 'on'); grid(app.UIAxes_Current, 'on');
            safe_plot(app.UIAxes_Current, res.t, res.Current, 'b-', 'DisplayName', 'Traub');
            legend(app.UIAxes_Current, 'Location', 'best'); title(app.UIAxes_Current, 'Load Current'); xlabel(app.UIAxes_Current, 't (s)'); ylabel(app.UIAxes_Current, 'Current (A)'); hold(app.UIAxes_Current, 'off');
            
            cla(app.UIAxes_FlightAngles, 'reset'); hold(app.UIAxes_FlightAngles, 'on'); grid(app.UIAxes_FlightAngles, 'on');
            safe_plot(app.UIAxes_FlightAngles, res.t, res.aoa, 'm-', 'DisplayName', '\alpha');
            safe_plot(app.UIAxes_FlightAngles, res.t, res.pitch, 'b-', 'DisplayName', '\theta');
            safe_plot(app.UIAxes_FlightAngles, res.t, res.fpa, 'r-', 'DisplayName', '\gamma');
            legend(app.UIAxes_FlightAngles, 'Location', 'best'); title(app.UIAxes_FlightAngles, 'Longitudinal Angles'); xlabel(app.UIAxes_FlightAngles, 't (s)'); ylabel(app.UIAxes_FlightAngles, 'Angle (deg)'); hold(app.UIAxes_FlightAngles, 'off');
            
            safe_plot(app.UIAxes_AirSpeed, res.t, res.Trvel, 'k-'); title(app.UIAxes_AirSpeed, 'Air Speed'); xlabel(app.UIAxes_AirSpeed, 't (s)'); ylabel(app.UIAxes_AirSpeed, 'Speed (m/s)'); grid(app.UIAxes_AirSpeed, 'on');
            safe_plot(app.UIAxes_BankAngle, res.t, res.bank, 'b-'); title(app.UIAxes_BankAngle, 'Bank Angle'); xlabel(app.UIAxes_BankAngle, 't (s)'); ylabel(app.UIAxes_BankAngle, 'Angle (deg)'); grid(app.UIAxes_BankAngle, 'on');
            
            cla(app.UIAxes_Power, 'reset'); hold(app.UIAxes_Power, 'on'); grid(app.UIAxes_Power, 'on');
            safe_plot(app.UIAxes_Power, res.t, res.P, 'b-', 'DisplayName', 'Prop Power');
            safe_plot(app.UIAxes_Power, res.t, res.P_Batt, 'r-', 'DisplayName', 'Batt. Power Avail.');
            legend(app.UIAxes_Power, 'Location', 'best'); title(app.UIAxes_Power, 'Power'); xlabel(app.UIAxes_Power, 't (s)'); ylabel(app.UIAxes_Power, 'Power (Watt)'); hold(app.UIAxes_Power, 'off');
            
            cla(app.UIAxes_SOC, 'reset'); hold(app.UIAxes_SOC, 'on'); grid(app.UIAxes_SOC, 'on');
            safe_plot(app.UIAxes_SOC, res.t, res.SOC, 'b-', 'DisplayName', 'Traub');
            legend(app.UIAxes_SOC, 'Location', 'best'); title(app.UIAxes_SOC, 'State of Charge'); xlabel(app.UIAxes_SOC, 't (s)'); ylabel(app.UIAxes_SOC, 'SOC (%)'); ylim(app.UIAxes_SOC, [0, 1]); hold(app.UIAxes_SOC, 'off');
            
            cla(app.UIAxes_Voltage, 'reset'); hold(app.UIAxes_Voltage, 'on'); grid(app.UIAxes_Voltage, 'on');
            safe_plot(app.UIAxes_Voltage, res.t, res.VoltIns, 'b-', 'DisplayName', 'Traub');
            legend(app.UIAxes_Voltage, 'Location', 'best'); title(app.UIAxes_Voltage, 'Terminal Voltage'); xlabel(app.UIAxes_Voltage, 't (s)'); ylabel(app.UIAxes_Voltage, 'Voltage (V)'); hold(app.UIAxes_Voltage, 'off');
            
            safe_plot(app.UIAxes_Thrust, res.t, res.T, 'm-'); title(app.UIAxes_Thrust, 'Thrust'); xlabel(app.UIAxes_Thrust, 't (s)'); ylabel(app.UIAxes_Thrust, 'Thrust (N)'); grid(app.UIAxes_Thrust, 'on');
        end

        function delete(app)
            disp('Closing the simulation application.');
        end
    end
end