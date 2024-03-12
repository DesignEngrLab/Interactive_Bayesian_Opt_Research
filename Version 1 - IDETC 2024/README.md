# Project

There are three folders in this: FireFightingDrones, Synthetic_Cost_Constrained, and MATLAB Bayesian Optimizer.

Any updates made to this repo after the submission date of March 12th, 2024, only affect organization and documentation. Any updates to this project, including changes to the userfeedback system and improvements on the ABMs, will be done in separate repositories.

## Synthetic_Cost_Constrained

This includes the model, the immediate output data, and images from the first case study in the paper. This case study involves simulating a fleet of ocean cleanup devices. Please see the **README.md** in this folder for clarificaton on the agents and how the ABM works.

## FireFightingDrones

This includes the model, the immediate output data, and images from the second case study in the paper. This case study involves simulating a fleet of forest firefighting drones. Please see the **README.md** in this folder for clarificaton on the agents and how the ABM works.


## MATLAB Bayesian Optimizer

There are four subfolders here, each described below.

The original intent was the generalize this, but that had to be changed when moving to the second experiment (since there was some uncertainty incorporation and an additional constraint).

### Dependencies
This contains the GPML library used for this project, which under the FreeBSD license includes the original copywrite notice. It also includes **minimize_noprint.m** which is a modified version of the original GPML function **minimized.m** used for fiting the GP models. The only difference is that it does not print out the progress into the MATLAB command window making it easier for users to navigate. 

### Data

This contains two more subfolders for the Fire Fighting Drones and Synthetic Ocean Cleanup example. They are just excel files for each iteration for reference. 


### User Feedback Support Code

This has the files actually used for the for the user feedback code in the main folder. Some is shared between the two experiments, while others are specific to each case study. They have their own in code comments (which will be improved upon)

- **User_Feedback.m** is the main function for adding in design points and boxing off areas of feasibility. In this iteration it is done before the the optimizer predicts the next point.

- **Bayesian_Optimizer.m** and **Bayesian_Optimizer_FF.m** are the constrained bayesian optimizer for the first and second case studies, respectively. 

- **Next_Point.m** takes the proposed new point and has the user input feasibile.



### Misc

This contains a set of functions that were only used for miscellaneous purposes. Some of which is extra work such as plotting and testing. 