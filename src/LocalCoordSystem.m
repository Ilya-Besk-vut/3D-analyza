function [N_i_loc] = LocalCoordSystem(ptCloud, p_i, K, PC)
% LOCALCOORDSYSTEM Transformace okolí bodu do lokálního souřadnicového systému (PCA).
%
% Vstupy:
%   ptCloud - Objekt pointCloud
%   p_i     - Souřadnice centrálního bodu (1x3)
%   K       - Počet sousedů
%   PC      - Pole všech bodů mračna (Nx3)
%
% Výstupy:
%   N_i_loc - Lokální souřadnice sousedů, kde osa Z je orientována ve směru normály.

    % Vyhledání sousedů a centrování dat
    [indices, ~] = findNearestNeighbors(ptCloud, p_i, K);
    N_i = PC(indices, :);
    c_i = sum(N_i) / K;
    
    % Výpočet kovarianční matice (Metoda hlavních komponent - PCA)
    P_i = (N_i - c_i)' * (N_i - c_i);
    [V, D] = eig(P_i);
    
    % Seřazení vlastních vektorů vzestupně podle vlastních čísel
    [~, idx] = sort(diag(D), 'ascend'); 
    V = V(:, idx); 

    % Rozdělení os: osa Z odpovídá nejmenšímu rozptylu (normála)
    X_axis = V(:, 3); 
    Y_axis = V(:, 2);
    Z_axis = V(:, 1); 

    V_final = [X_axis, Y_axis, Z_axis];
    
    % Výpočet lokálních souřadnic vůči centrálnímu bodu p_i
    N_i_loc = (N_i - p_i) * V_final;
end