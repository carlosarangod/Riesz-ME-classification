function total_dir = Img_from_database(database,subject,subset,varargin)
    if (nargin == 3) && (strcmp(database,'SMIC_High')||strcmp(database,'SMIC_RGB'))
        error('SMIC database requires to specify an emotion. Either "po" for positive, "ne" for negative or "sur" for surprised.');
    elseif (nargin == 3) && (strcmp(database,'SAMM')&&(abs(length(subset)-2)>0))
        error('SAMM database requires to specify a subset as a 2 element vector.');
    elseif nargin ==4 && (strcmp(database,'CASME2')||strcmp(database,'CK+'))
        error('Too many inputs for this specific database')
    elseif nargin < 3 
        error('Not enough inputs')
    elseif nargin > 4
        error('Too many inputs')
    end
    if strcmp(database,'SMIC_High')
        data_dir = 'C:\Databases\Emotions\SMIC-E_raw image';
        data_type = 'HS_long\SMIC-HS-E';
        emotion = varargin{1};
        total_dir = read_SMIC_imgs(data_dir,data_type,subject,emotion,subset);
    elseif strcmp(database,'SMIC_RGB')      
        data_dir = 'C:\Databases\Emotions\SMIC-E_raw image';
        data_type = 'VIS_long\SMIC_VIS_E\SMIC_VIS_E\VIS';
        emotion = varargin{1};
        total_dir = read_SMIC_imgs(data_dir,data_type,subject,emotion,subset);
    elseif strcmp(database,'CASME2')
        data_dir = 'C:\Databases\Emotions\CASME2_RAW\CASME2-RAW';
        total_dir = read_CASME_imgs(data_dir,subject,subset);
    elseif strcmp(database,'CAS(ME)2')
        data_dir = getenv('CAS(ME)2');
        total_dir = read_CASME_square_imgs(data_dir,subject,subset);
    elseif strcmp(database,'CAS(ME)2_Oppos')
        data_dir = getenv('CAS(ME)2');
        total_dir = read_CASME_square_Oppos_imgs(data_dir,subject,subset);
    elseif strcmp(database,'CK+')
%         data_dir = 'C:\Users\CarlosAndres.Carlos\Documents\PhD\Databases\Emotions\CK+\extended-cohn-kanade-images\cohn-kanade-images';
        data_dir = strcat(getenv('CK+'),'\extended-cohn-kanade-images\cohn-kanade-images');
        total_dir = read_CohnKanade_imgs(data_dir,subject,subset);
    elseif strcmp(database,'SAMM')
%         data_dir = 'C:\Users\CarlosAndres.Carlos\Documents\PhD\Databases\Emotions\CK+\extended-cohn-kanade-images\cohn-kanade-images';
        data_dir = strcat(getenv('SAMM'),'\SAMM');
        total_dir = read_SAMM_imgs(data_dir,subject,subset);
    else
        error('Wrong Database');
    end
end
