# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
from sys      import path as sys_path
from os.path  import abspath
from pathlib  import Path
from textwrap import dedent

# ==============================================================================
# Project configuration
# ==============================================================================
githubNamespace = "pyTooling"
githubProject =   "MiKTeX"
githubVersion =   "1.1.1"


# ==============================================================================
# Project paths
# ==============================================================================
ROOT = Path(__file__).resolve().parent

sys_path.insert(0, abspath("."))
sys_path.insert(0, abspath(".."))


# ==============================================================================
# Project information and versioning
# ==============================================================================
# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.

project =   githubProject
author =    "Patrick Lehmann"
copyright = "© 2026 The pyTooling Authors"
version =   ".".join(githubVersion.split(".")[:2])  # e.g. 2.3    The short X.Y version.
release =   githubVersion


# ==============================================================================
# Miscellaneous settings
# ==============================================================================
# The master toctree document.
master_doc = "index"

# Add any paths that contain templates here, relative to this directory.
templates_path = ["_templates"]

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = [
	"_build",
	"_theme",
	"Thumbs.db",
	".DS_Store"
]

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = "manni"


# ==============================================================================
# Restructured Text settings
# ==============================================================================
prologPath = Path("prolog.inc")
try:
	with prologPath.open("r", encoding="utf-8") as fileHandle:
		rst_prolog = fileHandle.read()
except Exception as ex:
	print(f"[ERROR:] While reading '{prologPath}'.")
	print(ex)
	rst_prolog = ""


# ==============================================================================
# Options for HTML output
# ==============================================================================
html_theme = "sphinx_rtd_theme"
html_theme_options = {
	"logo_only": True,
	"vcs_pageview_mode": 'blob',
	"navigation_depth": 5,
}
html_css_files = [
	'css/override.css',
]

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ["_static"]

html_logo = str(Path(html_static_path[0]) / "logo.png")
html_favicon = str(Path(html_static_path[0]) / "icon.png")

# Output file base name for HTML help builder.
htmlhelp_basename = f"{githubProject}Doc"

# If not None, a 'Last updated on:' timestamp is inserted at every page
# bottom, using the given strftime format.
# The empty string is equivalent to '%b %d, %Y'.
html_last_updated_fmt = "%d.%m.%Y"


# ==============================================================================
# Options for LaTeX / PDF output
# ==============================================================================
latex_engine = "lualatex"
latex_use_xindy = False
latex_elements = {
	"papersize":   "a4paper",      # The paper size ('letterpaper' or 'a4paper').
	"pointsize":   "10pt",         # The font size ('10pt', '11pt' or '12pt').
	"inputenc":    "",            # Let LuaLaTeX handle input encoding
	"utf8extra":   "",
	"polyglossia": "",
	"babel":      r"\usepackage[english]{babel}",
	"fontenc":    r"\usepackage{fontspec}",  # Disable the default T1 font encoding (Essential for LuaLaTeX)
	"fontpkg":    dedent("""\
		\\usepackage[fontfamily=libertinus]{pytooling}
	"""),
	"passoptionstopackages": dedent("""\
		\\PassOptionsToPackage{verbatimvisiblespace=\\ }{sphinx}
	"""),
# "sphinxsetup": "verbatimvisiblespace=\\textvisiblespace"
# "figure_align": "htbp",     # Latex figure (float) alignment
	"makeindex":  r"\usepackage[columns=1]{idxlayout}\makeindex",
	"printindex": r"\def\twocolumn[#1]{#1}\printindex",
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
	( master_doc,
		f"{githubProject}.tex",
		f"The {githubProject} Documentation",
		 "Patrick Lehmann",
		 "manual"
	),
]


# ==============================================================================
# Extensions
# ==============================================================================
extensions = [
# Standard Sphinx extensions
	"sphinx.ext.extlinks",
	"sphinx.ext.intersphinx",
	"sphinx.ext.todo",
	"sphinx.ext.graphviz",
	"sphinx.ext.mathjax",
	"sphinx.ext.ifconfig",
	"sphinx.ext.viewcode",
# SphinxContrib extensions
	"sphinxcontrib.mermaid",
# Other extensions
	"sphinx_design",
	"sphinx_copybutton",
# User defined extensions
]


# ==============================================================================
# Sphinx.Ext.InterSphinx
# ==============================================================================
intersphinx_mapping = {
	"python": ("https://docs.python.org/3", None),
	# "ghdl":   ("https://setuptools.pypa.io/en/latest", None),
	# "nvc":    ("https://setuptools.pypa.io/en/latest", None),
	"poc":    ("https://vhdl.github.io/PoC", None),
}


# ==============================================================================
# Sphinx.Ext.ExtLinks
# ==============================================================================
extlinks = {
	"gh":      (f"https://GitHub.com/%s", "gh:%s"),
	"ghissue": (f"https://GitHub.com/{githubNamespace}/{githubProject}/issues/%s", "issue #%s"),
	"ghpull":  (f"https://GitHub.com/{githubNamespace}/{githubProject}/pull/%s", "pull request #%s"),
	"ghsrc":   (f"https://GitHub.com/{githubNamespace}/{githubProject}/blob/main/%s", None),
	"wiki":    (f"https://en.wikipedia.org/wiki/%s", None),
}


# ==============================================================================
# Sphinx.Ext.Graphviz
# ==============================================================================
graphviz_output_format = "svg"


# ==============================================================================
# SphinxContrib.Mermaid
# ==============================================================================
mermaid_cmd = "mmdc"
mermaid_cmd_shell = True
mermaid_params = [
	'--backgroundColor', 'transparent',
]
mermaid_verbose = True


# ==============================================================================
# Sphinx.Ext.ToDo
# ==============================================================================
# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = True
todo_link_only = True


# ==============================================================================
# Sphinx_Design
# ==============================================================================
# sd_fontawesome_latex = True
