rojo sourcemap default.project.json -o sourcemap.json \
  & darklua process --config .darklua-dev.json src/ out/ --watch \
  & rojo serve out.project.json