#!/bin/bash
# file: denvreq.slurm
#SBATCH --partition=normal
#SBATCH --job-name=genome
#SBATCH --output=./logs_%j.out
#SBATCH --error=./logs_%j.err
#SBATCH --exclude=c001
#SBATCH -n 72
#SBATCH -N 1-1
#SBATCH --ntasks-per-node=72
#SBATCH --mem=400G 
#SBATCH --output=slurm-%j_denvreq.out
#SBATCH --error=slurm-%j_denvreq.err

# Enable hyperthreading. Set it after modules load.
export SLURM_HINT=multithread
export OMP_NUM_THREADS=$SLURM_NTASKS_PER_NODE
echo SLURM job id : $SLURM_JOB_ID
eval "$(conda shell.bash hook)"

# run the application

echo "Time: $(date)"
start=$(date +%s)
conda activate bacgenome_env

echo "---------- Begin Genome Analysis Job $(date)-------------"

mkdir -p ok

for n in meta_*.csv; do 
spp=${n:5:2}  
/share/home/dw_user0001/program/WGSBAC/wgsbac.pl --table ${n} \
--results results_${spp}/ \
--kraken src/minikraken_8GB_20200312/ \
--amr \
--virulence \
--plasmids \
--prokka \
--snippy \
--fasttree \
--run
mv ${n} ./ok
done

echo "---------- Finish Genome Analysis Job $(date)-------------"

echo "Time: $(date)"
end=$(date +%s)
runtime=$((end-start))
echo "Runtime was $runtime"

