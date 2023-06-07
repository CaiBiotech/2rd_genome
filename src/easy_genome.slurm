#!/bin/bash
# file: easy_genome.slurm
#SBATCH --partition=normal
#SBATCH --job-name=genome-mpi
#SBATCH --output=./logs_%j.out
#SBATCH --error=./logs_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=c001
#SBATCH --ntasks=40
#SBATCH --ntasks-per-node=40
#SBATCH --export=NONE
#SBATCH --mem=400G 
###SBATCH --gres=gpu:1
#SBATCH --mail-user=495253719@qq.com
#SBATCH --mail-type=END

# Enable hyperthreading. Set it after modules load.

export SLURM_HINT=multithread
export OMP_NUM_THREADS=$SLURM_NTASKS_PER_NODE

# run the application

echo SLURM job id : $SLURM_JOB_ID
echo TIME assemble start $(date)
eval "$(conda shell.bash hook)"

tmp="/share/home/dw_user0001/easy_genome/origin_data"
conda activate py3
cd ${tmp}
for n in *_1.fq.gz;do
	k=${n%%_1.fq.gz}
	cd ..
	trim_galore --trim-n --cores $OMP_NUM_THREADS --paired ${tmp}/${k}_1.fq.gz ${tmp}/${k}_2.fq.gz -o $(pwd)/clean_data
	cd ${tmp}
done
cd ..

conda activate genome
mkdir -p $(pwd)/assembly
mkdir -p $(pwd)/finish
ln -s $(pwd)/clean_data/*_val*.fq.gz $(pwd)/assembly

cd assembly
for n in *_1_val_1.fq.gz; do 
	k=${n%%_1_val_1.fq.gz}
	spades.py \
		-t $OMP_NUM_THREADS \
		--only-assembler \
		-m $((SLURM_MEM_PER_NODE/1024)) \
		-1 ${k}_1_val_1.fq.gz \
		-2 ${k}_2_val_2.fq.gz \
		-o $k
mv ${k}_*_val_* $(pwd)/../finish
done
cd ..

echo TIME subset end $(date)