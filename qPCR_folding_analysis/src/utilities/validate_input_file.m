function validate_input_file(inputFile)


    if ~(ischar(inputFile) || (isstring(inputFile) && isscalar(inputFile)))
        error('Input file must be a character vector or string scalar.');
    end

    if ~isfile(inputFile)
        error('Input file does not exist: %s', string(inputFile));
    end
end
