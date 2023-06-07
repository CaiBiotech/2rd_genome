## 分析跟参考序列的差异，并获取不匹配序列。

conda activate snippy_env

snippy --cpu 30 --outdir snippy_result --unmapped \
--reference /share/home/dw_user0001/easy_genome/refdata/GCF_013112415.1_ASM1311241v1_genomic.fna \
--R1 /share/home/dw_user0001/easy_genome/release20230209/results_cb/fastq/CBGD01_R1.fastq \
--R2 /share/home/dw_user0001/easy_genome/release20230209/results_cb/fastq/CBGD01_R2.fastq

## 将跟参考序列不匹配的单独进行组装
conda activate py3

trim_galore --trim-n --cores 30 \
--paired /share/home/dw_user0001/easy_genome/release20230209/snippy_result/snps.unmapped_R1.fq.gz /share/home/dw_user0001/easy_genome/release20230209/snippy_result/snps.unmapped_R2.fq.gz \
-o clean_data

spades.py -t 20 --only-assembler --careful \
-k 21,33 \
-1 /share/home/dw_user0001/easy_genome/release20230209/clean_data/snps.unmapped_R1_val_1.fq.gz \
-2 /share/home/dw_user0001/easy_genome/release20230209/clean_data/snps.unmapped_R2_val_2.fq.gz \
-o unmap_contig

## 将组装结果和NCBI的nr进行比对



