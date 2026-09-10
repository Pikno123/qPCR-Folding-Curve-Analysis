function [hillInputFiles, summaryFile] = fit_temperature_hill(folderPath)
% Inputs: *_aligned_temperature_windows.xlsx files 

% Outputs: temperature_hill_input.xlsx and temperature_hill_results.xlsx


    validate_input_folder(folderPath);
    inputFiles = list_stage_files(folderPath, '_aligned_temperature_windows');
    hillInputFiles = strings(numel(inputFiles), 1);

    for fileIndex = 1:numel(inputFiles)
        inputFile = fullfile(folderPath, inputFiles(fileIndex).name);
        raw = readcell(inputFile);
        headerRow = raw(1, :);
        body = raw(2:end, :);

        numericData = NaN(size(body));
        for columnIndex = 1:size(body, 2)
            numericData(:, columnIndex) = cell_column_to_numeric(body(:, columnIndex));
        end

        for columnIndex = 1:size(numericData, 2)
            columnMinimum = min(numericData(:, columnIndex));
            columnMaximum = max(numericData(:, columnIndex));
            numericData(:, columnIndex) = (numericData(:, columnIndex) - columnMinimum) ./ (columnMaximum - columnMinimum);
        end

        for signalColumn = 2:2:size(numericData, 2)
            numericData(:, signalColumn) = 1 - numericData(:, signalColumn);
        end

        outputFile = make_output_path(inputFile, '_temperature_hill_input');
        write_header_and_matrix(outputFile, headerRow, numericData);
        hillInputFiles(fileIndex) = string(outputFile);
    end

    hillFiles = list_stage_files(folderPath, '_temperature_hill_input');
    summaryBlocks = cell(numel(hillFiles), 1);
    maximumRows = 0;

    for fileIndex = 1:numel(hillFiles)
        inputFile = fullfile(folderPath, hillFiles(fileIndex).name);
        raw = readcell(inputFile);
        headerRow = raw(1, :);
        body = raw(2:end, :);

        numberOfSeries = size(body, 2) / 2;
        resultRows = cell(numberOfSeries, 2);

        for seriesIndex = 1:numberOfSeries
            x = cell_column_to_numeric(body(:, 2 * seriesIndex - 1));
            y = cell_column_to_numeric(body(:, 2 * seriesIndex));

            fitResult = fit_hill_curve(x, y);
            resultRows{seriesIndex, 1} = coerce_numeric_label(headerRow{2 * seriesIndex});
            resultRows{seriesIndex, 2} = fitResult.n;
        end

        datasetName = get_dataset_name(inputFile);
        summaryBlocks{fileIndex} = [{datasetName, [datasetName, '_n']}; resultRows];
        maximumRows = max(maximumRows, size(summaryBlocks{fileIndex}, 1));
    end

    summaryCell = cell(maximumRows, 2 * numel(summaryBlocks));
    for fileIndex = 1:numel(summaryBlocks)
        block = summaryBlocks{fileIndex};
        summaryCell(1:size(block, 1), 2 * fileIndex - 1:2 * fileIndex) = block;
    end

    summaryFile = fullfile(folderPath, 'temperature_hill_results.xlsx');
    if isfile(summaryFile)
        delete(summaryFile);
    end
    if ~isempty(summaryCell)
        writecell(summaryCell, summaryFile);
    end
end
