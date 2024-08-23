FROM quay.io/jupyter/minimal-notebook:lab-4.2.3
# base image documentation: https://jupyter-docker-stacks.readthedocs.io

WORKDIR /app/dev

COPY --chown=jovyan ./extensions/ ./extensions/

RUN find ./extensions/ -mindepth 1 -maxdepth 1 -type d | \
    while read ext_dir; \
    do \
      echo "Installing jupyter lab and server extension $ext_dir"; \
      pip install -e "$ext_dir"; \
      jupyter labextension develop "$ext_dir" --overwrite; \
    done

COPY --chown=jovyan ./settings/ /opt/conda/share/jupyter/lab/settings/

CMD ["jupyter", "lab"]
