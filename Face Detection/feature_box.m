function final_box = feature_box(init_box,face_roi,feature_roi)
    [a,~]=size(init_box);
    index = 1;
    if a>1
        max_area = 0;
        for i=1:a
            act_area = init_box(i,3)*init_box(i,4);
            if act_area > max_area
                max_area=act_area;
                index = i;
            end
        end
    end
    final_box(1) = init_box(index,1)+face_roi(1)+feature_roi(1);
    final_box(2) = init_box(index,2)+face_roi(2)+feature_roi(2);
    final_box(3:4) = init_box(index,3:4);
end