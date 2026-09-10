function write_header_and_matrix(outputFile, headerRow, dataMatrix)


    if isfile(outputFile)
        delete(outputFile);
    end

    writecell(headerRow, outputFile, 'Range', 'A1');
    if ~isempty(dataMatrix)
        writematrix(dataMatrix, outputFile, 'Range', 'A2');
    end
end
