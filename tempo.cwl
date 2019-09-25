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

  target_bed:
    type: File?
    secondaryFiles:
      - .tbi

  facets_vcf:
    type: File
    secondaryFiles:
      - .gz

  facets_params:
    type:
      type: record
      fields:
        pseudo_snps: int
        count_orphans: boolean
        gzip: boolean
        ignore_overlaps: boolean
        max_depth: int
        min_base_quality: int
        min_read_counts: int
        min_map_quality: int
        cval: int
        snp_nbhd: int
        ndepth: int
        min_nhet: int
        purity_cval: int
        purity_snp_nbhd: int
        purity_ndepth: int
        purity_min_nhet: int
        genome: string
        directory: string
        R_lib: string
        single_chrom: string
        ggplot2: string
        seed: int

  targets_list:
    type: File?

  baits_list:
    type: File?

outputs:
  dir_bams:
    type: Directory
    outputSource: run_make_bams_and_qc/dir_bams

  dir_qc:
    type: Directory
    outputSource: run_make_bams_and_qc/dir_qc

  dir_somatic:
    type: Directory
    outputSource: run_somatic/dir_somatic

steps:
  # combines R1s and R2s from both tumor and normal samples
  run_make_bams_and_qc:
    in:
      reference_sequence: reference_sequence
      tumor_sample: tumor_sample
      normal_sample: normal_sample
      known_sites: known_sites
      target_bed: target_bed
      targets_list: targets_list
      baits_list: baits_list
    out: [ tumor_bam, normal_bam, dir_qc, dir_bams ]
    run: tempo_make_bam_and_qc/make_bam_and_qc.cwl

  run_somatic:
    in:
      tumor_bam: run_make_bams_and_qc/tumor_bam
      normal_bam: run_make_bams_and_qc/normal_bam
      facets_vcf: facets_vcf
      tumor_sample: tumor_sample
      tumor_id: 
        valueFrom: $(inputs.tumor_sample.ID)
      facets_params: facets_params
    out: [ dir_somatic ]
    run: tempo_somatic/run_somatic.cwl 

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
