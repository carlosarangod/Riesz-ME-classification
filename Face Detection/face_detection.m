function face_coord = face_detection(input_image,mergeThresh)
    %% Configure Cascade
    detected = true;
    faceDetector = vision.CascadeObjectDetector;

    noseDetector = vision.CascadeObjectDetector('Nose','MergeThreshold',mergeThresh);
    mouthDetector = vision.CascadeObjectDetector('Mouth','MergeThreshold',mergeThresh);
    lefteyeDetector = vision.CascadeObjectDetector('LeftEye','MergeThreshold',mergeThresh);
    righteyeDetector = vision.CascadeObjectDetector('RightEye','MergeThreshold',mergeThresh);
    % Detecting Face
    bbox = step(faceDetector,input_image);
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
        ROIface=input_image(facebox(2):facebox(2)+facebox(4),facebox(1):facebox(1)+facebox(3),:);

        %% Defining the regions of interest of facial features
        box_lefteye=[1,round(facebox(4)/7),round(facebox(3)/2),round(facebox(4)/2)];
        box_righteye=[round(facebox(3)/2),round(facebox(4)/7),round(facebox(3)/2),round(facebox(4)/2)];
        box_nose=[round(facebox(3)/4),round(facebox(4)/3),round(facebox(3)/2),round(facebox(4)/2)];
        box_mouth=[round(facebox(3)/4),2*round(facebox(4)/3),round(facebox(3)/2),round(facebox(4)/3)];
        ROI_righteye = ROIface(box_righteye(2):box_righteye(2)+box_righteye(4),box_righteye(1):box_righteye(1)+box_righteye(3),:);
        ROI_lefteye = ROIface(box_lefteye(2):box_lefteye(2)+box_lefteye(4),box_lefteye(1):box_lefteye(1)+box_lefteye(3),:);
        ROI_nose = ROIface(box_nose(2):box_nose(2)+box_nose(4),box_nose(1):box_nose(1)+box_nose(3),:);
        ROI_mouth = ROIface(box_mouth(2):box_mouth(2)+box_mouth(4),box_mouth(1):box_mouth(1)+box_mouth(3),:);
        %% Visualization of ROI
%         ROIface2 = insertShape(ROIface, 'rectangle', box_lefteye);
%         ROIface2 = insertShape(ROIface2, 'rectangle', box_righteye);
%         ROIface2 = insertShape(ROIface2, 'rectangle', box_nose,'Color','r');
%         ROIface2 = insertShape(ROIface2, 'rectangle', box_mouth,'Color','g');
%         figure(2), imshow(ROIface2)
        %% Detecting Facial Features
        % Detecting Left Eye
        lefteyebox = step(lefteyeDetector,ROI_lefteye);
        if isempty(lefteyebox) detected = false;
        else lefteyebox2 = feature_box(lefteyebox,facebox,box_lefteye);
        end
        % Detecting Right Eye
        righteyebox = step(righteyeDetector,ROI_righteye);
        if isempty(righteyebox) detected = false;
        else righteyebox2 = feature_box(righteyebox,facebox,box_righteye);
        end
        % Detecting Nose
        nosebox = step(noseDetector,ROI_nose);
        if isempty(nosebox) detected = false;
        else nosebox2 = feature_box(nosebox,facebox,box_nose);
        end
        % Detecting Mouth
        mouthbox = step(mouthDetector,ROI_mouth);
        if isempty(mouthbox) detected = false;
        else mouthbox2 = feature_box(mouthbox,facebox,box_mouth);
        end
        %% Visualization
%         if (detected)
%             IFaces = insertObjectAnnotation(input_image, 'rectangle', facebox, 'Face');
%             IFaces = insertShape(IFaces, 'rectangle', nosebox2);
%             IFaces = insertShape(IFaces, 'rectangle', mouthbox2);
%             IFaces = insertShape(IFaces, 'rectangle', lefteyebox2);
%             IFaces = insertShape(IFaces, 'rectangle', righteyebox2);
%             figure(4), imshow(IFaces), title('Detected faces');
%         end
        if (detected)
            face_coord = [facebox;lefteyebox2;righteyebox2;nosebox2;mouthbox2];
        else
            face_coord = [];
        end
    else
        face_coord = [];
    end
end