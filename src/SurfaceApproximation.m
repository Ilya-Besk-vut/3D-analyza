function [alpha1, alpha2, alpha3, alpha4, alpha5] = SurfaceApproximation(X, Y, Z)
% SURFACEAPPROXIMATION Lokální aproximace povrchu polynomem 2. řádu.
% Vypočítává koeficienty pro konstrukci diferenciálního operátoru
% s přihlédnutím k riemannovské metrice povrchu v okolí bodu.

    %% 1. Konstrukce úplné matice báze pro metodu nejmenších čtverců
    B = [ones(size(X)), X, Y, X.^2, X.*Y, Y.^2]; % Rozměr: K x 6

    %% 2. Výpočet exponenciálních vah vzdáleností
    d = sqrt(X.^2 + Y.^2 + Z.^2);
    h = max(d); 
    W = diag(exp(-d.^2 / h^2));

    %% 3. Řešení soustavy nejmenších čtverců a extrakce koeficientů polynomu
    coeffs_z = (B' * W * B) \ (B' * W * Z);

    a2 = coeffs_z(2); % Lineární člen podle x (zx)
    a3 = coeffs_z(3); % Lineární člen podle y (zy)
    a4 = coeffs_z(4); % Kvadratický člen x^2
    a5 = coeffs_z(5); % Smíšený člen xy
    a6 = coeffs_z(6); % Kvadratický člen y^2

    % Hodnoty derivací povrchu v lokálním počátku souřadnic (0,0)
    zx  = a2;
    zy  = a3;
    zxx = 2 * a4;
    zxy = a5;
    zyy = 2 * a6;

    %% 4. Výpočet komponent riemannovské metriky (g_ij)
    g11 = 1 + zx^2;
    g12 = zx * zy;
    g22 = 1 + zy^2;
    g_mat = [g11, g12; g12, g22];
    g = det(g_mat);

    % Inverzní metrika g^ij
    G_inv = inv(g_mat);
    g11_inv = G_inv(1,1);
    g12_inv = G_inv(1,2);
    g22_inv = G_inv(2,2);

    %% 5. Výpočet koeficientů u druhých derivací
    alpha3 = g11_inv;
    alpha4 = 2 * g12_inv; 
    alpha5 = g22_inv;

    %% 6. Výpočet koeficientů u prvních derivací
    % Diferencování determinantu g
    dg_dx = 2*zx*zxx + 2*zy*zxy;
    dg_dy = 2*zy*zyy + 2*zx*zxy;

    % Diferencování komponent matice metriky
    dG_dx = [2*zx*zxx,         zx*zxy + zy*zxx; 
             zx*zxy + zy*zxx,  2*zy*zxy];
         
    dG_dy = [2*zx*zxy,         zx*zyy + zy*zxy; 
             zx*zyy + zy*zxy,  2*zy*zyy];

    % Derivace inverzní metriky: d(G^-1) = -G^-1 * dG * G^-1
    dG_inv_dx = -G_inv * dG_dx * G_inv;
    dG_inv_dy = -G_inv * dG_dy * G_inv;

    % Výsledné sestavení koeficientů alpha1 a alpha2
    term1_x = (1/(2*g) * dg_dx * g11_inv) + dG_inv_dx(1,1);
    term2_x = (1/(2*g) * dg_dy * g12_inv) + dG_inv_dy(1,2); 
    alpha1 = term1_x + term2_x;

    term1_y = (1/(2*g) * dg_dx * g12_inv) + dG_inv_dx(2,1);
    term2_y = (1/(2*g) * dg_dy * g22_inv) + dG_inv_dy(2,2);
    alpha2 = term1_y + term2_y;
end