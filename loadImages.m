function images = loadImages()
    for n_paste = 1:40 %Choisit le dossier d'ou prendre les images
% 
%         d = dir(['ORL/S', num2str(n_paste), '/*.bmp']); %Ouvre le dossier
%         nfiles = length(d); %Compte le nombre d'images

        for i = 1:10
            images{n_paste,i} = imread(['ORL/S', num2str(n_paste) ,'/',...
                num2str(i),'.bmp']);
        end
    end
    
end
