function outputFiles = transpose_for_ph_analysis(folderPath)


    validate_input_folder(folderPath);
    fileList = list_stage_files(folderPath, '_full_temperature_curves');
    outputFiles = strings(numel(fileList), 1);

    for fileIndex = 1:numel(fileList)
        inputFile = fullfile(folderPath, fileList(fileIndex).name);
        raw = readcell(inputFile);
        inputHeader = raw(1, :);
        body = raw(2:end, :);

        temperatureAxis = cell_column_to_numeric(body(:, 1));
        numberOfSeries = size(body, 2) / 2;
        foldingMatrix = NaN(size(body, 1), numberOfSeries);

        for seriesIndex = 1:numberOfSeries
            foldingMatrix(:, seriesIndex) = cell_column_to_numeric(body(:, 2 * seriesIndex));
        end

        outputCell = cell(numberOfSeries + 1, numel(temperatureAxis) + 1);
        outputCell{1, 1} = 'Temperature';
        outputCell(1, 2:end) = num2cell(temperatureAxis');

        for seriesIndex = 1:numberOfSeries
            outputCell{seriesIndex + 1, 1} = coerce_numeric_label(inputHeader{2 * seriesIndex});
        end

        outputCell(2:end, 2:end) = num2cell(foldingMatrix');

        outputFile = make_output_path(inputFile, '_pH_transposed');
        if isfile(outputFile)
            delete(outputFile);
        end
        writecell(outputCell, outputFile);
        outputFiles(fileIndex) = string(outputFile);
    end
end
