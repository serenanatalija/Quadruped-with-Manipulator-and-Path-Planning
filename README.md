# Solution to Excellence in Innovation project <'4.2'> <'Quadruped Robot with a Manipulator'>

University of Sheffield

Authors: Oluwaseun Adewola, Harry Armstrong, Serena Cicin-Sain, Will Foster, Joseph Moore, Olivia Organ, Josh Orme-Herbert, Sherif H El Sawwaf


[Program link](https://github.com/mathworks/MathWorks-Excellence-in-Innovation)


# Project details
Project was broken into three subsystems: 
  1) The quadruped subsystem for implementing a stable walking and turning algorithm using the Raibert Strategy.
  2) Navigation and path planning subsystem for creating effective path planning algorithms for the quadruped to follow.
  3) Manipulator subsystem for the quadruped to pick and place a ball.
  
  The subsystems were integrated together with a high-level Stateflow and a user-friendly GUI.

# How to run section
Open "Final System" folder and run the "RunModel" program to see the full system.
When prompted to input a start location, ball position and end location by the GUI please
make sure all three have been given positions on the map, if they have not the program
will crash.
Depending on how the map is arranged the simulation will take around 2 hours to run on a 
decent peformance computer.

  
# References
[1] S. Yang, 'QuadrupedSim', 2.0, 2018. [Source Code]. Accessed: Feb. 10, 2023. Available: https://github.com/ShuoYangRobotics/QuadrupedSim/blob/master/init_quad_new_leg_raibert_strategy_v2.m
[2] S. Miller, 'Running Robot Model in Simscape', 23.1.2.5, 2023. [Source Code]. Accessed: May. 22, 2023. Available: https://www.mathworks.com/matlabcentral/fileexchange/64237-running-robot-model-in-simscape
