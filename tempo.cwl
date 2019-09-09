class: Workflow
cwlVersion: v1.0
id: tempo
label: tempo
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
  - id: output_bam
    outputSource:
      - bam_preprocessing/output_bam
    type: File
steps:
  - id: bam_preprocessing
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
      - id: known_sites
        source:
          - known_sites
    out:
      - id: output_bam
    run: bam_preprocessing/bam_preprocessing.cwl
requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
