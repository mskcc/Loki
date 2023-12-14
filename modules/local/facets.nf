process FACETS {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/facets-suite:2.0.9':
        'docker.io/mskcc/facets-suite:2.0.9' }"

    input:

    tuple val(meta), path(snp_pileup)  //  [ meta (id, assay, normalType), ${prefix}.snp_pileup.gz]

    output:
    tuple val(meta), path("*_purity.seg")            , emit: purity_seg
    tuple val(meta), path("*_purity.Rdata")          , emit: purity_rdata
    tuple val(meta), path("*_purity.CNCF.png")       , emit: purity_png
    tuple val(meta), path("*_purity.out")            , emit: purity_out
    tuple val(meta), path("*_purity.CNCF.txt")       , emit: purity_cncf_txt
    tuple val(meta), path("*_hisens.seg")            , emit: hisens_seg
    tuple val(meta), path("*_hisens.Rdata")          , emit: hisens_rdata
    tuple val(meta), path("*_hisens.CNCF.png")       , emit: hisens_png
    tuple val(meta), path("*_hisens.out")            , emit: hisens_out
    tuple val(meta), path("*_hisens.CNCF.txt")       , emit: hisens_cncf_txt
    tuple val(meta), path("*.qc.txt")                , emit: qc_txt
    tuple val(meta), path("*.gene_level.txt")        , emit: gene_level_txt
    tuple val(meta), path("*.arm_level.txt")         , emit: arm_level_txt
    tuple val(meta), path("*.txt")                   , emit: output_txt
    path "versions.yml"                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    /usr/bin/facets-suite/run-facets-wrapper.R \
        ${args} \
        --sample-id ${prefix} \
        --counts-file ${snp_pileup}
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        facets_suite: 2.0.9
        facets: 0.5.14
        r: 3.6.1
        pctGCdata: 0.3.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_purity.seg
    touch ${prefix}_purity.CNCF.png
    touch ${prefix}_purity.cncf.txt
    touch ${prefix}_purity.Rdata
    touch ${prefix}_purity.out
    touch ${prefix}_hisens.seg
    touch ${prefix}_hisens.CNCF.png
    touch ${prefix}_hisens.cncf.txt
    touch ${prefix}_hisens.Rdata
    touch ${prefix}_hisens.out
    touch ${prefix}.qc.txt
    touch ${prefix}.gene_level.txt
    touch ${prefix}.arm_level.txt



    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        facets_suite: 2.0.9
        facets: 0.5.14
        r: 3.6.1
        pctGCdata: 0.3.0
    END_VERSIONS
    """
}
