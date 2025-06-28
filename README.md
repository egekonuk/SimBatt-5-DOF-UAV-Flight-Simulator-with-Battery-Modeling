<div align="center">
  <img src="https://i.imgur.com/8B1nF8X.png" alt="Logo" width="450">
  <br/>
  <p align="center">
    A modular 5-DOF trajectory solver with advanced battery modeling for electric UAVs.
    <br />
    <a href="https://github.com/your_username/SimBatt/issues">Report Bug</a>
    ·
    <a href="https://github.com/your_username/SimBatt/issues">Request Feature</a>
  </p>
</div>

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT) [![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-orange)](https://www.mathworks.com/)

---

**SimBatt** is a MATLAB-based tool for simulating the flight trajectories of electric-powered Unmanned Aerial Vehicles (UAVs). It combines a 5-DOF flight dynamics model with a detailed battery performance module, making it ideal for mission planning, performance analysis, and endurance estimation for fixed-wing electric aircraft.

## Key Features

<table>
<tr>
<td width="25%">
<p align="center">
  <img src="https://i.imgur.com/gA3d1gJ.png" width="60">
  <br>
  <strong>Interactive GUI</strong>
</p>
<p align="center">A user-friendly interface to easily set up and run complex analyses without touching the source code.</p>
</td>
<td width="25%">
<p align="center">
  <img src="https://i.imgur.com/k2sPZ5R.png" width="60">
  <br>
  <strong>Advanced Battery Model</strong>
</p>
<p align="center">Utilizes a constant power discharge method that accurately reflects real-world flight conditions.</p>
</td>
<td width="25%">
<p align="center">
  <img src="https://i.imgur.com/zV8QjBq.png" width="60">
  <br>
  <strong>Modular Mission Planning</strong>
</p>
<p align="center">Define complex flight plans with multiple segments (straight, turn) and control parameters.</p>
</td>
<td width="25%">
<p align="center">
  <img src="https://i.imgur.com/yFkYx9R.png" width="60">
  <br>
  <strong>Comprehensive Plotting</strong>
</p>
<p align="center">Automatically generates detailed performance graphs for trajectory, power, SOC, and more.</p>
</td>
</tr>
</table>

---

## How It Works

SimBatt streamlines the simulation process into four main stages, from initial setup to final analysis.

| ![Setup](https://i.imgur.com/mYl1bmy.png) | ![Mission](https://i.imgur.com/UoVlX1j.png) | ![Simulation](https://i.imgur.com/8Qk3E1t.png) | ![Analysis](https://i.imgur.com/nJ2s3oP.png) |
| :---: | :---: | :---: | :---: |
| **1. Setup** | **2. Mission Definition** | **3. Simulation Core** | **4. Analysis** |
| Configure aircraft dimensions, mass, motor specs, and battery parameters using the interactive GUI. | Define a multi-stage mission profile in the mission table, setting RPM, turn direction, and segment length for each phase. | The 5-DOF solver, using an adaptive Runge-Kutta method, calculates the aircraft's state at each time step. | Visualize the results with automatically generated plots for 3D trajectory, SOC, voltage, current, and aerodynamic coefficients. |

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

## Getting Started

### Prerequisites
* MATLAB (R2020a or newer)
* Simulink
* Required Toolboxes: Optimization, Simscape

### Installation
1. Clone the repo:
   ```sh
   git clone [https://github.com/your_username/SimBatt.git](https://github.com/your_username/SimBatt.git)
   ```
2. Open MATLAB and navigate to the cloned directory.

### Running the Simulation
1.  Run the main GUI file from the MATLAB command window:
    ```matlab
    FlightSimGUI
    ```
2.  Use the interface to configure all parameters and mission details.
3.  Click **Run Simulation** to begin the analysis and view the results.
