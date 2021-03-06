%% BE LBP-based face recognition
% Auteurs : Davi NATCHIGALL LAZZAROTTO et Arthur MAIA MENDES
% Enseignant : Prof. Liming Chen

%% Chargement des images

%Stocke toutes les images du dossier sur la cellule images
%Pourtant, on ne l'efface pas au debut. Donc, on le lit seulement si c'est
%la premiere fois qu'on execute le code

clearvars -except images;
close all;

if ~exist('images', 'var')
    images = loadImages();
end

fprintf('Images chargees\n');

%% Application de la methode LBP "hollistic"

[nPersonnes, nFaces] = size(images);

if ~exist('lbp', 'dir')
    mkdir lbp;
    for i = 1:nPersonnes
        mkdir(['lbp/',num2str(i)])
        for j = 1:nFaces
                imwrite(LBP(images{i,j}), ['lbp/', num2str(i),'/', ...
                    num2str(j), '.bmp']);
        end
    end
end

edges = 0:256;

if ~exist('LBP_im.mat', 'file')
    for i = 1:nPersonnes
        for j = 1:nFaces
            LBP_im{i,j} = imread(['lbp/', num2str(i),'/', num2str(j),...
                            '.bmp']);
            hist_hol{i,j} = histcounts(LBP_im{i,j}, edges);
        end
    end
    save LBP_im.mat LBP_im;
    save hist_hol.mat hist_hol;
else
    load LBP_im;
    load hist_hol;
end

fprintf('LBPs hollistics finished\n');


% % On prend d'abord l'image au dossier numero N_dossier, et dans le dossier,
% % l'image numero N_image
% 
% N_dossier = 1;
% N_image = 10;
% 
% im = images{N_dossier,N_image};
% 
% % On applique la methode LBP a l'image
% LBP_im = LBP(im); 
% 
% % h et l dimensions de l'image
% [h, l] = size(im);
% 
% % Vecteur qui donne les limites de chaque barre de l'histogramme
% edges = 0:256; 
% 
% %Vecteur histogramme de l'image LBP entiere
% hist1_entier = histcounts(LBP_im, edges);
% 
% % Affichage de l'histogramme
% figure,
% subplot(2, 2, 1), imshow(im); title('Image originelle');
% subplot(2, 2, 2), imshow(LBP_im); title('Image après application de la LBP');
% subplot(2, 2, 3), bar(hist1_entier);
% axis([0 256 0 max(hist1_entier)]);
% title("Histogramme de l'image entière")

%% Application de la methode LBP "spatially enhanced"

div_dim = [3, 5, 7];

if ~exist('hist_sp_enh.mat', 'file')
    for i = 1:nPersonnes
        for j = 1:nFaces
            n = 0;
            for k = div_dim
                n = n+1;
                [hist_sp_enh{i,j,n}, maxi(i,j,n)] = decoupe(...
                    LBP_im{i,j}, k);
            end
        end
    end
    save hist_sp_enh.mat hist_sp_enh maxi;
else
    load hist_sp_enh;
end

fprintf('LBPs spatially enhanced finished\n');

% D'abord on divise l'image en regions 3x3, 5x5 et 7x7

% % Initialisation de n, qui donnera les positions dans la cellule des 
% % histogrammes des images LBP decoupees
% n = 0;
% 
% % Vecteur qui indique les trois options de decoupe de l'image LBP 
% div_dim = [3 5 7]; 
% 
% for k = div_dim
%     
% % La cellule hist1_dec contient tous les vecteurs histogrammes des
% % images LBM decoupees
% % maxi contient les valeurs maximales pour chaque tableau 
% % d'histogrammes
%     n = n + 1;
%     [hist1_dec{n}, maxi(n)] = decoupe(LBP_im, k);
%     
% % Affichage des histogrammes des regions
%     figure;
%     for i = 1:k
%         for j = 1:k
%             subplot(k,k,(i-1)*k+j);
%             bar(hist1_dec{n}{i,j});
%             axis([0 256 0 maxi(n)]);
%         end
%     end
%             
% end

% La hauteur et la largeur de l'image LBP sont 2 pixels plus petites que 
% les originales, puisqu'on prend seulement les pixels de centre
% h_LBP = h - 2; 
% l_LBP = l - 2;

