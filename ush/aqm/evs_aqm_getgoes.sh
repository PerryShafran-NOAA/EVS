set -x

echo $GOESDIR
mkdir -p $GOESDIR

export OBSVDIR=/lfs/h2/emc/physics/noscrub/ho-chun.huang/GOES16_AOD/AOD/${VDATE}
export jday=`date2jday.sh $VDATE`
export REF_FILE=${COMINaqm}/cs.${VDATE}/aqm.t00z.aot.f01.148.grib2

oh=`printf %2.2d ${cyc}`
ls ${OBSVDIR}/OR_ABI-L2-AODC-M*_G16_s${jday}${oh}*.nc > aa1
aod_file=`head -n1 aa1`
element_1=$( echo ${aod_file} | awk -F"_" '{print $1}')
element_2=$( echo ${aod_file} | awk -F"_" '{print $2}')
element_3=$( echo ${aod_file} | awk -F"_" '{print $3}')
element_4=$( echo ${aod_file} | awk -F"_" '{print $4}')
element_5=$( echo ${aod_file} | awk -F"_" '{print $5}')
export infile=`head -n1 aa1`

run_metplus.py -c $PARMevs/metplus_config/${COMPONENT}/${VERIF_CASE}/stats/Point2grid_fcstAQM_obsGOES.conf $PARMevs/metplus_config/machine.conf

exit
