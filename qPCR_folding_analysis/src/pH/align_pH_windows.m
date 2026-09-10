function outputFiles = align_pH_windows(folderPath)

%  Inputs:  *_pH_transposed.xlsx files in folderPath


%  Outputs:  *_aligned_pH_windows.xlsx files


    validate_input_folder(folderPath);
    fileList = list_stage_files(folderPath, '_pH_transposed');
    outputFiles = strings(numel(fileList), 1);

    for fileIndex = 1:numel(fileList)
        inputFile = fullfile(folderPath, fileList(fileIndex).name);
        raw = readcell(inputFile);
        inputHeader = raw(1, :);
        body = raw(2:end, :);

        pHValues = cell_column_to_numeric(body(:, 1));
        numberOfSeries = size(body, 2) - 1;
        temperatureLabels = inputHeader(2:end);

        firstpH = pHValues(1);
        lastpH = pHValues(end);
        samplingpH = firstpH:0.05:lastpH;

        alignedMatrix = [];

        for seriesIndex = 1:numberOfSeries
            signal = cell_column_to_numeric(body(:, seriesIndex + 1));

            [xFit, yFit] = fit_boltzmann_curve(pHValues, signal, 1000);

            nearestIndices = zeros(numel(samplingpH), 1);
            for sampleIndex = 1:numel(samplingpH)
                [~, nearestIndices(sampleIndex)] = min(abs(xFit - samplingpH(sampleIndex)));
            end

            sampledpH = xFit(nearestIndices);
            sampledSignal = yFit(nearestIndices);

            [~, midpointIndex] = min(abs(sampledSignal - 0.5));
            midpointpH = round(sampledpH(midpointIndex), 2);
            alignedpH = (midpointpH - 1.5:0.05:midpointpH + 1.5)';

            if midpointIndex - 30 <= 0
                missingAtStart = 31 - midpointIndex;
                startSegment = [ones(missingAtStart, 1); sampledSignal(1:midpointIndex)];
                if numel(startSegment) < 31
                    startSegment = [startSegment; zeros(31 - numel(startSegment), 1)]; %#ok<AGROW>
                end
            else
                startSegment = sampledSignal(midpointIndex - 30:midpointIndex);
            end

            if midpointIndex + 30 > numel(sampledSignal)
                missingAtEnd = midpointIndex + 30 - numel(sampledSignal);
                endSegment = [sampledSignal(midpointIndex:end); zeros(missingAtEnd, 1)];
                if numel(endSegment) < 31
                    endSegment = [endSegment; zeros(31 - numel(endSegment), 1)]; %#ok<AGROW>
                end
            else
                endSegment = sampledSignal(midpointIndex:midpointIndex + 30);
            end

            alignedSignal = [startSegment; endSegment(2:end)];
            alignedMatrix = [alignedMatrix, alignedpH, alignedSignal]; %#ok<AGROW>
        end

        headerRow = cell(1, 2 * numberOfSeries);
        for seriesIndex = 1:numberOfSeries
            headerRow{2 * seriesIndex - 1} = 'Temperature';
            headerRow{2 * seriesIndex} = coerce_numeric_label(temperatureLabels{seriesIndex});
        end

        outputFile = make_output_path(inputFile, '_aligned_pH_windows');
        write_header_and_matrix(outputFile, headerRow, alignedMatrix);
        outputFiles(fileIndex) = string(outputFile);
    end
end
