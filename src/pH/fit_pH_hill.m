function [pHHillInputFiles, pHHillSummary] = fit_pH_hill(folderPath)

% Inputs:  *_aligned_pH_windows.xlsx files in folderPath

%  Outputs: pH_hill_input.xlsx and pH_hill_results.xlsx


    validate_input_folder(folderPath);
    inputFiles = list_stage_files(folderPath, '_aligned_pH_windows');
    pHHillInputFiles = strings(numel(inputFiles), 1);

    for fileIndex = 1:numel(inputFiles)
        alignedFile = fullfile(folderPath, inputFiles(fileIndex).name);
        raw = readcell(alignedFile);
        headerRow = raw(1, :);
        body = raw(2:end, :);

        normalizedBody = body;

        for oddColumn = 1:2:size(body, 2)
            values = cell_column_to_numeric(body(:, oddColumn));
            normalizedBody(:, oddColumn) = num2cell(normalize(values, 'range'));
        end

        for evenColumn = 2:2:size(body, 2)
            values = cell_column_to_numeric(body(:, evenColumn));
            normalizedBody(:, evenColumn) = num2cell(1 - values);
        end

        outputFile = make_output_path(alignedFile, '_pH_hill_input');
        write_header_and_cell(outputFile, headerRow, normalizedBody);
        pHHillInputFiles(fileIndex) = string(outputFile);
    end

    hillFiles = list_stage_files(folderPath, '_pH_hill_input');
    resultRows = cell(0, 5);
    targetY = [0.1, 0.5, 0.9];

    for fileIndex = 1:numel(hillFiles)
        normalizedFile = fullfile(folderPath, hillFiles(fileIndex).name);
        normalizedRaw = readcell(normalizedFile);
        headerRow = normalizedRaw(1, :);
        normalizedBody = normalizedRaw(2:end, :);

        datasetName = get_dataset_name(normalizedFile);
        alignedFile = fullfile(folderPath, [datasetName, '_aligned_pH_windows.xlsx']);
        if ~isfile(alignedFile)
            error('Corresponding aligned pH file was not found: %s', alignedFile);
        end

        alignedRaw = readcell(alignedFile);
        alignedBody = alignedRaw(2:end, :);
        numberOfSeries = size(normalizedBody, 2) / 2;

        for seriesIndex = 1:numberOfSeries
            oddColumn = 2 * seriesIndex - 1;
            evenColumn = 2 * seriesIndex;

            x = cell_column_to_numeric(normalizedBody(:, oddColumn));
            y = cell_column_to_numeric(normalizedBody(:, evenColumn));
            fitResult = fit_hill_curve(x, y);

            baselinepH = cell_column_to_numeric(alignedBody(:, oddColumn));
            baselinepH = baselinepH(1);

            transformedpH = zeros(1, 3);
            for targetIndex = 1:3
                rootX = fzero( ...
                    @(xValue) fitResult.Vmax * xValue.^fitResult.n ./ (fitResult.k.^fitResult.n + xValue.^fitResult.n) - targetY(targetIndex), 1);
                transformedpH(targetIndex) = rootX * 3 + baselinepH;
            end

            temperatureLabel = coerce_numeric_label(headerRow{evenColumn});
            if isnumeric(temperatureLabel)
                seriesName = sprintf('%s_%g', datasetName, temperatureLabel);
            else
                seriesName = sprintf('%s_%s', datasetName, char(string(temperatureLabel)));
            end

            resultRows(end + 1, :) = { ... %#ok<AGROW>
                seriesName, transformedpH(1), transformedpH(2), transformedpH(3), fitResult.n};
        end
    end

    summaryHeader = {'pH-φ-T', '0.1', '0.5', '0.9', 'n'};
    pHHillSummary = fullfile(folderPath, 'pH_hill_results.xlsx');
    if isfile(pHHillSummary)
        delete(pHHillSummary);
    end
    writecell([summaryHeader; resultRows], pHHillSummary);
end
