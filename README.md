# What is NanoSilicon Oxidation
Nano Silicon Oxidation is when we thermally, chemically or natively create silicon oxide films in either wet or dry conditions. There are two main models that are used to predict the silicon oxide growth. 
Massoud and Deal-Grove. My current model specifically looks into thermal oxidation. The Massoud model is actually an enhancement on the Deal-Grove model that can give better predictions when working below 25 nm. 
The only issue is that while it is possible to extrapolate the results, the original Massoud Method is only verified upto 1000 C and not including 1000 C so I decided to limit my simulator to 999.9 C. Another
limitation is Massoud cannot be used for wet oxidation, only Deal-Grove can be used there. (Which is why it's specifically a Dry Oxidation simulator) In this readme, I'll cover
more about my decisions and also give out the references for making the model

# Equations used
The Deal-Grove's equation is the equation of thickness and time which can be rearranged. The equation also accounts for the initial time. The Massoud's equation is slightly complicated. The original equation is a differential equation with enhancements parameters that I couldn't find published. The differential equation is also not solvable 
analytically and needs numerical methods to solve. As a result I found another source that covers the time based equation of Massoud which could be more easily integrated to 
solve for thickness. The issue was though that we want to solve for time not thickness but the work around for that is to arrange the equation so you are evaluating the change 
in thickness between the one using the equation and the final thickness, then set that to zero and use fzero to find a time solution for the equation. 

# The Coefficients used
My current model uses specific coefficients based on the crystal structure of the Silicon chosen. Both models use the Arrhenius relationship to find B and B/A and use that to find
B and A but the exact constants used are different for both equations. The enhancements terms include time dependent coeffecients that are different for different crystal structures

# Additional Features
**Three Tabs**: There are three tabs, one for prediction using Massoud, one using Deal-Grove and one using both which gives the oxidation time using both methods and the percentage
difference 
**Export**: You can export the data from the fitted curve as a csv file. 

# Validation
I used U of A's NanoFab to validate my predicted values with their predicted values. I was getting really close values but I decided to run a more official test by running 5
test using different crystal structures, Massoud, Deal-Grove, temperature and initial and final thickness level and achieved a < 0.5 % difference  

# References 
Deal, B. E., & Grove, A. S. (1965). General Relationship for the Thermal Oxidation of Silicon. Journal of Applied Physics, 36(12), 3770–3778. https://doi.org/10.1063/1.1713945 [1]



Massoud, H. Z., Plummer, J. D., & Irene, E. A. (1985). Thermal Oxidation of Silicon in Dry Oxygen: Growth-Rate Enhancement in the Thin Regime I. Experimental Results. Journal of The Electrochemical Society, 132(11), 2685–2693. https://doi.org/10.1149/1.2113648 [2]



Massoud, H. Z., Plummer, J. D., & Irene, E. A. (1985). Thermal Oxidation of Silicon in Dry Oxygen: Accurate Determination of the Kinetic Rate Constants. Journal of The Electrochemical Society, 132(7), 1745–1753. https://doi.org/10.1149/1.2114204 [3]



Massoud, H. Z., & Plummer, J. D. (1987). Analytic Relationship for the Oxidation of Silicon in Dry Oxygen in the Thin-Film Regime. Journal of Applied Physics, 62(8), 3416–3423. https://doi.org/10.1063/1.365382 [4]



Hollauer, C. (2007). Modeling of Thermal Oxidation and Stress Effects. Doctoral dissertation, Vienna University of Technology. https://www.iue.tuwien.ac.at/publist/pdf/20.500.12708_14629.pdf   [5]
