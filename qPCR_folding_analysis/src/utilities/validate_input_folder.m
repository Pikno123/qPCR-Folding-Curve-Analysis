function validate_input_folder(folderPath)


    if ~(ischar(folderPath) || (isstring(folderPath) && isscalar(folderPath)))
        error('Folder path must be a character vector or string scalar.');
    end

    if ~isfolder(folderPath)
        error('Folder does not exist: %s', string(folderPath));
    end
end
