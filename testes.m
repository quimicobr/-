n = 10;
s = [5, 2];
arthur = reshape([1,2,3,4,5;6,7,8,9,10], 2, 5);
t_arthur = arthur';
arthurz = zeros(n);
for i = 1:n
    for j = i:n
        [I1, J1] = ind2sub(s, i);
        [I2, J2] = ind2sub(s, j);
        arthurz(i,j) = t_arthur(I1,J1)+t_arthur(I2,J2); 
    end
end