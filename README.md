📖 Table of Contents
About The Project
Methodology
Getting Started
Usage
Roadmap
Contributing
License
Contact
Acknowledgments
✈️ About The Project
SimBatt is a comprehensive MATLAB-based simulation tool for analyzing the flight trajectory of electric-powered Unmanned Aerial Vehicles (UAVs). It integrates a 5-degree-of-freedom (5-DOF) flight dynamics model with a detailed battery performance module, allowing for accurate mission profiling and endurance analysis.
The simulation is built to be modular and user-friendly, with a GUI for parameter input and real-time visualization of the results. The current aircraft model is based on the Avistar ELITE RC plane, but the framework is adaptable for other fixed-wing electric aircraft.
Key Features:
5-DOF Flight Simulation: A robust framework for trajectory analysis, including takeoff, climb, cruise, turning, and landing phases.
Advanced Battery Modeling: Utilizes a constant power discharge method that accurately reflects real-world flight conditions, validated against an experimental Simulink model.
Modular Mission Planning: Define complex flight plans with multiple segments and control parameters.
Detailed Aerodynamic Model: Incorporates a component-based drag buildup model, utilizing data from XFLR5 and the UIUC Propeller Database.
Interactive GUI: Easily configure, run, and visualize simulations without deep-diving into the code.
Built With:
🔬 Methodology
The simulation core is based on a set of well-established flight dynamics and power modeling principles.
Flight Dynamics
The 5-DOF model assumes coordinated flight (neglecting sideslip) and solves the following primary equations of motion using an adaptive Runge-Kutta-Fehlberg 7(8) solver.
Velocity Derivative (V˙):
V˙=m1​[Tcosα−D]−gsinγ
Heading Angle Derivative (β˙​):
β˙​=mV1​[Tsinα+L]cosγsinμ​
Flight Path Angle Derivative (γ˙​):
γ˙​=mV1​[Tsinα+L]cosμ−Vg​cosγ
Takeoff Velocity Derivative:
V˙=Wg​[T−D−ξ(Wcosγ−L)−Wsinγ]
Where:
T: Thrust, D: Drag, L: Lift, W: Weight
α: Angle of Attack, γ: Flight Path Angle, μ: Bank Angle
m: Mass, g: Gravity, ξ: Runway friction coefficient
Battery Modeling
The battery's State of Charge (SOC) and terminal voltage are estimated using a constant power discharge model inspired by the work of Lance Traub. This method is ideal for aircraft where power output remains relatively stable during cruise.
Curve Collapse: Multiple constant-current discharge curves are "collapsed" into a single characteristic curve by finding an optimal exponent, n.
InV=Constant
Model Fitting: This collapsed curve is fitted to a rational polynomial function of SOC.
VIn(SOC)=1+b⋅SOC+d⋅SOC2+f⋅SOC3a+c⋅SOC+e⋅SOC2​
Iterative Solution: During simulation, the voltage, current, and SOC are solved iteratively at each time step based on the power required by the propulsion system.
🚀 Getting Started
To get a local copy up and running, follow these simple steps.
Prerequisites
MATLAB (R2020a or newer is recommended)
Simulink
Required Toolboxes:
Optimization Toolbox
Simscape
Installation
Clone the repository:
git clone https://github.com/your_username/SimBatt.git


Navigate to the project directory in MATLAB.
🎮 Usage
Open the project in MATLAB.
Run the main GUI file:
FlightSimGUI


The Simulation Parameters window will open. Use the tabs to configure the simulation:
General & Dimensions: Set the aircraft's physical properties (mass, wing area, fuselage dimensions, etc.).
Battery & Motor: Define the battery capacity, cell count, and motor characteristics.
Simulation: Configure initial conditions, control parameters, and solver settings.
Config & Mission: Select a propeller from the UIUC database, set flight configuration (gear, flaps), and define the mission profile in the table.
Click the Run Simulation button to start.
Results, including the 3D trajectory and various performance plots (SOC, Power, Voltage), will be displayed in the Simulation Results panel.
🙌 Contributing
Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.
If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Fork the Project
Create your Feature Branch (git checkout -b feature/AmazingFeature)
Commit your Changes (git commit -m 'Add some AmazingFeature')
Push to the Branch (git push origin feature/AmazingFeature)
Open a Pull Request
📜 License
Distributed under the MIT License. See LICENSE.txt for more information.
📬 Contact
Ege Konuk
Project Link: https://github.com/your_username/SimBatt
🙏 Acknowledgments
This work is based on the Master's Thesis: Trajectory Simulation With Battery Modeling for Electric Powered Unmanned Aerial Vehicles by Ege Konuk, Old Dominion University.
UIUC Propeller Database
XFLR5 Analysis Tool
Best-README-Template by Othneil Drew
