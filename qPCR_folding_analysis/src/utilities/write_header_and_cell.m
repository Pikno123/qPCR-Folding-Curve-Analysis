function write_header_and_cell(outputFile, headerRow, dataCell)


    if isfile(outputFile)
        delete(outputFile);
    end

    writecell(headerRow, outputFile, 'Range', 'A1');
    if ~isempty(dataCell)
        writecell(dataCell, outputFile, 'Range', 'A2');
    end
end
