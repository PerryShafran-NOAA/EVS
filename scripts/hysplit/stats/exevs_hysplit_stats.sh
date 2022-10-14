set -x

mkdir -p $DATA/logs
mkdir -p $DATA/stat

export OBSDIR=OBS
export fcstmax=48

export model1=`echo $MODELNAME | tr a-z A-Z`
echo $model1

run_metplus.py $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/GridStat_fcstHYSPLIT_obsMYDUST.conf $PARMevs/metplus_config/machine.conf

mkdir -p $COMOUTsmall
cp $DATA/grid_stat/$MODELNAME/* $COMOUTsmall

if [ $cyc = 23 ]
then
   mkdir -p $COMOUTfinal
   run_metplus.py $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/StatAnalysis_fcstHYSPLIT_obsMYDUST_GatherByDay.conf $PARMevs/metplus_config/machine.conf
fi


exit
