set -x

mkdir -p $DATA/logs
mkdir -p $DATA/stat

export OBSDIR=OBS
export modnam=hrrr
export fcstmax=48

export model1=`echo $MODELNAME | tr a-z A-Z`
echo $model1

export outtyp=wrfprs

export VIIRSDIR=$DATA/VIIRS_AOD_HRRR_REGRID
sh $USHevs/${COMPONENT}/evs_hrrr_getviirs.sh

run_metplus.py $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/GridStat_fcstHRRR_obsVIIRS.conf $PARMevs/metplus_config/machine.conf

mkdir -p $COMOUTsmall
cp $DATA/grid_stat/$MODELNAME/* $COMOUTsmall

if [ $cyc = 23 ]
then
   mkdir -p $COMOUTfinal
   run_metplus.py $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/StatAnalysis_fcstHRRR_obsVIIRS_GatherByDay.conf $PARMevs/metplus_config/machine.conf
 fi


exit
