function Lip_Height = betweenlips(mouth_img)
    % Lip_Height takes the grayscale image of a mouth and tries to find
    % the location of the line between the lips
    
    %Calculate the Laplacian of the image
    H = fspecial('log');
    Lapl = imfilter(mouth_img,H,'replicate');
%     mwidth = round(size(mouth_img,2)/4);
%     Lapl = imfilter(mouth_img(:,mwidth:(3*mwidth)),H,'replicate');

%      figure(); imshow(Lapl,jet); colorbar;
%     title('Image Laplacian');
    [a,b]=size(Lapl);
    % Select the 1% strongest Laplacian
    smallper = round(a*b*0.01);
    [~,I]=sort(reshape(Lapl,a*b,1),'descend');
    I2=I(1:smallper);
    % Discriminate strong laplacian with light intensity values
    mouth_thresh = 60;
    ZZ=mouth_img(I2) < mouth_thresh;
    I3=I2(ZZ);
    while isempty(I3)
        mouth_thresh = mouth_thresh + 10;
        ZZ=mouth_img(I2) < mouth_thresh;
        I3=I2(ZZ);
    end
    [LapY,LapX] =  ind2sub(size(Lapl),I3);
    %Detect Outliers using the method of Quartiles
    Lip_y = sort(LapY);
    Q = quantile(Lip_y,[0.25,0.5,0.75]);
    Qrange=Q(3)-Q(1);
    if Qrange>0
        K = 2;
        low_bound = Q(1)-Qrange*K;
        up_bound = Q(3)+Qrange*K;
        ZZ = (LapY>low_bound & LapY<up_bound);        % Visualize Strongest Values of the Region between Lips
        LapY2 = LapY(ZZ);
    else
        LapY2 = LapY;
        ZZ = 1:length(LapX);
    end
    LapX2=LapX(ZZ);
%     figure(7); imshow(mouth_img,[]); hold on;
%     plot(LapX,LapY,'y+')
%     plot(LapX2,LapY2,'r+')
%     plot(mean(LapX2),mean(LapY2),'m*')
    Lip_Height = mean(LapY2);
end