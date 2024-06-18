from glob import glob as glob
bins = glob_wildcards(config["bins"]+"/{bin}.fasta").bin
print(bins)

wdir = config["workdir"]

rule target:
    input:
        expand(
            wdir+"/gapseq/{bin}/{bin}.xml", 
            bin = bins
        )
rule run_gapseq:
    input:
        fasta = config["bins"]+"/{bin}.fasta"
    output:
        xml = wdir+"/gapseq/{bin}/{bin}.xml"
    log:
        wdir+"/gapseq/{bin}/{bin}.log"
    params:
        wdir = wdir+"/gapseq/{bin}",
        bind = config["gapseq_dir"]
    threads: 5
    conda:
        "gapseq"
    shell:
        """
        inf=`realpath {input.fasta}`
        inf_stem=`basename {input.fasta}`
        log=`realpath {log}`
        cd {params.wdir}
        cp $inf .
        ls $inf_stem
        {params.bind}/gapseq doall -n -K {threads} $inf_stem  Bacteria &> $log
        """
#/gapseq doall -n -K 96 nod_bin6.fasta  Bacteria