set -x

mkdir -p $DATA/logs
mkdir -p $DATA/stat

export OBSDIR=OBS
export modnam=rap
export fcstmax=51

export model1=`echo $MODELNAME | tr a-z A-Z`
echo $model1

export outtyp=awp130pgrb

export VIIRSDIR=$DATA/VIIRS_AOD_RAP_REGRID
sh $USHevs/${COMPONENT}/evs_rap_getviirs.sh

run_metplus.py $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/GridStat_fcstRAP_obsVIIRS.conf $PARMevs/metplus_config/machine.conf

mkdir -p $COMOUTsmall
cp $DATA/grid_stat/$MODELNAME/* $COMOUTsmall

if [ $cyc = 23 ]
then
   mkdir -p $COMOUT/${MOD}.${PDYm3}
   run_metplus.py $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/StatAnalysis_fcstRAP_obsVIIRS_GatherByDay.conf $PARMevs/metplus_config/machine.conf
 fi


exit
