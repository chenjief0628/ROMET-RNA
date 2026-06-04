ROMET-RNA Docker Usage Guide
1. Build Image
Run the following command in the directory containing the Dockerfile:
docker build -t romet-rna:latest .
2. Save & Load Image
Save:​ docker save -o romet-rna.tar romet-rna:latest
Load:​ docker load -i romet-rna.tar
3. Run Container
docker run -it --rm --gpus all -v /path/to/data:/data romet-rna:latest /bin/bash
4. Local Files Required (COPY)
Place these files in the same directory as the Dockerfile:
trRosettaRNA_v1.0.zip https://yanglab.qd.sdu.edu.cn/trRosettaRNA/download/trRosettaRNA_v1.0.zip
PETfold2.2.tar.gz https://rth.dk/resources/petfold/download/PETfold2.2.tar.gz
5. Databases Disabled (Manual Download Required)
Uncomment the corresponding sections in the Dockerfile to enable them:
UniRef30​ (~46G): http://wwwuser.gwdg.de/~compbiol/uniclust/2020_06/UniRef30_2020_06_hhsuite.tar.gz
BFD​ (~272G): https://bfd.mmseqs.com/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz
PDB Templates: https://files.ipd.uw.edu/pub/RoseTTAFold/pdb100_2021Mar03.tar.gz
Rfam: ftp://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/Rfam.cm.gz
RNAcentral: ftp://ftp.ebi.ac.uk/pub/databases/RNAcentral/current_release/