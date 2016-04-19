# Function to run Pandoc with the correct parameters

function make_report {
    for f in "$@"; do
      fn=${f%.md}
      echo "Converting ${f}.."
      PD_DIR=${ngi_reports_dir}/data/pandoc_templates
      ${PD_DIR}/pandoc --standalone --section-divs ${fn}.md -o ${fn}.html --template=${PD_DIR}/html_pandoc.html --default-image-extension=png --filter ${PD_DIR}/pandoc_filters.py -V template_dir=${PD_DIR}/ 
      ${PD_DIR}/pandoc --standalone ${fn}.md -o ${fn}.pdf --template=${PD_DIR}/latex_pandoc.tex --latex-engine=xelatex --default-image-extension=pdf --filter ${PD_DIR}/pandoc_filters.py -V template_dir=${PD_DIR}/ 
    done
}
export -f make_report
