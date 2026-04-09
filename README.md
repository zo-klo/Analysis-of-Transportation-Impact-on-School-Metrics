# High School Quality and Subway Access in New York City

**Author:** Zoe Frazer-Klotz | **Date:** December 2025

---

## Executive Summary

Public transportation is uniquely central to New York City life, to the extent that the city gives public high school students free subway and bus rides to commute to school. But are all students commuting equally? This study asks whether high-performing schools are disproportionately located near more convenient subway access (as measured by number of unique subway lines within .5 and 1mi buffer zones); and if so, whether that constitutes a structural inequity embedded in the built environment.

Using Using GIS analysis, spatial autocorrelation tests, and multivariate regression across 473 NYC public high schools, this project finds **mixed evidence for a transit-performance link**. Distance to the nearest subway station was not a significant predictor of school performance. However, **the number of unique subway lines within a one-mile radius was a small but statistically significant positive predictor** of performance scores (β = 0.008, p = 0.007). This scale-dependent effect—insignificant at half a mile, significant at one mile—suggests that broader network connectivity, not just proximity, may matter for school outcomes.

Critically, the strongest predictors of school performance were **within-school demographic factors**: the share of English Language Learners, the share of students with IEPs, and the instructional environment score. Tract-level income and child poverty rates were *not* significant, suggesting that NYC's school choice policies may partially decouple school quality from neighborhood socioeconomic conditions—but not from student population characteristics.

**The core policy implication**: transit inequity and educational inequity intersect, but the mechanism is more nuanced than simple station proximity. Subway network density (particularly at broader scales) appears more relevant than raw distance, and borough-level differences likely mask important variation that citywide analysis cannot capture.

---

## Research Question

> Does subway access predict NYC high school academic performance, after controlling for student demographics and neighborhood socioeconomic factors?

NYC is unique among American cities in that many teens commute to school by subway, rather than school bus or car. Given documented socioeconomic disparities in subway access (Baghestani et al., 2024) and well-established links between school choice policies and student sorting by achievement (Nathanson et al., 2013), this study investigates whether transit access is an additional axis of educational inequity.

---

## Hypotheses

1. Schools **nearer** to subway stations will have higher performance scores.
2. Schools with **greater variety of nearby subway lines** (within 0.5 and 1 mile radii) will have higher performance scores.

**Result:** Hypothesis 1 was **not supported**. Hypothesis 2 was **partially supported**, with a significant positive effect only at the one-mile radius.

---

## Data

| Variable | Description | Source |
|---|---|---|
| `PerfScr` | School performance score (0–1.08), composite of Regents scores, graduation rates, post-secondary enrollment | NYC DOE 2023–24 School Quality Report |
| `sb_l_05` | Avg. unique subway lines within 0.5 mi of school | MTA Subway Stations / NYC Open Data |
| `sb_ln_1` | Avg. unique subway lines within 1 mi of school | MTA Subway Stations / NYC Open Data |
| `nrst_sb_m` | Distance (meters) to nearest subway station | MTA / computed in R via `nngeo` |
| `ELL_pct` | Percent English Language Learners | NYC DOE |
| `IEP_pct` | Percent students with Individualized Education Plans | NYC DOE |
| `chld_pv` | Number of children in poverty per census tract | ACS 2023 5-Year Estimate |
| `Med_ncm` | Median household income in census tract | ACS 2023 5-Year Estimate |
| `InstrEn` | Percent positive ratings for instructional environment | NYC DOE |

- **N = 473** NYC public high schools
- Census tract geometry: TIGER/Line 2023, reprojected to CRS 3857
- Spatial weights: Queen contiguity, row-standardized (`schools_shapeweight`)

---

## Maps

### Map 1: Average High School Performance Scores Across NYC Census Tracts

![Average Performance Score for High Schools across NYC Census Tracts](Map_1-_Average_Performance_Scores_for_High_Schools_across_NYC.png)

Most NYC census tracts contain no high school at all. Among those that do, performance scores are unevenly distributed. There is no single concentrated zone of high-performing schools; instead, high-performing and low-performing schools appear in close geographic proximity throughout the city. This spatial intermixing reflects the city's school choice system, in which students are not restricted to a neighborhood school, weakening the typical link between residential location and school quality.

---

### Map 2: Distance to Nearest Subway Station over Average Tract Performance

![Distance to Nearest Subway Station from High School over Average HS Performance Score in Census Tract](dist_to_nearest_subway__points__over_mean_tract_perf_score.png)

