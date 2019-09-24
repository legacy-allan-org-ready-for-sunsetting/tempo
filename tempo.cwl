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

outputs:
  tumor_bam:
    type: File
    outputSource: make_bams/tumor_bam
    secondaryFiles:
      - ^.bai
  normal_bam:
    type: File
    outputSource: make_bams/normal_bam
    secondaryFiles:
      - ^.bai

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

  bam_qc_alfred_rg:
    type: File[]?
    outputSource: run_alfred/bam_qc_alfred_rg

  bam_qc_alfred_ignore_rg:
    type: File[]?
    outputSource: run_alfred/bam_qc_alfred_ignore_rg

  bam_qc_alfred_rg_pdf:
    type: File[]?
    outputSource: run_alfred/bam_qc_alfred_rg_pdf

  bam_qc_alfred_ignore_rg_pdf:
    type: File[]?
    outputSource: run_alfred/bam_qc_alfred_ignore_rg_pdf

  facets_png:
    type: File[]?
    outputSource: run_somatic/facets_png

  facets_txt_purity:
    type: File?
    outputSource: run_somatic/facets_txt_purity

  facets_txt_hisens:
    type: File?
    outputSource: run_somatic/facets_txt_hisens

  facets_out_files:
    type: File[]?
    outputSource: run_somatic/facets_out_files

  facets_rdata:
    type: File[]?
    outputSource: run_somatic/facets_rdata

  facets_seg:
    type: File[]?
    outputSource: run_somatic/facets_seg

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

  run_alfred:
    in:
      bam:
        source: [ make_bams/tumor_bam, make_bams/normal_bam ]
        linkMerge: merge_flattened
      bed: target_bed
      reference_sequence: reference_sequence
    out: [ bam_qc_alfred_rg, bam_qc_alfred_ignore_rg, bam_qc_alfred_rg_pdf, bam_qc_alfred_ignore_rg_pdf ]
    run: qc_bams/run_alfred.cwl
    scatter: [ bam ]
    scatterMethod: dotproduct

  run_somatic:
    in:
      tumor_bam: make_bams/tumor_bam
      normal_bam: make_bams/normal_bam
      facets_vcf: facets_vcf
      tumor_sample: tumor_sample
      tumor_id: 
        valueFrom: $(inputs.tumor_sample.ID)
      facets_params: facets_params
    out: [ facets_out_files, facets_png, facets_rdata, facets_seg, facets_txt_hisens, facets_txt_purity ]
    run: tempo_somatic/run_somatic.cwl 

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
