function [hist, maxi] = decoupe(LBP_im, k)   
%Cette fonction prend à l'entrée le LBP d'une image et la découpe en k x k
%rectangles de même taille. Puis, elle fait l'histogramme de chaque
%rectangle et l'envoie à la sortie dans la cellule hist, qui a dimension k
%x k. Aussi, elle envoie à la sortie la valeur maximale de tous les
%histogrammes de la cellule.

edges = 0:256;
maxi = 0;


[h_LBP l_LBP] = size(LBP_im);
    for ni = 1:k
        for nj = 1:k
            
           
            inf_i = floor(h_LBP*(ni-1)/k) + 1;
            inf_j = floor(l_LBP*(nj-1)/k) + 1;
            sup_i = floor(h_LBP*ni/k);
            sup_j = floor(l_LBP*nj/k);
            
            LBP_div = LBP_im(inf_i:sup_i, inf_j:sup_j);
            vals = histcounts(LBP_div,edges);
            if (max(vals) > maxi)
                maxi = max(vals);
            end 
            
            hist{ni,nj} = vals;
        end
    end
end
