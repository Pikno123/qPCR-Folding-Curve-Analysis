function outputFile = calculate_adjacent_ratios(inputFile)

% Output: adjacent_ratios.xlsx


    validate_input_file(inputFile);

    raw = readcell(inputFile);
    header = raw(1, :);
    body = raw(2:end, :);

    numeratorWells = {'A1','B1','C1','D1','E1','F1','G1','H1', ...
        'A3','B3','C3','D3','E3','F3','G3','H3', ...
        'A5','B5','C5','D5','E5','F5','G5','H5', ...
        'A7','B7','C7','D7','E7','F7','G7','H7', ...
        'A9','B9','C9','D9','E9','F9','G9','H9', ...
        'A11','B11','C11','D11','E11','F11','G11','H11'};

    denominatorWells = {'A2','B2','C2','D2','E2','F2','G2','H2', ...
        'A4','B4','C4','D4','E4','F4','G4','H4', ...
        'A6','B6','C6','D6','E6','F6','G6','H6', ...
        'A8','B8','C8','D8','E8','F8','G8','H8', ...
        'A10','B10','C10','D10','E10','F10','G10','H10', ...
        'A12','B12','C12','D12','E12','F12','G12','H12'};

    numberOfPairs = numel(numeratorWells);
    outputMatrix = NaN(size(body, 1), 2 * numberOfPairs);

    headerText = string(header);

    for pairIndex = 1:numberOfPairs
        numeratorColumn = find(headerText == numeratorWells{pairIndex}, 1);
        denominatorColumn = find(headerText == denominatorWells{pairIndex}, 1);

        if isempty(numeratorColumn) || isempty(denominatorColumn)
            error('Required well columns were not found: %s and/or %s.', numeratorWells{pairIndex}, denominatorWells{pairIndex});
        end
        if numeratorColumn <= 1
            error('No temperature column exists immediately before %s.', numeratorWells{pairIndex});
        end

        temperature = cell_column_to_numeric(body(:, numeratorColumn - 1));
        numerator = cell_column_to_numeric(body(:, numeratorColumn));
        denominator = cell_column_to_numeric(body(:, denominatorColumn));

        outputMatrix(:, 2 * pairIndex - 1) = temperature;
        outputMatrix(:, 2 * pairIndex) = numerator ./ denominator;
    end

    headerRow = cell(1, 2 * numberOfPairs);
    for pairIndex = 1:numberOfPairs
        headerRow{2 * pairIndex - 1} = 'Temperature';
        headerRow{2 * pairIndex} = 3.0 + 0.2 * (pairIndex - 1);
    end

    outputFile = make_output_path(inputFile, '_adjacent_ratios');
    write_header_and_matrix(outputFile, headerRow, outputMatrix);
end
