**Analysis of Transportation Impact on School Metrics**

High School Quality and Subway Access in New York City








Overview

This project investigates whether access to public transportation—specifically the New York City subway system—is associated with variation in high school performance.

Using spatial analysis methods, this study evaluates whether:

proximity to subway infrastructure, and
access to multiple transit lines

are predictive of school-level academic outcomes.

The project integrates geospatial data, school performance metrics, and socioeconomic indicators to examine whether the built environment contributes to educational inequality in NYC.

The full paper is included in /paper/.

Research Question

To what extent is school quality in New York City associated with access to public transportation?

Does distance to the nearest subway station predict school performance?
Does the number of accessible subway lines influence school performance?

In a system where students rely heavily on public transit, transportation represents a potential structural mechanism shaping access to educational opportunity .

Data

Spatial Data

NYC School Point Locations (2024)
MTA Subway Stations
NYC Census Tracts (TIGER/Line)

Socioeconomic Data

American Community Survey (ACS), 2023 (5-year estimates)

School Performance Data

NYC DOE School Quality Reports (2023–2024)
Key Variables

Dependent Variable

School Performance Score (composite of Regents performance, graduation rates, and postsecondary outcomes)

Independent Variables

Distance to nearest subway station
Number of unique subway lines within:
0.5 mile
1 mile

Controls

% English Language Learners
% Students with IEPs
Median income (tract)
Child poverty rate (tract)
Methods
Spatial joins linking schools, census tracts, and subway infrastructure
Buffer analysis (0.5 and 1 mile) to measure transit accessibility
Nearest-neighbor distance calculations
Global Moran’s I and Local Moran’s I (LISA) for spatial clustering
Ordinary Least Squares (OLS) regression with diagnostics
Spatial lag/error models evaluated but not retained

Tools

R (sf, dplyr, tmap, nngeo, ggplot2)
QGIS (mapping, spatial joins)
GeoDa (spatial statistics)
Results
Spatial Distribution of School Performance

School performance exhibits modest spatial clustering (Moran’s I ≈ 0.075), with limited evidence of strong geographic segregation .

Subway Access and School Performance

Distance to the nearest subway station is not a statistically significant predictor of school performance (p ≈ 0.11) .

Transit Connectivity (Line Density)

Lines within 0.5 miles: not significant
Lines within 1 mile: positive and statistically significant, but small effect size (p < 0.01)

This suggests a scale-dependent relationship between transit access and school outcomes.

Socioeconomic Context

Neighborhood income and poverty were not significant predictors
Within-school characteristics (ELL %, IEP %) were strong predictors
Interpretation

The results indicate that transportation access has a limited relationship with school performance:

Proximity to transit does not meaningfully predict outcomes
Broader transit connectivity has a small positive association
Student composition and within-school factors dominate

These findings suggest that:

Educational inequality is not strongly driven by subway access alone
NYC’s school choice system may weaken the link between geography and school quality
Transportation may enable access to better schools without determining their quality
Limitations
No student-level commuting data
No borough-level heterogeneity analysis
Shared school buildings may introduce spatial duplication
Cross-sectional, non-causal design
Performance data limited to 2023–2024



Repository Structure
Analysis-of-Transportation-Impact-on-School-Metrics/
│
├── code/          # Data cleaning, spatial processing, modeling
├── data/          # Raw and processed datasets
├── maps/          # Final visualizations used in analysis
├── output/        # Tables and model results
├── paper/         # Final paper (PDF)
└── README.md
Reproducibility
Clone the repository
Install required R packages
Run scripts in code/
Generate spatial features and models
Use QGIS/GeoDa for mapping and diagnostics
Author

Zoe Frazer-Klotz
M.A. Candidate, Quantitative Methods in the Social Sciences
Columbia University