%% Calcul de la distance Chi Carre

% Maintenant, on applique une distribution de chi carre entre le LBP d'une
% image e d'autre. D'abord, pour la LBP 'hollistic', puis pour celle 
% 'spatially enhanced', avec differents poids pour chaque region.

% On compte le nombre d'images enregistrées
nImages = size(images,1)*size(images,2);

% D'abord le chi carre entre les LBPs hollistics
if ~exist('chi_carre_hol.mat', 'file')
    s = [10, 40];
    t_hist_hol = hist_hol';
    chi_carre_hol = zeros(nImages);
    for i = 1:nImages
        for j = i:nImages
            [I1, J1] = ind2sub(s, i);
            [I2, J2] = ind2sub(s, j);
            chi_carre_hol(i,j) = chicarre(t_hist_hol{I1, J1}, ...
                t_hist_hol{I2, J2}); 
        end
    end
    chi_carre_hol = chi_carre_hol + chi_carre_hol';
    save chi_carre_hol.mat chi_carre_hol;
else
    load chi_carre_hol
end

fprintf('ChiSquare hollistic finished\n');

%% Calcul de la distance Chi Carre 'spatially enhanced'

%%%%%'Spatially enhanced' 3x3

chi_carre_sp_enh_3 = zeros(400);
dim = div_dim(1);

if ~exist('chi_carre_sp_enh_3.mat', 'file')
    for i = 1:nPersonnes
        for j = 1:nFaces
            for ii = 1:nPersonnes
                for jj = 1:nFaces
                    chi_carre_aux = zeros(dim);
                    for k = 1:dim
                        for l = 1:dim
                            chi_carre_aux(k,l) = chicarre(hist_sp_enh{i,j,1}{k,l},...
                                hist_sp_enh{ii,jj,1}{k,l});
                        end
                    end
                    c = sum(sum(chi_carre_aux.*matpoids(dim)));
                    chi_carre_sp_enh_3((i-1)*nFaces + j,(ii-1)*nFaces + jj) = c;
                end
            end
        end
    end
    save chi_carre_sp_enh_3.mat chi_carre_sp_enh_3;
else
    load chi_carre_sp_enh_3
end

fprintf('ChiSquare spatially enhanced 3x3 finished\n');

%%%%%'Spatially enhanced' 5x5

chi_carre_sp_enh_5 = zeros(400);
dim = div_dim(2);

if ~exist('chi_carre_sp_enh_5.mat', 'file')
    for i = 1:nPersonnes
        for j = 1:nFaces
            for ii = 1:nPersonnes
                for jj = 1:nFaces
                    chi_carre_aux = zeros(dim);
                    for k = 1:dim
                        for l = 1:dim
                            chi_carre_aux(k,l) = chicarre(hist_sp_enh{i,j,2}{k,l},...
                                hist_sp_enh{ii,jj,2}{k,l});
                        end
                    end
                    c = sum(sum(chi_carre_aux.*matpoids(dim)));
                    chi_carre_sp_enh_5((i-1)*nFaces + j,(ii-1)*nFaces + jj) = c;
                end
            end
        end
    end
    save chi_carre_sp_enh_5.mat chi_carre_sp_enh_5;
else
    load chi_carre_sp_enh_5
end

fprintf('ChiSquare spatially enhanced 5x5 finished\n');

%%%%%'Spatially enhanced' 7x7

chi_carre_sp_enh_7 = zeros(400);
dim = div_dim(3);

if ~exist('chi_carre_sp_enh_7.mat', 'file')
    for i = 1:nPersonnes
        for j = 1:nFaces
            for ii = 1:nPersonnes
                for jj = 1:nFaces
                    chi_carre_aux = zeros(dim);
                    for k = 1:dim
                        for l = 1:dim
                            chi_carre_aux(k,l) = chicarre(hist_sp_enh{i,j,3}{k,l},...
                                hist_sp_enh{ii,jj,3}{k,l});
                        end
                    end
                    c = sum(sum(chi_carre_aux.*matpoids(dim)));
                    chi_carre_sp_enh_7((i-1)*nFaces + j,(ii-1)*nFaces + jj) = c;
                end
            end
        end
    end
    save chi_carre_sp_enh_7.mat chi_carre_sp_enh_7;
