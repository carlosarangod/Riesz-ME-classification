clearvars
close all
clc

% matlab_dir = getenv('MATLAB_CODE');
aamdir = strcat('AAM\functions'); addpath(aamdir)
facedecdir = strcat('Face Detection'); addpath(facedecdir)
facelocdir = strcat('Face Registration'); addpath(facelocdir)
faceacqdir = strcat('Image acquisition'); addpath(faceacqdir)
rieszdir = strcat('Riesz Pyramid'); addpath(rieszdir)
pyrdir = strcat('Riesz Pyramid\image_pyramid'); addpath(pyrdir)

%% Selecting an specific image from a Database 
%% SMIC DATABASE
% Database = 'CASME2';
Database = 'SMIC_High';
% 
%% Image Acquistion from Databases
% This part can be commented and replaced for another acuisition scheme
if strcmp(Database,'SMIC_High')||strcmp(Database,'SMIC_RGB')
    if strcmp(Database,'SMIC_High')
        load SMIC_High_labels.mat
    else
        load SMIC_RGB_labels.mat
    end
    Emo_str{length(Subject_label)}=[];
    for i=1:length(Subject_label)
        if (Emotion_label(i)==1)
            Emo_str{i}='po';
        elseif (Emotion_label(i)==2)
            Emo_str{i}='ne';
        elseif (Emotion_label(i)==3)
            Emo_str{i}='sur';
        end
    end    
    sample_freq = 100;
    filter_order = 18;
    spot_interval = 13;
    riez_pyr_ini = 2;
elseif strcmp(Database,'CASME2')
    load CASME2_labels.mat
    sample_freq = 200;
    filter_order = 36;
    spot_interval = 25;
    riez_pyr_ini = 2;
end

% savedir = strcat(featdir,'\Riesz_Histograms_Dmean6para_',Database,'.mat');
% savedirb = strcat(featdir,'\Riesz_Histograms_Dmean6para_secemo_',Database,'.mat');
% Create the face detector object.
mergeThresh = 10;
% Create the point tracker object.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
% Create the Template matcher object.
hTM = vision.TemplateMatcher('ROIInputPort', true,'BestMatchNeighborhoodOutputPort', true);

runLoop = true;
numPts = 0;
Frame_offset = 20;

% AAM parameters
load('cAAM.mat');
%%fitting related parameters
num_of_scales_used = 2;
num_of_iter = 20;
s0 = cAAM.shape{1}.s0;
model_size = sum(max(s0) - min(s0))/2;
current_shape = s0;
sc = 2.^(cAAM.scales-1);
ii=2;
conv_count = 1;
Main_landmarks = [18,20,22,23,25,27,28,30,32,34,36,37,40,43,46,49,52,55,58];
Fixed_points = [32,33,35,36,37,40,43,46,];
rigid_points = [34,40,43];
selected_ROI = [1:5,8:9];

Riesz_Grid_X = 4:10;
Riesz_Grid_Y = 6:12;
Angles = 4:10;

savedir = strcat('Riesz_Histograms_Dmean_',Database,'.mat');
savedirb = strcat('Riesz_Histograms_Dmean_secemo_',Database,'.mat');

