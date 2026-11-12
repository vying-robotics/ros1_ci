#!/bin/bash
# Downloads the Jenkins plugins used by the ros1_ci / ros2_ci pipelines (Pipeline + Git)
# Versions pinned for Jenkins 2.479.3 (the update center now offers versions that need a newer Jenkins)
# Run once with Jenkins stopped, then start Jenkins (start_jenkins.sh) and choose "None" in the plugin step

set -e
mkdir -p ~/webpage_ws/jenkins/plugins
cd ~/webpage_ws/jenkins/plugins
B=https://updates.jenkins.io/download/plugins
wget -q -O apache-httpcomponents-client-4-api.jpi $B/apache-httpcomponents-client-4-api/4.5.14-269.vfa_2321039a_83/apache-httpcomponents-client-4-api.hpi
wget -q -O asm-api.jpi $B/asm-api/9.8-135.vb_2239d08ee90/asm-api.hpi
wget -q -O bouncycastle-api.jpi $B/bouncycastle-api/2.30.1.86.2-310.v4655f6742752/bouncycastle-api.hpi
wget -q -O branch-api.jpi $B/branch-api/2.1229.ve86b_d02b_5e56/branch-api.hpi
wget -q -O caffeine-api.jpi $B/caffeine-api/3.3.1-214.v18eb_56b_34920/caffeine-api.hpi
wget -q -O cloudbees-folder.jpi $B/cloudbees-folder/6.1026.ve06dfa_cf31c3/cloudbees-folder.hpi
wget -q -O commons-lang3-api.jpi $B/commons-lang3-api/3.21.0-122.v6a_ea_4fd34049/commons-lang3-api.hpi
wget -q -O commons-text-api.jpi $B/commons-text-api/1.15.0-218.va_61573470393/commons-text-api.hpi
wget -q -O credentials.jpi $B/credentials/1453.v9b_a_29777a_b_fd/credentials.hpi
wget -q -O credentials-binding.jpi $B/credentials-binding/728.v902a_273b_8947/credentials-binding.hpi
wget -q -O display-url-api.jpi $B/display-url-api/2.217.va_6b_de84cc74b_/display-url-api.hpi
wget -q -O durable-task.jpi $B/durable-task/605.v9a_b_9040c9970/durable-task.hpi
wget -q -O git.jpi $B/git/5.7.0/git.hpi
wget -q -O git-client.jpi $B/git-client/6.2.1/git-client.hpi
wget -q -O gson-api.jpi $B/gson-api/2.13.1-139.v4569c2ef303f/gson-api.hpi
wget -q -O instance-identity.jpi $B/instance-identity/203.v15e81a_1b_7a_38/instance-identity.hpi
wget -q -O ionicons-api.jpi $B/ionicons-api/88.va_4187cb_eddf1/ionicons-api.hpi
wget -q -O jackson2-api.jpi $B/jackson2-api/2.19.2-408.v18248a_324cfe/jackson2-api.hpi
wget -q -O jakarta-activation-api.jpi $B/jakarta-activation-api/2.1.4-1/jakarta-activation-api.hpi
wget -q -O jakarta-mail-api.jpi $B/jakarta-mail-api/2.1.5-1/jakarta-mail-api.hpi
wget -q -O javax-activation-api.jpi $B/javax-activation-api/1.2.0-8/javax-activation-api.hpi
wget -q -O jaxb.jpi $B/jaxb/2.3.9-143.v5979df3304e6/jaxb.hpi
wget -q -O joda-time-api.jpi $B/joda-time-api/2.14.0-127.v7d9da_295a_d51/joda-time-api.hpi
wget -q -O json-api.jpi $B/json-api/20250517-153.vc8a_a_d87c0ce3/json-api.hpi
wget -q -O mailer.jpi $B/mailer/489.vd4b_25144138f/mailer.hpi
wget -q -O mina-sshd-api-common.jpi $B/mina-sshd-api-common/2.20.1-199.v8ce76b_c93542/mina-sshd-api-common.hpi
wget -q -O mina-sshd-api-core.jpi $B/mina-sshd-api-core/2.20.1-199.v8ce76b_c93542/mina-sshd-api-core.hpi
wget -q -O pipeline-build-step.jpi $B/pipeline-build-step/605.v00486e8f4b_3e/pipeline-build-step.hpi
wget -q -O pipeline-groovy-lib.jpi $B/pipeline-groovy-lib/752.vdddedf804e72/pipeline-groovy-lib.hpi
wget -q -O pipeline-input-step.jpi $B/pipeline-input-step/568.v0c9db_2652741/pipeline-input-step.hpi
wget -q -O pipeline-milestone-step.jpi $B/pipeline-milestone-step/152.v6e22b_8cfc66c/pipeline-milestone-step.hpi
wget -q -O pipeline-model-api.jpi $B/pipeline-model-api/2.2265.v140e610fe9d5/pipeline-model-api.hpi
wget -q -O pipeline-model-definition.jpi $B/pipeline-model-definition/2.2265.v140e610fe9d5/pipeline-model-definition.hpi
wget -q -O pipeline-model-extensions.jpi $B/pipeline-model-extensions/2.2265.v140e610fe9d5/pipeline-model-extensions.hpi
wget -q -O pipeline-stage-step.jpi $B/pipeline-stage-step/345.va_96187909426/pipeline-stage-step.hpi
wget -q -O pipeline-stage-tags-metadata.jpi $B/pipeline-stage-tags-metadata/2.2265.v140e610fe9d5/pipeline-stage-tags-metadata.hpi
wget -q -O plain-credentials.jpi $B/plain-credentials/199.v9f8e1f741799/plain-credentials.hpi
wget -q -O scm-api.jpi $B/scm-api/709.v6c27075a_b_1c7/scm-api.hpi
wget -q -O script-security.jpi $B/script-security/1436.v1082791135e4/script-security.hpi
wget -q -O snakeyaml-api.jpi $B/snakeyaml-api/2.7-152.vc672728cf536/snakeyaml-api.hpi
wget -q -O ssh-credentials.jpi $B/ssh-credentials/372.va_250881b_08cd/ssh-credentials.hpi
wget -q -O structs.jpi $B/structs/362.va_b_695ef4fdf9/structs.hpi
wget -q -O variant.jpi $B/variant/70.va_d9f17f859e0/variant.hpi
wget -q -O workflow-aggregator.jpi $B/workflow-aggregator/608.v67378e9d3db_1/workflow-aggregator.hpi
wget -q -O workflow-api.jpi $B/workflow-api/1373.v7b_813f10efa_b_/workflow-api.hpi
wget -q -O workflow-basic-steps.jpi $B/workflow-basic-steps/1079.vce64b_a_929c5a_/workflow-basic-steps.hpi
wget -q -O workflow-cps.jpi $B/workflow-cps/4183.v94b_6fd39da_c1/workflow-cps.hpi
wget -q -O workflow-durable-task-step.jpi $B/workflow-durable-task-step/1479.v56e587f413a_7/workflow-durable-task-step.hpi
wget -q -O workflow-job.jpi $B/workflow-job/1549.vc8d7f497b_22f/workflow-job.hpi
wget -q -O workflow-multibranch.jpi $B/workflow-multibranch/811.vcd33d074c2a_0/workflow-multibranch.hpi
wget -q -O workflow-scm-step.jpi $B/workflow-scm-step/437.v05a_f66b_e5ef8/workflow-scm-step.hpi
wget -q -O workflow-step-api.jpi $B/workflow-step-api/724.v538c2362b_dfb_/workflow-step-api.hpi
wget -q -O workflow-support.jpi $B/workflow-support/976.vb_d9493c2eb_09/workflow-support.hpi

echo "$(ls *.jpi | wc -l) plugins downloaded (expected 53)"
