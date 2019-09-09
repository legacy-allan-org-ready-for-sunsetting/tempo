class: Workflow
cwlVersion: v1.0
id: bam_preprocessing
label: bam_preprocessing
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
  - id: fastp_html
    outputSource:
      - fastp/html_output
    type: File[]
  - id: fastp_json
    outputSource:
      - fastp/json_output
    type: File[]
  - id: output_md_bam
    outputSource:
      - align_sample/output_md_bam
    type: File
  - id: output_bam
    outputSource:
      - base_recalibration/output_bam
    type: File
steps:
  - id: fastp
    in:
      - id: in1
        source:
          - r1
      - id: in2
        source:
          - r2
      - id: lane_id
        source:
          - lane_id
      - id: sample_id
        source:
          - sample_id
      - id: output_prefix
        valueFrom: $(inputs.sample_id + "_" + inputs.lane_id)
      - id: html
        valueFrom: $(inputs.output_prefix + ".html")
      - id: json
        valueFrom: $(inputs.output_prefix + ".json")
    out:
      - id: html_output
      - id: json_output
    scatter:
      - in1
      - in2
      - lane_id
    scatterMethod: dotproduct
    run: qc/command_line_tools/fastp_0.19.7/fastp.cwl
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
      - id: reference_sequence
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
    run: base_recalibration/base_recalibrate.cwl
requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