else
    load chi_carre_sp_enh_7
end

fprintf('ChiSquare spatially enhanced 7x7 finished\n');

%% Reconnaissance 'hollistic' (minimum chi carre)

essais = 10;
taux = zeros(essais,1);
M = cell(nPersonnes, nFaces);
I = cell(nPersonnes, nFaces);

size_gal = 4;

for h = 1:essais
    galerie = randperm(nFaces, size_gal);    
    for k = 1:nPersonnes
        for l = 1:nFaces
            if ~ismember(l, galerie)
                diff = zeros(1,nPersonnes);
                for i = 1:nPersonnes
                    comparaison = zeros(1,size_gal);
                    d = 0;
                    for j = 1:nFaces
                        if ismember(j, galerie) 
                            d = d + 1;
                            comparaison(d) = chi_carre_hol((k-1)*nFaces + ...
                                l,(i-1)*nFaces + j);
                        end
                    end
                    diff(i) = min(comparaison);
                end
                [M{k,l}, I{k,l}] = min(diff);
            end
        end
    end
    
    counter = 0;
    for m = 1:nPersonnes
        for n = 1:nFaces
            if ~ismember(n, galerie) && I{m, n} == m
                counter = counter + 1;
            end
        end
    end
    taux(h) = counter/(nPersonnes*6);
end

taux_moy = mean(taux);
taux_ec_type = std(taux);

fprintf('Recognition hollistic finished\n');


%% Reconnaissance 'spatially enhanced'
% 
 essais_sp_enh = 10;
 taux_sp_enh = zeros(essais_sp_enh,1);
 M_sp_enh = cell(nPersonnes, nFaces);
 I_sp_enh = cell(nPersonnes, nFaces);
 
 size_gal = 4;
 
 for h = 1:essais_sp_enh
     galerie = randperm(nFaces, size_gal);    
     for k = 1:nPersonnes
         for l = 1:nFaces
             if ~ismember(l, galerie)
                 diff = zeros(1,nPersonnes);
                 for i = 1:nPersonnes
                     comparaison = zeros(1,size_gal);
                     d = 0;
                     for j = 1:nFaces
                         if ismember(j, galerie) 
                             d = d + 1;
                             comparaison(d) = chi_carre_sp_enh_3((k-1)*nFaces + ...
                                 l,(i-1)*nFaces + j);
                         end
                     end
                     diff(i) = min(comparaison);
                 end
                 [M_sp_enh{k,l}, I_sp_enh{k,l}] = min(diff);
             end
         end
     end
     
     counter = 0;
     for m = 1:nPersonnes
         for n = 1:nFaces
             if ~ismember(n, galerie) && I_sp_enh{m, n} == m
                 counter = counter + 1;
             end
         end
     end
     taux_sp_enh(h) = counter/(nPersonnes*6);
 end
 
 taux_moy_sp_enh = mean(taux_sp_enh);
 taux_ec_type_sp_enh = std(taux_sp_enh);
 
 fprintf('Recognition sp_enh finished\n');

%% Verification hollistic

verif_mat_hol = zeros(size(chi_carre_hol, 1));
Pv_hol = zeros(nPersonnes, 1);
Pf_hol = zeros(nPersonnes, 1);
lim = 1000;
essai = 3;
c = 0;
m = 1;

while c < lim
    for i = 1:nPersonnes
        for l = 1:nPersonnes
            for k = 2:nFaces
                if chi_carre_hol((i-1)*nFaces + 1,(l-1)*nFaces + k) ...
                        <= c
                    verif_mat_hol((i-1)*nFaces + 1, (l-1)*nFaces + k) = 1;
                end
            end
            if l == i
                Pv_hol(i) = sum(verif_mat_hol((i-1)*nFaces + 1, ...
                    (l-1)*nFaces + 2:(l-1)*nFaces + nFaces))/(nFaces-1);
            else
                Pf_hol(i) = Pf_hol(i) + sum(verif_mat_hol((i-1)*nFaces + 1, ...
                    (l-1)*nFaces + 2:(l-1)*nFaces + nFaces));
            end
        end
        Pf_hol(i) = Pf_hol(i)/((nPersonnes-1)*(nFaces-1));
    end
    Pv_tot_hol(m) = mean(Pv_hol);
    Pf_tot_hol(m) = mean(Pf_hol);
    c = c + 25;
    m = m + 1;
