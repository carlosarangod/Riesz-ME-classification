function [ROI_coordinates,ROI_crop,ROI_geotrans] = crop_coordinates(ROI_polygon,im_size,varargin)
    if (nargin==2)
        type = 'other';
    elseif (nargin==3)
        type  = varargin(1);
    else
        error('Unexpected inputs')
    end
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
    if strcmp(type,'nose')
        width = sqrt(sum(a-d).^2);
        height = sqrt(sum((a-b).^2));
        Xout = [0,0,width,width];
        Yout = [0,height,height,0];
    elseif strcmp(type,'forehead')
        width = sqrt(sum(a-b).^2);
        height = sqrt(sum((c-b).^2));
        Xout = [0,width,width,0];
        Yout = [height,height,0,0];
    else
        width = sqrt(sum(a-b).^2);
        height = sqrt(sum((c-b).^2));
        Xout = [0,width,width,0];
        Yout = [0,0,height,height];
    end
    ROI_geotrans = fitgeotrans( [Xin;Yin]', [Xout;Yout]', 'affine' );
    ROI_coordinates=round([minROI(2),maxROI(2),minROI(1),maxROI(1)]);
    bigbox = double(ceil(maxROI-minROI));
    crop_mask = poly2mask(double(Xin),double(Yin),bigbox(2),bigbox(1));
%         Img_crop = repmat(crop_mask,[1,1,3]);
    Transformed_mask = imwarp( double(crop_mask), ROI_geotrans, 'cubic' );
    [y,x,~] = size(Transformed_mask);
    deltax = (x-width)/2+1;
    deltay = (y-height)/2+1;
    ROI_crop = round([deltay,y-deltay,deltax,x-deltax]); 
end
