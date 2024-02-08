# ShellPress - Article Directory to HTML Portal Generator

ShellPress is a tool designed to operate over an article directory containing Markdown files, converting them into an HTML portal with ease. This README provides an overview of the tool's functionality and usage.

Input Files
ShellPress processes Markdown files with the extension .markdown. Each file must contain:

The title of the article listed as the first Markdown first-level heading.
The creation date given as the date the file was last modified (Linux mtime attribute).


Generating HTML Files
The command to generate HTML files for all articles in the articles directory is as follows:

Publish-Portal [-Statistics] [-Destination target] [file.markdown...]

If no file is specified, HTML files for all articles in the directory are generated. An index.html page is also created, listing all articles in the portal with their titles, publication dates, and hyperlinks to the article texts.

Statistical Information
The -Statistics parameter enables the generation of an HTML file with statistical information, including:

Number of articles
Number of words in all articles
Portal Publication
The -Destination parameter specifies the destination where the portal should be published. ShellPress supports copying to a remote server using various protocols such as HTTP, FTP, etc.
