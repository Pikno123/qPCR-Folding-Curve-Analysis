# qPCR Folding-Curve Analysis

MATLAB scripts for processing qPCR melting data, fitting temperature-dependent folding curves, calculating thermodynamic parameters, and performing temperature- and pH-dependent Hill analysis.

## Requirements

- MATLAB
- Curve Fitting Toolbox


## Project structure

```
qpcr_folding_analysis/
├── README.md
├── example_data/
├── config/
│   ├── create_filter_range_template.m
│   └── filter_ranges.xlsx
└── src/
    ├── preprocessing/
    ├── thermal/
    ├── pH/
    ├── models/
    └── utilities/
```

Place the qPCR Excel file to be analyzed in `example_data/`.

## How to run



### 1. Set up paths and input file

Before running the code, open the `qPCR_folding_analysis` folder in MATLAB and make sure it is the Current Folder.

```matlab
repoRoot = pwd;

addpath(genpath(fullfile(repoRoot, 'src')));
addpath(fullfile(repoRoot, 'config'));

rawFile = fullfile(repoRoot, 'example_data', 'example.xlsx');
```

Replace `example.xlsx` with the name of your own input file when necessary.

### 2. Reformat the qPCR export

```matlab
reformattedFile = reformat_qpcr_export(rawFile);
```

Output:

```text
example_reformatted.xlsx
```

### 3. Calculate adjacent-well ratios

```matlab
ratioFile = calculate_adjacent_ratios(reformattedFile);
```

Output:

```text
example_adjacent_ratios.xlsx
```

### 4. Set the temperature filtering ranges

A predefined `config/filter_ranges.xlsx` file is provided for the example dataset and contains the corresponding temperature filtering ranges. For other datasets, modify these ranges as needed before running the analysis.

The filter table uses:

- numeric lower and upper temperatures: retain that temperature interval;
- `/`: remove entire condition from the analysis;
- both boundaries left blank: retain the entire condition.

Define the filter parameter file:

```matlab
parameterFile = fullfile(repoRoot, 'config', 'filter_ranges.xlsx');
```
Then run the temperature filtering step:

```matlab
filteredFile = filter_temperature_ranges(ratioFile, parameterFile);
```

Output:

```text
example_temperature_filtered.xlsx
```

### 5. Fit temperature-dependent folding curves

```matlab
fittedFile = fit_temperature_folding_curves(filteredFile);
```

Output:

```text
example_temperature_folding_fit.xlsx
```

### 6. Extract thermodynamic parameters

```matlab
thermodynamicFile = extract_thermodynamic_parameters(fittedFile);
```

Output:

```text
example_thermodynamic_parameters.xlsx
```

### 7. Build full temperature folding curves

```matlab
analysisFolder = fileparts(fittedFile);

fullCurveFiles = build_full_temperature_curves(analysisFolder);
```

Output:

```text
example_full_temperature_curves.xlsx
```

## Temperature-dependent Hill analysis

Starting from the full temperature folding curves:

```matlab
alignedTemperatureFiles = align_temperature_windows(analysisFolder);

[temperatureHillInputFiles, temperatureHillSummary] = fit_temperature_hill(analysisFolder);
```

Outputs:

```text
example_aligned_temperature_windows.xlsx
example_temperature_hill_input.xlsx
temperature_hill_results.xlsx
```

## pH-dependent Hill analysis

Starting from the same full temperature folding curves:

```matlab
pHTransposedFiles = transpose_for_pH_analysis(analysisFolder);

alignedpHFiles = align_pH_windows(analysisFolder);

[pHHillInputFiles, pHHillSummary] = fit_pH_hill(analysisFolder);
```

Outputs:

```text
example_pH_transposed.xlsx
example_aligned_pH_windows.xlsx
example_pH_hill_input.xlsx
pH_hill_results.xlsx
```

# Complete command sequence

If `filter_ranges.xlsx` has existed, the complete analysis can be run with:

```matlab
repoRoot = pwd;

addpath(genpath(fullfile(repoRoot, 'src')));
addpath(fullfile(repoRoot, 'config'));

rawFile = fullfile(repoRoot, 'example_data', 'example.xlsx');

reformattedFile = reformat_qpcr_export(rawFile);
ratioFile = calculate_adjacent_ratios(reformattedFile);

parameterFile = fullfile(repoRoot, 'config', 'filter_ranges.xlsx');
filteredFile = filter_temperature_ranges(ratioFile, parameterFile);

fittedFile = fit_temperature_folding_curves(filteredFile);
thermodynamicFile = extract_thermodynamic_parameters(fittedFile);

analysisFolder = fileparts(fittedFile);

fullCurveFiles = build_full_temperature_curves(analysisFolder);

alignedTemperatureFiles = align_temperature_windows(analysisFolder);
[temperatureHillInputFiles, temperatureHillSummary] = fit_temperature_hill(analysisFolder);
    

pHTransposedFiles = transpose_for_pH_analysis(analysisFolder);
alignedpHFiles = align_pH_windows(analysisFolder);
[pHHillInputFiles, pHHillSummary] = fit_pH_hill(analysisFolder);
```

All generated Excel files use descriptive filenames based on the original dataset name.
