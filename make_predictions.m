%%%%%%%%%% 
% This script is designed to process data and make predictions using multiple different ML algorithms
% I also include plots which will visualize the performance of the different methods
%  addpath /data/project1/matlabpathfiles
%  addpath /data/project1/dclements/matlabfiles
%  addpath /data/project1/yangsi/MATLAB/functions
%  outpath='/data/project1/dclements/Particles/scripts/Flux_Estimates/Flux_3D/processed/';

%% To start - load in the data and the predictior matrix in a meaningful way, raw format, processed
  biov_data = get_data('var','biov_tot','shape',1);
  slope_data = get_data('var','slope','shape',1);

  biov_data = log10(biov_data(:,:,:,:)+0.01);
  maxBV = nanmean((biov_data(:))) + 5*(nanstd(biov_data(:)));
  biov_data(biov_data >maxBV) = nan;

  slope_data = abs(slope_data(:,:,:,:));

  outpath  = pwd;
  load([outpath,'/predictors_3D.mat'])

  names = fieldnames(pred_3d);
keyboard
  % Reduce the predition structure to only the data we are interested in
  for ind = 8:length(names)
  pred.(names{ind}) = (pred_3d.(names{ind})(:,:,:,:));
  end

%% Make predictions using the best model (RF)
   disp('making predicitons')
   clearvars -except biov_data slope_data pred
   [PredBV_reg PredSp_reg] = make_python_regress(biov_data,slope_data,pred); 
   save('Ensemble_BV_50.mat','PredBV_reg','-v7.3')
   save('Ensemble_SP_50.mat','PredSp_reg','-v7.3')
 
