---
layout: post
title: Start a tech blog using Jekyll Part II
category: blog
tags: [blog, jekyll, github-pages]
comments: true
image:
    feature: start-a-tech-blog-using-jekyll/blog-1024x768.jpg
---

In the previous [post]({% post_url 2015-07-25-start-a-tech-blog-using-jekyll-part-i %}), we saw how to start a new blog from scratch using Jekyll and Github Pages. In this second one I'll explain some modifications that can be made to get some extra functionality out of Jekyll.

It's worth mentioning that Jekyll uses [Liquid](https://github.com/Shopify/liquid/wiki), a template engine for ruby. It provides the necessary control structures and functions to allow you to perform simple operations in your templates. We're going to be using those structures quite a bit here, so we can get as much juice as possible from the possibilities that static content generation provides.


# Adding Google Analytics

Lets start with something simple. Everyone knows that adding GA to any page consists on appending a bit of Javascript to the bottom of the page. So lets do that very quickly.

First things first. Create a GA's account associated to your domain and get your tracking code from [Google Analytics](https://www.google.com/analytics/web/).

Stick that code into a variable in your "\_config.yml" like so:
{% highlight yaml %}
analytics:
  google:
    tracking_id: "{YOUR_TRACKING_CODE_HERE}"
{% endhighlight %}
 
Next, create a file "analytics.html" in your "\_includes" folder, and add the following content:

{% highlight javascript %}
{% raw %}

{% if site.analytics.google %}
    <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

        ga('create', '{{site.analytics.google.tracking_id}}', 'auto');
        ga('send', 'pageview');
    </script>
{% endif %}

{% endraw %}
{% endhighlight %}

This will add the necessary javascript code to the page only if the configuration value for google is defined in the "_config.yml" file.

Finally, include this piece of code in your "footer.html" to make sure your track all your blog pages:

{% highlight liquid %}
{% raw %}

    </footer>
    {% include analytics.html %}
  </body>
</html>

{% endraw %}
{% endhighlight %}


# A comments section

A very similar approach can be used to get a comments section in your blog. I've seen a great increase in adoption of [Disqus](https://disqus.com/) as a comments tool in all sorts of tech blogs. I liked both the styling and the way it displays conversations. And it's also very easy to set up, very much like Google Analytics.

