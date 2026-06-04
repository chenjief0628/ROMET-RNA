# ========== BASE IMAGE ==========
FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu20.04 AS BUILD

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# ========== SYSTEM DEPENDENCIES ==========
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    cmake \
    g++ \
    clang \
    libboost-all-dev \
    libopenblas-dev \
    libhdf5-dev \
    libgl1 \
    libglib2.0-0 \
    perl \
    unzip \
    pkg-config \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

# ========== CONDA INSTALLATION ==========
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_23.11.0-2-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

ENV PATH=/opt/conda/bin:$PATH

# ========== TOOL 1: DeepFoldRNA ==========
WORKDIR /opt/softwares/

# 1. Clone repository
RUN git clone https://github.com/robpearc/DeepFoldRNA.git /opt/softwares/DeepFoldRNA
WORKDIR /opt/softwares/DeepFoldRNA

# 2. Create main conda environment using official yml (Python 3.7 + PyTorch 1.10)
RUN /opt/conda/bin/conda env create -f /opt/softwares/DeepFoldRNA/environment.yml

# 3. Install SPOT-RNA-1D (Required by DeepFoldRNA for initial conformations)
WORKDIR /opt/softwares/
RUN git clone https://github.com/jaswindersingh2/SPOT-RNA-1D.git /opt/softwares/SPOT-RNA-1D
WORKDIR /opt/softwares/SPOT-RNA-1D

# Create venv environment (Python 3.6 + TF 1.15 CPU)
# Note: Must use CPU version of TF 1.15 because CUDA 12.2 base image is too new for TF 1.x GPU
RUN /opt/conda/bin/conda create -n venv python=3.6 -y
RUN /opt/conda/bin/conda run -n venv pip install \
    tensorflow==1.15.0 \
    numpy==1.16.4 \
    scipy
# Install any additional requirements if the file exists
RUN if [ -f requirements.txt ]; then /opt/conda/bin/conda run -n venv pip install -r requirements.txt; fi

# 4. Create database directory placeholder (do not download 500GB+ data)
RUN mkdir -p /opt/softwares/DeepFoldRNA/bin/rMSA/database

# 5. Environment Variables
ENV DEEPFOLD_PATH=/opt/softwares/DeepFoldRNA
# Add both environments to PATH so DeepFoldRNA can find its executables and the venv python
ENV PATH="/opt/conda/envs/deepfoldrna/bin:/opt/conda/envs/venv/bin:${PATH}"

# ========== TOOL 2: trRosettaRNA ==========
WORKDIR /opt/softwares/

#RUN wget -O trRosettaRNA.zip https://yanglab.qd.sdu.edu.cn/trRosettaRNA/download/trRosettaRNA_v1.0.zip && \
#    unzip trRosettaRNA.zip && \
#    rm trRosettaRNA.zip
# 1. Copy local zip file (since server network is unreachable)
COPY trRosettaRNA_v1.0.zip /opt/softwares/
RUN unzip trRosettaRNA_v1.0.zip && rm trRosettaRNA_v1.0.zip

# 2. Create conda environment using official linux.yml (CUDA 11.x compatible)
WORKDIR /opt/softwares/trRosettaRNA_v1.0
# This creates an environment named 'trRNA' as per the yml file
RUN /opt/conda/bin/conda env create -f linux.yml

# 3. Install SPOT-RNA Dependency
WORKDIR /opt/softwares/
RUN git clone https://github.com/jaswindersingh2/SPOT-RNA.git /opt/softwares/SPOT-RNA
WORKDIR /opt/softwares/SPOT-RNA

# Download models
# RUN wget -O SPOT-RNA-models.tar.gz 'https://app.nihaocloud.com/f/fbf3315a91d542c0bdc2/?dl=1' && \
#    tar -xvzf SPOT-RNA-models.tar.gz && \
#    rm SPOT-RNA-models.tar.gz