The vast majority of NYC high schools—particularly in Manhattan and western Brooklyn—lie within 69 to 1,178 meters of their nearest subway station. Schools farther from the subway cluster in eastern Queens, parts of the Bronx, and Staten Island. However, this geographic distance does not appear to correlate with performance score in any consistent way, consistent with the non-significant regression result for Hypothesis 1 (β = 0.00001, p = 0.111).

---

### Map 3: Performance Scores over Average Number of Train Lines within 1 Mile

![Performance Scores over Average Number of Train Lines Within One Mile Radius of Tract High Schools](perf_over_one_mi_radius.png)

High-performing schools in lower Manhattan are concentrated in areas with the densest subway line access (14–19 unique lines within one mile). Outside of Manhattan, however, the relationship between transit density and performance is less clear. This geographic concentration of high performers in lower Manhattan may be driving the significant one-mile subway coefficient, and future research should test this by analyzing boroughs separately.

---

### Map 4: Performance Scores over Train Lines within 0.5 Miles

![School Performance Scores over Average Number of Train Lines within .5 Miles of Schools](average_performance_score_over__5_mi.png)

At the narrower half-mile radius, the relationship between subway line density and performance is weaker and turns marginally negative (β = −0.008, p = 0.069). This scale-dependent reversal is notable: in hyper-dense transit zones, many schools of varying quality share the same immediate transit environment, compressing any signal. At one mile, broader network connectivity provides a more meaningful differentiator.

---

### Map 5: NYC High School Performance Scores over Median Tract Income

![NYC High School Location and Average Performance Score over Median Income of Census Tract](performance_score_over_median_tract_income__2.png)

Despite expectations, tract-level median income was not a significant predictor of school performance (β ≈ 0, p = 0.961). While lower Manhattan's wealthy tracts do host several high-performing schools, low- and medium-income neighborhoods in western Queens and south Brooklyn also contain above-average schools. This supports prior findings from Schwartz et al. (2014) that NYC school choice policies weaken the conventional link between neighborhood wealth and school quality.

---

### Map 6: Number of Train Lines within 0.5 Miles over Average Tract Performance

![High School locations and Number of Train Lines within .5 mile radius over Average HS Performance Score in Census Tract](Map_2-_Number_of_stations_in__5_mile_radius_over_average_performance_in_tract.png)

---

## Spatial Autocorrelation Analysis

### Global Moran's I

A global Moran's I test (999 permutations) found modest but statistically significant positive spatial autocorrelation in performance scores (I = 0.075, p = 0.001). Notably, the Moran scatterplot revealed a left-hand tail of low-performing outlier schools that exhibit *less* clustering than the rest—and when isolated, these schools display a *negative* spatial autocorrelation (I = −0.113, p = 0.001). This suggests a subset of low-performing schools are situated near clusters of higher-performing schools, potentially a byproduct of the city's school choice geography.

### LISA Cluster Maps

Local Indicators of Spatial Association (LISA) were computed at two significance thresholds to identify local performance clusters.

**LISA at p < 0.05**

![LISA at 0.05 level](LISA_05_level.png)

**LISA at p < 0.01**

![LISA at 0.01 level](LISA_01_level.png)

| Cluster Type | p < 0.05 | p < 0.01 |
|---|---|---|
| High-High (high school near other high-performers) | 41 | 9 |
| Low-Low (low school near other low-performers) | 31 | 14 |
| Low-High (low school near high-performers) | 23 | 7 |
| High-Low (high school near low-performers) | 13 | 5 |
| Not Significant | 395 | 468 |

The clustering is real but modest. Low-performing schools show somewhat more tendency to cluster together than high-performing ones, consistent with Nathanson et al. (2013)'s finding that low-achieving students tend to attend schools concentrated in lower-income neighborhoods. The number of Low-High outliers (23 at p < 0.05) reflects NYC's school choice dynamics: high-performing schools located in or near lower-performing neighborhoods.

---

## Regression Results

### Table 1: Spatial Dependence Diagnostic Tests

| Test | MI / DF | Value | p-value |
|---|---|---|---|
| Moran's I (error) | 0.0236 | 1.496 | 0.135 |
| Lagrange Multiplier (lag) | 1 | 1.331 | 0.249 |
| Robust LM (lag) | 1 | 0.183 | 0.669 |
| Lagrange Multiplier (error) | 1 | 1.156 | 0.282 |
| Robust LM (error) | 1 | 0.007 | 0.932 |
| LM (SARMA) | 2 | 1.339 | 0.512 |

