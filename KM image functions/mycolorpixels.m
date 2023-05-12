function I=mycolorpixels(I,idx,co)

for ich = 1:3
    temp = I(:,:,ich);
    temp(idx)=co(ich);
    I(:,:,ich) = temp;
end

end