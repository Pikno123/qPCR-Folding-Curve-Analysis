function label = coerce_numeric_label(value)


    label = value;
    if ischar(value) || (isstring(value) && isscalar(value))
        numericValue = str2double(string(value));
        if ~isnan(numericValue)
            label = numericValue;
        end
    end
end
