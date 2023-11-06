# Fetch the sitemap and return a list of all URLs
export def sitemap [] {
    http get "https://ourworldindata.org/sitemap.xml" | get content | each {|it| $it | get content.0.content.0.content }
}

# Commands related to the live website
export def main [] {
}