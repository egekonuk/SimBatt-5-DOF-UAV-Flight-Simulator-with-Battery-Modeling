📖 Table of Contents
About The Project

Key Features

Methodology

Getting Started

Usage

Roadmap

Contributing

License

Contact

Acknowledgments

✈️ About The Project
SimBatt is a comprehensive MATLAB-based simulation tool for analyzing the flight trajectory of electric-powered Unmanned Aerial Vehicles (UAVs). This tool is a direct result of my M.Sc. research in Aerospace Engineering at Old Dominion University, where my work specialized in developing reduced-order aerodynamic and power models for electric aircraft.

I believe in the power of simplicity in making complex aerodynamic problems digestible for practical use. With SimBatt, my goal was to embody this approach by creating a tool with a very gentle learning curve. I wanted it to be powerful enough for detailed research yet intuitive enough to become a go-to utility in any engineer's or enthusiast's toolkit. I hope it aids you in your own design projects, learning, and discovery :)

Built With:
✨ Key Features
Interactive GUI: A user-friendly graphical interface to easily set up and run complex analyses without modifying code.

5-DOF Flight Simulation: A robust framework for trajectory analysis, including takeoff, climb, cruise, turning, and landing phases.

Advanced Battery Modeling: Utilizes a constant power discharge method that accurately reflects real-world flight conditions, validated against an experimental Simulink model.

Modular Mission Planning: Define complex flight plans with multiple segments (straight, turn) and control parameters.

Detailed Aerodynamic Model: Incorporates a component-based drag buildup model, utilizing data from XFLR5 and the UIUC Propeller Database.

Comprehensive Plotting: Automatically generates performance curves (3D Trajectory, SOC, Power, Voltage, Current, Flight Angles, etc.).

🔬 Methodology
The simulation core is based on a set of well-established flight dynamics and power modeling principles.

Flight Dynamics
The 5-DOF model assumes coordinated flight (neglecting sideslip) and solves the following primary equations of motion using an adaptive Runge-Kutta-Fehlberg 7(8) solver.

Velocity Derivative ( 
V
˙
 ):


V
˙
 = 
m
1
​
 [Tcosα−D]−gsinγ
Heading Angle Derivative ( 
β
˙
​
 ):


β
˙
​
 = 
mV
1
​
 [Tsinα+L] 
cosγ
sinμ
​
 
Flight Path Angle Derivative ( 
γ
˙
​
 ):


γ
˙
​
 = 
mV
1
​
 [Tsinα+L]cosμ− 
V
g
​
 cosγ
Takeoff Velocity Derivative:


V
˙
 = 
W
g
​
 [T−D−ξ(Wcosγ−L)−Wsinγ]
Where:

T: Thrust, D: Drag, L: Lift, W: Weight

α: Angle of Attack, γ: Flight Path Angle, μ: Bank Angle

m: Mass, g: Gravity, ξ: Runway friction coefficient

Battery Modeling
The battery's State of Charge (SOC) and terminal voltage are estimated using a constant power discharge model inspired by the work of Lance Traub. This method is ideal for aircraft where power output remains relatively stable during cruise.

Curve Collapse: Multiple constant-current discharge curves are "collapsed" into a single characteristic curve by finding an optimal exponent, n.


I 
n
 V=Constant
Model Fitting: This collapsed curve is fitted to a rational polynomial function of SOC.


VI 
n
 (SOC)= 
1+b⋅SOC+d⋅SOC 
2
 +f⋅SOC 
3
 
a+c⋅SOC+e⋅SOC 
2
 
​
 
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

Navigate to the project directory in MATLAB and add it to the path.

🎮 Usage
Open the project in MATLAB.

Run the main GUI file:

FlightSimGUI

The Simulation Parameters window will open. Use the tabs to configure the simulation:

General & Dimensions: Set the aircraft's physical properties.

Battery & Motor: Define the battery and motor characteristics.

Simulation: Configure initial conditions and solver settings.

Config & Mission: Select a propeller, set flight configuration, and define the mission profile.

Click the Run Simulation button to start.

Results, including the 3D trajectory and performance plots, will be displayed in the Simulation Results panel.

🗺️ Roadmap
[ ] Upgrade to 6-DOF Model: Incorporate sideslip and yaw dynamics.

[ ] Advanced Control Systems: Implement more sophisticated autopilot logic.

[ ] Thermal Battery Model: Add temperature effects to the battery simulation.

[ ] Full Flight Test Validation: Compare simulation results against data from a fully instrumented flight test.

See the open issues for a full list of proposed features and known issues.

🙌 Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

Fork the Project

Create your Feature Branch (git checkout -b feature/AmazingFeature)

Commit your Changes (git commit -m 'Add some AmazingFeature')

Push to the Branch (git push origin feature/AmazingFeature)

Open a Pull Request

📜 License
Distributed under the MIT License. See LICENSE.txt for more information.

📬 Contact
Ege Konuk - egekonuk@gmail.com

Project Link: https://github.com/your_username/SimBatt

🙏 Acknowledgments
This work is based on the Master's Thesis: Trajectory Simulation With Battery Modeling for Electric Powered Unmanned Aerial Vehicles by Ege Konuk, Old Dominion University.

UIUC Propeller Database

XFLR5 Analysis Tool

Best-README-Template by Othneil Drew
