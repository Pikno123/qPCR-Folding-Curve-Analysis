function fileList = list_stage_files(folderPath, stageSuffix)


    validate_input_folder(folderPath);
    fileList = dir(fullfile(folderPath, ['*', stageSuffix, '.xlsx']));

    if numel(fileList) > 1
        [~, order] = sort(lower({fileList.name}));
        fileList = fileList(order);
    end
end
