function [pred_bv pred_sp] = make_python_regress(biov_data,slope_data,Features,varargin);
%%%
 % The purpose of this script is to take the matlab output of my proceesed variables and use the python SKlearn machine learning algorithm to make reconstructions. 
 A.scale = 0;
 A.pred = 0;
 A = parse_pv_pairs(A,varargin);

 pyenv
 py.importlib.import_module('sklearn');
 MDL = py.sklearn.ensemble.RandomForestRegressor(pyargs('random_state',int32(0),'oob_score',py.bool('True')));
 depthbnds=ncread('/data/project3/data/woa18/nitrate/1p0/woa18_all_n00_01.nc','depth_bnds');
 depth = nanmean(depthbnds',2);

 oxy = {'o2','aou'};
 nut = {'no3','po4'};
 chl = {'chl_gc','chl_md'};
 npp = {'vgpm','cbpm','cafe','epp'};
 mld = {'mld_dbm','mld_mm'};
 irn = {'LFE','SFE'};
 zeu = {'zeu_cbpm','zeu_vgpm','zeu_epp'};
 load WOA_grid;

  top.path = 'etopo2.nc';
  top.lon = ncread(top.path,'x');
  top.lat = ncread(top.path,'y');
  top.var = 'topo';
  top.val = ncread(top.path,top.var);
  tmptopo = smooth2a_cyclic(top.val,16);
  topo = inpaint_nans_bc(interp2_cyclic(top.lon,top.lat,tmptopo,wcoord.LON,wcoord.LAT,'cubic')',4)';
  topo = repmat(topo,1,1,12)*-1; % make positive
  topo(topo<0)=0; % Remove "negative" elevation
  top_lon = -179.5:179.5;
  tmp = find(top_lon<25);
  for ind = 1:12
  topo(:,:,ind) = cat(1,topo(max(tmp)+1:end,:,ind),...
                      topo(1:max(tmp),:,ind));
  end
  topo(topo>5500) = 5500;
  top_mask = topo;
  tp_msk = nan(360,180,102,12);

for ind = 1:360
for idd = 1:180
for idm = 1:12
  tpp = findin(top_mask(ind,idd,idm),depth);
  tp_msk(ind,idd,1:tpp,idm) = 1;
end
end
end

% top_mask = tp_msk;
%keyboard
 for ind = 1:50

 tmp_oxy = (oxy{randperm(2,1)});
 tmp_nut = (nut{randperm(2,1)});
 tmp_chl = (chl{randperm(2,1)});
 tmp_npp = (npp{randperm(2,1)});
 tmp_mld = (mld{randperm(2,1)});
 tmp_irn = (irn{randperm(2,1)});
 tmp_zeu = (zeu{randperm(2,1)});

 preds= [Features.temp(:),Features.salt(:),Features.ddepth(:)...
        ,Features.si(:), Features.shwv(:),Features.temp_ddt(:)...
        ,Features.temp_ddd(:), Features.salt_ddd(:),...
        Features.salt_ddt(:),Features.si_ddt(:),...
        Features.si_ddd(:), Features.ddepth_ddd(:),...
        Features.shwv_ddt(:), Features.(tmp_oxy)(:),...
        Features.([tmp_oxy,'_ddd'])(:),...
        Features.([tmp_oxy,'_ddt'])(:), Features.(tmp_nut)(:),...
        Features.([tmp_nut,'_ddd'])(:),...
        Features.([tmp_nut,'_ddt'])(:),Features.(tmp_chl)(:),...
        Features.([tmp_chl,'_ddt'])(:),...
        Features.(tmp_npp)(:), Features.([tmp_npp,'_ddt'])(:),...
        Features.(tmp_mld)(:), Features.([tmp_mld,'_ddt'])(:),...
        Features.(tmp_irn)(:), Features.([tmp_irn,'_ddt'])(:),...
        Features.(tmp_zeu)(:), Features.([tmp_zeu,'_ddt'])(:)];

 x = preds;
 X = preds;
 y = [biov_data(:), slope_data(:)];
  
 idrem = unique([find(isnan(mean(y,2))); find(isnan(mean(x,2)))]);
 x(idrem,:) = [];
 y(idrem,:) = [];

 MD = MDL.fit(x,y);

 yhat = MDL.predict(x);
 yhat = double(yhat);
 y_oob = double(MD.oob_prediction_);

 pred_bv(ind).oobPred_bv = y_oob(:,1); % OOB
 pred_bv(ind).inBagPred_bv = yhat(:,1); % In bag
 pred_bv(ind).keep_data_bv = y(:,1);
 pred_bv(ind).oobStats = r2rmse(y_oob(:,1),y(:,1));
 pred_bv(ind).inBagStats = r2rmse(yhat(:,1),y(:,1));

 pred_sp(ind).oobPred = y_oob(:,2); % OOB
 pred_sp(ind).inBagPred = yhat(:,2); % In bag
 pred_sp(ind).keep_data = y(:,2);
 pred_sp(ind).oobStats = r2rmse(y_oob(:,2),y(:,2));
 pred_sp(ind).inBagStats = r2rmse(yhat(:,2),y(:,2));

 mask = mean(X,2);
 mask(~isnan(mask)) = 1;
 mask(isnan(mask)) = 0;
 
 X(isnan(X)) = 0;
 y_recon = double(MDL.predict(X));
 y_recon = y_recon.*mask;
 pred_bv(ind).recon = reshape(y_recon(:,1),360,180,102,12);  
 pred_sp(ind).recon = reshape(y_recon(:,2),360,180,102,12);
 pred_bv(ind).recon = pred_bv(ind).recon.*tp_msk;
 pred_sp(ind).recon = pred_sp(ind).recon.*tp_msk;
 end
