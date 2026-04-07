# Analysis of Transportation Impact on School Performance Metrics in NYC

This project investigates whether proximity to subway infrastructure is associated with high school academic performance across New York City census tracts. Using spatial econometric methods, GIS mapping, and multivariate regression, we analyze 473 high schools across all five boroughs to understand how transit access, income, and student demographics relate to school performance scores.

---

## Research Question

> Does proximity to New York City subway stations predict high school academic performance, and does this relationship hold after controlling for socioeconomic and demographic factors?

---

## Data

| Variable | Description | Source |
|---|---|---|
| `PerfScr` | School performance score (0–1.08 scale) | NYC DOE |
| `sb_l_05` | Avg. number of train lines within 0.5 mi of school | MTA / GIS |
| `sb_ln_1` | Avg. number of train lines within 1 mi of school | MTA / GIS |
| `nrst_sb_m` | Distance (meters) to nearest subway station | MTA / GIS |
| `ELL_pct` | Percent English Language Learners | NYC DOE |
| `IEP_pct` | Percent students with Individualized Education Plans | NYC DOE |
| `chld_pv` | Child poverty rate in tract | ACS |
| `Med_ncm` | Median household income in tract | ACS |
| `InstrEn` | Instructional environment score | NYC DOE |

- **N = 473** high schools across NYC census tracts
- Unit of analysis: individual school (geolocated), aggregated to tract for choropleth mapping
- Spatial weights matrix: queen contiguity (`schools_shapeweight`)

---

## Maps

### Map 1: Average High School Performance Scores Across NYC

![Average Performance Score for High Schools across NYC Census Tracts](Map_1-_Average_Performance_Scores_for_High_Schools_across_NYC.png)

Performance scores are unevenly distributed across the city. Tracts with the highest-performing schools (dark red, 0.7–1.08) appear in parts of Manhattan and isolated pockets in the outer boroughs. The majority of tracts fall in the middle range (0.38–0.52), with the lowest-performing schools concentrated in the Bronx and parts of Brooklyn.

---

### Map 2: Train Line Density (0.5 mi radius) over Average Tract Performance

![High School locations and Number of Train Lines within .5 mile radius over Average HS Performance Score in Census Tract](Map_2-_Number_of_stations_in__5_mile_radius_over_average_performance_in_tract.png)

Schools with access to more train lines (darker green circles) cluster heavily in Manhattan and the northern Bronx. While some high-transit areas overlap with higher-performing tracts, the pattern is not uniform—many schools in dense transit zones still show moderate performance scores—suggesting transit alone is insufficient to explain outcomes.

---

### Map 3: Performance Scores over Average Number of Train Lines within 1 Mile

![Performance Scores over Average Number of Train Lines Within One Mile Radius of Tract High Schools](perf_over_one_mi_radius.png)

---

### Map 4: School Performance over Median Census Tract Income

![NYC High School Location and Average Performance Score over Median Income of Census Tract](performance_score_over_median_tract_income__2.png)

The relationship between income and performance is visible but imperfect. High-performing schools (dark green diamonds) appear more frequently in wealthier tracts, particularly in lower Manhattan. However, multiple high-performing schools exist in lower-income tracts, pointing to the importance of school-level factors like instructional environment.

---

### Map 5: Distance to Nearest Subway Station over Average Tract Performance

![Distance to Nearest Subway Station from High School over Average HS Performance Score in Census Tract](dist_to_nearest_subway__points__over_mean_tract_perf_score.png)

Schools farther from any subway station are concentrated in Staten Island and outer Queens and Brooklyn—areas that generally show lower average tract performance scores. However, proximity to a station alone does not guarantee strong performance, reinforcing that the relationship is mediated by other factors.

---

## Spatial Autocorrelation (LISA Analysis)

Local Indicators of Spatial Association (LISA) were computed at two significance levels to identify performance clusters and spatial outliers.

### LISA at p < 0.05

![LISA at 0.05 level](LISA_05_level.png)

### LISA at p < 0.01

![LISA at 0.01 level](LISA_01_level.png)

At the p < 0.05 level, 41 **High-High** clusters (schools surrounded by other high-performing schools) appear, primarily in upper Manhattan. 31 **Low-Low** clusters are also evident, concentrated in parts of the Bronx. The pattern weakens at p < 0.01, with only 9 HH and 14 LL clusters remaining, indicating that while some spatial clustering of performance exists, global autocorrelation is modest.

> Moran's I (error) = 0.0236, p = 0.135 — spatial autocorrelation in residuals is present but not statistically significant, supporting the use of OLS as the primary model.

---

## Models

### Table 1: OLS Regression — Spatial Dependence Diagnostics

| Test | MI / DF | Value | Prob |
|---|---|---|---|
| Moran's I (error) | 0.0236 | 1.4958 | 0.135 |
| LM (lag) | 1 | 1.3312 | 0.249 |
| Robust LM (lag) | 1 | 0.1827 | 0.669 |
| LM (error) | 1 | 1.1558 | 0.282 |
| Robust LM (error) | 1 | 0.0073 | 0.932 |
| LM (SARMA) | 2 | 1.3385 | 0.512 |

