function outputFiles = build_full_temperature_curves(folderPath)

% Input: *_temperature_folding_fit.xlsx files in folderPath

% Output: *_full_temperature_curves.xlsx files



    validate_input_folder(folderPath);
    fileList = list_stage_files(folderPath, '_temperature_folding_fit');
    outputFiles = strings(numel(fileList), 1);

    targetTemperature = (5:94)';

    for fileIndex = 1:numel(fileList)
        inputFile = fullfile(folderPath, fileList(fileIndex).name);
        raw = readcell(inputFile);
        inputHeader = raw(1, :);
        body = raw(2:end, :);

        numberOfColumns = size(body, 2);
        outputMatrix = zeros(numel(targetTemperature), numberOfColumns);
        outputMatrix(:, 1:2:end) = repmat(targetTemperature, 1, numberOfColumns / 2);

        for temperatureColumn = 1:2:numberOfColumns
            signalColumn = temperatureColumn + 1;

            temperature = cell_column_to_numeric(body(:, temperatureColumn));
            signal = cell_column_to_numeric(body(:, signalColumn));
            roundedTemperature = round(temperature);

            [~, targetIndices] = ismember(roundedTemperature, targetTemperature);
            validRows = targetIndices ~= 0 & ~isnan(signal);

            % Repeated integer indices intentionally retain the same mapping
            % behavior as the analysis workflow.
            outputMatrix(targetIndices(validRows), signalColumn) = signal(validRows);

            observedTemperature = roundedTemperature(~isnan(roundedTemperature));
            if ~isempty(observedTemperature)
                minimumTemperature = min(observedTemperature);
                maximumTemperature = max(observedTemperature);

                outputMatrix(targetTemperature < minimumTemperature, signalColumn) = 1;
                outputMatrix(targetTemperature > maximumTemperature, signalColumn) = 0;
            end
        end

        headerRow = inputHeader;
        for temperatureColumn = 1:2:numberOfColumns
            headerRow{temperatureColumn} = 'Temperature';
        end

        outputFile = make_output_path(inputFile, '_full_temperature_curves');
        write_header_and_matrix(outputFile, headerRow, outputMatrix);
        outputFiles(fileIndex) = string(outputFile);
    end
end
