function c = chicarre(hist1, hist2)
%Cette fonction fait le chicarre entre les deux histogrammes envoyés à
%l'entrée hist1 et hist2

c = 0;
if ((length(hist1) == length(hist2)) && length(hist1) == 256)
    for i = 1:256
        if (hist1(i) ~= hist2(i))
            c = c + (hist1(i) - hist2(i))^2/(hist1(i) + hist2(i));
        end
    end
else
    c = NaN;
end

end