class: Workflow
cwlVersion: v1.0
id: tempo
label: tempo
inputs:
  reference_sequence:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict

  tumor_sample:
    type:
      type: record
      fields:
        ID: string
        CN: string
        LB: string
        PL: string
        PU: string[]
        R1: File[]
        R2: File[]
        RG_ID: string[]
        adapter: string
        adapter2: string
        bwa_output: string

  normal_sample:
    type: 
      type: record
      fields:
        ID: string
        CN: string
        LB: string
        PL: string
        PU: string[]
        R1: File[]
        R2: File[]
        RG_ID: string[]
        adapter: string
        adapter2: string
        bwa_output: string

  known_sites:
    type:
      type: array
      items: File
    secondaryFiles:
      - .idx

outputs:
  tumor_bam:
    type: File
    outputSource: make_bams/tumor_bam
  normal_bam:
    type: File
    outputSource: make_bams/normal_bam

  fastp_html:
    type: File[]
    outputSource: run_qc_fastqs/fastp_html
  fastp_json:
    type: File[]
    outputSource: run_qc_fastqs/fastp_json

#  fastp_html:
#    type: Directory
#    outputSource: qc_output/fastp_dir_html
#  fastp_json:
#    type: Directory
#    outputSource: qc_output/fastp_dir_json

steps:
  # combines R1s and R2s from both tumor and normal samples
  run_qc_fastqs:
    in:
      tumor_sample: tumor_sample
      normal_sample: normal_sample
      r1:
        valueFrom: ${ var data = []; data = inputs.tumor_sample.R1.concat(inputs.normal_sample.R1); return data }
      r2:
        valueFrom: ${ var data = []; data = inputs.tumor_sample.R2.concat(inputs.normal_sample.R2); return data }
      output_prefix:
        valueFrom: ${ var data = []; data = inputs.tumor_sample.RG_ID.concat(inputs.normal_sample.RG_ID); return data }
    out: [ fastp_html, fastp_json ]
    run: qc_fastqs/scatter_fastqs_for_qc.cwl
  
  make_bams:
    in:
      tumor_sample: tumor_sample
      normal_sample: normal_sample
      reference_sequence: reference_sequence
      known_sites: known_sites
    out: [ tumor_bam, normal_bam ]
    run: preprocess_tumor_normal_bam/preprocess_tumor_normal_pair.cwl

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
