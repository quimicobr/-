clearvars -except images
close all

ex = exist('images');
if (ex == 0)
    for n_paste = 1:40; %Choisit le dossier d'où prendre les images

        d = dir(['ORL/S', num2str(n_paste), '/*.bmp']); %Ouvre le dossier
        nfiles = length(d); %Compte le nombre d'images

        for i = 1:nfiles
            images{n_paste,i} = imread(['ORL/S', num2str(n_paste) ,'/',num2str(i),'.bmp']);
        end
    end
end
%Stocke toutes les images du dossier sur la cellule images
%Pourtant, on ne l'efface pas au début. Donc, on le lit seulement si c'est
%la première fois qu'on exécute le code

N_dossier = 1;
N_image = 10;

im = images{N_dossier,N_image};
%On prend d'abord l'image au dossier numéro N_dossier, et dans le dossier,
%l'image numéro N_image

LBP_im = LBP(im); % Fonction qui donne le LBP de l'image

[h, l] = size(im); %h et l dimensions de l'image

edges = 0:256; %Vecteur qui donne les limites de chaque barre de l'histogramme

% figure;
% subplot(1,3,1);
% imshow(im);
% 
% subplot(1,3,2);
% imshow(LBP_im);
% 
% subplot(1,3,3);

hist1_entier = histcounts(LBP_im, edges);
%Vecteur histogramme de l'image LBP entière 

% bar(hist1);
% axis([0 256 0 max(hist1)]);
%Montre l'image original, l'image LBP et son histogramme

%Maintenant, il faut faire le LBP 'spatially enhanced', c'est-à-dire pour
%pour régions 3x3, 5x5 et 7x7

n = 0;
%Initialise n, qui donnera les positions dans la cellule des histogrammes
%des images LBP decoupées
div_dim = [3 5 7]; 
%Vecteur qui indique les trois options de découpe de l'image LBP 

for k = div_dim

    n = n + 1;
    [hist1_dec{n}, maxi(n)] = decoupe(LBP_im, k);
    %La cellule hist1_dec contient tous les vecteurs histogrammes des
    %images LBM découpées
    %maxi contient les valeurs maximales pour chaque tableau d'histogrammes
    
    

%     figure;
%     for i = 1:k
%         for j = 1:k
%             subplot(k,k,(i-1)*k+j);
%             bar(hist{n}{i,j});
%             axis([0 256 0 maxi(n)]);
%         end
%     end
            
end

h_LBP = h - 2; 
l_LBP = l - 2;
%La hauteur et la largeur de l'image LBP sont 2 pixels plus petites que les
%originales, puisqu'on prend seulement les pixels de centre

%Maintenant, il faut faire une distribution de chi carré entre le LBP d'une
%image e d'autre. D'abord, pour le LBP d'une image entière, puis divisé par
%régions, avec différents poids pour chaque région


for nd = 1:10
    %Cette boucle en nd fait varier le dossier pour lequel on prend la 
    %deuxième image 
for ni = 1:9
    %Cette boucle en ni fait varier le numéro d'image dans un dossier pour
    %lequel on prend la deuxième image    

im2 = images{nd,ni}; %Lit une deuxième image

LBP_im2 = LBP(im2); %Fait le LBP de la deuxième image

hist2_entier = histcounts(LBP_im2, edges);%Histogramme du LBP de la deuxième image entière

% figure;
% subplot(1,3,1);
% imshow(im2);
% 
% subplot(1,3,2);
% imshow(LBP_im2);
% 
% subplot(1,3,3);
% bar(hist2);
% axis([0 256 0 max(hist2)]);

chi2_entier(ni,nd) = chicarre(hist1_entier,hist2_entier);
%Calcule le chi2 entre la première et la deuxième image

%Maintenant, il faut calculer le chi carré pour la division par régions
n = 0;

for k = div_dim
    n = n+1;

hist2_dec = decoupe(LBP_im2, k);
%On prend les histogrammes de chaque région

clearvars mat_chi2
for i = 1:k
    for j = 1:k        
        mat_chi2(i,j) = chicarre(hist1_dec{n}{i,j},hist2_dec{i,j})
        %Calcule le chi carre pour chaque petite région de l'image et le
        %stocke sur une matrice. Cette matrice sera nécéssaire après pour
        %appliquer les coefficients de poids
    end
end

mat = matpoids(k);
%On calcule les poids pour chaque région dans le calcule du coefficient de
%similarité, en utilisant la fonction matpoids

chi2_dec(ni,nd,n) = sum(sum(mat.*mat_chi2));
%Finalement, on calcule le chi carre pour chaque image (par rapport à la
%première image choisie), aussi bien que pour chaque nombre de divisions
%(3x3, 5x5 et 7x7)

end
end
end

moy_dec = sum(chi2_dec)/9;

moy_entier = sum(chi2_entier)/9;

%On calcule la moyenne des chi carre entre toutes les images d'un même
%dossier, pour les images découpées (spacially enhanced) ou non-découpées
%(hollistic)
