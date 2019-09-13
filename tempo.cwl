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
steps:
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
