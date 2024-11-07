ARG NUSSKNACKER_VERSION="NUSSKNACKER_VERSION_IS_UNDEFINED"

FROM touk/nussknacker:${NUSSKNACKER_VERSION}_scala-2.12

ARG NU_COMPAT_VERSION="NU_COMPAT_VERSION_IS_UNDEFINED"

USER root

# flink-compatibility-model and flink-compatibility-kafka-components have to be added
RUN curl -L https://oss.sonatype.org/content/repositories/snapshots/pl/touk/nussknacker/nussknacker-flink-compatibility-1-18-model_2.12/${NU_COMPAT_VERSION}/nussknacker-flink-compatibility-1-18-model_2.12-${NU_COMPAT_VERSION}.jar \
   -o /opt/nussknacker/components/flink/extra/nussknacker-flink-compatibility-1-18-model_2.12-${NU_COMPAT_VERSION}.jar

RUN curl -L https://oss.sonatype.org/content/repositories/snapshots/pl/touk/nussknacker/nussknacker-flink-compatibility-1-18-kafka-components_2.12/${NU_COMPAT_VERSION}/nussknacker-flink-compatibility-1-18-kafka-components_2.12-${NU_COMPAT_VERSION}-assembly.jar \
   -o /opt/nussknacker/components/flink/extra/nussknacker-flink-compatibility-1-18-kafka-components_2.12-${NU_COMPAT_VERSION}-assembly.jar

RUN chown -R demiourgos728:root /opt/nussknacker

USER demiourgos728