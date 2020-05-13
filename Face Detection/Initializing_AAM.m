function trans_shape = Initializing_AAM(face_coord,init_shape,Mouth_img)
    lefteye_loc_det = (face_coord(2,1:2) + face_coord(2,3:4)/2);
    righteye_loc_det = (face_coord(3,1:2) + face_coord(3,3:4)/2);
    nose_loc_det = (face_coord(4,1:2) + face_coord(4,3:4)/2);
    mouth_loc_det = (face_coord(5,1:2) + face_coord(5,3:4)/2);
%     Lip_Height = betweenlips(Mouth_img);
    mwidth = round(size(Mouth_img,2)/5);
    Lip_Height = betweenlips(Mouth_img(:,mwidth:(4*mwidth)));

    Mouth_new_height = Lip_Height + face_coord(5,2);
    face_height = Mouth_new_height - (lefteye_loc_det(2) + righteye_loc_det(2))/2;
    face_width = (righteye_loc_det(1) - lefteye_loc_det(1));

    lefteye_loc_model = mean(init_shape(37:42,:));
    righteye_loc_model = mean(init_shape(43:48,:)); 
    %%% Face Height calculated using the modelled mouth as reference
    mouth_loc_model = mean(init_shape(62:68,:));
    centroid_model = mean([lefteye_loc_model;righteye_loc_model;mouth_loc_model]);
    centroid_located = mean([lefteye_loc_det;righteye_loc_det;mouth_loc_det(1),Mouth_new_height]);
    
    model_height = mouth_loc_model(2) - (righteye_loc_model(2)+lefteye_loc_model(2))/2;
    model_width = righteye_loc_model(1) - lefteye_loc_model(1);
    scx = face_width/model_width;
    scy = face_height/model_height;

    model_points = [lefteye_loc_model;righteye_loc_model;mouth_loc_model] - repmat(centroid_model,[3,1]);
    located_points = [lefteye_loc_det;righteye_loc_det;mouth_loc_det(1),Mouth_new_height] - repmat(centroid_located,[3,1]);
%     C = model_points'*located_points;
    C = located_points'*model_points;
    [U,~,V] = svd(C);
    R = V*U';
    trans_shape = (repmat([scx,scy], 68, 1).*(init_shape-repmat(centroid_model,68,1)))*(R) + repmat(centroid_located, 68, 1);
end