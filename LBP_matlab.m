clear all
close all

for n_paste = 1:2; %Choisit le dossier d'o� prendre les images

d = dir(['ORL/S', num2str(n_paste), '/*.bmp']); %Ouvre le dossier
nfiles = length(d); %Compte le nombre d'images

for i = 1:nfiles
    images{n_paste,i} = imread(['ORL/S', num2str(n_paste) ,'/',num2str(i),'.bmp']);
end
end
%Stocke toutes les images du dossier sur la cellule images

im = images{1,1};
%On prend seulement la premi�re image du dossier

LBP_im = LBP(im); % Fonction qui donne le LBP de l'image

[h, l] = size(im); %h et l dimensions de l'image

edges = 0:256;

figure;
subplot(1,3,1);
imshow(im);

subplot(1,3,2);
imshow(LBP_im);

subplot(1,3,3);
hist1 = histogram(LBP_im, edges);
axis([0 256 0 max(hist1.Values)]);
%Montre l'image original, l'image LBP et son histogramme

%Maintenant, il faut faire le LBP 'spatially enhanced', c'est-�-dire pour
%pour r�gions 3x3, 5x5 et 7x7

%Il faut faire une fonction qui re�oit l'image en LBP et envoie � la sortie
%la variable histogramme de chacune des r�gions

n = 0;
div_dim = [3 5 7];

for k = div_dim

    n = n + 1;
    [hist{n}, maxi(n)] = decoupe(LBP_im, k);

    figure;
    for i = 1:k
        for j = 1:k
            subplot(k,k,(i-1)*k+j);
            bar(hist{n}{i,j});
            axis([0 256 0 maxi(n)]);
        end
    end
            
end


h_LBP = h - 2;
l_LBP = l - 2;

%Maintenant, il faut faire une distribution de chi carr� entre le LBP d'une
%image e d'autre. D'abord, pour le LBP d'une image enti�re, puis divis� par
%r�gions, avec diff�rents poids pour chaque r�gion
                   
im2 = images{1,2}; %Lit une deuxi�me image

LBP_im2 = LBP(im2); %Fait le LBP de la deuxi�me image

chi2 = 0; %Initialise la valeur du chi carr�

%%
%for i = 1:h_LBP
%    for j = 1:l_LBP
%        chi2 = chi2 + (LBP_im(i,j) - LBP_im2(i,j)).^2./(LBP_im(i,j) + LBP_im2(i,j));
%        %Calcule le chi carr�
%    end
%end
%%%%
%Calcule probablement mauvais, il faut parcourir l'histogramme, pas l'image
%%

hist2 = histcounts(LBP_im2, edges);

for i = 1:256
    if (hist1.Values(i) ~= hist2(i))
        chi2 = chi2 + (hist1.Values(i) - hist2(i))^2/(hist1.Values(i) + hist2(i));
    end
end

%Maintenant, il faut calculer le chi carr� pour la division par r�gions
%D'abord, on prend les r�gions de la nouvelle image

hist2_dec = decoupe(LBP_im2, 7);





                    

