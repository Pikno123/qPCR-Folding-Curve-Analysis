function outputFile = reformat_qpcr_export(inputFile)

% Output: reformatted.xlsx


    validate_input_file(inputFile);

    dataTable = readtable(inputFile);

    if width(dataTable) < 7
        error('The raw qPCR export does not contain the expected columns.');
    end

    dataTable(:, [1, 3, 6, 7]) = [];

    if ~ismember('WellPosition', dataTable.Properties.VariableNames)
        error('The qPCR export must contain a WellPosition column.');
    end

    rowLetters = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
    maximumWellNumber = 12;
    destinationColumn = 4;

    for rowIndex = 1:numel(rowLetters)
        for wellNumber = 1:maximumWellNumber
            wellName = [rowLetters{rowIndex}, num2str(wellNumber)];
            matchingRows = strcmp(dataTable.WellPosition, wellName);

            temperatureValues = dataTable{matchingRows, 2};
            signalValues = dataTable{matchingRows, 3};

            startRow = 2;
            endRow = startRow + numel(temperatureValues) - 1;

            dataTable{startRow:endRow, destinationColumn} = num2cell(temperatureValues);
            dataTable{1, destinationColumn + 1} = {wellName};
            dataTable{startRow:endRow, destinationColumn + 1} = num2cell(signalValues);

            destinationColumn = destinationColumn + 2;
        end
    end

    dataTable(:, 1:3) = [];

    for columnIndex = 1:2:width(dataTable)
        dataTable{1, columnIndex} = {'Temperature'};
    end

    outputCell = table2cell(dataTable);
    nonEmptyRows = any(~cellfun('isempty', outputCell), 2);
    outputCell = outputCell(nonEmptyRows, :);

    outputFile = make_output_path(inputFile, '_reformatted');
    if isfile(outputFile)
        delete(outputFile);
    end
    writecell(outputCell, outputFile);
end
