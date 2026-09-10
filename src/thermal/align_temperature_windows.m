function outputFiles = align_temperature_windows(folderPath)

% Input: *_full_temperature_curves.xlsx files in folderPath


% Output: *_aligned_temperature_windows.xlsx files



    validate_input_folder(folderPath);
    fileList = list_stage_files(folderPath, '_full_temperature_curves');
    outputFiles = strings(numel(fileList), 1);

    for fileIndex = 1:numel(fileList)
        inputFile = fullfile(folderPath, fileList(fileIndex).name);
        raw = readcell(inputFile);
        inputHeader = raw(1, :);
        body = raw(2:end, :);

        numberOfColumns = size(body, 2);
        alignedMatrix = [];

        for signalColumn = 2:2:numberOfColumns
            temperatureColumn = signalColumn - 1;
            temperature = cell_column_to_numeric(body(:, temperatureColumn));
            signal = cell_column_to_numeric(body(:, signalColumn));

            [~, midpointIndex] = min(abs(signal - 0.5));
            midpointTemperature = temperature(midpointIndex);
            alignedTemperature = (midpointTemperature - 20:midpointTemperature + 20)';

            if midpointIndex - 20 <= 0
                missingAtStart = 21 - midpointIndex;
                startSegment = [ones(missingAtStart, 1); signal(1:midpointIndex)];
                if numel(startSegment) < 21
                    startSegment = [startSegment; zeros(21 - numel(startSegment), 1)]; %#ok<AGROW>
                end
            else
                startSegment = signal(midpointIndex - 20:midpointIndex);
            end

            if midpointIndex + 20 > numel(signal)
                missingAtEnd = midpointIndex + 20 - numel(signal);
                endSegment = [signal(midpointIndex:end); zeros(missingAtEnd, 1)];
                if numel(endSegment) < 21
                    endSegment = [endSegment; zeros(21 - numel(endSegment), 1)]; %#ok<AGROW>
                end
            else
                endSegment = signal(midpointIndex:midpointIndex + 20);
            end

            alignedSignal = [startSegment; endSegment(2:end)];
            alignedMatrix = [alignedMatrix, alignedTemperature, alignedSignal]; %#ok<AGROW>
        end

        headerRow = inputHeader;
        for temperatureColumn = 1:2:numberOfColumns
            headerRow{temperatureColumn} = 'Temperature';
        end

        outputFile = make_output_path(inputFile, '_aligned_temperature_windows');
        write_header_and_matrix(outputFile, headerRow, alignedMatrix);
        outputFiles(fileIndex) = string(outputFile);
    end
end
