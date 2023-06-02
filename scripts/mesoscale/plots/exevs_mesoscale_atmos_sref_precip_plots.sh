#!/bin/ksh

set -x 

cd $DATA

export prune_dir=$DATA/data
export save_dir=$DATA/out
export output_base_dir=$DATA/stat_archive
export log_metplus=$DATA/logs/GENS_verif_plotting_job.out
mkdir -p $prune_dir
mkdir -p $save_dir
mkdir -p $output_base_dir
mkdir -p $DATA/logs


export eval_period='TEST'

export interp_pnts=''

export init_end=$VDATE
export valid_end=$VDATE

model_list='GEFS SREF'
          
models='GEFS, SREF'

n=0
while [ $n -le $past_days ] ; do
    hrs=$((n*24))
    first_day=`$NDATE -$hrs ${VDATE}00|cut -c1-8`
    n=$((n+1))
done

export init_beg=$first_day
export valid_beg=$first_day

n=0
while [ $n -le $past_days ] ; do
  #hrs=`expr $n \* 24`
  hrs=$((n*24))
  day=`$NDATE -$hrs ${VDATE}00|cut -c1-8`
  echo $day
  $USHevs/mesoscale/evs_get_sref_stat_file_link_plots.sh $day "$model_list"
  n=$((n+1))
done 


VX_MASK_LIST="CONUS"
																  
export fcst_init_hour="0,3,6,9,12,15,18,21"
export fcst_valid_hour="0,3,6,9,12,15,18,21"
valid_time='valid00z_03z_06z_09z_12z_15z_18z_21z'
init_time='init00_to_21z'

export plot_dir=$DATA/out/precip/${valid_beg}-${valid_end}


verif_case=precip
verif_type=ccpa 

> run_all_poe.sh

VARs=APCP_06
FCST_LEVEL_values=A6

for stats in  ets fbias fss ; do 
 if [ $stats = ets ] ; then
  stat_list='ets'
  line_tp='ctc'
  score_types='lead_average threshold_average'
  export interp_pnts=''
 elif [ $stats = fbias ] ; then
  stat_list='fbias'
  line_tp='ctc'
  score_types='lead_average threshold_average'
  export interp_pnts=''