# 4. Setup SPOT-RNA environment (Python 3.6 + TF 1.14)
RUN /opt/conda/bin/conda create -n spot_venv python=3.6 -y

# CRITICAL FIX: Use CPU version of TF 1.14 because CUDA 12.2 base image is incompatible with TF 1.x GPU
RUN /opt/conda/bin/conda run -n spot_venv pip install \
    tensorflow==1.14.0 \
    numpy==1.16.4 \
    scipy

# Install requirements if exists
RUN if [ -f requirements.txt ]; then /opt/conda/bin/conda run -n spot_venv pip install -r requirements.txt; fi

# 5. Install PyRosetta into trRNA environment
# Ensure the channel is added or specified correctly
RUN /opt/conda/bin/conda install -n trRNA -y \
    -c https://conda.rosettacommons.org \
    -c conda-forge \
    pyrosetta

# 6. Environment Variables
ENV TRROSETTA_PATH=/opt/softwares/trRosettaRNA_v1.0
ENV SPOT_RNA_PATH=/opt/softwares/SPOT-RNA
# Add both environments to PATH
ENV PATH="/opt/conda/envs/trRNA/bin:/opt/conda/envs/spot_venv/bin:${PATH}"

# ========== TOOL 3: DRfold ==========
WORKDIR /opt/softwares/
# ViennaRNA
RUN cd /tmp && \
    wget https://www.tbi.univie.ac.at/RNA/download/sourcecode/2_7_x/ViennaRNA-2.7.2.tar.gz && \
    tar -xzf ViennaRNA-2.7.2.tar.gz && \
    cd ViennaRNA-2.7.2 && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && make install && \
    cd / && rm -rf /tmp/ViennaRNA-2.7.2*

# PETfold

#RUN cd /tmp && \
#    wget https://rth.dk/resources/petfold/download/PETfold2.2.tar.gz && \
#    tar -xzf PETfold2.2.tar.gz
COPY PETfold2.2.tar.gz /tmp/
RUN cd /tmp && \
    tar -xzf PETfold2.2.tar.gz

# Modify Makefile and compile
RUN cd /tmp/PETfold && \
    sed -i 's|^HPATH.*|HPATH = /opt/conda/include|' src/Makefile && \
    sed -i 's|^LPATH.*|LPATH = /opt/conda/lib|' src/Makefile && \
    cd src && \
    make clean && \
    make

# Install: Copy executable and Grammar files
RUN cd /tmp/PETfold && \
    cp bin/PETfold /usr/local/bin/ && \
    mkdir -p /usr/local/share/PETfold && \
    cp bin/scfg.rate bin/article.grm /usr/local/share/PETfold/

# Cleanup
RUN rm -rf /tmp/PETfold*
ENV PETFOLDBIN=/usr/local/share/PETfold

# 3. Python Environment for DRfold
RUN /opt/conda/bin/conda create -n drfold python=3.10 -y
RUN /opt/conda/bin/conda run -n drfold pip install torch numpy scipy biopython openmm

# 4. DRfold Repo & Arena
RUN git clone https://github.com/leeyang/DRfold.git /opt/softwares/DRfold
WORKDIR /opt/softwares/DRfold

# Install Arena (Official method: make Arena)
RUN git clone https://github.com/pylelab/Arena.git bin/Arena_src && \
    cd bin/Arena_src && \
    make Arena && \
    cp Arena ../Arena && \
    cd .. && \
    rm -rf bin/Arena_src

# 5. Configure Paths (Official documentation requirement)
# Features.py: Point to executable files, not directories
RUN sed -i 's|petfoldbin.*|petfoldbin = "/usr/local/bin/PETfold"|' /opt/softwares/DRfold/scripts/Features.py && \
    sed -i 's|ViennaRNAbin.*|ViennaRNAbin = "/usr/local/bin/RNAfold"|' /opt/softwares/DRfold/scripts/Features.py

