# ROMET-RNA
# Overview

Here we present a new meta-predicted server, ROMET-RNA, to model the 3D structure of RNAs from the primary sequence. Firstly, the six individual predicted servers are installed locally. This will allow us to control and tune our meta-server algorithms in a consistent manner and enable users to obtain comprehensive predictions from all servers quickly. Then, in addition to the construction of the best possible 3D models, the ROMET-RNA server also presents a score for ranking RNA 3D structures generated from different individual algorithms. In comparison to other structure prediction software and methods, ROMET-RNA can generate more accurate models than both threading templates and the peer methods benchmarked.

# Installation
## Prerequisites

Note that ROMET-RNA depends on and uses several external programs and libraries.

- **Linux or Unix-like operating systems**
- **DeepFoldRNA**
  ```
  https://zhanggroup.org/DeepFoldRNA/download.html or
  https://github.com/robpearc/DeepFoldRNA
  ```
- **trRosettaRNA**
  ```
  https://yanglab.qd.sdu.edu.cn/trRosettaRNA/download/
  ```
  
- **DRfold**
  ```
  https://zhanggroup.org/DRfold/DRfold.zip or
  https://github.com/leeyang/DRfold/
  ```
  
- **RhoFold**
  ```
  https://github.com/ml4bio/RhoFold
  ```

- **RoseTTAFoldNA**
  ```
  https://github.com/uw-ipd/RoseTTAFold2NA
  ```

- **SimRNA**
  ```
  wget --no-check-certificate https://ftp.users.genesilico.pl/software/simrna/version_3.20/SimRNA_64bitIntel_Linux.tgz
  ```

- **lociPARSE**
  ```
  https://github.com/Bhattacharya-Lab/lociPARSE
  ```

- **RNAalign**
  ```
  https://zhanggroup.org/RNA-align/download.html
  ```

## Installation of ROMET-RNA

We store the public release versions of ROMET-RNA on GitHub, a site that provides code development with version control and issue tracking through the use of git. We will not describe the use of git in general, as you will not need more than very basic features. Below we outline the few commands needed on a UNIX system; please refer to general git descriptions and tutorials to suit your system. To get the code, you clone or download the repository. We recommend cloning, as it allows you to easily update the code when new versions are released. To do so, use the shell command-line:

- **Download**
  ```bash
  git clone https://github.com/chenjief0628/ROMET-RNA/
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
soft_list=(DeepFoldRNA trRosettaRNA RhoFold RosettaFoldNA Drfold SimRNA)
```
