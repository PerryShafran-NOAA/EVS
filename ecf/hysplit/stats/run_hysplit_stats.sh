#PBS -N run_hysplit
#PBS -j oe
#PBS -S /bin/bash
#PBS -q "dev"
#PBS -A VERF-DEV
#PBS -l walltime=02:00:00
#PBS -l select=1:ncpus=1:mem=2GB
#PBS -l debug=true

set -x

for fhr in 16 17 18 19 20 21 22 23
do
   export fhr
   qsub -v cyc=$fhr /lfs/h2/emc/vpppg/save/perry.shafran/EVS7/ecf/hysplit/stats/jevs_hysplit_stats.ecf
   sleep 60
done

exit
