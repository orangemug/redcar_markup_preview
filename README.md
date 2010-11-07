# redcar_markup viewer
Redcar plugin to render files with Markdown, so I (and others) don't have to keep checking in incorrect versions of the README.md on github!

    cd ~/.redcar/plugins
    git clone git://github.com/orangemug/redcar_markup_viewer.git
    git submodule init
    git submodule update

Supported formats:

 * [Markdown](http://daringfireball.net/projects/markdown/)
 * [Textile](http://en.wikipedia.org/wiki/Textile_%28markup_language%29)


## Usage
The following opens a new tab with the generated Markdown file.

    Plugins -> Markup Viewer -> Generate from filename

