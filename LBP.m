function LBP_im = LBP(im)

circ = [0 -1; 1 -1; 1 0; 1 1; 0 1; -1 1; -1 0; -1 -1];
%Vecteur qui va conduire le calcule du LBP pour un pixel. Il commence au
%point à gauche du point de comparaison, et tourne dans le sens
%anti-horaire

[h, l] = size(im); %h et l dimensions de l'image

%Application du LBP
for i = 2:(h-1)
    for j = 2: (l-1)
        %On ne fait pas le calcule pour les points du bord, parce qu'ils ne
        %sont pas entourés d'autres points dans toutes directions. Aussi,
        %ils sont négligeables car le visage est au centre de l'image
        
        thresh = im(i,j);
        %Le seuil est la valeur du pixel du centre
        
        LBP_pixel = uint8(0); %Initialisation de la valeur du calcule du LBP pour le pixel
        
        for n = 1:8
            loc = im((i+circ(n,1)),(j+circ(n,2)));
            %loc est un point qui entoure le point centrale du calcul, et
            %la rotation autour du point centrale est assuré par le vecteur
            %circ
            
            if (loc > thresh)
                LBP_pixel = LBP_pixel + 2^(8-n);
                %Calcule la valeur du LBP, ajoutant une puissance de 2 si
                %la valeur du pixel qui entoure le pixel central est plus
                %grande que la valeur du pixel central
            end
        end
        LBP_im((i-1),(j-1)) = LBP_pixel;
        %Construit l'image LBP
        
    end
end

end