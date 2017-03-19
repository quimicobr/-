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

fprintf('Images chargées\n');

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
                [hist_sp_enh{i,j,n}, max(i,j,n)] = decoupe(...
                    LBP_im{i,j}, k);
            end
        end
    end
    save hist_sp_enh.mat hist_sp_enh max;
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

%% Reconnaissance
essais = 10;
taux = zeros(essais,1);
difference = cell(nPersonnes, nFaces);
M = cell(nPersonnes, nFaces);
I = cell(nPersonnes, nFaces);

for h = 1:essais
    galerie = randperm(nFaces, 4);
    for k = 1:nPersonnes
        for l = 1:nFaces
            if ~ismember(l, galerie)
                for i = 1:nPersonnes
                    difference{k,l}(i) = 0;
                    for j = 1:nFaces
                        if ismember(j, galerie)
                            difference{k,l}(i) = difference{k,l}(i) + ...
                                chi_carre_hol(nFaces*(k-1) + l, ...
                                nFaces*(i-1) + j);
                        end
                    end
                    difference{k,l}(i) = difference{k,l}(i)/4;
                end
                [M{k,l}, I{k,l}] = min(difference{k,l});
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









