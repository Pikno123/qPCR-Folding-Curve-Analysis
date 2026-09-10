function [xFit, yFit, fitResult] = fit_boltzmann_curve(x, y, numberOfPoints)

%   Model: y = A2 + (A1 - A2) / (1 + exp((x - x0) / dx))

    if nargin < 3
        numberOfPoints = 1000;
    end

    x = x(:);
    y = y(:);

    nanRows = any(isnan([x, y]), 2);
    x(nanRows) = [];
    y(nanRows) = [];

    if isempty(x)
        error('No valid data points are available for Boltzmann fitting.');
    end

    sortedData = sortrows([x, y], 1);
    x = sortedData(:, 1);
    y = sortedData(:, 2);

    xMin = min(x);
    xMax = max(x);
    initialDx = (xMax - xMin) / 20;

    % Preserve the initial-value rule.
    if min(y) > max(y)
        initialA1 = min(y);
        initialA2 = max(y);
    else
        initialA1 = max(y);
        initialA2 = min(y);
    end

    [~, midpointIndex] = min(abs(y - 0.5 * (initialA1 + initialA2)));
    initialX0 = x(midpointIndex);

    boltzmannModel = @(A1, A2, x0, dx, x) A2 + (A1 - A2) ./ (1 + exp((x - x0) ./ dx));
        

    fitType = fittype(boltzmannModel, 'independent', 'x', 'coefficients', {'A1', 'A2', 'x0', 'dx'});

    options = fitoptions('Method', 'NonlinearLeastSquares', 'StartPoint', [initialA1, initialA2, initialX0, initialDx], 'Lower', [-Inf, -Inf, -Inf, -Inf], 'Upper', [Inf, Inf, Inf, Inf]);

    options.TolFun = 1e-9;
    options.TolX = 1e-9;
    options.MaxIter = 1000;

    fitResult = fit(x, y, fitType, options);

    xFit = linspace(xMin, xMax, numberOfPoints)';
    yFit = feval(fitResult, xFit);
end
