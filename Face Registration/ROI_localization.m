function [ROI,Ang,Center] = ROI_localization(face_landmarks)
    % Eyes,Nose and Mouth axis calculation
    [eye_eq,ey_ln] = facial_features_axis(face_landmarks(20:31,:),face_landmarks(20,1),face_landmarks(29,1));
%     [nose_eq,ns_ln] = facial_features_axis(face_landmarks([11:14 17],:),face_landmarks(11,1),face_landmarks(17,1));
    [mouth_eq,mo_ln] = facial_features_axis(face_landmarks([32,38,44:51],:),face_landmarks(32,1),face_landmarks(38,1));
    
    % Nose axis calculation based on Eye axis
    nose_xy = mean(face_landmarks([11:14 17],:));
    b_nose = nose_xy(2) + nose_xy(1)*1/eye_eq(2);
    nose_eq = [b_nose,-1/eye_eq(2)];
    
    % Eyebrow axis calculation based on Eye axis
    left_brow_xy = mean(face_landmarks(1:5,:));
    right_brow_xy = mean(face_landmarks(6:10,:));
    b_lbr = left_brow_xy(2) + left_brow_xy(1)*eye_eq(2)*(-1);
    b_rbr = right_brow_xy(2) + right_brow_xy(1)*eye_eq(2)*(-1);
    lbr_eq = [b_lbr,eye_eq(2)];
    rbr_eq = [b_rbr,eye_eq(2)];
    
    % Calculation of ROI aound the eyes
    [Left_eye_ROI,LE_ang,LE_cen] = facial_features_box(face_landmarks(20:25,:),eye_eq,'eye',2);
    [Right_eye_ROI,RE_ang,RE_cen] = facial_features_box(face_landmarks(26:31,:),eye_eq,'eye',2);
    % Calculation of ROI aound the eyebrows
    [Left_brow_ROI,LBR_ang,LBR_cen] = facial_features_box(face_landmarks(1:5,:),lbr_eq,'brow',[0,1],mean(Left_eye_ROI(1:2,:)));
    [Right_brow_ROI,RBR_ang,RBR_cen] = facial_features_box(face_landmarks(6:10,:),rbr_eq,'brow',[0,1],mean(Right_eye_ROI(1:2,:)));

    % Calculation of ROI around the nose and mouth area
    [Upper_Nose_ROI,~,~] = facial_features_box(face_landmarks(11:19,:),nose_eq,'up_nose',[1,1],face_landmarks(11,:),[mean(Left_eye_ROI(2:3,:));mean(Right_eye_ROI(4:5,:))]);    
    [Left_Mcorner_ROI,~,~] = facial_features_box(face_landmarks(32:51,:),mouth_eq,'m_corner',[2,0;2,1],face_landmarks(32,:));
    [Right_Mcorner_ROI,~,~] = facial_features_box(face_landmarks(32:51,:),mouth_eq,'m_corner',[0,2;2,1],face_landmarks(38,:));
    [Lower_Nose_ROI,~,~] = facial_features_box(face_landmarks(11:19,:),nose_eq,'low_nose',[2,2;1,0.5],face_landmarks(17,:),[face_landmarks(32,:);face_landmarks(38,:)]);
    [Mouth_ROI,M_ang,M_cen] = facial_features_box(face_landmarks(32:51,:),mouth_eq,'mouth',[0,1],mean(Lower_Nose_ROI(2:3,:)));

    % Resulting Regions of Interests
%     ROI = cat(3,Left_brow_ROI,Right_brow_ROI,Left_eye_ROI,Right_eye_ROI,Mouth_ROI,Upper_Nose_ROI,Lower_Nose_ROI,Left_Mcorner_ROI,Right_Mcorner_ROI);
    ROI = cat(3,Left_brow_ROI,Right_brow_ROI,Left_eye_ROI,Right_eye_ROI,Mouth_ROI,Upper_Nose_ROI,Lower_Nose_ROI,Left_Mcorner_ROI,Right_Mcorner_ROI);
    Ang = cat(1,LBR_ang,RBR_ang,LE_ang,RE_ang,M_ang);
    Center = cat(1,LBR_cen,RBR_cen,LE_cen,RE_cen,M_cen);
    % Visualization of the Axis Lines
%     hold on;
%     plot(face_landmarks(:,1),face_landmarks(:,2),'*','Color',[0 1 1]);
%     plot(ey_ln(:,1),ey_ln(:,2),'y')
%     plot(mo_ln(:,1),mo_ln(:,2),'y')
%     plot(lbrow_ln(:,1),lbrow_ln(:,2),'y')

end