process SNPPILEUP {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/facets-suite:2.0.9':
        'docker.io/mskcc/facets-suite:2.0.9' }"

    input:

    tuple val(meta), path(input), path(input_index)    //  [ meta (id, assay, normalType), [ tumorBam, normalBam ], [ tumorBai, normalBai ]]


    output:
    tuple val(meta), path("*.snp_pileup.gz")   , emit: pileup
    path "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    /usr/bin/snp-pileup \
        ${args} \
        ${prefix}.snp_pileup.gz \
        ${input[1]} \
        ${input[0]}
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        htslib: 1.5
        htstools: 0.1.1
        r: 3.6.1
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.snp_pileup.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        facets_suite: 2.0.9-7d54d0f67e3136bd60d94ad810a9c855df113096
        facets: 0.6.2
        htslib: 1.18
        r: 4.3
        pctGCdata: 0.3.0
    END_VERSIONS
    """
}
