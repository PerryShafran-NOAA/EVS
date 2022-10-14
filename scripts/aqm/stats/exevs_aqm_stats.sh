set -x

mkdir -p $DATA/logs
mkdir -p $DATA/stat

export OBSDIR=OBS
export modnam=cs
export fcstmax=72

export model1=`echo $MODELNAME | tr a-z A-Z`
echo $model1

export outtyp=aot

### METplus vs VIIRS

export VIIRSDIR=$DATA/VIIRS_AOD_CMAQ_REGRID
sh $USHevs/${MODELNAME}/evs_aqm_getviirs.sh

run_metplus.py $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/GridStat_fcstAQM_obsVIIRS.conf $PARMevs/metplus_config/machine.conf

#mkdir -p $COMOUTsmall
#cp $DATA/grid_stat/$MODELNAME/* $COMOUTsmall

### METplus vs GOES

export GOESDIR=$DATA/GOES_AOD_CMAQ_REGRID
sh $USHevs/${MODELNAME}/evs_aqm_getgoes.sh

run_metplus.py $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/GridStat_fcstAQM_obsGOES.conf $PARMevs/metplus_config/machine.conf

mkdir -p $COMOUTsmall
cp $DATA/grid_stat/$MODELNAME/* $COMOUTsmall

if [ $cyc = 23 ]
then
   mkdir -p $COMOUTfinal
   run_metplus.py $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/StatAnalysis_fcstAQM_obs_VIIRS_GatherByDay.conf $PARMevs/metplus_config/machine.conf
   run_metplus.py $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/StatAnalysis_fcstAQM_obs_GOES_GatherByDay.conf $PARMevs/metplus_config/machine.conf
fi 

exit