end

fprintf('Verification finished\n');


%% Verification sp_enh

verif_mat_sp_enh_3 = zeros(size(chi_carre_sp_enh_3, 1));
Pv_3 = zeros(nPersonnes, 1);
Pf_3 = zeros(nPersonnes, 1);
verif_mat_sp_enh_5 = zeros(size(chi_carre_sp_enh_5, 1));
Pv_5 = zeros(nPersonnes, 1);
Pf_5 = zeros(nPersonnes, 1);
verif_mat_sp_enh_7 = zeros(size(chi_carre_sp_enh_7, 1));
Pv_7 = zeros(nPersonnes, 1);
Pf_7 = zeros(nPersonnes, 1);
lim = 1000;
essai = 3;
c = 0;
m = 1;

while c < lim
    for i = 1:nPersonnes
        for l = 1:nPersonnes
            for k = 2:nFaces
                if chi_carre_sp_enh_3((i-1)*nFaces + 1,(l-1)*nFaces + k) ...
                        <= c
                    verif_mat_sp_enh_3((i-1)*nFaces + 1, (l-1)*nFaces + k) = 1;
                end
                if chi_carre_sp_enh_5((i-1)*nFaces + 1,(l-1)*nFaces + k) ...
                        <= c
                    verif_mat_sp_enh_5((i-1)*nFaces + 1, (l-1)*nFaces + k) = 1;
                end
                if chi_carre_sp_enh_7((i-1)*nFaces + 1,(l-1)*nFaces + k) ...
                        <= c
                    verif_mat_sp_enh_7((i-1)*nFaces + 1, (l-1)*nFaces + k) = 1;
                end
            end
            if l == i
                Pv_3(i) = sum(verif_mat_sp_enh_3((i-1)*nFaces + 1, ...
                    (l-1)*nFaces + 2:(l-1)*nFaces + nFaces))/(nFaces-1);
                Pv_5(i) = sum(verif_mat_sp_enh_5((i-1)*nFaces + 1, ...
                    (l-1)*nFaces + 2:(l-1)*nFaces + nFaces))/(nFaces-1);
                Pv_7(i) = sum(verif_mat_sp_enh_7((i-1)*nFaces + 1, ...
                    (l-1)*nFaces + 2:(l-1)*nFaces + nFaces))/(nFaces-1);
            else
                Pf_3(i) = Pf_3(i) + sum(verif_mat_sp_enh_3((i-1)*nFaces + 1, ...
                    (l-1)*nFaces + 2:(l-1)*nFaces + nFaces));
                Pf_5(i) = Pf_5(i) + sum(verif_mat_sp_enh_5((i-1)*nFaces + 1, ...
                    (l-1)*nFaces + 2:(l-1)*nFaces + nFaces));
                Pf_7(i) = Pf_7(i) + sum(verif_mat_sp_enh_7((i-1)*nFaces + 1, ...
                    (l-1)*nFaces + 2:(l-1)*nFaces + nFaces));
            end
        end
        Pf_3(i) = Pf_3(i)/((nPersonnes-1)*(nFaces-1));
        Pf_5(i) = Pf_5(i)/((nPersonnes-1)*(nFaces-1));
        Pf_7(i) = Pf_7(i)/((nPersonnes-1)*(nFaces-1));
    end
    Pv_tot_3(m) = mean(Pv_3);
    Pf_tot_3(m) = mean(Pf_3);
    Pv_tot_5(m) = mean(Pv_5);
    Pf_tot_5(m) = mean(Pf_5);
    Pv_tot_7(m) = mean(Pv_7);
    Pf_tot_7(m) = mean(Pf_7);
    c = c + 10;
    m = m + 1;
end

fprintf('Verification sp finished\n');

figure,
plot(Pf_tot_hol, Pv_tot_hol, '-g', Pf_tot_3, Pv_tot_3, '-r', ...
    Pf_tot_5, Pv_tot_5, '-b', Pf_tot_7, Pv_tot_7, '-m');
xlim([0 1]);
ylim([0.4 1])
legend('hollistic', '3x3', '5x5', '7x7')
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC')
grid on
grid minor