# DRfold.sh: Modify PETFOLDBIN and PYTHON paths
RUN sed -i '6s|.*|PETFOLDBIN=/usr/local/bin/PETfold|' /opt/softwares/DRfold/DRfold.sh && \
    sed -i "7s|.*|PYTHON=/opt/conda/envs/drfold/bin/python|" /opt/softwares/DRfold/DRfold.sh

# 6. Models
RUN cd /opt/softwares/DRfold && \
    wget https://zhanggroup.org/DRfold/DRfold_models.zip -O models.zip && \
    unzip models.zip && \
    cp -r DRfold/* . && \
    rm -rf DRfold models.zip
RUN chmod +x /opt/softwares/DRfold/bin/*

ENV DRFLD_PATH=/opt/softwares/DRfold
ENV PATH="/opt/conda/envs/drfold/bin:${PATH}"

# ========== TOOL 4: DRfold2 ==========
WORKDIR /opt/softwares/
RUN git clone https://github.com/leeyang/DRfold2.git /opt/softwares/DRfold2
RUN /opt/conda/bin/conda create -n drfold2 python=3.10 -y
RUN /opt/conda/bin/conda run -n drfold2 pip install torch numpy scipy biopython openmm

# Models
RUN cd /opt/softwares/DRfold2 && \
    wget --no-check-certificate -O model_hub.tar.gz https://zhanggroup.org/DRfold2/res/model_hub.tar.gz && \
    tar -xzf model_hub.tar.gz && \
    rm model_hub.tar.gz

# Arena
RUN cd /opt/softwares/DRfold2 && \
    git clone https://github.com/pylelab/Arena.git && \
    cd Arena && \
    make Arena

ENV DRFLD2_PATH=/opt/softwares/DRfold2
ENV PATH="/opt/conda/envs/drfold2/bin:${PATH}"

# ========== TOOL 5: RhoFold ==========
WORKDIR /opt/softwares/
RUN git clone https://github.com/ml4bio/RhoFold.git /opt/softwares/RhoFold
RUN /opt/conda/bin/conda env create -f /opt/softwares/RhoFold/envs/environment_linux.yaml
RUN /opt/conda/bin/conda run -n RhoFold python /opt/softwares/RhoFold/setup.py install

ENV RHOFOLD_PATH=/opt/softwares/RhoFold
ENV PATH="/opt/conda/envs/RhoFold/bin:${PATH}"

# ========== TOOL 6: RoseTTAFold2NA ==========
WORKDIR /opt/softwares/
RUN git clone https://github.com/uw-ipd/RoseTTAFold2NA.git /opt/softwares/RoseTTAFold2NA
RUN /opt/conda/bin/conda env create -f /opt/softwares/RoseTTAFold2NA/RF2na-linux.yml
RUN /opt/conda/bin/conda run -n RF2NA bash -c "cd /opt/softwares/RoseTTAFold2NA/SE3Transformer && \
    pip install --no-cache-dir -r requirements.txt && \
    python setup.py install"

# Weights
RUN cd /opt/softwares/RoseTTAFold2NA/network && \
    wget https://files.ipd.uw.edu/dimaio/RF2NA_apr23.tgz && \
    tar xvfz RF2NA_apr23.tgz && \
    rm RF2NA_apr23.tgz

# ========== DATABASES (DISABLED) ==========
# The following database downloads are commented out to reduce build time and image size.
# Please download and mount these manually at runtime if needed.

# WORKDIR /opt/softwares/RoseTTAFold2NA

# # UniRef30 [46G]
# RUN wget http://wwwuser.gwdg.de/~compbiol/uniclust/2020_06/UniRef30_2020_06_hhsuite.tar.gz && \
#     mkdir -p UniRef30_2020_06 && \
#     tar xfz UniRef30_2020_06_hhsuite.tar.gz -C ./UniRef30_2020_06 && \
#     rm UniRef30_2020_06_hhsuite.tar.gz

# # BFD [272G]
# RUN wget https://bfd.mmseqs.com/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz && \
#     mkdir -p bfd && \
#     tar xfz bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz -C ./bfd && \
#     rm bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz

# # Structure templates
# RUN wget https://files.ipd.uw.edu/pub/RoseTTAFold/pdb100_2021Mar03.tar.gz && \
#     tar xfz pdb100_2021Mar03.tar.gz && \
#     rm pdb100_2021Mar03.tar.gz

# # RNA databases
# RUN mkdir -p RNA && cd RNA && \
#     wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/Rfam.full_region.gz && \
#     wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/Rfam.cm.gz && \
#     gunzip Rfam.cm.gz && \
#     cmpress Rfam.cm && \
#     wget ftp://ftp.ebi.ac.uk/pub/databases/RNAcentral/current_release/rfam/rfam_annotations.tsv.gz && \
#     wget ftp://ftp.ebi.ac.uk/pub/databases/RNAcentral/current_release/id_mapping/id_mapping.tsv.gz && \
#     wget ftp://ftp.ebi.ac.uk/pub/databases/RNAcentral/current_release/sequences/rnacentral_species_specific_ids.fasta.gz && \
#     perl ../input_prep/reprocess_rnac.pl id_mapping.tsv.gz rfam_annotations.tsv.gz && \
#     gunzip -c rnacentral_species_specific_ids.fasta.gz | makeblastdb -in - -dbtype nucl -parse_seqids -out rnacentral.fasta -title "RNACentral" && \
#     update_blastdb.pl --decompress nt

# Create empty directories so the software doesn't crash looking for paths
RUN mkdir -p /opt/softwares/RoseTTAFold2NA/UniRef30_2020_06 && \
    mkdir -p /opt/softwares/RoseTTAFold2NA/bfd && \
    mkdir -p /opt/softwares/RoseTTAFold2NA/pdb100_2021Mar03 && \
    mkdir -p /opt/softwares/RoseTTAFold2NA/RNA

ENV ROSETTANA_PATH=/opt/softwares/RoseTTAFold2NA
ENV PATH="/opt/conda/envs/RF2NA/bin:${PATH}"

# ========== TOOL 7: Boltz ==========
WORKDIR /opt/softwares/
RUN git clone https://github.com/jwohlwend/boltz.git /opt/softwares/boltz
RUN /opt/conda/bin/conda create -n boltz python=3.10 -y
RUN /opt/conda/bin/conda run -n boltz pip install "boltz[cuda]" -U
ENV BOLTZ_PATH=/opt/softwares/boltz
ENV PATH="/opt/conda/envs/boltz/bin:${PATH}"

# ========== TOOL 8: Protenix ==========
WORKDIR /opt/softwares/
RUN git clone https://github.com/bytedance/Protenix.git /opt/softwares/Protenix
RUN /opt/conda/bin/conda create -n protenix python=3.10 -y
RUN /opt/conda/bin/conda run -n protenix pip install --upgrade protenix --index-url https://pypi.org/simple
ENV PROTENIX_PATH=/opt/softwares/Protenix
ENV PATH="/opt/conda/envs/protenix/bin:${PATH}"

# ========== TOOL 9: SimRNA ==========
WORKDIR /opt/softwares/
RUN wget --no-check-certificate -O SimRNA.tgz \
    https://ftp.users.genesilico.pl/software/simrna/version_3.20/SimRNA_64bitIntel_Linux.tgz && \
    mkdir -p /opt/softwares/SimRNA && \
    tar -xzf SimRNA.tgz -C /opt/softwares/SimRNA && \
    rm SimRNA.tgz
ENV SIMRNA_PATH="/opt/softwares/SimRNA/SimRNA_64bitIntel_Linux"
ENV PATH="/opt/softwares/SimRNA/SimRNA_64bitIntel_Linux:${PATH}"

# ========== TOOL 10: lociPARSE ==========
WORKDIR /opt/softwares/
RUN git clone https://github.com/Bhattacharya-Lab/lociPARSE.git /opt/softwares/lociPARSE
RUN /opt/conda/bin/conda create -n lociparse python=3.10 -y
RUN /opt/conda/bin/conda run -n lociparse pip install /opt/softwares/lociPARSE
ENV LOCIPARSE_PATH=/opt/softwares/lociPARSE
ENV PATH="/opt/conda/envs/lociparse/bin:${PATH}"

# ========== TOOL 11: RNAalign ==========
WORKDIR /opt/softwares/
RUN wget -O RNAalign.zip https://aideepmed.com/RNA-align/bin/RNAalign.zip && \
    unzip RNAalign.zip -d RNAalign && \
    rm RNAalign.zip
ENV RNAALIGN_PATH="/opt/softwares/RNAalign"
ENV PATH="/opt/softwares/RNAalign:${PATH}"

# ========== INSTALL ROMET-RNA ==========
WORKDIR /opt/
RUN git clone https://github.com/chenjief0628/ROMET-RNA.git /opt/ROMET-RNA

# Configure ROMET-RNA paths
# Note: Using static paths here as they are more reliable in sed than variable expansion
RUN if [ -f /opt/ROMET-RNA/run.sh ]; then \
      sed -i 's|RNAalign_path=.*|RNAalign_path="/opt/softwares/RNAalign/RNAalign"|' /opt/ROMET-RNA/run.sh && \
      sed -i 's|lociPARSE_path=.*|lociPARSE_path="/opt/softwares/lociPARSE"|' /opt/ROMET-RNA/run.sh && \
      sed -i 's|lociPARSE_env=.*|lociPARSE_env="lociparse"|' /opt/ROMET-RNA/run.sh; \
    else \
      echo "Warning: run.sh not found"; \
    fi

# 2. Configure gene_meta.sh (Set paths and environments for each tool)
RUN if [ -f /opt/ROMET-RNA/gene_meta.sh ]; then \
      sed -i 's|deepfoldrna_path=.*|deepfoldrna_path="/opt/softwares/DeepFoldRNA"|' /opt/ROMET-RNA/gene_meta.sh && \
      sed -i 's|deepfoldrna_env=.*|deepfoldrna_env="deepfoldrna"|' /opt/ROMET-RNA/gene_meta.sh && \
      sed -i 's|trrosettarna_path=.*|trrosettarna_path="/opt/softwares/trRosettaRNA_v1.0"|' /opt/ROMET-RNA/gene_meta.sh && \
      sed -i 's|trrosettarna_env=.*|trrosettarna_env="trRNA"|' /opt/ROMET-RNA/gene_meta.sh && \
      sed -i 's|rhofold_path=.*|rhofold_path="/opt/softwares/RhoFold"|' /opt/ROMET-RNA/gene_meta.sh && \
      sed -i 's|rhofold_env=.*|rhofold_env="RhoFold"|' /opt/ROMET-RNA/gene_meta.sh && \
      sed -i 's|rf2na_path=.*|rf2na_path="/opt/softwares/RoseTTAFold2NA"|' /opt/ROMET-RNA/gene_meta.sh && \
      sed -i 's|rf2na_env=.*|rf2na_env="RF2NA"|' /opt/ROMET-RNA/gene_meta.sh && \
      sed -i 's|drfold_path=.*|drfold_path="/opt/softwares/DRfold"|' /opt/ROMET-RNA/gene_meta.sh && \
      sed -i 's|simrna_path=.*|simrna_path="/opt/softwares/SimRNA/SimRNA_64bitIntel_Linux"|' /opt/ROMET-RNA/gene_meta.sh; \
    else \
      echo "Warning: gene_meta.sh not found"; \
    fi

WORKDIR /opt/ROMET-RNA
CMD ["/bin/bash"]