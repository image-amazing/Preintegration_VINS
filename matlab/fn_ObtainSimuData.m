function [imuData_cell, uvd_cell, noisefree_imuData_cell, noisefree_uvd_cell, Ru_cell, Tu_cell, FeatureObs, inertialDelta, vu, SLAM_Params] = ...
                    fn_ObtainSimuData(  SLAM_Params, nPoses, nPts, nIMUrate, inertialDelta )

    global PreIntegration_options Data_config

    %% Use previous observation data or not
    if(PreIntegration_options.bUsePriorZ == 0)   
    
        SLAM_Params.bf0 = [1.0, 2.0, 3.0]'; % bias for acceleration
        SLAM_Params.bw0 = [1.0, 2.0, 3.0]'; %[0, 0, 0]'; % bias for rotaion velocity    
        arPts = [0,0,0; 1,0.5,2;0.5,2,2.6;1.8,2.4,3.5];
        
        [imuData_cell, uvd_cell, noisefree_imuData_cell, noisefree_uvd_cell, Ru_cell, Tu_cell, FeatureObs, vu, SLAM_Params] = ...
                                    fn_GeneratePoseFeatData( nPoses, nPts, nIMUrate, SLAM_Params );

        save( [ Data_config.DATA_DIR, 'SimuData.mat' ], 'imuData_cell', 'uvd_cell', 'noisefree_imuData_cell', 'noisefree_uvd_cell', 'Ru_cell', 'Tu_cell', 'FeatureObs', 'vu', 'SLAM_Params' );
        
    else
        
        load( [ Data_config.DATA_DIR, 'SimuData.mat' ] );
        
    end    
    
    for pid=2:nPoses%1e-2,1e-3+3*sigmaf+3*sigmaw
        [ inertialDelta.dp(:,pid), inertialDelta.dv(:,pid), inertialDelta.dphi(:,pid), inertialDelta.Jd{pid}, inertialDelta.Rd{pid} ] = ...
                            fn_DeltObsAccu( SLAM_Params.bf0, SLAM_Params.bw0, ...
                                    imuData_cell{pid}.samples, SLAM_Params.sigma_w_cov, SLAM_Params.sigma_f_cov ); 
    end 
            