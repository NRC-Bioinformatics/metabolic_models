from glob import glob as glob
bins = glob_wildcards(config["bins"]+"/{bin}.fasta").bin
print(bins)

wdir = config["workdir"]

rule target:
    input:
        # expand(
        #     wdir+"/gapseq/{bin}/{bin}.xml", 
        #     bin = bins
        # )
        expand(
            wdir+"/gapseq_filled/{bin}/{bin}.xml", 
            bin = bins
        )

def get_medium(wildcards):
    if wildcards.bin in  config["special_mediums"].keys():
        out = config["special_mediums"][wildcards.bin]
    else:
        out = config["special_mediums"]['default']
    return( os.path.realpath(out))

rule run_gapfill:
    input:
        xml = wdir+"/gapseq/{bin}/{bin}-draft.xml"
    output:
        xml = wdir+"/gapseq_filled/{bin}/{bin}.xml"
    log:
        wdir+"/gapseq_filled/{bin}/{bin}.log"
    params:
        wdir = wdir+"/gapseq_filled/{bin}",
        instem = wdir+"/gapseq/{bin}/{bin}",
        bind = config["gapseq_dir"],
        media = get_medium
    threads: 5
    conda:
        "gapseq"
    shell:
        """
        instem=`realpath {params.instem}`
        log=`realpath {log}`
        cd {params.wdir}
        {params.bind}/gapseq fill --media {params.media} \
        -m $instem-draft.RDS -c $instem-rxnWeights.RDS -g $instem-rxnXgenes.RDS     &> $log    
        """

rule run_gapseq:
    input:
        fasta = config["bins"]+"/{bin}.fasta"
    output:
        xml = wdir+"/gapseq/{bin}/{bin}-draft.xml"
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