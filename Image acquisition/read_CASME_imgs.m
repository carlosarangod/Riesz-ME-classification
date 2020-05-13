function total_dir = read_CASME_imgs(data_dir,subject,subset)
    gap1='';
    if strcmp(data_dir(end),'/')== 0 || strcmp(data_dir(end),'\')== 0 
        gap1='\'; 
    end
    total_dir = strcat(data_dir,gap1);
    folder_list = dir(data_dir);
    fold_le = length(folder_list);
    fold_count=1;
    subject_list=zeros(1,fold_le-2);
    for k = 3:fold_le
        if folder_list(k).isdir == 1
            subject_list(fold_count) = str2double(folder_list(k).name(4:end));
            fold_count = fold_count+1;
        end
    end
    subject_found = find(subject_list == subject,1);
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
        subject_dir = strcat('sub',sprintf('%02d',subject),'\');
        total_dir = strcat(total_dir,subject_dir);
        subfolder_list = dir(total_dir);
        subfold_le = length(subfolder_list);
        subfold_count=1;
        for k = 3:subfold_le
            if subfolder_list(k).isdir == 1
                subsetcode_list{subfold_count} = subfolder_list(k).name;
                subfold_count = subfold_count+1;
            end
        end
        if subset>(subfold_count-1)
            choice = questdlg('The requested subject is not valid for this specific database. Would you like to see a list of the available subjects?',...
                'Subject not available','No','Yes','Yes');
            switch choice
                case 'Yes'
                    disp('The available subsets are: ')
                    disp (1:subfold_count-1);
                    disp ('Their Codes are: ')
                    disp(subsetcode_list);
                case 'No'
            end
            total_dir=[];
        else
            total_dir = strcat(total_dir,subsetcode_list{subset});
        end
    end
end
