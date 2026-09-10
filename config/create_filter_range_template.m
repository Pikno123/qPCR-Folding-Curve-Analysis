function filterTable = create_filter_range_template(outputFile)

% The 48 series represent pH 3.0 to 12.4 in increments of 0.2.

    if nargin < 1 || strlength(string(outputFile)) == 0
        configFolder = fileparts(mfilename('fullpath'));
        outputFile = fullfile(configFolder, 'filter_ranges.xlsx');
    end

    if isfile(outputFile)
        error(['Filter-range file already exists: %s\n', 'Edit the existing file, or delete/rename it before creating a new template.'], outputFile);
    end

    series = (1:48)';
    pH = (3.0:0.2:12.4)';
    lowerTemperature = NaN(48, 1);
    upperTemperature = NaN(48, 1);

    filterTable = table( series, pH, lowerTemperature, upperTemperature, 'VariableNames', {'Series', 'pH', 'LowerTemperature', 'UpperTemperature'});
    writetable(filterTable, outputFile);
end
