function total_dir = read_SMIC_imgs(data_dir,data_type,subject,emotion,subset)
    gap1='';
    gap2='';
    if strcmp(data_dir(end),'/')== 0 || strcmp(data_dir(end),'\')== 0 
        gap1='\'; 
    end
    if strcmp(data_type(end),'/')== 0 || strcmp(data_type(end),'\')== 0
        gap2='\';
    end
    total_dir = strcat(data_dir,gap1,data_type,gap2);
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
    subject_found =find(subject_list == subject,1);
    if isempty(subject_found)==1
        choice = questdlg('The requested subject is not valid for this specific database. Would you like to see a list of the available subjects?',...
            'Subject not available','No','Yes','Yes');
        switch choice
            case 'Yes'
                disp('The available subjects are: ')
                disp(subject_list);
            case 'No'
        end
        total_dir=[];
    else
        subject_dir = strcat('s',sprintf('%02d',subject));
        total_dir = strcat(total_dir,subject_dir);
%         disp (total_dir)
        subfolder_list = dir(total_dir);
        subfold_le = length(subfolder_list);
        check_list=zeros(3,20);
        for k = 3:subfold_le
            if subfolder_list(k).isdir == 1
               line_pos=strfind(subfolder_list(k).name,'_');
               check_number = str2double(subfolder_list(k).name(line_pos(2)+1:line_pos(2)+2));
               if strcmp(subfolder_list(k).name(line_pos(1)+1:line_pos(1)+2),'po')
                   check_emo = 1;
               elseif strcmp(subfolder_list(k).name(line_pos(1)+1:line_pos(1)+2),'ne')
                   check_emo = 2;
               elseif strcmp(subfolder_list(k).name(line_pos(1)+1:line_pos(1)+2),'su')
                   check_emo = 3;
               end
               check_list(check_emo,check_number) = 1;
            end
        end
        if strcmp(emotion,'po')
            emo_num = 1;
        elseif strcmp(emotion,'ne')
            emo_num = 2;
        elseif strcmp(emotion,'sur')
            emo_num = 3;
        end
        if check_list(emo_num,subset)==0
            choice = questdlg('The selected subset is not available for this subject. Would you like to see a list of the available subsets?',...
            'Subset not available','No','Yes','Yes');
            switch choice
                case 'Yes'
                    disp('The available subsets are: ')
                    subfolder_list(3:end).name
                case 'No'
            end
            total_dir=[];
        else
            subset_dir = strcat('\s',num2str(subject),'_',emotion,'_',sprintf('%02d',subset));
            total_dir = strcat(total_dir,subset_dir);
        end
    end
    
end