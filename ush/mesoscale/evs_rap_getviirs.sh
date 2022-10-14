set -x

echo $VIIRSDIR
mkdir -p $VIIRSDIR

run_metplus.py -c $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/RegridDataPlane_fcstRAP_obsVIIRS_gridRAP.conf $PARMevs/metplus_config/machine.conf

exit


