function face_coord = Pose_Face(Img,mergeThresh)
    angle = -30:15:30;
    faceDetector = vision.CascadeObjectDetector;
    maxfacearea = 2500;
    finalbox = [];
    detected = true;
    for i = 1:length(angle)
       bbox = step(faceDetector,imrotate(Img,angle(i)));
       [v,~]=size(bbox);
        if ~isempty(bbox)
            if v==1
                facebox=bbox;
            else
                maxarea = 0;
                boxind = 0;
                for l=1:v
                    boxarea = bbox(l,3)*bbox(l,4);
                    if boxarea>maxarea
                        maxarea = boxarea;
                        boxind = l;
                    end
                end
                facebox = bbox(boxind,:);
            end
            if ~isempty(facebox)
                facearea = facebox(3)*facebox(4);
                if  facearea>maxfacearea
                    maxfacearea = facearea;
                    finalbox = facebox;
                    final_angle = angle(i);
                end                
            end
        end
    end
    if ~isempty(finalbox)
        noseDetector = vision.CascadeObjectDetector('Nose','MergeThreshold',mergeThresh);
        mouthDetector = vision.CascadeObjectDetector('Mouth','MergeThreshold',mergeThresh);
        lefteyeDetector = vision.CascadeObjectDetector('LeftEye','MergeThreshold',mergeThresh);
        righteyeDetector = vision.CascadeObjectDetector('RightEye','MergeThreshold',mergeThresh);
        input_img = imrotate(Img,final_angle);
        ROIface = input_img(finalbox(2):finalbox(2)+finalbox(4),finalbox(1):finalbox(1)+finalbox(3),:);
        box_lefteye=[1,round(finalbox(4)/7),round(finalbox(3)/2),round(finalbox(4)/2)];
        box_righteye=[round(finalbox(3)/2),round(finalbox(4)/7),round(finalbox(3)/2),round(finalbox(4)/2)];
        box_nose=[round(finalbox(3)/4),round(finalbox(4)/3),round(finalbox(3)/2),round(finalbox(4)/2)];
%         box_mouth=[round(finalbox(3)/4),2*round(finalbox(4)/3),round(finalbox(3)/2),round(finalbox(4)/3)];
        box_mouth=[round(finalbox(3)/4),3*round(finalbox(4)/5),round(finalbox(3)/2),2*floor(finalbox(4)/5)];

        ROI_righteye = ROIface(box_righteye(2):box_righteye(2)+box_righteye(4),box_righteye(1):box_righteye(1)+box_righteye(3),:);
        ROI_lefteye = ROIface(box_lefteye(2):box_lefteye(2)+box_lefteye(4),box_lefteye(1):box_lefteye(1)+box_lefteye(3),:);
        ROI_nose = ROIface(box_nose(2):box_nose(2)+box_nose(4),box_nose(1):box_nose(1)+box_nose(3),:);
        ROI_mouth = ROIface(box_mouth(2):box_mouth(2)+box_mouth(4),box_mouth(1):box_mouth(1)+box_mouth(3),:);
        %% Visualization of ROI
        ROIface2 = insertShape(ROIface, 'rectangle', box_lefteye);
        ROIface2 = insertShape(ROIface2, 'rectangle', box_righteye);
        ROIface2 = insertShape(ROIface2, 'rectangle', box_nose,'Color','r');
        ROIface2 = insertShape(ROIface2, 'rectangle', box_mouth,'Color','g');
        figure(2), imshow(ROIface2)

        
        lefteyebox = step(lefteyeDetector,ROI_lefteye);
        if isempty(lefteyebox) detected = false;
        else lefteyebox2 = feature_box(lefteyebox,finalbox,box_lefteye);
        end
        % Detecting Right Eye
        righteyebox = step(righteyeDetector,ROI_righteye);
        if isempty(righteyebox) detected = false;
        else righteyebox2 = feature_box(righteyebox,finalbox,box_righteye);
        end
        % Detecting Nose
        nosebox = step(noseDetector,ROI_nose);
        if isempty(nosebox) detected = false;
        else nosebox2 = feature_box(nosebox,finalbox,box_nose);
        end
        % Detecting Mouth
        mouthbox = step(mouthDetector,ROI_mouth);
        if isempty(mouthbox) detected = false;
        else mouthbox2 = feature_box(mouthbox,finalbox,box_mouth);
        end
        if (detected)
            face_coord = [finalbox;lefteyebox2;righteyebox2;nosebox2;mouthbox2];
        else
            face_coord = [];
        end
    else
        face_coord = [];
    end
end