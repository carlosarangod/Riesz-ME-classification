function Face_coord = Pose_Landmark(Img,model,Thresh)
    angle = -30:15:30;
    max_s = -1000;
    k=0;
    [y,x,~]=size(Img);
    for i = 1:length(angle)
        b = detect(imrotate(Img,angle(i)), model, model.thresh);
        b = clipboxes(Img, b);
        b = nms_face(b,Thresh);
        if ~isempty(b)
            bs{i} = b(1);
            if (max_s < bs{i}.s)
                max_s = bs{i}.s;
                k = i;
            end
        else
            bs{i} = [];
        end
    end
    bs2 = bs{k};
    Face_Positions{1} = 10:15;
    Face_Positions{2} = 21:26;
    Face_Positions{3} = 6;
    Face_Positions{4} = [34:38,40:51];
    figure;
    imagesc(imrotate(Img,angle(k)));
    hold on;
    axis image;
    axis off;
    for i = size(bs2.xy,1):-1:1
        x1 = bs2.xy(i,1);
        y1 = bs2.xy(i,2);
        x2 = bs2.xy(i,3);
        y2 = bs2.xy(i,4);
        plot((x1+x2)/2,(y1+y2)/2,'r.','markersize',15);
    end
    for i = 1:4
        j = Face_Positions{i};
        x1 = bs2.xy(j,1);
        y1 = bs2.xy(j,2);
        x2 = bs2.xy(j,3);
        y2 = bs2.xy(j,4);
        Face_coord_t(i,:) = [mean(x1+x2)'/2,mean(y1+y2)'/2]; 
        plot(Face_coord_t(i,1),Face_coord_t(i,2),'b*','markersize',10);
    end
    angle2 = angle*pi/180;
    [y,x,~]=size(imrotate(Img,angle(k)));
    [yb,xb,~]=size(Img);

    rotation_matrix = [cos(-angle2(k)),-sin(-angle2(k));sin(-angle2(k)),cos(-angle2(k))];
    Face_coord = (Face_coord_t-repmat([x,y]/2,[4,1]))*rotation_matrix + repmat([xb,yb]/2,[4,1]);
end