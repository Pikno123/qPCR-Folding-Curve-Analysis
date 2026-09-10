function outputFile = filter_temperature_ranges(inputFile, filterConfig)

%   "/": Exclude the entire series from all downstream analyses.

%    Output: temperature_filtered.xlsx

    validate_input_file(inputFile);

    
    % Read filtering configuration


    if ischar(filterConfig) || (isstring(filterConfig) && isscalar(filterConfig))

        parameterFile = char(filterConfig);

        if ~isfile(parameterFile)
            error('Filter parameter file does not exist: %s', parameterFile);
        end

        configRaw = readcell(parameterFile);


        header = string(configRaw(1, :));

        lowerColumn = find( header == "LowerTemperature", 1);
            

        upperColumn = find( header == "UpperTemperature", 1);
            

        if isempty(lowerColumn) || isempty(upperColumn)
            error(['Filter parameter file must contain ', 'LowerTemperature and UpperTemperature columns.']);
        end

        lowerValues = configRaw(2:end, lowerColumn);
        upperValues = configRaw(2:end, upperColumn);

    elseif istable(filterConfig)

        requiredNames = { 'LowerTemperature',  'UpperTemperature'};

        if ~all(ismember(requiredNames, filterConfig.Properties.VariableNames))
    error('Filter table must contain LowerTemperature and UpperTemperature.');
end

lowerValues = table2cell(filterConfig(:, 'LowerTemperature'));
upperValues = table2cell(filterConfig(:, 'UpperTemperature'));

elseif iscell(filterConfig)

    if size(filterConfig, 2) ~= 2
        error('Cell filter configuration must contain two columns.');
    end

    lowerValues = filterConfig(:, 1);
    upperValues = filterConfig(:, 2);

elseif isnumeric(filterConfig)

    if size(filterConfig, 2) ~= 2
        error('Numeric filter configuration must be N-by-2.');
    end

    lowerValues = num2cell(filterConfig(:, 1));
    upperValues = num2cell(filterConfig(:, 2));

else

    error('Unsupported filter configuration format.');

end


% Read adjacent-ratio workbook

raw = readcell(inputFile);

inputHeader = raw(1, :);
inputBody = raw(2:end, :);

numberOfColumns = size(inputBody, 2);

if mod(numberOfColumns, 2) ~= 0
    error('Input workbook must contain Temperature/signal column pairs.');
end

numberOfPairs = numberOfColumns / 2;

if numel(lowerValues) < numberOfPairs || numel(upperValues) < numberOfPairs
    error('Filter configuration must provide at least %d rows.', numberOfPairs);
end


outputHeader = {};
outputBody = cell(size(inputBody, 1), 0);

outputPairIndex = 0;

for pairIndex = 1:numberOfPairs

    temperatureColumn = 2 * pairIndex - 1;
    signalColumn = 2 * pairIndex;

    lowerEntry = lowerValues{pairIndex};
    upperEntry = upperValues{pairIndex};

    if is_discard_marker(lowerEntry) || is_discard_marker(upperEntry)
        continue;
    end

    pairBody = inputBody(:, [temperatureColumn, signalColumn]);

    lowerBoundary = convert_boundary(lowerEntry);
    upperBoundary = convert_boundary(upperEntry);


    % If BOTH boundaries are numeric, apply filtering

    if ~isnan(lowerBoundary) && ~isnan(upperBoundary)

        temperatureValues = cell_column_to_numeric(pairBody(:, 1));

        validTemperatures = ~isnan(temperatureValues);

        if ~any(validTemperatures)
            error('No valid temperature values found for series %d.', pairIndex);
        end

        [~, lowerIndex] = min(abs(temperatureValues - lowerBoundary));
        [~, upperIndex] = min(abs(temperatureValues - upperBoundary));

        % Boundary order is intentionally ignored.
        firstKeptRow = min(lowerIndex, upperIndex);
        lastKeptRow = max(lowerIndex, upperIndex);

        outsideRange = (1:size(pairBody, 1))' < firstKeptRow | (1:size(pairBody, 1))' > lastKeptRow;

        % Only blank the signal column.
        pairBody(outsideRange, 2) = {''};

    end


    outputPairIndex = outputPairIndex + 1;

    outputColumns = 2 * outputPairIndex - 1 : 2 * outputPairIndex;

    outputBody(:, outputColumns) = pairBody;

    % Preserve the original pH header.
    outputHeader{outputColumns(1)} = 'Temperature';
    outputHeader{outputColumns(2)} = inputHeader{signalColumn};

end


if isempty(outputBody)
    error('All pH series were excluded.');
end


% Write output

outputFile = make_output_path(inputFile, '_temperature_filtered');

write_header_and_cell(outputFile, outputHeader, outputBody);

end


function tf = is_discard_marker(value)

    tf = false;

    if ischar(value) || (isstring(value) && isscalar(value))

        textValue = strtrim(string(value));

        tf = textValue == "/" || textValue == "／";

    end

end


function value = convert_boundary(entry)

% Blank cells to NaN
% Numeric cells to numeric value
% Numeric text to numeric value

    if isempty(entry)
        value = NaN;
        return;
    end

    if isnumeric(entry)

        if isscalar(entry)
            value = double(entry);
        else
            value = NaN;
        end

        return;
    end

    if ismissing(string(entry)) || strlength(strtrim(string(entry))) == 0

        value = NaN;
        return;

    end

    value = str2double(string(entry));

    if isnan(value)
        error('Invalid filter boundary: "%s". Use a number, blank cell, or "/".', string(entry));
    end

end