So the steps are pretty similar. First go to the [Disqus](https://disqus.com/) website and create an account if you don't have one already. Find the section "Add Disqus to a site" and pick up a name. 

Store that name into your "_config.yml", like so:

{% highlight yaml %}
{% raw %}
owner:
    disqus: "{YOUR_DISQUS_NAME}"
{% endraw %}
{% endhighlight %}

Once you have that in place, you'll need to create a "comments.html" file in your "_includes" section, with following content:

{% highlight javascript %}
{% raw %}

{% if page.comments %}

<aside class="disqus">
    <div id="disqus_thread"></div>
    <script type="text/javascript">
        var disqus_shortname = '{{ site.owner.disqus }}';

        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
    </script>
    <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
    <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
</aside>

{% endif %}

{% endraw %}
{% endhighlight %}

Similarly to Google Analytics, this piece of code will only be added if the comments for the page are set to true in the [Front Matter](http://jekyllrb.com/docs/frontmatter/) of your page.

{% highlight text %}
---
layout: post
comments: true
---
{% endhighlight %}

Finally, just include this file wherever you want your comments section to be. In my case, I have it at the bottom of my "post.html" layout:

{% highlight liquid %}
{% raw %}

        {{ content }}

      {% include share.html %}

      {% include comments.html %}

      </article>

    </section>
</div>

{% include footer.html %}

{% endraw %}
{% endhighlight %}


# Creating an "All posts" page 

This piece of functionality is meant to simply list all the posts of the blog in a page that is accessible from a top navigation menu bar. That would be the "POSTS" section in this blog, for instance.

So the first thing to do, is to add a new link to the navigation menu. We can use some custom variables defined in the "\_config.yml" file like so:

{% highlight yaml %}
links:
  - title: About
    url: /about
  - title: Posts
    url: /posts
{% endhighlight %}

These variables are then available in the layouts and includes, which are used to generate the navigation menu. You should add this little loop to the section where you create your navigation menu:

{% highlight liquid %}
{% raw %}
{% for link in site.links %}
    <li><a href="{{ link.url }}">{{ link.title }}</a></li>
{% endfor %}
{% endraw %}
{% endhighlight %}

Next, we need to create the page that the URL points to. In this case "posts.md". In here we just select which layout to use:
{% highlight liquid %}
{% raw %}
---
layout: post-index
permalink: /posts/index.html
title: All posts
---
{% endraw %}
{% endhighlight %}

And finally, we create the layout "post-index.html" in the "\_layouts" folder with the content:

{% highlight javascript %}
{% raw %}

<h2><span>{{ page.title }}</span></h2>

{% for post in site.posts %}
    <article>
        <h3><a href="{{ site.url }}{{ post.url }}" title="{{ post.title }}">{{ post.title }}</a></h3>
        <p>{{ post.description | strip_html | truncate: 160 }}</p>
    </article>
{% endfor %}

{% endraw %}
{% endhighlight %}

This code just loops through the existing posts on the site, creating a link to each of them and displaying a truncated version of its description. Piece of cake!


# Tags with Jekyll

Now, to the meaty parts. There's a problem with static file generation and that is the lack of a persistence layer such as a database that can link information together. And that's quite a key part for creating a system such as post tagging.
 
Funnily enough, Jekyll provides a tagging mechanism by default, which you the can use to produce your own implementation of a tagging system. That's done through the "tags" section in the Front Matter of your posts. 

{% highlight liquid %}
{% raw %}
---
layout: post
tags: [blog, jekyll, github-pages]
---
{% endraw %}
{% endhighlight %}

Jekyll does actually nothing with those tags, but it allows you to access them through its plugin mechanism. The idea is to generate a new static page for each of the existing tags in all our posts. We then make a list of those posts and their links, ordered by publication date.

Bare with me, it's simpler than it sounds. Everything is explained in the [Plugins](http://jekyllrb.com/docs/plugins/) page. What we only need is to create our own [generator](http://jekyllrb.com/docs/plugins/#generators).

Firstly, we create a new layout for the tags section in the "_layout" directory called "tag-index.html". In here, we build the structure of the page that will contain the list of posts that have a given tag on them. Something like:

{% highlight html %}
{% raw %}
{% include header.html %}

<div id='tag-list'>
    <section>
        <article>
            <ol>
            <h2><span>{{page.title}}</span></h2>
            <ul>
            {% for post in site.posts %}
                {% for tag in post.tags %}
                    {% assign tag = {{ tag | slugify }} %}
                    {% if tag == page.tag %}
                        <article>
                            <h3><a href="{{ site.url }}{{ post.url }}" title="{{ post.title }}">{{ post.title }}</a></h3>
                            <p>{{ post.description | strip_html | truncate: 160 }}</p>
                        </article>
                    {% endif %}
                {% endfor %}
            {% endfor %}
            </ul>
            </ol>
        </article>
    </section>
</div>

{% include footer.html %}
{% endraw %}
{% endhighlight %}

What we're doing here, is to go through all the existing posts and all their tags, checking if they happen to have the tag for the current page (made available in the "page.tag" variable). If they do, we add them to the list of the page.

Secondly, we need to create a folder "_plugins" in the project's root. In there, we're going to place our generator. Create a file named "tag_generator.rb" and copy the following content in it:

{% highlight ruby %}
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
{% endhighlight %}

The generator class, which extends from Generator, receives a site as a parameter and should generate some content as a side effect. So we choose a folder name where we're going to be generating this content ('tag' sounds good enough to me) and we loop through all the existing tags in the site (these are the ones defined in all our Front Matters). For each of them, we're going to generate a static page with a list of posts that contain that tag.
 
To generate the content, we use another class "TagIndex". This class is aware of the page that we're going to be generating so we can pass information to it, like the title or the tag we're building the page for (yes! the very same that is made available in the "tag-index.html"). We then render the page in combination with "tag-index.html" and store the content of the newly generated page in the indicated path 'tag'. 

Finally, we just need to add the list of tags at the end of our posts with links to the newly created tag pages:

{% highlight html %}
{% raw %}
{% if page.tags.size > 0 %}
<div class="tags">
    <span>Tags:</span>
    {% for tag in page.tags %}
        <a href="{{site.url}}/tag/{{ tag | slugify }}">{{ tag }}</a>
        {% unless forloop.last %}
        -
        {% endunless %}
    {% endfor %}
</div>
{% endif %}

{% endraw %}
{% endhighlight %}

This approach has a big drawback though, which is that you'll need to tell Github pages to do not build your site using Jekyll in order to get this to work. Why? Security reasons again. Github pages uses the "--safe" when building your site ignoring custom plugins. 

You can disable Jekyll in Github pages by simply creating an empty ".nojekyll" file in your repository root.

But then, how do I deploy as I was doing by simply pushing my master branch? Well, there's also a "solution" to it, which I'll explain next.

# Deploying Github pages without Jekyll

So here is the dilemma. Do I use custom plugins to enhance the default tooling provided by "safe Jekyll" or I use those plugins but change my deployment procedure?

To overcome this problem, there are a few solutions.

## Making the "\_site" folder your master branch

This seems like a good idea at first. Simply get your "username.github.io" repository started in the "\_site" folder, build your project locally and then commit and push all the new content.

This actually works, but there is a huge drawback. You loose the ability to track changes in your main project's source code. Everytime that you code, you should **always** do it using a CVS. Period. The flexibility and safety that it provides is just too huge to be ignored.

## Having two repositories

Another strategy to overcome this problem is to have two repositories. One containing your source code of the blog and the other one the compiled version of it. Something like:

github.com/username/username.github.io.source
github.com/username/username.github.io

Again, this works, but seems a bit of an overkill to have two different repositories for the same project. 

But wait... we are working with git! We have branches, right?

## Using two branches within the same repository

I think this solution is the best of both worlds. You can actually use the "_site" folder as your master branch, but also have the rest of your code in CVS too. I came across this solution in this [post](http://drewsilcock.co.uk/custom-jekyll-plugins/) which I'm going to summarize here.

The idea is to make your blog's source repository a branch called "source". Then transform the folder "_site" into the master branch. And finally automate the publishing process using a bash script.

So the first thing is to create the "source" branch:

{% highlight sh %}
{% raw %}
# Create a new source branch
git checkout -b source

# Tell git to track source remote branch & push
git branch -u origin/source source
git push origin source

{% endraw %}
{% endhighlight %}

Then the master branch:

{% highlight sh %}
{% raw %}
# Locally delete the original master branch
git branch -D master

# Make a new git repository within _site
cd _site
git init
touch .nojekyll

# Make the new repository point to the existing master branch in Github 
git remote add origin https://github.com/{YOUR_USERNAME}/{YOUR_USERNAME}.github.io
git branch -u origin/master master

{% endraw %}
{% endhighlight %}

In order to do not incidentally erase the ".nojekyll" file from the "_site" folder when building the content with Jekyll locally, we need to mark the file as included in the "_config.yml" file:

{% highlight yaml %}
include: [".nojekyll"]
{% endhighlight %}

Finally, we only need to automate the deployment process. You can use any scripting language that you want to do this, but bash should serve well. Create a "publish.sh" file in the blog's root with the content: 

{% highlight sh %}
#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Enter a git commit message!"
  exit
fi

jekyll build && \
  cd _site && \
  git add . && \
  git commit -am "$1" && \
  git push origin master && \
  cd .. && \
  echo "Blog deployed."
{% endhighlight %}

Now every time you want to deploy your blog you only need to run this bash script indicating a commit message like so:
{% highlight sh %}
./publish.sh "New blog post!"
{% endhighlight %}


And there you go! You now have your blog up and running with a few bells and whistles. Happy blogging!
