% Je rappelle qu’il faut avoir une matrice de similarité (« MatchingScore ») 
%et une matrice qui précise la classe des visages(« FaceClass».

 
%Dans l’exemple, la matrice de similarité et la matrice des classes ont 
%la même dimension (960*16). Avec 960 images probes et 16 images de galerie.


clear all;

GalleryNum = 16;  % 16
ProbeNum   = 60*16;  % 60
Piecewise  = 1000;

%load '16 AU result.mat';
%load 'FaceClass.Mat';

% MatchingScore = [ ];
% FaceClass = [];
% 
% % Convert the data from cell to matrix
% for i = 1:ProbeNum
%     TempScore = result_f(1,i).score;
%     MatchingScore = [MatchingScore; TempScore];
%     FaceClass = [FaceClass; result_f(1,i).expression];
%     
% end
% 
% 
% for i = 1 : ProbeNum
%     
%    scores = MatchingScore(i,:);
%    scores = (scores-min(scores))/(max(scores)-min(scores));
%    MatchingScore(i,:) = scores; 
% end


% Max and min value of the matching scores
MaxValue = max(max(MatchingScore));
MinValue = min(min(MatchingScore));

ThresInterval = (MaxValue - MinValue)/Piecewise;



for k = 1:Piecewise
    disp(k);
    TruePosNum = 0;
    FalsePosNum = 0;
    for i = 1:GalleryNum
        for j = 1:ProbeNum
            if (MatchingScore(j, i) > (MinValue+k*ThresInterval))&&(FaceClass(j) == i)
                TruePosNum = TruePosNum + 1;
            elseif (MatchingScore(j, i) > (MinValue+k*ThresInterval))&&(FaceClass(j) ~= i)
                FalsePosNum = FalsePosNum + 1;
            end
        end
    end
    VR(k) = TruePosNum/(ProbeNum);
    FAR(k) = FalsePosNum/((GalleryNum - 1)*ProbeNum);
end

plot(FAR, VR);
hold;
grid;

