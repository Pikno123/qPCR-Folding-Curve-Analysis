function outputFile = fit_temperature_folding_curves(inputFile)

% Output: temperature_folding_fit.xlsx


    validate_input_file(inputFile);

    raw = readcell(inputFile);
    inputHeader = raw(1, :);
    body = raw(2:end, :);

    numberOfColumns = size(body, 2);
    if mod(numberOfColumns, 2) ~= 0
        error('Input workbook must contain Temperature/signal column pairs.');
    end

    fittedCell = cell(1000, numberOfColumns);

    for temperatureColumn = 1:2:numberOfColumns
        signalColumn = temperatureColumn + 1;

        x = cell_column_to_numeric(body(:, temperatureColumn));
        y = cell_column_to_numeric(body(:, signalColumn));

        [xFit, yFit] = fit_boltzmann_curve(x, y, 1000);

        fittedCell(:, temperatureColumn) = num2cell(xFit);
        fittedCell(:, signalColumn) = num2cell(yFit);
    end

    for signalColumn = 2:2:numberOfColumns
        fittedSignal = cell2mat(fittedCell(:, signalColumn));
        normalizedSignal = (fittedSignal - min(fittedSignal)) ./ (max(fittedSignal) - min(fittedSignal));
        fittedCell(:, signalColumn) = num2cell(1 - normalizedSignal);
    end

    headerRow = inputHeader;
    for temperatureColumn = 1:2:numberOfColumns
        headerRow{temperatureColumn} = 'Temperature';
    end

    outputFile = make_output_path(inputFile, '_temperature_folding_fit');
    write_header_and_cell(outputFile, headerRow, fittedCell);
end
