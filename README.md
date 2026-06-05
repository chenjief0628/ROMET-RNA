# ROMET-RNA
# Overview

Here we present a new meta-predicted server, ROMET-RNA, to model the 3D structure of RNAs from the primary sequence. Firstly, the six individual predicted servers are installed locally. This will allow us to control and tune our meta-server algorithms in a consistent manner and enable users to obtain comprehensive predictions from all servers quickly. Then, in addition to the construction of the best possible 3D models, the ROMET-RNA server also presents a score for ranking RNA 3D structures generated from different individual algorithms. In comparison to other structure prediction software and methods, ROMET-RNA can generate more accurate models than both threading templates and the peer methods benchmarked.

# Installation
### Dependencies and environment challenges

Note that ROMET-RNA depends on and uses several external programs and libraries.  
Different tools require incompatible environments (specific CUDA / PyTorch / TensorFlow / compiler versions) and some need very large third‑party databases, which makes a single unified install impractical.

To address this we provide a **Docker image** that integrates all locally runnable tools, each in its own conda environment. The Dockerfile and usage instructions are available in the [`Docker/`](./Docker) folder.

### Tool access modes

Table classifies every tool by access mode:

| Access mode | Tools |
|-------------|-------|
| **Locally installable** (conda / Docker) | DeepFoldRNA, RoseTTAFoldNA, trRosettaRNA, RhoFold, DRfold, DRfold2, SimRNA, Boltz, Protenix (prediction); lociPARSE (scoring); RNAalign (scoring). All are bundled in our Docker image with isolated per‑tool conda environments. |
| **External databases** (downloaded separately) | UniRef30, BFD, PDB templates, Rfam, RNAcentral – not redistributable; the user must download them. |
| **Web‑server only** (batch script provided) | RNAComposer |
| **Closed API** (account required) | AlphaFold3 (AlphaFold Server) |

### Using the Docker image (recommended)

The Docker image provides a ready‑to‑run environment for all **locally installable** tools listed above. No manual dependency resolution is required.  

Please refer to the [`Docker/readme.md`](./Docker/readme.md) for build and run instructions.

For **non‑local tools** (RNAComposer, AlphaFold Server) we document the exact submission protocol, and driver scripts are deposited in this GitHub repository.

### Native installation (without Docker)

If you prefer a native installation, the following external programs and libraries need to be downloaded and installed separately. **Linux or Unix‑like operating systems** are required.

