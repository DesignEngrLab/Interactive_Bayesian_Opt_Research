
designs = zeros(25,2)
suppresent = [30,150,270,390,510]
battery_range =  [10,50,90,130,170]

for i in 1:1:5

    for j in 1:1:5
        designs[(i-1)*5 + j,1] = suppresent[i]
        designs[(i-1)*5 + j,2] = battery_range[j]
    end


end