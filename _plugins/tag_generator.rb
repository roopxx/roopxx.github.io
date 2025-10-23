module Jekyll
  class TagPageGenerator < Generator
    safe true
    priority :low

    def generate(site)
      tags = site.posts.docs.flat_map { |post| post.data['tags'] || [] }.to_set
      tags.each do |tag|
        site.pages << TagPage.new(site, site.source, tag)
      end

      site.pages << TagsIndexPage.new(site, site.source, tags.to_a.sort)
    end
  end

  class TagPage < Page
    def initialize(site, base, tag)
      @site = site
      @base = base
      @dir  = File.join('tag', tag)
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')
      self.data['tag'] = tag
      self.data['title'] = "Posts tagged '#{tag}'"
    end
  end

  class TagsIndexPage < Page
    def initialize(site, base, tags)
      @site = site
      @base = base
      @dir  = 'tags'
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tags_index.html')
      self.data['tags'] = tags
      self.data['title'] = "Tags"
    end
  end
end