- **Linux or Unix-like operating systems**
- **DeepFoldRNA**
  ```
  https://zhanggroup.org/DeepFoldRNA/download.html or
  https://github.com/robpearc/DeepFoldRNA
  ```
  Citation: see [Citations](#citations).
  
- **trRosettaRNA**
  ```
  https://yanglab.qd.sdu.edu.cn/trRosettaRNA/download/
  ```
  Citation: see [Citations](#citations).
  
- **DRfold**
  ```
  https://zhanggroup.org/DRfold/DRfold.zip or
  https://github.com/leeyang/DRfold/
  ```
  Citation: see [Citations](#citations).
  
- **DRfold2**
  ```
  https://github.com/leeyang/DRfold2
  ```
  Citation: see [Citations](#citations).
  
- **RhoFold**
  ```
  https://github.com/ml4bio/RhoFold
  ```
  Citation: see [Citations](#citations).

- **RoseTTAFoldNA**
  ```
  https://github.com/uw-ipd/RoseTTAFold2NA
  ```
  Citation: see [Citations](#citations).
  
- **Boltz**
  ```
  https://github.com/jwohlwend/boltz
  ```
  Citation: see [Citations](#citations).
  
- **Protenix**
  ```
  https://github.com/bytedance/Protenix
  ```
  Citation: see [Citations](#citations).
  
- **SimRNA**
  ```
  wget --no-check-certificate https://ftp.users.genesilico.pl/software/simrna/version_3.20/SimRNA_64bitIntel_Linux.tgz
  ```
  Citation: see [Citations](#citations).

- **lociPARSE**
  ```
  https://github.com/Bhattacharya-Lab/lociPARSE
  ```
  Citation: see [Citations](#citations).

- **RNAalign**
  Download:
  ```
  https://zhanggroup.org/RNA-align/download.html
  ```
  Citation: see [Citations](#citations).

## Installation of ROMET-RNA

We store the public release versions of ROMET-RNA on GitHub, a site that provides code development with version control and issue tracking through the use of git. We will not describe the use of git in general, as you will not need more than very basic features. Below we outline the few commands needed on a UNIX system; please refer to general git descriptions and tutorials to suit your system. To get the code, you clone or download the repository. We recommend cloning, as it allows you to easily update the code when new versions are released. To do so, use the shell command-line:

- **Download**
  ```bash
  git clone https://github.com/chenjief0628/ROMET-RNA.git
  ```

- **In order to run ROMET-RNA properly, users should properly set the variables in `run.sh`**
  - *Set "RNAalign_path" to the path of RNAalign, for example*
    ```bash
    RNAalign_path="path/software/RNAalign/RNAalign"
    ```
  - *Set "lociPARSE_path" to the path of lociPARSE, and set "lociPARSE_env" to the name of the python conda virtual environment for lociPARSE, for example*
    ```bash
    lociPARSE_path="path/software/lociPARSE-main"
    lociPARSE_env="lociPARSE"
    ```

- **Set the variables in `gene_mate.sh`**
  Configure the installation paths and conda environments for the required RNA structure prediction tools.
  - *Set "deepfoldrna_path" to the path of DeepFoldRNA, and set "deepfoldrna_env" to the name of the python conda virtual environment for DeepFoldRNA, for example*
    ```bash
    deepfoldrna_path="path/DeepFoldRNA/"
    infernal_dir="${deepfoldrna_path}/bin/rMSA/infernal-1.1.4-linux-intel-gcc/binaries/"
    deepfoldrna_env="path/DeepFoldRNA/conda_local/conda/envs/deepfoldrna"
    ```
  - *Set "trrosettarna_path" to the path of trRosettaRNA, and set "trrosettarna_env" to the name of the python conda virtual environment for trRosettaRNA, for example*
    ```bash
    trrosettarna_path="path/trRosettaRNA"
    trrosettarna_env="trRNA"
    ```
  - *Set "rhofold_path" to the path of RhoFold, and set "rhofold_env" to the name of the python conda virtual environment for RhoFold, for example*
    ```bash
    rhofold_path='path/software/RhoFold/'
    rhofold_env="rhofold"
    ```
  - *Set "rf2na_path" to the path of RoseTTAFoldNA, and set "rf2na_env" to the name of the python conda virtual environment for RoseTTAFoldNA, for example*
    ```bash
    rf2na_path="path/software/RoseTTAFold2NA"
    rf2na_env="RF2NA"
    ```
  - *Set "drfold_path" to the path of DRfold, and set "drfold_env" to the name of the python conda virtual environment for DRfold, for example*
    ```bash
    drfold_path="path/DRfold/"
    ```
  - *Set "drfold2_path" to the path of DRfold2, and set "drfold2_env" to the name of the python conda virtual environment for DRfold2, for example*
    ```bash
    drfold2_path="/path/DRfold2/"
    ```
  - *Set "boltz_path" to the path of Boltz, and set "boltz_env" to the name of the python conda virtual environment for Boltz, for example*
    ```bash
    boltz_path="/path/boltz/"
    ```
  - *Set "protenix_path" to the path of Protenix, and set "protenix_env" to the name of the python conda virtual environment for Protenix, for example*
    ```bash
    protenix_path="/path/protenix/"
    ```
  - *Set "simrna_path" to the path of SimRNA, for example*
    ```bash
    simrna_path="path/SimRNA_64bitIntel_Linux"
    ```

# Explanation of Parameters and Useful Example
## Parameter Explanation of ROMET-RNA  
### Command Line Arguments

- **Required options**
  - `--input (-i): specify the input file (The input file extension is .fasta).`
    ```
    --input seq.fasta or -i seq.fasta
    ```
    
  - `--output (-o): specify the output_directory`
    ```
    --output output_directory or -o output_directory
    ```

- **Optional options**
  - `--help (-h): print help content, no extra argument needed.`

We have supplied an example of the input file format on GitHub ([ROMET-RNA GitHub](https://github.com/chenjief0628/ROMET-RNA/)), which users can download and view.

## Explanation of the Content in the Output Folder
- **'MSA'**
  - Input multi-sequence alignment (MSA) file retrieved from the FASTA sequences.
  
- **'input_afa'**
  - Input file composed of stage 1 MSA.

- **'input_a2m'**
  - Input file composed of stage 2 MSA.

- **'input_a2m_msa'**
  - Input file composed of stage 3 MSA.

- **'input_nomsa'**
  - Input file with no MSA composition.

- **'Outputs'**
  - Output folder during program execution, including results from various software (DeepFoldRNA, trRosettaRNA, RhoFold, RoseTTAFoldNA, DRfold, SimRNA) and ROMET-RNA results.

- **'seq_output'**
  - Output results from all programs: *.pdb.

- **'ROMET_pdb'**
  - Output results of ROMET-RNA: model_${rank}.pdb.

- **'method_pdb'**
  - The model_1.pdb files from various programs.

- **'seq_rometa_score.csv'**
  - The output file of ROMET-RNA includes the fasta name, pdb file name, ROMET-RNA score, and sorted results. The naming convention for the pdb files is "software-name_MSA-type_num"; if MSA is not used, it will be "software-name_num".

## Example

When using ROMET-RNA for RNA three-dimensional structure prediction, users need to locally install DeepFoldRNA, trRosettaRNA, RhoFold, RoseTTAFoldNA, DRfold, and SimRNA software. ROMET-RNA will automate the execution of each program for meta-prediction. The necessary parameters include the fasta sequence to be predicted (in .fasta format) and the output result storage path.

The following is a useful example of input from the command line: 

```bash
./run.sh -i example/seq.fasta -o example_Outputs/
```

**NOTE: If there are changes in the software to be executed, please modify the “soft_list” line in `run.sh`, for example:**
```bash
soft_list=(DeepFoldRNA trRosettaRNA RhoFold RosettaFoldNA DRfold SimRNA)
```

## Citations

This repository uses and benchmarks several external prediction methods, evaluation tools, MSA/homology-search pipelines, and public datasets/databases. If you use this repository, please cite the relevant original publications listed below. A complete BibTeX file is also provided in [`references.bib`](./references.bib).

### Prediction methods included in benchmarking

| Method | Source / URL | Reference |
|---|---|---|---|
| AlphaFold3 | https://github.com/google-deepmind/alphafold3 | Abramson et al., 2024. *Nature*. DOI: [10.1038/s41586-024-07487-w](https://doi.org/10.1038/s41586-024-07487-w) |
| DRfold | [Website](https://zhanggroup.org/DRfold) | Li, Y., Zhang, C., Feng, C. et al. Integrating end-to-end learning with deep geometrical potentials for ab initio RNA structure prediction. *Nature Communications* 14, 5745 (2023). DOI: [10.1038/s41467-023-41303-9](https://doi.org/10.1038/s41467-023-41303-9) |
| DRfold2 | https://github.com/leeyang/DRfold2 | Li et al., 2025. *Ab initio RNA structure prediction with composite language model and denoised end-to-end learning*. |
| Protenix | https://github.com/bytedance/Protenix | Protenix Team et al., 2026. *bioRxiv*. DOI: [10.64898/2026.02.05.703733](https://doi.org/10.64898/2026.02.05.703733) |
| Boltz | https://github.com/jwohlwend/boltz | Wohlwend et al., 2024. *bioRxiv*. DOI: [10.1101/2024.11.19.624167](https://doi.org/10.1101/2024.11.19.624167); Passaro et al., 2025. *bioRxiv*. DOI: [10.1101/2025.06.14.659707](https://doi.org/10.1101/2025.06.14.659707) |
| RhoFold | https://github.com/ml4bio/RhoFold | Shen et al., 2024. *Nature Methods*. |
| trRosettaRNA | https://yanglab.qd.sdu.edu.cn/trRosettaRNA/ | Wang et al., 2023. *Nature Communications*. DOI: [10.1038/s41467-023-42528-4](https://doi.org/10.1038/s41467-023-42528-4) |
| DeepFoldRNA | https://zhanggroup.org/DeepFoldRNA | Pearce, R., Omenn, G. S., and Zhang, Y. De novo RNA tertiary structure prediction at atomic resolution using geometric potentials from deep learning. *bioRxiv* (2022). DOI: [10.1101/2022.05.15.491755](https://doi.org/10.1101/2022.05.15.491755) |
| RoseTTAFoldNA | https://github.com/RoseTTAFold2NA | Baek et al., 2024. *Nature Methods*. DOI: [10.1038/s41592-023-02086-5](https://doi.org/10.1038/s41592-023-02086-5) |
| SimRNA | https://genesilico.pl/SimRNAweb/ | Boniecki et al., 2016. *Nucleic Acids Research*. DOI: [10.1093/nar/gkv1479](https://doi.org/10.1093/nar/gkv1479) |
| RNAComposer | http://rnacomposer.ibch.poznan.pl | Antczak, M., Popenda, M., Zok, T. et al. New functionality of RNAComposer: an application to shape the axis of miR160 precursor structure. *Acta Biochimica Polonica* 63(4), 737–744 (2016). |

### Evaluation tools and auxiliary tools

| Tool | Usage in this work | Reference |
|---|---|---|
| RNA-align | RNA 3D structure alignment and TM-scoreRNA calculation | Gong et al., 2019. *Bioinformatics*. DOI: [10.1093/bioinformatics/btz282](https://doi.org/10.1093/bioinformatics/btz282) |
| lociPARSE alone | [DOI](https://doi.org/10.1021/acs.jcim.4c01621) | Tarafder, S., and Bhattacharya, D. lociPARSE: a locality-aware invariant point attention model for scoring RNA 3D structures. *Journal of Chemical Information and Modeling* 64, 8655–8664 (2024). DOI: [10.1021/acs.jcim.4c01621](https://doi.org/10.1021/acs.jcim.4c01621) |
| RNAdvisor | [DOI](https://doi.org/10.1093/bib/bbae064) | Bernard, C., Postic, G., Ghannay, S., and Tahi, F. RNAdvisor: a comprehensive benchmarking tool for the measure and prediction of RNA structural model quality. *Briefings in Bioinformatics* 25(2), bbae064 (2024). DOI: [10.1093/bib/bbae064](https://doi.org/10.1093/bib/bbae064) |
| SPOT-RNA | RNA secondary structure prediction | Singh et al., 2019. *Nature Communications*. DOI: [10.1038/s41467-019-13395-9](https://doi.org/10.1038/s41467-019-13395-9) |
### Datasets, databases, and MSA/homology-search resources

| Resource | Usage in this work | Reference |
|---|---|---|
| CASP15 blind tests | Benchmark dataset | Kryshtafovych et al., 2023. *Proteins*. DOI: [10.1002/prot.26515](https://doi.org/10.1002/prot.26515) |
| RNA-Puzzles | Benchmark dataset | Cruz et al., 2012. *RNA*. DOI: [10.1261/rna.031054.111](https://doi.org/10.1261/rna.031054.111) |
| Protein Data Bank, PDB | Source of experimentally determined structures | Berman et al., 2000. *Nucleic Acids Research*. DOI: [10.1093/nar/28.1.235](https://doi.org/10.1093/nar/28.1.235) |
| rMSA | RNA sequence search and multiple sequence alignment generation | Zhang et al., 2023. *Journal of Molecular Biology*. DOI: [10.1016/j.jmb.2022.167904](https://doi.org/10.1016/j.jmb.2022.167904) |
| RNAcentral | RNA sequence database | RNAcentral Consortium, 2021. *Nucleic Acids Research*. DOI: [10.1093/nar/gkaa921](https://doi.org/10.1093/nar/gkaa921) |
| RNAcmap3-MARS | RNA homology search and RNA sequence database resource | Chen et al., 2024. *Genomics, Proteomics & Bioinformatics*. DOI: [10.1093/gpbjnl/qzae018](https://doi.org/10.1093/gpbjnl/qzae018) |
| Rfam | RNA family database | Kalvari et al., 2021. *Nucleic Acids Research*. DOI: [10.1093/nar/gkaa1047](https://doi.org/10.1093/nar/gkaa1047) |

### Notes

For tools or datasets without a DOI or formal publication available at the time of writing, we cite the corresponding preprint, software repository, or official resource page where applicable.


