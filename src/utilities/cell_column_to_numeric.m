function values = cell_column_to_numeric(columnCells)

% Empty or nonnumeric cells are returned as NaN.

    values = NaN(numel(columnCells), 1);

    for rowIndex = 1:numel(columnCells)
        value = columnCells{rowIndex};

        if isnumeric(value) && isscalar(value)
            values(rowIndex) = value;
        elseif islogical(value) && isscalar(value)
            values(rowIndex) = double(value);
        elseif ischar(value) || (isstring(value) && isscalar(value))
            numericValue = str2double(string(value));
            if ~isnan(numericValue)
                values(rowIndex) = numericValue;
            end
        end
    end
end
