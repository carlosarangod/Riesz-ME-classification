function total_dir = read_CASME_square_Oppos_imgs(data_dir,subject,video)
    gap1='';
    if strcmp(data_dir(end),'/')== 0 || strcmp(data_dir(end),'\')== 0 
        gap1='\'; 
    end
    total_dir = strcat(data_dir,'\rawpic',gap1);
    label_file = 'CAS(ME)^2code_final';
    file_name = strcat(data_dir,'\',label_file);
    [~,~,excel_table] = xlsread(file_name,3);
%     [~,~,excel_table] = xlsread(file_name,3);
    types_video = excel_table(:,1);
    folder_list = dir(total_dir);
    fold_le = length(folder_list);
    fold_count=1;
    subject_list=zeros(1,fold_le-2);
    for k = 3:fold_le
        if folder_list(k).isdir == 1
            subject_list(fold_count) = str2double(folder_list(k).name(2:end));
            fold_count = fold_count+1;
        end
    end
    subject_dir = strcat('s',sprintf('%02d',subject_list(subject)),'\');
    total_dir = strcat(total_dir,subject_dir);
    subfolder_list = dir(total_dir);
    subfold_le = length(subfolder_list);
    subfold_count=1;
    video_found = [];
    for k = 3:subfold_le
        if subfolder_list(k).isdir == 1
            subsetcode_list{subfold_count} = subfolder_list(k).name;
            video_code = subsetcode_list{subfold_count}(4:7);
            Video_list{subfold_count} = video_code;
%             Video_list(subfold_count) = find(strcmp(video,types_video));
            if strcmp(video_code,types_video(video))
               video_found = subfold_count;               
            end
            subfold_count = subfold_count + 1;
        end
    end
%     video_found =find(Video_list == video,1);
    if isempty(video_found)
        choice = questdlg('The selected video is not available for this subject. Would you like to see a list of the available subsets?',...
        'Subset not available','No','Yes','Yes');
        switch choice
            case 'Yes'
                disp('The available subsets are: ')
                disp(unique(Video_list))
            case 'No'
        end
        total_dir=[];
    else
        total_dir = strcat(total_dir,subsetcode_list{video_found});
    end
    
end