function [warped_face,Circ_Mask] = Warp_crop_face(Face_img,ROI_polygon,AAM_shape,im_size,face_size)
    minROI = min(ROI_polygon);
    maxROI = max(ROI_polygon);
    if maxROI(2)>im_size(1)
        maxROI(2)=im_size(1);
    end
    if maxROI(1)>im_size(2)
        maxROI(1)=im_size(2);
    end
    a = ROI_polygon(1,:)-minROI;
    b = ROI_polygon(2,:)-minROI;
    c = ROI_polygon(3,:)-minROI;
    d = ROI_polygon(4,:)-minROI;
    Yin = [a(2) b(2) c(2) d(2)];
    Xin = [a(1) b(1) c(1) d(1)];
    width = sqrt(sum(a-b).^2);
    height = sqrt(sum((c-b).^2));
    Xout = [0,face_size(2),face_size(2),0];
    Yout = [0,0,face_size(1),face_size(1)];
    ROI_geotrans = fitgeotrans( [Xin;Yin]', [Xout;Yout]', 'affine' );
    ROI_coordinates=ceil([minROI(2),maxROI(2),minROI(1),maxROI(1)]);
    crop_face = Face_img(ROI_coordinates(1):ROI_coordinates(2),ROI_coordinates(3):ROI_coordinates(4),:);
    bigbox = double([ROI_coordinates(2)-ROI_coordinates(1),ROI_coordinates(4)-ROI_coordinates(3)]+1);
    crop_mask = poly2mask(double(Xin),double(Yin),bigbox(1),bigbox(2));
    cir_poly = AAM_shape(1:17,:)- repmat(minROI,[17,1]);
    cir_lbrow = AAM_shape(18,:) - minROI;
    cir_rbrow = AAM_shape(27,:) - minROI;
%     cir_poly = transformPointsForward(ROI_geotrans, cir_poly);
    left_line(:,1) = linspace(cir_lbrow(1),cir_poly(1,1),6);
    left_line(:,2) = linspace(0,1,6).^3 * (cir_poly(1,2));
    left_line(end,:) = [];
    right_line(:,1) = linspace(cir_poly(17,1),cir_rbrow(1),6);
    right_line(:,2) = linspace(1,0,6).^3 * (cir_poly(17,2));
    right_line(1,:) = [];
%     cir_poly = cat(1,[0,0],cir_poly,[bigbox(1),0]);
    cir_poly = cat(1,left_line,cir_poly,right_line);

    cyr_mask = poly2mask(cir_poly(:,1),cir_poly(:,2),bigbox(1),bigbox(2));
    Warp_Mask = imwarp( cyr_mask, ROI_geotrans, 'cubic' );
    Img_crop = im2double(crop_face).*crop_mask;
    Transformed_img = imwarp( Img_crop, ROI_geotrans, 'cubic' );
    [y,x,~] = size(Transformed_img);
    deltax = abs(x-face_size(2))/2+1;
    deltay = abs(y-face_size(1))/2+1;
    ROI_crop = round([deltay,y-deltay,deltax,x-deltax]); 
    warped_face = Transformed_img(ROI_crop(1):ROI_crop(2),ROI_crop(3):ROI_crop(4),:);
    Circ_Mask = Warp_Mask(ROI_crop(1):ROI_crop(2),ROI_crop(3):ROI_crop(4));
end
