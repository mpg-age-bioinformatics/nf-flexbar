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
        if [[ ! -f fastqc-0.11.9.sif ]] ;
          then
            singularity pull fastqc-0.11.9.sif docker://index.docker.io/mpgagebioinformatics/fastqc:0.11.9
        fi

    fi


    if [[ "${params.run_type}" == "local" ]] ; 
      then
        docker pull mpgagebioinformatics/flexbar:3.5
        docker pull mpgagebioinformatics/fastqc:0.11.9
        
    fi

    """

}

process get_quality {
  stageInMode 'symlink'
  stageOutMode 'move'
  
  input:
    path f
  
  output:
    env fqformat 
  
  script:
  """

    TASK_DIR=\$(pwd)

    f=\$(readlink -f ${f})
    cd \$f
    qual_zip_file=\$(ls *.zip |head -n 1)
    if [[ ! -e "\${qual_zip_file%.zip}/fastq_qual.txt" ]] ; then
      unzip -o \$qual_zip_file
      cd \${qual_zip_file%.zip}
      fastq_qual=\$(grep 'Encoding' fastqc_data.txt)
      if [[ "\${fastq_qual}" == *"1.8"* ]] ; then
        echo i1.8 > fastq_qual.txt
      elif [[ "\${fastq_qual}" == *"1.5"* ]] ; then
        echo i1.5 > fastq_qual.txt
      elif [[ "\${fastq_qual}" == *"1.3"* ]] ; then
        echo i1.3 > fastq_qual.txt
      elif [[ "\${fastq_qual}" == *"Sanger"* ]] ; then
        echo sanger > fastq_qual.txt
      else 
        echo undefined > fastq_qual.txt
      fi
    fi
    
    cd \$f
    tempfolder=\${qual_zip_file%.zip}
    fqformat=\$(cat \${tempfolder}/fastq_qual.txt)

    if [[ "\${fqformat}" == "undefined" ]] ; then
      echo "ERROR unexpected flexbar_quality, please check \${qual_zip_file%.zip}/fastqc_data.txt for Encoding"
      exit
    fi

    cd \$TASK_DIR   #so that .command.env generated in the right folder

  """
}


process flexbar_trim {
  stageInMode 'symlink'
  stageOutMode 'move'

  input:
    tuple val(pair_id), path(fastq)
    val fqformat

  output:
    val pair_id

  when:
  //  ( ! file("${params.project_folder}/trimmed_raw/${pair_id}.fastq.gz").exists() )
    ( ( ! file("${params.project_folder}/trimmed_raw/${pair_id}.fastq.gz").exists()  ) & ( ! file("${params.project_folder}/trimmed_raw/${pair_id}_1.fastq.gz").exists() ) )
  
  script:
  def single = fastq instanceof Path

  if ( single ) {
    """
      mkdir -p /workdir/trimmed_raw
      flexbar  -n ${task.cpus} -ae 0.2 -ac ON  -r /raw_data/${pair_id}${params.read1_sufix} -t /workdir/trimmed_raw/${pair_id} -z GZ -q TAIL -qf "${fqformat[0]}" -qt 25 -u 5
    """
  } 
  else { 
    """
      mkdir -p /workdir/trimmed_raw
      flexbar  -n ${task.cpus} -ae 0.2 -ac ON  -r /raw_data/${pair_id}${params.read1_sufix} -p ${pair_id}${params.read2_sufix} -t /workdir/trimmed_raw/${pair_id} -z GZ -q TAIL -qf "${fqformat[0]}" -qt 25 -u 5
    """
  }
}


workflow images {
  main:
    get_images()
}


workflow {
  main:
    // Channel
    //   .fromFilePairs( "${params.kallisto_raw_data}*.READ_{1,2}.fastq.gz", size: -1 )
    //   .ifEmpty { error "Cannot find any reads matching: ${params.kallisto_raw_data}*.READ_{1,2}.fastq.gz" }
    //   .set { read_files }
    read_files=Channel.fromFilePairs( "${params.flexbar_raw_data}/*${params.read12_sufix}", size: -1 )
    // read_files.view()

    if ( 'fqformat' in params.keySet() ) {
      fqformat="${params.fqformat}"
      flexbar_trim( read_files, fqformat )
    } else {
      if ( 'fastqc_output' in params.keySet() ) {
        // copy the file from a non mounted location to a location that will be mount 
        // either in docker with -v or singularity with -B
        get_quality( "${params.fastqc_output}" )
        // get_quality.out.collect().view()
        flexbar_trim( read_files, get_quality.out.collect() )
      } else {
        printf("You need to either use the fqformat or the fastqc_output argument so that quality encoding can be detected." )
        // exit
      }
    }          
}