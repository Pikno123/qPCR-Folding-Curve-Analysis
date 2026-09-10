function outputFile = make_output_path(inputFile, stageSuffix)


    [folderPath, ~, ~] = fileparts(inputFile);
    datasetName = get_dataset_name(inputFile);
    outputFile = fullfile(folderPath, [datasetName, stageSuffix, '.xlsx']);
end
