function outputFile = extract_thermodynamic_parameters(inputFile)

% Output: thermodynamic_parameters.xlsx


    validate_input_file(inputFile);

    raw = readcell(inputFile);
    inputHeader = raw(1, :);
    body = raw(2:end, :);

    numberOfSeries = size(body, 2) / 2;
    outputRows = cell(numberOfSeries, 9);

    for seriesIndex = 1:numberOfSeries
        temperatureColumn = 2 * seriesIndex - 1;
        signalColumn = 2 * seriesIndex;

        temperature = cell_column_to_numeric(body(:, temperatureColumn));
        signal = cell_column_to_numeric(body(:, signalColumn));

        outputRows{seriesIndex, 1} = coerce_numeric_label(inputHeader{signalColumn});

        [~, index01] = min(abs(signal - 0.1));
        [~, index05] = min(abs(signal - 0.5));
        [~, index09] = min(abs(signal - 0.9));

        temperature01 = temperature(index01);
        temperature05 = temperature(index05);
        temperature09 = temperature(index09);

        outputRows{seriesIndex, 2} = temperature01;
        outputRows{seriesIndex, 3} = temperature05;
        outputRows{seriesIndex, 4} = temperature09;

        if index05 > 1 && index05 < numel(signal)
            localTemperature = temperature(index05 - 1:index05 + 1);
            localSignal = signal(index05 - 1:index05 + 1);
            coefficients = polyfit(localTemperature, localSignal, 1);
            derivativeAtMidpoint = coefficients(1);
        else
            derivativeAtMidpoint = NaN;
        end

        deltaHvH = 4 * 8.341 * (273.15 + temperature05)^2 * derivativeAtMidpoint;
        g25 = (1 - ((273.15 + 25) / (273.15 + temperature05))) * deltaHvH;
        g37 = (1 - ((273.15 + 37) / (273.15 + temperature05))) * deltaHvH;
        entropy = deltaHvH / (273.15 + temperature05);

        outputRows{seriesIndex, 5} = derivativeAtMidpoint;
        outputRows{seriesIndex, 6} = deltaHvH;
        outputRows{seriesIndex, 7} = g25;
        outputRows{seriesIndex, 8} = g37;
        outputRows{seriesIndex, 9} = entropy;
    end

    headerRow = {'pH-phi', '0.1', '0.5', '0.9', '0.5_derivative', 'DeltaHvH', 'G25', 'G37', 'S'};

    outputFile = make_output_path(inputFile, '_thermodynamic_parameters');
    if isfile(outputFile)
        delete(outputFile);
    end
    writecell([headerRow; outputRows], outputFile);
end
