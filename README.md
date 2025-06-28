SimBatt: 5-DOF UAV Flight Simulator with Battery Modeling
SimBatt is a comprehensive 5-degree-of-freedom (5-DOF) flight performance simulator for electric unmanned aerial vehicles (UAVs), developed entirely in MATLAB. It features a detailed graphical user interface (GUI) built with MATLAB's App Designer, allowing for in-depth configuration of aircraft geometry, mission profiles, and power systems.

The core of the simulator is its detailed physics-based models, including a full aerodynamic drag buildup, an adaptive Runge-Kutta-Fehlberg (RKF7(8)) solver for the equations of motion, and a sophisticated battery performance model based on Traub's collapsed-curves method.

Key Features
5-DOF Flight Dynamics: Simulates the aircraft's trajectory by solving for velocity, flight path angle, and heading.

Detailed Aerodynamic Modeling: Implements a full drag buildup calculation, including parasite drag (fuselage friction, landing gear) and induced drag. The model is sensitive to the aircraft's configuration, such as deployed flaps or landing gear.

Advanced Battery Performance: Simulates battery state of charge (SOC) and voltage drop under load using Traub's collapsed-curves method. Includes an option to integrate a custom Simulink battery model.

Customizable Mission Profiling: An interactive table in the GUI allows users to define complex multi-segment flight plans, specifying the type of segment (straight or turn), its properties (distance or angle), and the exact RPM to be used for that segment.

Adaptive High-Order Solver: Utilizes an adaptive Runge-Kutta-Fehlberg 7(8) solver to ensure numerical accuracy and stability throughout the simulation.

Fully Interactive GUI: All aircraft parameters, mission profiles, and simulation settings are configured through a user-friendly, tabbed graphical interface. No code changes are needed to run a new simulation.

Comprehensive Visualization: Generates 12 distinct plots to visualize every aspect of the flight, from the 3D trajectory to battery voltage, SOC, and aerodynamic performance.

The SimBatt GUI
The user interface is organized into four distinct tabs to manage the large number of input parameters logically.

1. General & Dimensions Tab
This tab is for defining the physical characteristics of the aircraft.

Wing & Mass: Total mass, reference area, wingspan, chord, etc.

Vertical Tail: Geometry of the vertical stabilizer.

Horizontal Tail: Geometry of the horizontal stabilizer.

Fuselage: Length, diameter, and wetted area.

Landing Gear: Number of tires and their dimensions.

2. Battery Tab
This tab contains the specifications for the electric power source.

Capacity (Ah)

C-Rate

Nominal Voltage

Number of Cells in Series

3. Simulation Tab
This tab controls the initial state of the simulation and the behavior of the solver.

Initial & Takeoff Conditions: Starting position, speed, heading, and takeoff-specific parameters like runway friction and slope.

Flight Control: Defines autopilot-like parameters such as cruise altitude and bank rate.

Solver Settings: Allows configuration of the time step and error tolerance for the RKF7(8) solver.

4. Config & Mission Tab
This tab is for high-level configuration and detailed mission planning.

Propeller & Configuration: Propeller diameter and pitch, skin roughness, and flags for landing gear and flap deployment.

Mission Profile: An interactive table to build a flight plan segment by segment. Users can add or delete segments and specify the type, target property (distance or turn angle), and RPM for each.

Setup & Installation
Prerequisites
MATLAB (Tested on R2025a).

Curve Fitting Toolbox™: Required for the fit function used in aerodynamic and battery modeling.

File Structure
For the simulator to find all necessary data files, your project must be organized with the following folder structure. Place all .m files in the root project folder.

/SimBatt_Project/
|
|-- FlightSimGUI.m
|-- Takeoff.m
|-- MissionMain.m
|-- Dragpolar.m
|-- Power.m
|-- PropMotor.m
|-- Rungeforth.m
|-- Runge_Kutta_Fehlberg_7_8.m
|-- traub_clps_battery.m
|-- readpropdata.m
|-- Aero3D.m
|-- (and all other .m files)
|
|-- /Aero_Data/
|   |-- CD0vsAOA.xlsx
|   |-- CDIvsAOA.xlsx
|   |-- CLvsAOA.xlsx
|   +-- (all other aero data files)
|
|-- /RPMvsV/
|   |-- RPM_V_1.mat
|   |-- RPM_V_08.mat
|   +-- (all other RPM data files)
|
|-- /Traub_Batt/
|   |-- 6Sbatt_data_10A_mod.mat
|   +-- (all other battery data files)
|
+-- /UIUC-propDB/
    |-- apc_12x6_....txt
    +-- (all your propeller performance .txt files)

How to Run the Simulator
Ensure your project follows the File Structure described above.

Open MATLAB.

In the MATLAB Command Window, navigate to the root of your project folder (e.g., cd C:\Your\Path\To\SimBatt_Project).

Run the application by typing the following command and pressing Enter:

FlightSimGUI

The GUI will launch, and you can configure your simulation.

Using the Simulator
Navigate through the tabs on the left panel to configure all aircraft, battery, and simulation parameters.

Go to the Config & Mission tab to define your desired flight plan in the Mission Profile table. Use the "Add Segment" and "Delete Selected Segment" buttons to customize the mission.

Click the Run Simulation button to start the simulation.

View the results on the 12 plots on the right panel.

If the simulation takes a long time or gets stuck, you can press the Exit Simulation button to stop it gracefully.
