function fitResult = fit_hill_curve(x, y)

%  Model: y = Vmax * x^n / (k^n + x^n)

    x = x(:);
    y = y(:);

    hillType = fittype(@(Vmax, k, n, x) Vmax * x.^n ./ (k.^n + x.^n), 'independent', 'x', 'dependent', 'y');

    options = fitoptions('Method', 'NonlinearLeastSquares', 'StartPoint', [1, 1, 1], 'Lower', [0, 0, 0], 'Upper', [Inf, Inf, Inf], 'MaxIter', 10000);

    fitResult = fit(x, y, hillType, options);
end