None of the spatial dependence tests reach conventional significance levels, indicating that OLS residuals do not exhibit meaningful spatial autocorrelation. Spatial lag and spatial error models were estimated for robustness but neither improved fit significantly.

---

### Table 2: OLS Regression Coefficients (N = 473)

| Variable | Coefficient | Std. Error | t-Statistic | p-value |
|---|---|---|---|---|
| Constant | 0.563 | 0.041 | 13.83 | 0.000 *** |
| Train lines within 0.5 mi (`sb_l_05`) | −0.008 | 0.004 | −1.82 | 0.069 · |
| Train lines within 1 mi (`sb_ln_1`) | 0.008 | 0.003 | 2.70 | 0.007 ** |
| % ELL students | −0.482 | 0.049 | −9.87 | 0.000 *** |
| Child poverty rate | −0.000015 | 0.000026 | −0.59 | 0.556 |
| % IEP students | −1.001 | 0.109 | −9.18 | 0.000 *** |
| Median income | ~0.000 | 0.000 | −0.05 | 0.961 |
| Instructional environment | 0.244 | 0.035 | 6.92 | 0.000 *** |
| Distance to nearest station (m) | 0.0000114 | 0.0000072 | 1.59 | 0.111 |

**R² = 0.288 | Adjusted R² = 0.276 | F = 23.50, p < 0.001**

*Significance: *** p < 0.01, ** p < 0.05, · p < 0.10*

---

### Table 3: Model Comparison

| Model | R² | Log-Likelihood | AIC | Spatial Term (p) |
|---|---|---|---|---|
| OLS | 0.288 | 160.85 | −303.70 | — |
| Spatial Lag | 0.291 | 161.43 | −302.86 | ρ = 0.086 (p = 0.298) |
| Spatial Error | 0.291 | 161.38 | −304.76 | λ = 0.094 (p = 0.303) |

The spatial lag and spatial error models show marginal improvement in log-likelihood over OLS, but neither spatial coefficient (ρ or λ) reaches statistical significance. The Likelihood Ratio Tests for both spatial models also fail to reject the null of no spatial dependence (LR p ≈ 0.28–0.30). **OLS remains the preferred model.**

---

## Key Findings

- **Transit access at the 1-mile radius is positively associated** with performance scores (`sb_ln_1`, β = 0.008, p = 0.007), even after controlling for demographics.
- **Transit access at the 0.5-mile radius is marginally negatively associated** (`sb_l_05`, β = −0.008, p = 0.069), possibly reflecting collinearity or congestion effects in hyper-dense transit zones.
- **Distance to the nearest subway station is not significant** (p = 0.111), suggesting that station *density* matters more than simple proximity.
- **ELL enrollment and IEP enrollment are the strongest negative predictors** of performance, consistent with the broader literature on resource needs.
- **Instructional environment is the strongest positive predictor**, underscoring the primacy of school-level factors.
- **Median income and child poverty rate are not significant** once other covariates are included, suggesting collinearity with ELL/IEP and instructional measures.
- **Spatial autocorrelation in residuals is weak and non-significant** (Moran's I = 0.024, p = 0.135), and spatial models do not improve on OLS.

---

## Methods

- **Software**: GeoDa (spatial regression and LISA), ArcGIS/QGIS (mapping), Python (data preparation)
- **Spatial weights**: Queen contiguity, row-standardized (`schools_shapeweight`)
- **Regression diagnostics**: Breusch-Pagan test for heteroskedasticity (significant across all models — robust SEs recommended), Jarque-Bera for normality, Moran's I and Lagrange Multiplier tests for spatial dependence
- **Classification method**: Natural Breaks (Jenks) for all choropleth maps
- **LISA significance levels**: p < 0.05 and p < 0.01, 999 permutations

---

## Limitations

- Heteroskedasticity is present in all models (Breusch-Pagan p < 0.001); coefficient estimates are consistent but standard errors may be understated.
- The performance score metric combines multiple outcomes and may mask variation in specific academic indicators.
- Transit access is measured at the school level, but students commute from across the city — a student-level origin-destination approach would more precisely capture transit's role.
- Unobserved school-level factors (principal quality, curriculum, peer effects) are captured only partially through the instructional environment score.

---

## Repository Structure

```
├── data/               # Shapefiles and CSV inputs
├── maps/               # QGIS/ArcGIS project files and exported map images
├── regression/         # GeoDa output files (OLS, spatial lag, spatial error)
├── scripts/            # Data cleaning and join scripts
└── README.md
```

---

## Citation

If you use this analysis, please cite:

> [Author(s)]. *Analysis of Transportation Impact on School Performance Metrics in New York City.* GitHub, 2025. https://github.com/zo-klo/Analysis-of-Transportation-Impact-on-School-Metrics
