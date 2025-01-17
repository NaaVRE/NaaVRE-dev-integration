FROM quay.io/jupyter/minimal-notebook:lab-4.2.5 AS base
RUN conda install -y -c conda-forge nodejs r-irkernel
RUN mkdir /tmp/data

# Install python dependencies for all extensions
FROM base AS deps-py
RUN pip install uv
COPY --chown=jovyan ./extensions/NaaVRE-communicator-jupyterlab/pyproject.toml ./extensions/NaaVRE-communicator-jupyterlab/
COPY --chown=jovyan ./extensions/NaaVRE-containerizer-jupyterlab/pyproject.toml ./extensions/NaaVRE-containerizer-jupyterlab/
COPY --chown=jovyan ./extensions/NaaVRE-workflow-jupyterlab/pyproject.toml ./extensions/NaaVRE-workflow-jupyterlab/
RUN export CONDA_PREFIX=/opt/conda; \
    uv pip install -r ./extensions/NaaVRE-communicator-jupyterlab/pyproject.toml; \
    uv pip install -r ./extensions/NaaVRE-containerizer-jupyterlab/pyproject.toml; \
    uv pip install -r ./extensions/NaaVRE-workflow-jupyterlab/pyproject.toml


# Install js dependencies for each extension
FROM base AS deps-js-communicator
WORKDIR /deps/
COPY --chown=jovyan ./extensions/NaaVRE-communicator-jupyterlab/package.json .
RUN jlpm

FROM base AS deps-js-containerizer
WORKDIR /deps/
COPY --chown=jovyan ./extensions/NaaVRE-containerizer-jupyterlab/package.json .
## For this extension, we have patches in .yarn/
COPY --chown=jovyan ./extensions/NaaVRE-containerizer-jupyterlab/.yarn/patches/ .yarn/patches/
RUN jlpm

FROM base AS deps-js-workflow
WORKDIR /deps/
COPY --chown=jovyan ./extensions/NaaVRE-workflow-jupyterlab/package.json .
## For this extension, we have patches in .yarn/
COPY --chown=jovyan ./extensions/NaaVRE-workflow-jupyterlab/.yarn/patches/ .yarn/patches/
RUN jlpm


# Install extensions into runtime environment
FROM base AS runtime

WORKDIR /app/
RUN mkdir -p \
    ./extensions/NaaVRE-communicator-jupyterlab/ \
    ./extensions/NaaVRE-containerizer-jupyterlab/ \
    ./extensions/NaaVRE-workflow-jupyterlab/

# Copy extensions python dependencies
COPY --from=deps-py /opt/conda/ /opt/conda/

# Copy extensions js dependencies
COPY --from=deps-js-communicator /deps/ ./extensions/NaaVRE-communicator-jupyterlab/
COPY --from=deps-js-containerizer /deps/ ./extensions/NaaVRE-containerizer-jupyterlab/
COPY --from=deps-js-workflow /deps/ ./extensions/NaaVRE-workflow-jupyterlab/

# Install extensions
COPY --chown=jovyan ./extensions/NaaVRE-communicator-jupyterlab/ ./extensions/NaaVRE-communicator-jupyterlab/
RUN pip install ./extensions/NaaVRE-communicator-jupyterlab/
COPY --chown=jovyan ./extensions/NaaVRE-containerizer-jupyterlab/ ./extensions/NaaVRE-containerizer-jupyterlab/
RUN pip install ./extensions/NaaVRE-containerizer-jupyterlab/
COPY --chown=jovyan ./extensions/NaaVRE-workflow-jupyterlab/ ./extensions/NaaVRE-workflow-jupyterlab/
RUN pip install ./extensions/NaaVRE-workflow-jupyterlab/

# Copy configuration
COPY --chown=jovyan ./settings/ /opt/conda/share/jupyter/lab/settings/

CMD ["jupyter", "lab"]
