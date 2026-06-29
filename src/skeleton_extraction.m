%% Extrakce kostry 3D modelu na základě spektrální analýzy
% Skript využívá vlastní vektory Laplace-Beltramiova operátoru 
% pro vrstevnatou segmentaci objektu a konstrukci minimální kostry grafu (MST).

clear; clc; close all;

%% 1. Načtení dat
load('../data/auto_mensi.mat'); % Načte mračna bodů (PC, ptCloud) a vypočtenou matici operátoru (L)
N = length(PC);

%% 2. Konstrukce symetrické matice sousednosti grafu
adj_full = sparse(N, N);
K_neighbors = 15; % Počet sousedů pro topologické vazby

for i = 1:N
    [indices, ~] = findNearestNeighbors(ptCloud, PC(i,:), K_neighbors);
    adj_full(i, indices) = 1;
    adj_full(indices, i) = 1;
end

%% 3. Spektrální analýza (Hledání vlastních vektorů)
% Vypočítáme prvních 5 vlastních vektorů operátoru -L
[V_eig, D_eig] = eigs(-L, 5, 'sm'); 
[~, idx] = sort(abs(diag(D_eig)), 'ascend');
phi = V_eig(:, idx(2)); % Použijeme druhý souřadnicový vektor (Fiedlerův vektor)

%% 4. Vrstevnatá segmentace a detekce uzlů kostry
num_steps = 45; 
intervals = linspace(min(phi), max(phi), num_steps + 1);
all_skeleton_nodes = []; 

for j = 1:num_steps
    % Výběr bodů spadajících do aktuální frekvenční vrstvy
    idx_in_slice = find(phi >= intervals(j) & phi < intervals(j+1));
    
    % Vizualizace mezilehlých vrstev (každá 3. vrstva)
    figure(1);
    if (j == 1 || mod(j,3) == 0 || j == num_steps)
        scatter3(PC(idx_in_slice,1), PC(idx_in_slice,2), PC(idx_in_slice,3), 'filled');
        hold on;
    end

    if length(idx_in_slice) > 3
        % Detekce souvislých komponent uvnitř vrstvy pomocí podgrafů
        sub_adj = adj_full(idx_in_slice, idx_in_slice);
        G_slice = graph(sub_adj);
        bins = conncomp(G_slice);
        
        % Nalezení geometrického středu pro každou komponentu (klastr)
        for k = 1:max(bins)
            component_indices = idx_in_slice(bins == k);
            
            % Filtrace drobného šumu
            if length(component_indices) > 5
                cluster_pts = PC(component_indices, :);
                node = mean(cluster_pts, 1);
                all_skeleton_nodes = [all_skeleton_nodes; node];
            end
        end
    end
end

title('Vrstevnatá segmentace mračna bodů');
grid on; axis equal; view(3);

%% 5. Konstrukce stromu kostry (MST)
if ~isempty(all_skeleton_nodes)
    % Výpočet matice vzdáleností mezi uzly kostry
    dist_mtx = squareform(pdist(all_skeleton_nodes));
    adj_skel = dist_mtx;
    
    % Omezení maximální délky hrany kostry
    avg_dist = mean(min(dist_mtx + eye(size(dist_mtx)) * 1e10));
    adj_skel(dist_mtx > avg_dist * 2) = 0;  
    
    % Konstrukce minimální kostry grafu (MST)
    G_skel = graph(adj_skel);
    T = minspantree(G_skel);

    %% 6. Finální vizualizace výsledků
    % Zobrazení původního modelu s gradientem spektrální funkce
    figure(2);
    scatter3(PC(:,1), PC(:,2), PC(:,3), 5, phi, 'filled', 'MarkerFaceAlpha', 0.2); 
    hold on;
    
    % Vykreslení grafu kostry přes model
    p = plot(T, 'XData', all_skeleton_nodes(:,1), ...
                'YData', all_skeleton_nodes(:,2), ...
                'ZData', all_skeleton_nodes(:,3));
                
    p.EdgeColor = [0.2 0.2 0.2]; % Barva hran (kostí)
    p.LineWidth = 2.5;           % Tloušťka hran
    p.Marker = 'o';              % Markery uzlů
    p.MarkerSize = 4;            % Velikost bodů spojení
    p.NodeColor = 'r';           % Barva uzlů kostry
    
    title('Finální graf kostry na mračnu bodů');
    grid on; axis equal; view(3);
end