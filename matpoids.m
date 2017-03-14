function m = matpoids(k)
%Cette fonction produit une matrice qui donne les poids de chaque région.

x = 0.5:(k-0.5);
y = -4*x.*(x-k)/k^2;
%Fonction utilisé pour calculé les poids : quadratique

s = 0;
for i = 1:k
    for j = 1:k
        m(i,j) = y(i)*y(j);
        s = s + m(i,j);
    end
end

m = m/s;
end