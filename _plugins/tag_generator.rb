module Jekyll
  class TagIndex < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag-index.html')
      self.data['tag'] = tag
      tag_title_prefix = site.config['tag_title_prefix'] || 'Tagged as &ldquo;'
      tag_title_suffix = site.config['tag_title_suffix'] || '&rdquo;'
      self.data['title'] = "#{tag_title_prefix}#{tag}#{tag_title_suffix}"
      self.render(site.layouts, site.site_payload)
      self.write(site.dest)
    end
  end
  class TagGenerator < Generator
    safe true
    def generate(site)
      if site.layouts.key? 'tag-index'
        dir = site.config['tag_dir'] || 'tag'
        site.tags.keys.each do |tag|
          site.pages << TagIndex.new(site, site.source, File.join(dir, tag.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')), tag)
        end
      end
    end
  end
end