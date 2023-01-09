#!/usr/bin/env nextflow
nextflow.enable.dsl=2


process get_images {
  stageInMode 'symlink'
  stageOutMode 'move'

  script:
    """

    if [[ "${params.run_type}" == "r2d2" ]] || [[ "${params.run_type}" == "raven" ]] ; 

      then

        cd ${params.image_folder}

        if [[ ! -f flexbar-3.5.sif ]] ;
          then
            singularity pull flexbar-3.5.sif docker://index.docker.io/mpgagebioinformatics/flexbar:3.5
        fi

    fi


    if [[ "${params.run_type}" == "local" ]] ; 

      then

        docker pull mpgagebioinformatics/flexbar:3.5

    fi

    """

}



process flexbar {
  tag "${f}"
  stageInMode 'symlink'
  stageOutMode 'move'
  
  input:
    path f
  
  script:
    """
    mkdir -p /workdir/flexbar_output
    flexbar -r /raw_data/${f} -n ${task.cpus} -t /workdir/flexbar_output/${f} -q TAIL -qf i1.8
    """
}


workflow images {
  main:
    get_images()
}


workflow {
    data = channel.fromPath( "${params.flexbar_raw_data}/i*fastq.gz" )
    flexbar(data)
}