None of the six spatial dependence tests—including Moran's I on residuals, and Lagrange Multiplier lag, error, and SARMA tests—approached statistical significance. This indicates no meaningful spatial autocorrelation in model residuals, confirming that **OLS is the appropriate estimator** for this data. Spatial lag and spatial error models were estimated for robustness; neither improved fit, and their spatial coefficients (ρ and λ) were not significant.

---

### Table 2: OLS Regression Results (N = 473)

| Variable | Coefficient | Std. Error | t-Statistic | p-value |
|---|---|---|---|---|
| Constant | 0.563 | 0.041 | 13.83 | < 0.001 *** |
| Subway lines within 0.5 mi | −0.008 | 0.004 | −1.82 | 0.069 † |
| Subway lines within 1 mi | 0.008 | 0.003 | 2.70 | 0.007 ** |
| % ELL students | −0.482 | 0.049 | −9.87 | < 0.001 *** |
| Child poverty in tract | −0.00002 | 0.00003 | −0.59 | 0.556 |
| % IEP students | −1.001 | 0.109 | −9.18 | < 0.001 *** |
| Median income in tract | ~0.000 | ~0.000 | −0.05 | 0.961 |
| Instructional environment % positive | 0.244 | 0.035 | 6.92 | < 0.001 *** |
| Distance to nearest station (m) | 0.00001 | 0.00001 | 1.59 | 0.111 |

**Adjusted R² = 0.276 | F(8, 464) = 23.50, p < 0.001**

*Significance codes: *** p < 0.01 · ** p < 0.05 · † p < 0.10*

**Additional diagnostics:**
- Jarque-Bera (normality): 221.39, df = 2, p < 0.001 — errors are not normally distributed
- Breusch-Pagan (heteroskedasticity): 91.23, p < 0.001 — variance of residuals is non-constant
- Koenker-Bassett: 41.63, p < 0.001 — confirms heteroskedasticity

Heteroskedasticity is present across all model specifications. OLS coefficient estimates remain consistent but standard errors should be interpreted with caution; robust standard errors are recommended in future work.

---

### Table 3: Model Comparison (OLS vs. Spatial Models)

| Model | Adj. R² | Log-Likelihood | AIC | Spatial Coefficient | p |
|---|---|---|---|---|---|
| OLS | 0.276 | 160.85 | −303.70 | — | — |
| Spatial Lag | ~0.291 | 161.43 | −302.86 | ρ = 0.086 | 0.298 |
| Spatial Error | ~0.291 | 161.38 | −304.76 | λ = 0.094 | 0.303 |

The spatial models produced marginal gains in log-likelihood over OLS, but the Likelihood Ratio Tests for both failed to reject the null of no spatial dependence (LR p ≈ 0.28–0.30). **OLS is retained as the primary model.**

---

## Key Findings

**On subway proximity (Hypothesis 1 — Not Supported):**
Distance to the nearest subway station was not a significant predictor of school performance (p = 0.111). Most NYC high schools—especially in dense boroughs—are already within walkable distance of at least one station, leaving little variance to explain. Geographic access to *some* subway stop is not the binding constraint.

**On subway network variety (Hypothesis 2 — Partially Supported):**
A scale-dependent effect emerged: at 0.5 miles, subway line variety was marginally negative (p = 0.069); at 1 mile, it was a small but significant positive predictor (β = 0.008, p = 0.007). Broader network connectivity—which increases a student's ability to reach a school *of their choice* without transfers—may matter more than having a station immediately outside the door.

**On student demographics:**
ELL enrollment (β = −0.482) and IEP enrollment (β = −1.001) are the dominant predictors of lower performance, with large, highly significant coefficients. The instructional environment rating is the strongest positive predictor (β = 0.244). These within-school factors dwarf the transit effects.

**On neighborhood socioeconomics:**
Neither median tract income nor child poverty rate was a significant predictor of performance. This is in contrast to findings from British school systems (Conduit et al., 1996) and supports Schwartz et al. (2014)'s argument that NYC school choice policies break the conventional link between neighborhood wealth and school quality—though student-level socioeconomic sorting persists through ELL and IEP rates.

---

## Real-World Implications

**1. Transit equity ≠ just station proximity.**
Policymakers focused on improving educational equity through transportation should look beyond whether schools are "near" a station. Network connectivity—the number of lines accessible within a broader radius—may be more consequential for whether students can feasibly reach a school of their choice. Outer-borough transit expansion (particularly in eastern Queens, the eastern Bronx, and Staten Island, where schools are farthest from any station) could meaningfully expand the effective school choice set for students in those areas.

