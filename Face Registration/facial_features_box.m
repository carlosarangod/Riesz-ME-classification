function [Corners,feat_ang,Center] = facial_features_box(feat_points,axis_eq,roi_parent,box_width,varargin)
    switch nargin
        case 4
            if strcmp(roi_parent,'eye')
                parallel_points = [2,3,5,6];
                orthogonal_points = [1,4];
                flip = 2;
            elseif strcmp(roi_parent,'face')
                parallel_points = [2:4,6:8,11:15];
                orthogonal_points = [1,10];
                flip = 6;
            end
            diff_landmark = false;

        case 5  
            if strcmp(roi_parent,'brow')
                diff_landmark = false;
                parallel_points = [2,3,4,1,5];
                orthogonal_points = [1,5];
                flip = 3;
                limit_point = varargin{1};
            elseif strcmp(roi_parent,'m_corner')
                diff_landmark = true;
                parallel_points = [3,5,9,10,11];
                orthogonal_points = [1,7];
                flip = 2;   
                box_center = varargin{1};
            elseif strcmp(roi_parent,'mouth')
                diff_landmark = false;
                parallel_points = [3,5,9,10,11];
                orthogonal_points = [1,7];
                flip = 2;
                limit_point = varargin{1};
            end    
        case 6
            if strcmp(roi_parent,'up_nose')||strcmp(roi_parent,'low_nose')
                parallel_points = [5,9];
                orthogonal_points = [5,1];
                flip = 1;
            end
            diff_landmark = true;
            box_center = varargin{1};
            limit_point = varargin{2};
        otherwise
            error('Unexpected inputs')
    end
    m = axis_eq(2);
    b = axis_eq(1);
    feat_ang = atan(m);
    if strcmp(roi_parent,'up_nose')||strcmp(roi_parent,'low_nose')&& feat_ang<0
        feat_ang = -feat_ang;
    end
    ABC = [-m,1,-b];
    d=length(parallel_points);
    max_dist2=[0,0];
    x12 = [0,0];
    y12 = [0,0];
    z=1;
    for k=1:d
        x0=feat_points(parallel_points(k),1);
        y0=feat_points(parallel_points(k),2);
        Dist = abs(ABC(1)*x0 + ABC(2)*y0 + ABC(3))/sqrt(ABC(1)^2+ABC(2)^2);
        if Dist>max_dist2(z)
            max_dist2(z) = Dist;
            x12(z) = x0;
            y12(z) = y0;
        end
        if k==flip
            z = 2;
        end
    end
    max_dist = mean(max_dist2);
    max_brow_dist=10000;
    if strcmp(roi_parent,'brow')||strcmp(roi_parent,'up_nose')||strcmp(roi_parent,'low_nose')||strcmp(roi_parent,'mouth')
        d=size(limit_point,1);
        for k = 1:d
            x0 = limit_point(k,1);
            y0 = limit_point(k,2);
            Dist = abs(ABC(1)*x0 + ABC(2)*y0 + ABC(3))/sqrt(ABC(1)^2+ABC(2)^2);
            if k == 1 || Dist < max_brow_dist
                max_brow_dist = Dist;
                x12b = x0;
                y12b = y0;
            end
        end
    end
    if diff_landmark
        x12(:) = box_center(1);
        y12(:) = box_center(2);
    end
    
    d2=length(box_width(:));
    if d2==1
        box_scale = repmat(box_width,2,2);
    elseif d2==2
        box_scale = repmat(box_width',1,2);
    else
        box_scale = box_width;
    end
    
    x1 = x12(1) - box_scale(1,1)*max_dist*cos(pi/2-feat_ang);
    y1 = y12(1) - box_scale(2,1)*max_dist*sin(pi/2-feat_ang);
    x2 = x12(2) + box_scale(1,2)*max_dist*cos(pi/2-feat_ang);
    y2 = y12(2) + box_scale(2,2)*max_dist*sin(pi/2-feat_ang);
    
     
        if strcmp(roi_parent,'brow')&& max_brow_dist < (1+box_scale(2,2))*max_dist
                x2 = x12b;
                y2 = y12b;
        elseif strcmp(roi_parent,'mouth') && max_brow_dist < (1+box_scale(2,1))*max_dist
                x1 = x12b;
                y1 = y12b;
        elseif (strcmp(roi_parent,'up_nose')||strcmp(roi_parent,'low_nose')) && max_brow_dist < (1+box_scale(2,2))*max_dist 
                x1 = x12(1) - max_brow_dist*cos(pi/2-feat_ang);
                y1 = y12(1) - max_brow_dist*sin(pi/2-feat_ang);
                x2 = x12(2) + max_brow_dist*cos(pi/2-feat_ang);
                y2 = y12(2) + max_brow_dist*sin(pi/2-feat_ang);    
        end
    
    b1 = y1+x1*(-m);
    b2 = y2+x2*(-m);

    if diff_landmark
        x3 = box_center(1);
        y3 = box_center(2);
        x4 = box_center(1);
        y4 = box_center(2);
    else
        x3 = feat_points(orthogonal_points(1),1);
        x4 = feat_points(orthogonal_points(2),1);
        y3 = feat_points(orthogonal_points(1),2);
        y4 = feat_points(orthogonal_points(2),2);
    end
    
    x3 = x3 - box_scale(1,1)*max_dist*cos(feat_ang);
    y3 = y3 - box_scale(2,1)*max_dist*sin(feat_ang);
    b3 = y3+x3*(1/m);
    x4 = x4 + box_scale(1,2)*max_dist*cos(feat_ang);
    y4 = y4 + box_scale(2,2)*max_dist*sin(feat_ang);
    b4 = y4+x4*(1/m);
    
    Corners(1,1) = (b3-b1)/(m+1/m);
    Corners(1,2) = m*Corners(1,1)+b1;
    Corners(2,1) = (b4-b1)/(m+1/m);
    Corners(2,2) = m*Corners(2,1)+b1;
    Corners(3,1) = (b4-b2)/(m+1/m);
    Corners(3,2) = m*Corners(3,1)+b2;
    Corners(4,1) = (b3-b2)/(m+1/m);
    Corners(4,2) = m*Corners(4,1)+b2;
    Corners(5,:) = Corners(1,:);
    Center = mean(Corners(1:4,:));
end