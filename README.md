# TEMPO

Set of CWLs used by TEMPO (currently in development).

What's in:
- Generates base-recalibrated BAMs for tumor and normal samples
- Creates FastQ QC (with FastP, `gatk CollectHsMetrics`) and BAM QC (with Alfred) files
- Runs two pieces of the somatic variant pipeline, `facets` and `msisensor`.
