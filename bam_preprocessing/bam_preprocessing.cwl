class: Workflow
cwlVersion: v1.0
id: align_sample
label: align_sample
inputs:
  - id: reference_sequence
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict
  - id: r1
    type: 'File[]'
  - id: r2
    type: 'File[]'
  - id: sample_id
    type: string
  - id: lane_id
    type: 'string[]'
  - id: known_sites
    type:
      type: array
      items: File
    secondaryFiles:
      - .idx
outputs:
  - id: output_md_bam
    outputSource:
      - align_sample/output_md_bam
    type: File
  - id: output_bam
    outputSource:
      - gatk_apply_bqsr/output
    type: File
steps:
  - id: align_sample
    in:
      - id: reference_sequence
        source:
          - reference_sequence
      - id: r1
        source:
          - r1
      - id: r2
        source:
          - r2 
      - id: sample_id
        source:
          - sample_id
      - id: lane_id
        source:
          - lane_id
    out:
      - id: output_md_bam
    run: align_sample/align_sample.cwl
  - id: base_recalibration
    in:
      - id: reference
      source:
        - reference_sequence
      - id: bam
      source:
        - align_sample/output_md_bam
      - id: known_sites
      source:
        - known_sites
    out:
      - id: output_bam
requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
