 # DMC 

Matlab implementation of the diffusion process model (Diffusion Model
for Conflict Tasks, DMC) presented in Automatic and controlled stimulus
processing in conflict tasks: Superimposed diffusion processes and delta
functions
(https://www.sciencedirect.com/science/article/pii/S0010028515000195). 

NB. See also R/Cpp package DMCfun for further functionality including fitting
procedures.

## Installation
git clone https://github.com/igmmgi/DMCmatlab.git

## Basic Examples
```matlab
res = dmcSim(); % Fig 3
```
![alt text](/figures/figure1.png)

```matlab
res = dmcSim('tau', 150);  % Fig 4
```
![alt text](/figures/figure2.png)