**2. School choice amplifies commute burdens for disadvantaged students.**
Cordes & Schwartz (2018) found that students who use public transportation to attend choice schools tend to have lower-quality zoned schools—meaning transit is a necessity, not an amenity, for a better education. This study's finding that broader subway network access correlates with higher performance reinforces that transit infrastructure is part of the educational equity equation, even if its effect size is small.

**3. The Manhattan effect warrants scrutiny.**
The significant one-mile transit coefficient may be substantially driven by lower Manhattan, where elite high-performing schools (including specialized high schools) co-locate with the city's densest transit network. If so, citywide transit investment would not automatically improve outcomes in lower-performing boroughs. Borough-stratified analysis is needed before drawing policy conclusions about transit expansion as an educational intervention.

**4. Within-school resources remain the primary lever.**
The outsized predictive power of ELL and IEP shares, and of instructional environment ratings, means that interventions targeting school-level resources—bilingual instruction, special education staffing, and teaching quality—will have larger effects on performance than transit infrastructure changes. Transit access can expand opportunity; it cannot substitute for school-level investment.

**5. Data gaps limit the current analysis.**
This study lacks student-level commute data. Schools where the majority of students commute long distances by subway are likely more sensitive to transit network quality than schools with primarily local enrollment. Future research with origin-destination commute data could more precisely identify the schools and boroughs where transit improvements would have the greatest educational impact.

---

## Methods

- **Software**: R (`sf`, `dplyr`, `nngeo`, `ggplot2`, `tmap`), QGIS (mapping, spatial joins), GeoDa (spatial regression, LISA)
- **Spatial weights**: Queen contiguity, row-standardized
- **Buffer analysis**: 0.5-mile and 1-mile radii around each school; unique subway lines counted per buffer (intersects join); schools with no lines counted as 0
- **Nearest station distance**: Computed in R using `nngeo`
- **Tract-level aggregation**: QGIS "join attributes by location – summary" to generate tract-level means and counts
- **Classification**: Natural Breaks (Jenks) for all choropleth maps
- **LISA**: 999 permutations, Monte Carlo simulation, reported at p < 0.05 and p < 0.01

---

## Limitations

- Heteroskedasticity is present across all model specifications; robust standard errors should be used in future work.
- Results are not broken down by borough; citywide analysis likely masks meaningful geographic variation, particularly the Manhattan effect described above.
- No student-level commute data is available; the study cannot distinguish schools with high transit-dependent populations from those with predominantly local students.
- Schools sharing a building are treated as independent observations, which may introduce measurement error for transit variables.
- The 2023–24 School Quality Report was slightly outdated by the time of analysis (the 2025 SQR was released mid-project).

---

## Repository Structure

```
├── data/
│   ├── schools/          # School point shapefile (geometry + SQR + ACS variables)
│   ├── tracts/           # NYC census tract polygons (geopackage)
│   └── mta/              # MTA subway station point data
├── maps/                 # QGIS project files and exported map images
├── regression/           # GeoDa output files (OLS, spatial lag, spatial error)
├── scripts/              # R data cleaning, spatial join, and buffer scripts
└── README.md
```

---

## References

Baghestani, A., Nikbakht, M., Kucheva, Y., & Afshar, A. (2024). Assessing spatial and racial equity of subway accessibility: Case study of New York City. *Cities, 155*, 105489.

Conduit, E., Brookes, R., Bramley, G., & Fletcher, C. L. (1996). The value of school locations. *British Educational Research Journal, 22*(2), 199–206.

Cordes, S. A., & Schwartz, A. E. (2019). *Does pupil transportation close the school quality gap? Evidence from New York City.* Urban Institute.

Nathanson, L., Corcoran, S., & Baker-Smith, C. (2013). *High school choice in New York City: A report on the school choices and placements of low-achieving students.* Institute for Education and Social Policy.

Schwartz, A. E., Voicu, I., & Horn, K. M. (2014). Do choice schools break the link between public schools and property values? Evidence from house prices in New York City. *Regional Science and Urban Economics, 49*, 1–10.

---

## Citation

> Frazer-Klotz, Z. (2025). *High School Quality and Subway Access in New York City.* GitHub. https://github.com/zo-klo/Analysis-of-Transportation-Impact-on-School-Metrics
