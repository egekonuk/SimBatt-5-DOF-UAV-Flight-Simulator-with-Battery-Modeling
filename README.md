<div align="center">
  <h1 align="center">SimBatt</h1>
  <p align="center">
    A modular 5-DOF trajectory solver with advanced battery modeling for electric UAVs.
    <br />
    <a href="https://github.com/egekonuk/SimBatt/issues">Report Bug</a>
    ·
    <a href="https://github.com/egekonuk/SimBatt/issues">Request Feature</a>
  </p>
</div>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![DOI](https://img.shields.io/badge/Cite-10.25777/15bx--re63-brightgreen.svg)](https://doi.org/10.25777/15bx-re63) [![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-orange)](https://www.mathworks.com/)

---

**SimBatt** is a MATLAB-based tool for simulating the flight trajectories of electric-powered Unmanned Aerial Vehicles (UAVs). It combines a 5-DOF flight dynamics model with a detailed battery performance module, making it ideal for mission planning, performance analysis, and endurance estimation for fixed-wing electric aircraft.

## Key Features

-   **Interactive GUI:** A user-friendly interface to easily set up and run complex analyses without touching the source code.
-   **Advanced Battery Model:** Utilizes a constant power discharge method that accurately reflects real-world flight conditions.
-   **Modular Mission Planning:** Define complex flight plans with multiple segments (straight, turn) and control parameters.
-   **Comprehensive Plotting:** Automatically generates detailed performance graphs for trajectory, power, SOC, and more.

---

## How It Works

SimBatt streamlines the simulation process into four main stages, from initial setup to final analysis.

1.  **Setup:** Configure aircraft dimensions, mass, motor specs, and battery parameters using the interactive GUI.
2.  **Mission Definition:** Define a multi-stage mission profile in the mission table, setting RPM, turn direction, and segment length for each phase.
3.  **Simulation Core:** The 5-DOF solver, using an adaptive Runge-Kutta method, calculates the aircraft's state at each time step.
4.  **Analysis:** Visualize the results with automatically generated plots for 3D trajectory, SOC, voltage, current, and aerodynamic coefficients.

---

## Methodology Spotlight

#### Flight Dynamics
The 5-DOF model solves the primary equations of motion, assuming coordinated flight:

* **Velocity Derivative ($\dot{V}$):**
    $$\dot{V} = \frac{1}{m}[T\cos\alpha - D] - g\sin\gamma$$
* **Heading Angle Derivative ($\dot{\beta}$):**
    $$\dot{\beta} = \frac{1}{mV}[T\sin\alpha + L]\frac{\sin\mu}{\cos\gamma}$$
* **Flight Path Angle Derivative ($\dot{\gamma}$):**
    $$\dot{\gamma} = \frac{1}{mV}[T\sin\alpha + L]\cos\mu - \frac{g}{V}\cos\gamma$$

#### Battery Modeling
The battery's State of Charge (SOC) is estimated using a constant power discharge model, which is ideal for aircraft where power output remains stable during cruise.

1.  **Curve Collapse:** Multiple constant-current discharge curves are "collapsed" into a single characteristic curve by finding an optimal exponent, **n**.
    $$I^n V = \text{Constant}$$
2.  **Model Fitting:** This collapsed curve is fitted to a rational polynomial function of SOC.
    $$V I^n(\text{SOC}) = \frac{a+c\cdot\text{SOC}+e\cdot\text{SOC}^2}{1+b\cdot\text{SOC}+d\cdot\text{SOC}^2+f\cdot\text{SOC}^3}$$

---
## Citing SimBatt

If you use this project in your research, please cite the underlying thesis:

> Konuk, E. (2020). *Trajectory Simulation With Battery Modeling for Electric Powered Unmanned Aerial Vehicles* (Master's thesis, Old Dominion University, Norfolk, VA). DOI: 10.25777/15bx-re63

---

## Getting Started

### Prerequisites
* MATLAB (R2020a or newer)
* Simulink
* Required Toolboxes: Optimization, Simscape

### Installation
1.  Clone the repo:
    ```sh
    git clone [https://github.com/egekonuk/SimBatt.git](https://github.com/egekonuk/SimBatt.git)
    ```
2.  Open MATLAB and navigate to the cloned directory.

### Running the Simulation
1.  Run the main GUI file from the MATLAB command window:
    ```matlab
    FlightSimGUI
    ```
2.  Use the interface to configure all parameters and mission details.
3.  Click **Run Simulation** to begin the analysis and view the results.

---

## License

This project is licensed under the GNU General Public License v3.0. See the `LICENSE.md` file for more details.