elif [ $stats = fss ] ; then
  stat_list='fss'
  score_types='lead_average'
  line_tp='nbrcnt'
  interp_pnts='1,9,25,49,91,121'
 else
  echo $stats is wrong stat
  exit
 fi   

 for score_type in $score_types ; do

  if [ $score_type = lead_average ] ; then
    if [ $stats = ets ] || [ $stats = fbias ] ; then
	threshes='>=0.1 >=1 >=5 >=10 >=25 >=50'
    elif [ $stats = fss ] ; then
	threshes='>=0.1,>=1,>=5,>=10,>=25,>=50'
    fi
  elif [ $score_type = threshold_average ] ; then
	threshes='>=0.1,>=1,>=5,>=10,>=25,>=50'
  fi

  export fcst_leads="vs_lead" 
 
  for lead in $fcst_leads ; do 

    export fcst_lead=" 24, 36, 48, 60, 72, 84"

    for VAR in $VARs ; do 

       var=`echo $VAR | tr '[A-Z]' '[a-z]'` 
	    
     for FCST_LEVEL_value in $FCST_LEVEL_values ; do 

	OBS_LEVEL_value=$FCST_LEVEL_value

        level=`echo $FCST_LEVEL_value | tr '[A-Z]' '[a-z]'`      

      for line_type in $line_tp ; do 

       for thr in $threshes ; do

	if [ $thr = '>=0.1' ] ; then
	  thresh=0.1
        elif [ $thr = '>=1' ] ; then
          thresh=1
        elif [ $thr = '>=5' ] ; then
	  thresh=5
        elif [ $thr = '>=10' ] ; then
          thresh=10
        elif [ $thr = '>=25' ] ; then
          thresh=25
        elif [ $thr = '>=50' ] ; then
          thresh=50
        elif [ $thr = '>=0.1,>=1,>=5,>=10,>=25,>=50' ] ; then
          thresh=all
	fi

         thresh_fcst=$thr
         thresh_obs=$thresh_fcst

         > run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh  

        echo "export PLOT_TYPE=$score_type" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
        echo "export field=${var}_${level}" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh

        echo "export vx_mask_list='$VX_MASK_LIST'" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
        echo "export verif_case=$verif_case" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
        echo "export verif_type=$verif_type" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh

        echo "export log_level=DEBUG" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
        echo "export met_ver=$met_v" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh

        echo "export eval_period=TEST" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh


        if [ $score_type = valid_hour_average ] ; then
          echo "export date_type=INIT" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
        else
          echo "export date_type=VALID" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
        fi


         echo "export var_name=$VAR" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
         echo "export fcts_level=$FCST_LEVEL_value" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
         echo "export obs_level=$OBS_LEVEL_value" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh

         echo "export line_type=$line_type" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
         if [ $stats = fss ] ; then
	   echo "export interp=NBRHD_SQUARE" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
	 else
	   echo "export interp=NEAREST" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh
	 fi 

         echo "export score_py=$score_type" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh


         sed -e "s!model_list!$models!g" -e "s!stat_list!$stat_list!g"  -e "s!thresh_fcst!$thresh_fcst!g"  -e "s!thresh_obs!$thresh_obs!g"   -e "s!fcst_init_hour!$fcst_init_hour!g" -e "s!fcst_valid_hour!$fcst_valid_hour!g" -e "s!fcst_lead!$fcst_lead!g"  -e "s!interp_pnts!$interp_pnts!g" $USHevs/mesoscale/evs_sref_plots_config.sh > run_py.${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh

         chmod +x  run_py.${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh

         echo "run_py.${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh" >> run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh

         chmod +x  run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh 
         echo " run_${stats}.${score_type}.${lead}.${VAR}.${FCST_LEVEL_value}.${line_type}.${thresh}.sh" >> run_all_poe.sh


       done #end of thresh

      done #end of line_type

     done #end of FCST_LEVEL_value

    done #end of VAR

  done #end of fcst_lead

 done #end of score_type

done #end of stats 

chmod +x run_all_poe.sh


if [ $run_mpi = yes ] ; then
  export LD_LIBRARY_PATH=/apps/dev/pmi-fix:$LD_LIBRARY_PATH
   mpiexec -np 54 -ppn 15 --cpu-bind verbose,depth cfp run_all_poe.sh
else
  run_all_poe.sh
fi

cd $plot_dir

for stats in  ets fbias fss  ; do
 if [ $stats = ets ] || [ $stats = fbias ] ; then 
   score_types='lead_average threshold_average'
 else
   score_types='lead_average'
 fi   
 for score_type in $score_types ; do

  if [ $score_type = lead_average ] ; then 
    if [ $stats = ets ] || [ $stats = fbias ] ; then
      threshes='ge0.1 ge1 ge5 ge10 ge25 ge50'
      scoretype='fhrmean'
    elif [ $stats = fss ] ; then
      threshes='width1-3-5-7-9-11'
      scoretype='fhrmean'
    fi
  elif [ $score_type = threshold_average ] ; then
      threshes='f24-36-48-60-72-84'
      scoretype='threshholdmean'
  fi

  var='apcp_06'
  level='6h'
  new_level='a06'

  for thresh in $threshes ; do

    if [ $score_type = lead_average ] ; then
      if [ $stats = ets ] || [ $stats = fbias ] ; then
         mv ${score_type}_regional_conus_valid_00z_03z_06z_09z_12z_15z_18z_21z_6h_apcp_06_${stats}_${thresh}.png evs.sref.${stats}.apcp_6a.${thresh}.last${past_days}days.${scoretype}.valid00z_03z_06z_09z_12z_15z_18z_21z.buk_conus.png
      elif [ $stats = fss ] ; then
         mv ${score_type}_regional_conus_valid_00z_03z_06z_09z_12z_15z_18z_21z_6h_apcp_06_${stats}_${thresh}.png evs.sref.${stats}.apcp_6a.last${past_days}days.${scoretype}.valid00z_03z_06z_09z_12z_15z_18z_21z.buk_conus.png	    
      fi
    elif [ $score_type = threshold_average ] ; then
         mv ${score_type}_regional_conus_valid_00z_03z_06z_09z_12z_15z_18z_21z_6h_apcp_06_${stats}_${thresh}.png evs.sref.${stats}.apcp_6a.last${past_days}days.${scoretype}.valid00z_03z_06z_09z_12z_15z_18z_21z.buk_conus.png
    fi	 

  done   # thresh
 done    #score_type
done     #stats


tar -cvf evs.plots.sref.precip.${past_days}.v${VDATE}.tar *.png

cp evs.plots.sref.precip.${past_days}.v${VDATE}.tar  $COMOUT/.  









