function outputFile = sample_integer_temperatures(inputFile)

% Output: integer_temperature_samples.xlsx


    validate_input_file(inputFile);

    raw = readcell(inputFile);
    inputHeader = raw(1, :);
    body = raw(2:end, :);

    numberOfColumns = size(body, 2);
    numberOfPairs = numberOfColumns / 2;
    pairData = cell(1, numberOfPairs);
    maximumHeight = 0;

    for pairIndex = 1:numberOfPairs
        temperatureColumn = 2 * pairIndex - 1;
        signalColumn = 2 * pairIndex;

        temperature = cell_column_to_numeric(body(:, temperatureColumn));
        signal = cell_column_to_numeric(body(:, signalColumn));

        validRows = ~isnan(temperature) & ~isnan(signal);
        temperature = temperature(validRows);
        signal = signal(validRows);

        closestValues = [];

        for integerTemperature = 0:100
            distance = abs(temperature - integerTemperature);
            closestMask = distance == min(distance);

            if any(closestMask)
                candidatePairs = [temperature(closestMask), signal(closestMask)];
                for candidateIndex = 1:size(candidatePairs, 1)
                    candidate = candidatePairs(candidateIndex, :);
                    if isempty(closestValues) || ~any(ismember(candidate, closestValues, 'rows'))
                        closestValues = [closestValues; candidate]; %#ok<AGROW>
                    end
                end
            end
        end

        pairData{pairIndex} = closestValues;
        maximumHeight = max(maximumHeight, size(closestValues, 1));
    end

    outputMatrix = NaN(maximumHeight, numberOfColumns);
    for pairIndex = 1:numberOfPairs
        values = pairData{pairIndex};
        outputMatrix(1:size(values, 1), 2 * pairIndex - 1:2 * pairIndex) = values;
    end

    headerRow = inputHeader;
    for temperatureColumn = 1:2:numberOfColumns
        headerRow{temperatureColumn} = 'Temperature';
    end

    outputFile = make_output_path(inputFile, '_integer_temperature_samples');
    write_header_and_matrix(outputFile, headerRow, outputMatrix);
end