%%% Load Feature Extraction Files
% load(savedir)
% load(savedirb)
% 
%%% Initialize Feature Extraction Files
% 
%% Main Process
p2 = 1;
for p = 1:length(Subject_label)
% for p = Second_Emo(:,1)'
    subject = Subject_label(p);
    subset = Subset_label(p);
    onset = Onset_label(p);
    offset = Offset_label(p);
    Emotion = Emotion_label(p);
    Video_str = strcat('Subject: ',num2str(subject),', Subset: ',num2str(subset),', Emotion: ',num2str(Emotion_label(p)));
    disp(Video_str)
    % Read Images from a sequence
    if strcmp(Database,'CASME2')
        total_dir = Img_from_database(Database,subject,subset);
        apex = Apex_label(p);
        sec_emo = [];
        face_sz = [320,295];
    elseif strcmp(Database,'SMIC_High')||strcmp(Database,'SMIC_RGB')
        total_dir = Img_from_database(Database,subject,subset,Emo_str{p});
        sec_emo = find(Second_Emo(:,1)==p);
        if ~isempty(sec_emo)
            onset(2,1) = Second_Emo(sec_emo,2);
            offset(2,1) = Second_Emo(sec_emo,3);
        end
        apex = round((offset+onset)/2);
        face_sz = [240,220];
    end
    myfolderinfo = dir(total_dir);
    length_seq=length(myfolderinfo);
    init_list = [];
    %%%%%%% Sort files
    for k = 3:length_seq
        img_name = myfolderinfo(k,1).name;
        numb = isstrprop(img_name,'digit');
        init_list(k-2) = str2double(img_name(numb));
    end
    [~,sorted_list]=sort(init_list);
    img_name = myfolderinfo(sorted_list(1)+2,1).name;

    dir_img = strcat(total_dir,'\',img_name);
    videoFrame = imread(dir_img);
    % Capture one frame to get its size.
    frameSize = size(videoFrame);

    % Intialize Flags
    is_detecting = true;
    is_aam = false;
    is_tracking = false;
    convergence = false;
    extraction = false;
    frame = 1;
    extraction_frame = 1;
    extraction_frame2 = 1;
    extraction_frame3 = 1;

    Face_crops = [];
    Mini_Face_crops = [];
    Mini_Face_crops2 = [];
    Cir_Mask = [];
    Cir_Mask2 = [];
    % while runLoop && frameCount < 1200
    %% Process Begins
    while (runLoop) && (frame <= length_seq-2)
        %% Detecting Facial Features
        % Reading Image
        if (frame <= length_seq-2)
            img_name = myfolderinfo(sorted_list(frame)+2,1).name;
        end
        dir_img = strcat(total_dir,'\',img_name);
        videoFrame = imread(dir_img);
        % Get the next frame.
        videoFrame2 = videoFrame;
        videoFrameGray = rgb2gray(videoFrame);
        im_size = size(videoFrameGray);
        if is_detecting
            % Detection mode.
            face_coord = face_detection(videoFrame,mergeThresh);
            if ~isempty(face_coord)
                Mouth_img = videoFrameGray(face_coord(5,2)+(0:face_coord(5,4)),face_coord(5,1)+(0:face_coord(5,3)));
                current_shape = Initializing_AAM(face_coord,current_shape,Mouth_img);
                is_detecting = false;
                is_aam = true;
            end
        elseif is_aam
            Z2=current_shape(18:end,:)*sc(ii);
            [current_shape, Mdqp] = update_AAM(current_shape,videoFrameGray,cAAM,ii,conv_count);
            Z1=current_shape(18:end,:)*sc(ii);
            eucZ=mean(sqrt(sum((Z2-Z1).^2,2)));
            conv_count = conv_count + 1; 
            if ((conv_count>25)||(eucZ < 0.12))
                % AAM converges 
                if ii==1
                    convergence = true;
                    is_aam = false;
                    is_tracking = true;
                    final_shape = current_shape(18:end,:);              
                    %% Face ROI
                    face_ROI = Face_ROI_localization(final_shape);
                    [ROI_face_coordinates,ROI_face_crop,ROI_face_geotrans] = crop_coordinates(face_ROI,im_size);
                    init_h = ROI_face_coordinates(2)-ROI_face_coordinates(1)+1;
                    init_w = ROI_face_coordinates(4)-ROI_face_coordinates(3)+1;
                    Face_bbox = [ROI_face_coordinates(3),ROI_face_coordinates(1),ROI_face_coordinates(4)-ROI_face_coordinates(3),ROI_face_coordinates(2)-ROI_face_coordinates(1)];
                     %% Facial Features ROI 
                    [ROI,ROI_ang,ROI_cen] = ROI_localization(final_shape);
                    oldInliers = current_shape(rigid_points,:);
                     num_ROI = size(ROI,3);
                     ROI_size=zeros(num_ROI,2);
                     ROI_coordinates=zeros(num_ROI,4);
                     ROI_crop=zeros(num_ROI,4);
                     for i=1:9
                         if (i==6 || i==7 )
                             [ROI_coordinates(i,:),ROI_crop(i,:),ROI_geotrans{i}] = crop_coordinates(ROI(:,:,i),im_size,'nose');
                         else
                             [ROI_coordinates(i,:),ROI_crop(i,:),ROI_geotrans{i}] = crop_coordinates(ROI(:,:,i),im_size);
                             maxROI = max(ROI(:,:,i));
                             minROI = min(ROI(:,:,i));
                         end
                     end
                    ROI2 = ROI(1:4,:,:);
                    frame = 0;
                    extraction = true;
                end
                ii=1;
                conv_count = 1;
            end
        elseif is_tracking
             conv_count = 0; eucZ = 1;
            while ((conv_count<3)&&(eucZ > 0.12))
            %             while ((conv_count<10)&&(eucZ > 0.07))
                Z2=current_shape(18:end,:)*sc(ii);
                [current_shape, Mdqp] = update_AAM(current_shape,videoFrameGray,cAAM,ii,conv_count);
                Z1=current_shape(18:end,:)*sc(ii);
                eucZ=mean(sqrt(sum((Z2-Z1).^2,2)));
                conv_count = conv_count + 1; 
            end
            visiblePoints = current_shape(rigid_points,:);
            xform = estimateGeometricTransform(oldInliers,visiblePoints,'similarity');
            oldInliers = visiblePoints;
            face_ROI = transformPointsForward(xform, face_ROI);
            facePolygon = reshape(face_ROI', 1, []);
            face_ROI(find(face_ROI(:,2)>im_size(1))+5) = im_size(1);
            face_ROI(find(face_ROI(:,1)>im_size(2))) = im_size(2);
            [Face_crops,Temp_Cir_Mask] = Warp_crop_face(videoFrameGray,face_ROI,current_shape,im_size,face_sz);
            if (frame>= subplus(onset(1) - Frame_offset)) && (frame<=offset(1) + Frame_offset)
                Mini_Face_crops(:,:,extraction_frame2) = Face_crops;
                Cir_Mask(:,:,extraction_frame2) = Temp_Cir_Mask;
                extraction_frame2 = extraction_frame2 + 1;
            end
            if ~isempty(sec_emo) && (frame>= subplus(onset(2) - Frame_offset)) && (frame<=offset(2) + Frame_offset)
                Mini_Face_crops2(:,:,extraction_frame3) = Face_crops;
                Cir_Mask2(:,:,extraction_frame3) = Temp_Cir_Mask;
                extraction_frame3 = extraction_frame3 + 1;
            end
            extraction_frame = extraction_frame + 1;
        end                    
        frame = frame + 1;
    end
 
    %% Video Processing

    max_level = maxSCFpyrHt(Mini_Face_crops(:,:,1));
%     level = 3;
    [~,phase_cos_sin_amp,Amplitude_t] =  RieszMagnificationAnalysis(Mini_Face_crops,2, 10,...
        sample_freq,10,'fil_ord',filter_order,'sigma',2,'pyr_level',4,'pyr_ini',0);
     if ~isempty(sec_emo)
        [~,phase_cos_sin_amp2,Amplitude_t2] =  RieszMagnificationAnalysis(Mini_Face_crops2,2, 10,...
        sample_freq,10,'fil_ord',filter_order,'sigma',2,'pyr_level',4,'pyr_ini',0);
    end

    %%% Phase Analysis
    Amp_thresh = 0.1;
    lambda = [25,50,200];
    pyr_level = 3;
    f3 = size(Amplitude_t{1,1},3);
    %% Histogram Features Extractions
    phase_magnitude = []; phase_angle = []; 
    %%%% Phase Pre-processing
    k2 = 1;
    % for s=1:f3
    if onset<=Frame_offset
        F_onset = onset(1);
    else
        F_onset = Frame_offset+1;
    end
    if apex == 0
        apex = round((offset+onset)/2);
    end
    F_apex  = F_onset+(apex(1)-onset(1));
    for lev = 1:3
        [img_h,img_w,~]=size(phase_cos_sin_amp{1,lev+1});
        fr_ofset = 5;
        wd_ofset = fr_ofset:(img_w-fr_ofset);
        ht_ofset = fr_ofset:(img_h-fr_ofset);

        Amplitude = Amplitude_t{1,lev+1};
        Cir_Maskb = imresize(Cir_Mask,size(Amplitude(:,:,1)));
        New_ROI_Masks2 = sum(Cir_Maskb(ht_ofset,wd_ofset,F_onset:F_apex),3)>0;
        Weighted_Average_X = mean(squeeze(phase_cos_sin_amp{1,lev+1}(ht_ofset,wd_ofset,1,F_onset:F_apex)).*Cir_Maskb(ht_ofset,wd_ofset,F_onset:F_apex),3);
        Weighted_Average_Y = mean(squeeze(phase_cos_sin_amp{1,lev+1}(ht_ofset,wd_ofset,2,F_onset:F_apex)).*Cir_Maskb(ht_ofset,wd_ofset,F_onset:F_apex),3);        
       
        phase_magnitude = sqrt(Weighted_Average_X.^2 + Weighted_Average_Y.^2);
        phase_angle = atan2(Weighted_Average_Y,Weighted_Average_X);
         %%%% Feature Extraction
        for x = 1:length(Riesz_Grid_X)
            for y=1:length(Riesz_Grid_Y)
                for a=1:length(Angles)
                     % Extract Feature Histograms for Riesz Pyramid
                    Riesz_Hist_grid_para{p,a,x,y,lev} = Grid_oriented_features(phase_magnitude,phase_angle,[Riesz_Grid_X(x),Riesz_Grid_Y(y)],Angles(a));
                end
            end
         end
    
        save(savedir,'Riesz_Hist_grid_para');

        if ~isempty(sec_emo)
            if onset<=Frame_offset
                F_onset = onset(2);
            else
                F_onset = Frame_offset+1;
            end
            F_apex  = F_onset+(apex(2)-onset(2));
            Amplitude = Amplitude_t{1,lev+1};
            Cir_Maskb = imresize(Cir_Mask2,size(Amplitude(:,:,1)));
            New_ROI_Masks2 = sum(Cir_Maskb(ht_ofset,wd_ofset,F_onset:F_apex),3)>0;
            Weighted_Average_X = mean(squeeze(phase_cos_sin_amp2{1,lev+1}(ht_ofset,wd_ofset,1,F_onset:F_apex)).*Cir_Maskb(ht_ofset,wd_ofset,F_onset:F_apex),3);
            Weighted_Average_Y = mean(squeeze(phase_cos_sin_amp2{1,lev+1}(ht_ofset,wd_ofset,2,F_onset:F_apex)).*Cir_Maskb(ht_ofset,wd_ofset,F_onset:F_apex),3);        

            phase_magnitude = sqrt(Weighted_Average_X.^2 + Weighted_Average_Y.^2);
            phase_angle = atan2(Weighted_Average_Y,Weighted_Average_X);
            %%%% Feature Extraction
            for x = 1:length(Riesz_Grid_X)
                for y=1:length(Riesz_Grid_Y)
                    for a=1:length(Angles)
                         % Extract Feature Histograms for Riesz Pyramid
                        Riesz_Hist_grid_parab{p2,a,x,y,lev} = Grid_oriented_features(phase_magnitude,phase_angle,[Riesz_Grid_X(x),Riesz_Grid_Y(y)],Angles(a));
                    end
                end
            end
            save(savedirb,'Riesz_Hist_grid_parab');

            if lev==3
                p2 = p2+1;
            end
        end
    end
end
    beep

